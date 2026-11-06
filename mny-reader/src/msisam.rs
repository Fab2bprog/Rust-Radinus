//! Couche MSISAM : en-tête de la page 0 et déchiffrement RC4 des pages 1 à 14.
//!
//! Voir la spécification, document 01.

use md5::{Digest as _, Md5};
use sha1::Sha1;

use crate::bytes::{f64_at, u32_at};
use crate::error::{Error, Result};
use crate::rc4;

/// Taille d'une page.
pub const PAGE_SIZE: usize = 4096;

/// Dernière page chiffrée (incluse).
pub const LAST_ENCRYPTED_PAGE: u32 = 14;

/// Masque XOR des octets `0x18..0x98` de la page 0 (flux RC4 de la clé `C7 DA 39 6B`).
pub const HEADER_MASK: [u8; 128] = [
    0xB5, 0x6F, 0x03, 0x62, 0x61, 0x08, 0xC2, 0x55, 0xEB, 0xA9, 0x67, 0x72, 0x43, 0x3F, 0x00, 0x9C,
    0x7A, 0x9F, 0x90, 0xFF, 0x80, 0x9A, 0x31, 0xC5, 0x79, 0xBA, 0xED, 0x30, 0xBC, 0xDF, 0xCC, 0x9D,
    0x63, 0xD9, 0xE4, 0xC3, 0x7B, 0x42, 0xFB, 0x8A, 0xBC, 0x4E, 0x86, 0xFB, 0xEC, 0x37, 0x5D, 0x44,
    0x9C, 0xFA, 0xC6, 0x5E, 0x28, 0xE6, 0x13, 0xB6, 0x8A, 0x60, 0x54, 0x94, 0x7B, 0x36, 0xF5, 0x72,
    0xDF, 0xB1, 0x77, 0xF4, 0x13, 0x43, 0xCF, 0xAF, 0xB1, 0x33, 0x34, 0x61, 0x79, 0x5B, 0x92, 0xB5,
    0x7C, 0x2A, 0x05, 0xF1, 0x7C, 0x99, 0x01, 0x1B, 0x98, 0xFD, 0x12, 0x4F, 0x4A, 0x94, 0x6C, 0x3E,
    0x60, 0x26, 0x5F, 0x95, 0xF8, 0xD0, 0x89, 0x24, 0x85, 0x67, 0xC6, 0x1F, 0x27, 0x44, 0xD2, 0xEE,
    0xCF, 0x65, 0xED, 0xFF, 0x07, 0xC7, 0x46, 0xA1, 0x78, 0x16, 0x0C, 0xED, 0xE9, 0x2D, 0x62, 0xD4,
];

const SIGNATURE: &[u8; 16] = b"MSISAM Database\0";
const OFFSET_SIGNATURE: usize = 0x04;
const OFFSET_VERSION: usize = 0x14;
const OFFSET_MASKED: usize = 0x18;
const OFFSET_PASSWORD: usize = 0x42;
const OFFSET_SALT: usize = 0x72;
const OFFSET_FLAGS: usize = 0x298;
const OFFSET_CHECK: usize = 0x2E9;

const FLAG_MODERN: u8 = 0x06;
const FLAG_SHA1: u8 = 0x20;

/// Schéma de dérivation de clé utilisé par le fichier.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum KeyScheme {
    /// Schéma moderne (Money 2002 et suivants) : condensat du mot de passe + sel, clé de 20 octets.
    Modern {
        /// `true` : SHA-1, `false` : MD5.
        sha1: bool,
    },
    /// Schéma historique (Money 2001 et antérieurs) : clé de 4 octets tirée de l'en-tête,
    /// le mot de passe n'intervient pas.
    Legacy,
}

/// Informations de chiffrement lues dans la page 0.
#[derive(Debug, Clone)]
pub struct EncryptionInfo {
    /// Octet de drapeaux en `0x298`.
    pub flags: u8,
    /// Schéma de clé.
    pub scheme: KeyScheme,
    /// `true` si le fichier contient des octets de contrôle permettant de vérifier le mot de passe.
    pub password_checkable: bool,
    /// Clé de base (20 octets en schéma moderne, 4 en schéma historique).
    pub base_key: Vec<u8>,
    /// Date de création de la base (format date Jet, `f64` brut).
    pub creation_date: f64,
    /// Schéma historique uniquement : mot de passe enregistré en clair dans l'en-tête (s'il y en a un).
    pub legacy_password: Option<String>,
}

