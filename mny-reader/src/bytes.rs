//! Lecture little-endian vérifiée (aucune panique sur des données corrompues).

use crate::error::{Error, Result};

#[inline]
pub(crate) fn slice(buf: &[u8], start: usize, len: usize) -> Result<&[u8]> {
    let end = start
        .checked_add(len)
        .ok_or_else(|| Error::corrupt("débordement d'offset"))?;
    buf.get(start..end).ok_or_else(|| {
        Error::corrupt(format!(
            "lecture hors limites [{start}..{end}) sur {} octets",
            buf.len()
        ))
    })
}

#[inline]
pub(crate) fn u8_at(buf: &[u8], off: usize) -> Result<u8> {
    Ok(slice(buf, off, 1)?[0])
}

#[inline]
pub(crate) fn u16_at(buf: &[u8], off: usize) -> Result<u16> {
    let s = slice(buf, off, 2)?;
    Ok(u16::from_le_bytes([s[0], s[1]]))
}

#[inline]
pub(crate) fn u32_at(buf: &[u8], off: usize) -> Result<u32> {
    let s = slice(buf, off, 4)?;
    Ok(u32::from_le_bytes([s[0], s[1], s[2], s[3]]))
}

#[inline]
pub(crate) fn f64_at(buf: &[u8], off: usize) -> Result<f64> {
    let s = slice(buf, off, 8)?;
    let mut a = [0u8; 8];
    a.copy_from_slice(s);
    Ok(f64::from_le_bytes(a))
}

/// Décode de l'UTF-16LE ; un octet final orphelin est ignoré, les surrogates isolés deviennent U+FFFD.
pub(crate) fn utf16le(bytes: &[u8]) -> String {
    let (pairs, _) = bytes.as_chunks::<2>();
    let units: Vec<u16> = pairs.iter().map(|pair| u16::from_le_bytes(*pair)).collect();
    String::from_utf16_lossy(&units)
}
