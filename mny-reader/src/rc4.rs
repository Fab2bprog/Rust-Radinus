//! RC4 standard (KSA + PRGA, sans octets ignorés).

/// Chiffre ou déchiffre `data` sur place avec un flux RC4 neuf initialisé par `key`.
pub fn apply(key: &[u8], data: &mut [u8]) {
    assert!(!key.is_empty(), "clé RC4 vide");
    let mut s = [0u8; 256];
    for (i, v) in s.iter_mut().enumerate() {
        *v = i as u8;
    }
    let mut j: u8 = 0;
    for i in 0..256 {
        j = j.wrapping_add(s[i]).wrapping_add(key[i % key.len()]);
        s.swap(i, j as usize);
    }
    let (mut i, mut j) = (0u8, 0u8);
    for b in data.iter_mut() {
        i = i.wrapping_add(1);
        j = j.wrapping_add(s[i as usize]);
        s.swap(i as usize, j as usize);
        let k = s[s[i as usize].wrapping_add(s[j as usize]) as usize];
        *b ^= k;
    }
}

#[cfg(test)]
mod tests {
    #[test]
    fn vecteur_standard() {
        // Vecteur de test RC4 classique : clé "Key", texte "Plaintext".
        let mut d = *b"Plaintext";
        super::apply(b"Key", &mut d);
        assert_eq!(d, [0xBB, 0xF3, 0x16, 0xE8, 0xD9, 0x40, 0xAF, 0x0A, 0xD3]);
    }
}