/// Le fichier entier, avec la page 0 démasquée et les pages 1 à 14 déchiffrées.
#[derive(Debug, Clone)]
pub(crate) struct Pages {
    data: Vec<u8>,
    count: u32,
}

impl Pages {
    pub(crate) fn count(&self) -> u32 {
        self.count
    }

    /// Renvoie la page `n` (4096 octets).
    pub(crate) fn page(&self, n: u32) -> Result<&[u8]> {
        if n >= self.count {
            return Err(Error::PageOutOfRange(n));
        }
        let start = n as usize * PAGE_SIZE;
        Ok(&self.data[start..start + PAGE_SIZE])
    }
}

/// Démasque l'en-tête, dérive la clé, déchiffre les pages 1 à 14.
pub(crate) fn decrypt(
    mut data: Vec<u8>,
    password: Option<&str>,
) -> Result<(Pages, EncryptionInfo)> {
    if !data.len().is_multiple_of(PAGE_SIZE) || data.len() < 3 * PAGE_SIZE {
        return Err(Error::InvalidFileSize(data.len()));
    }
    if &data[OFFSET_SIGNATURE..OFFSET_SIGNATURE + 16] != SIGNATURE {
        return Err(Error::NotMoneyFile);
    }
    let version = u32_at(&data, OFFSET_VERSION)?;
    if version != 1 {
        return Err(Error::UnsupportedVersion(version));
    }

    // Page 0 : retrait du masque d'en-tête.
    for (i, m) in HEADER_MASK.iter().enumerate() {
        data[OFFSET_MASKED + i] ^= m;
    }
    let p0 = &data[..PAGE_SIZE];

    let flags = p0[OFFSET_FLAGS];
    let mut salt8 = [0u8; 8];
    salt8.copy_from_slice(&p0[OFFSET_SALT..OFFSET_SALT + 8]);
    let creation_date = f64_at(p0, OFFSET_SALT)?;

    let (scheme, base_key, page_key_offset, password_checkable, legacy_password) =
        if flags & FLAG_MODERN != 0 {
            let sha1 = flags & FLAG_SHA1 != 0;
            let digest = password_digest(password, sha1);
            let checkable = check_password(p0, &digest, &salt8)?;
            let mut key = digest.to_vec();
            key.extend_from_slice(&salt8[..4]);
            (KeyScheme::Modern { sha1 }, key, 16usize, checkable, None)
        } else {
            let key = legacy_key(p0)?;
            let pwd = legacy_password(p0);
            (KeyScheme::Legacy, key.to_vec(), 0usize, false, pwd)
        };

    let count = (data.len() / PAGE_SIZE) as u32;
    for n in 1..count.min(LAST_ENCRYPTED_PAGE + 1) {
        let key = page_key(&base_key, page_key_offset, n);
        let start = n as usize * PAGE_SIZE;
        rc4::apply(&key, &mut data[start..start + PAGE_SIZE]);
    }

    // Test structurel : la page 1 est une page de données.
    if data[PAGE_SIZE] != 0x01 || data[PAGE_SIZE + 1] != 0x01 {
        return Err(if password_checkable {
            Error::DecryptionCheckFailed
        } else {
            Error::WrongPassword
        });
    }

    let info = EncryptionInfo {
        flags,
        scheme,
        password_checkable,
        base_key,
        creation_date,
        legacy_password,
    };
    Ok((Pages { data, count }, info))
}

/// Clé de la page `n` : XOR de `n` (u32 little-endian) dans 4 octets de la clé de base, à partir de `offset`.
pub fn page_key(base_key: &[u8], offset: usize, n: u32) -> Vec<u8> {
    let mut k = base_key.to_vec();
    for (i, b) in n.to_le_bytes().iter().enumerate() {
        k[offset + i] ^= b;
    }
    k
}

/// Condensat du mot de passe (schéma moderne) : 16 premiers octets de MD5/SHA-1
/// de l'UTF-16LE du mot de passe en majuscules, complété par des zéros à 40 octets.
pub fn password_digest(password: Option<&str>, sha1: bool) -> [u8; 16] {
    let mut pw = [0u8; 40];
    if let Some(p) = password.filter(|p| !p.is_empty()) {
        let upper = p.to_uppercase();
        let enc: Vec<u8> = upper.encode_utf16().flat_map(|u| u.to_le_bytes()).collect();
        let n = enc.len().min(40);
        pw[..n].copy_from_slice(&enc[..n]);
    }
    let mut out = [0u8; 16];
    if sha1 {
        out.copy_from_slice(&Sha1::digest(pw)[..16]);
    } else {
        out.copy_from_slice(&Md5::digest(pw)[..16]);
    }
    out
}

