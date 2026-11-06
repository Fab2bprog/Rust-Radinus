//! Pages de données, lignes déplacées et cartes d'occupation — spécification, document 02 §3, §8, §9.

use crate::bytes::{u16_at, u32_at};
use crate::error::{Error, Result};
use crate::msisam::{Pages, PAGE_SIZE};

pub(crate) const PAGE_TYPE_DATA: u8 = 0x01;
const PAGE_TYPE_USAGE_MAP: u8 = 0x05;
pub(crate) const ROW_DELETED: u16 = 0x8000;
pub(crate) const ROW_OVERFLOW: u16 = 0x4000;
const ROW_OFFSET_MASK: u16 = 0x1FFF;
const MAX_OVERFLOW_HOPS: usize = 16;
const MAX_USAGE_MAP_PAGES: usize = 17;

/// Nombre d'entrées de ligne d'une page de données.
pub(crate) fn row_count(page: &[u8]) -> Result<u16> {
    u16_at(page, 0x0C)
}

/// Entrée brute de la ligne `row` (offset + drapeaux).
pub(crate) fn row_entry(page: &[u8], row: u16) -> Result<u16> {
    u16_at(page, 0x0E + 2 * row as usize)
}

/// Octets de la ligne `row` d'une page de données, et son entrée brute. Les drapeaux ne sont pas testés.
pub(crate) fn row_bytes(pages: &Pages, page_no: u32, row: u16) -> Result<(u16, &[u8])> {
    let page = pages.page(page_no)?;
    if page[0] != PAGE_TYPE_DATA {
        return Err(Error::corrupt(format!(
            "la page {page_no} n'est pas une page de données"
        )));
    }
    let n = row_count(page)?;
    if row >= n {
        return Err(Error::corrupt(format!(
            "ligne {row} absente de la page {page_no} ({n} lignes)"
        )));
    }
    let raw = row_entry(page, row)?;
    let start = (raw & ROW_OFFSET_MASK) as usize;
    let end = if row == 0 {
        PAGE_SIZE
    } else {
        (row_entry(page, row - 1)? & ROW_OFFSET_MASK) as usize
    };
    let header_end = 0x0E + 2 * n as usize;
    if start < header_end || start > end || end > PAGE_SIZE {
        return Err(Error::corrupt(format!(
            "bornes de ligne invalides page {page_no} ligne {row} : [{start}..{end})"
        )));
    }
    Ok((raw, &page[start..end]))
}

/// Découpe un pointeur de ligne `u32` en (page, ligne).
pub(crate) fn split_pointer(v: u32) -> (u32, u16) {
    (v >> 8, (v & 0xFF) as u16)
}

/// Suit une ligne déplacée jusqu'à la ligne réelle (le drapeau « supprimée » de la cible est ignoré).
pub(crate) fn follow_overflow<'a>(pages: &'a Pages, mut bytes: &'a [u8]) -> Result<&'a [u8]> {
    for _ in 0..MAX_OVERFLOW_HOPS {
        let (page, row) = split_pointer(u32_at(bytes, 0)?);
        let (raw, target) = row_bytes(pages, page, row)?;
        if raw & ROW_OVERFLOW == 0 {
            return Ok(target);
        }
        bytes = target;
    }
    Err(Error::corrupt("chaîne de lignes déplacées trop longue"))
}

/// Pages référencées par une carte d'occupation (pointeur de ligne), en ordre croissant.
pub(crate) fn usage_map_pages(pages: &Pages, pointer: u32) -> Result<Vec<u32>> {
    let (page, row) = split_pointer(pointer);
    let (_, r) = row_bytes(pages, page, row)?;
    let map_type = *r
        .first()
        .ok_or_else(|| Error::corrupt("carte d'occupation vide"))?;
    let mut out = Vec::new();
    match map_type {
        0x00 => {
            let start = u32_at(r, 1)?;
            push_bits(&r[5..], start as u64, pages.count(), &mut out);
        }
        0x01 => {
            let per_page = ((PAGE_SIZE - 4) * 8) as u64;
            let entries = (r.len() - 1) / 4;
            if entries > MAX_USAGE_MAP_PAGES {
                return Err(Error::corrupt(
                    "carte d'occupation : trop de pages de bitmap",
                ));
            }
            for j in 0..entries {
                let m = u32_at(r, 1 + 4 * j)?;
                if m == 0 {
                    continue;
                }
                let mp = pages.page(m)?;
                if mp[0] != PAGE_TYPE_USAGE_MAP {
                    return Err(Error::corrupt(format!("page de bitmap {m} invalide")));
                }
                push_bits(&mp[4..], j as u64 * per_page, pages.count(), &mut out);
            }
        }
        t => {
            return Err(Error::corrupt(format!(
                "type de carte d'occupation inconnu : {t}"
            )))
        }
    }
    Ok(out)
}

fn push_bits(bitmap: &[u8], base: u64, page_count: u32, out: &mut Vec<u32>) {
    for (i, &byte) in bitmap.iter().enumerate() {
        if byte == 0 {
            continue;
        }
        for bit in 0..8 {
            if byte >> bit & 1 == 1 {
                let p = base + (i as u64) * 8 + bit;
                if p < page_count as u64 {
                    out.push(p as u32);
                }
            }
        }
    }
}