/// Contrôle du mot de passe. Renvoie `Ok(true)` si contrôlé, `Ok(false)` si le contrôle est impossible.
fn check_password(p0: &[u8], digest: &[u8; 16], salt8: &[u8; 8]) -> Result<bool> {
    let off = OFFSET_CHECK + salt8[0] as usize;
    let mut check = [0u8; 4];
    check.copy_from_slice(crate::bytes::slice(p0, off, 4)?);
    if check == [0; 4] {
        return Ok(false);
    }
    let mut test_key = digest.to_vec();
    test_key.extend_from_slice(salt8);
    rc4::apply(&test_key, &mut check);
    if check != salt8[..4] {
        return Err(Error::WrongPassword);
    }
    Ok(true)
}

/// Masque de date : `(date as i32)` en little-endian.
fn date_mask(p0: &[u8]) -> [u8; 4] {
    let d = f64::from_le_bytes(p0[OFFSET_SALT..OFFSET_SALT + 8].try_into().unwrap());
    (d as i32).to_le_bytes()
}

/// Clé du schéma historique (4 octets).
fn legacy_key(p0: &[u8]) -> Result<[u8; 4]> {
    let mask = date_mask(p0);
    let mut region = crate::bytes::slice(p0, OFFSET_PASSWORD, 80)?.to_vec();
    for i in 0..40 {
        region[i] ^= mask[i % 4];
    }
    for i in 0..20 {
        region[60 + i] ^= mask[i % 4];
    }
    let hash_data: Vec<u8> = (0..40).map(|pos| region[2 * pos]).collect();
    let mut key = [0u8; 4];
    key.copy_from_slice(&p0[OFFSET_SALT..OFFSET_SALT + 4]);
    let key = hash_salt(key, &hash_data);
    let key = hash_salt(key, &p0[OFFSET_SIGNATURE..OFFSET_SIGNATURE + 15]);
    Ok(key)
}

fn hash_salt(key: [u8; 4], data: &[u8]) -> [u8; 4] {
    let mut h = u32::from_le_bytes(key);
    for (pos, &b) in data.iter().enumerate() {
        h ^= (b as u32) << (pos % 24);
    }
    h.to_le_bytes()
}

/// Mot de passe lisible dans l'en-tête (schéma historique).
fn legacy_password(p0: &[u8]) -> Option<String> {
    let mask = date_mask(p0);
    let mut field = p0[OFFSET_PASSWORD..OFFSET_PASSWORD + 40].to_vec();
    for (i, b) in field.iter_mut().enumerate() {
        *b ^= mask[i % 4];
    }
    let s = crate::bytes::utf16le(&field);
    let s = s.split('\0').next().unwrap_or("").to_string();
    if s.is_empty() {
        None
    } else {
        Some(s)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn hex(b: &[u8]) -> String {
        b.iter().map(|x| format!("{x:02x}")).collect()
    }

    #[test]
    fn masque_en_tete_est_un_flux_rc4() {
        let mut z = [0u8; 128];
        rc4::apply(&[0xC7, 0xDA, 0x39, 0x6B], &mut z);
        assert_eq!(z, HEADER_MASK);
    }

    #[test]
    fn condensats_sans_mot_de_passe() {
        assert_eq!(
            hex(&password_digest(None, false)),
            "fd4b38e94292e00251b9f39c47ee5710"
        );
        assert_eq!(
            hex(&password_digest(Some(""), true)),
            "b80de5d138758541c5f05265ad144ab9"
        );
    }

    #[test]
    fn cle_de_page_moderne() {
        let base = [
            0xfd, 0x4b, 0x38, 0xe9, 0x42, 0x92, 0xe0, 0x02, 0x51, 0xb9, 0xf3, 0x9c, 0x47, 0xee,
            0x57, 0x10, 0x64, 0x3b, 0x06, 0x16,
        ];
        assert_eq!(
            hex(&page_key(&base, 16, 1)),
            "fd4b38e94292e00251b9f39c47ee5710653b0616"
        );
        assert_eq!(
            hex(&page_key(&base, 16, 14)),
            "fd4b38e94292e00251b9f39c47ee57106a3b0616"
        );
    }

    #[test]
    fn cle_de_page_historique() {
        let base = [0x3d, 0xbb, 0x74, 0x7e];
        assert_eq!(hex(&page_key(&base, 0, 1)), "3cbb747e");
        assert_eq!(hex(&page_key(&base, 0, 14)), "33bb747e");
    }
}
