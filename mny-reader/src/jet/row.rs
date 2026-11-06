//! Décodage des lignes, valeurs longues et texte — spécification, documents 02 §7, §11 et 03.

use crate::bytes::{f64_at, slice, u16_at, u32_at};
use crate::error::{Error, Result};
use crate::jet::page::{row_bytes, split_pointer};
use crate::jet::tdef::Column;
use crate::msisam::Pages;
use crate::value::{col_type, Guid, JetDateTime, Money, Value};

/// Décode une ligne : une valeur par colonne, dans l'ordre de `columns`.
/// Une erreur sur une cellule produit `Value::Invalid` sans interrompre la ligne.
pub(crate) fn decode_row(pages: &Pages, columns: &[Column], r: &[u8]) -> Result<Vec<Value>> {
    let len = r.len();
    let ncols = u16_at(r, 0)? as usize;
    let nm = ncols.div_ceil(8);
    if len < nm + 4 {
        return Err(Error::corrupt("ligne trop courte"));
    }
    let mask = &r[len - nm..];
    let nvar = u16_at(r, len - nm - 2)? as usize;
    if len < nm + 4 + 2 * nvar {
        return Err(Error::corrupt(
            "table des offsets variables hors de la ligne",
        ));
    }
    let var_off = |j: usize| u16_at(r, len - nm - 4 - 2 * j).map(|v| v as usize);
    let bit = |n: usize| mask[n / 8] >> (n % 8) & 1 == 1;

    let mut out = Vec::with_capacity(columns.len());
    for c in columns {
        let n = c.number as usize;
        let v = if n >= ncols {
            if c.col_type == col_type::BOOL {
                Value::Bool(false)
            } else {
                Value::Null
            }
        } else if c.col_type == col_type::BOOL {
            Value::Bool(bit(n))
        } else if !bit(n) {
            Value::Null
        } else if c.fixed {
            match slice(r, 2 + c.fixed_offset as usize, c.length as usize) {
                Ok(d) => decode_value(pages, c.col_type, d),
                Err(e) => Value::Invalid(e.to_string()),
            }
        } else if c.var_index as usize >= nvar {
            Value::Null
        } else {
            let vi = c.var_index as usize;
            match (var_off(vi), var_off(vi + 1)) {
                (Ok(a), Ok(b)) if a <= b && b <= len => decode_value(pages, c.col_type, &r[a..b]),
                _ => Value::Invalid("offsets variables invalides".into()),
            }
        };
        out.push(v);
    }
    Ok(out)
}

fn decode_value(pages: &Pages, t: u8, d: &[u8]) -> Value {
    match try_decode_value(pages, t, d) {
        Ok(v) => v,
        Err(e) => Value::Invalid(e.to_string()),
    }
}

fn try_decode_value(pages: &Pages, t: u8, d: &[u8]) -> Result<Value> {
    Ok(match t {
        col_type::BYTE => Value::Byte(slice(d, 0, 1)?[0]),
        col_type::INT16 => Value::Int16(u16_at(d, 0)? as i16),
        col_type::INT32 => Value::Int32(u32_at(d, 0)? as i32),
        col_type::INT64 => Value::Int64(i64::from_le_bytes(slice(d, 0, 8)?.try_into().unwrap())),
        col_type::MONEY => Value::Money(Money(i64::from_le_bytes(
            slice(d, 0, 8)?.try_into().unwrap(),
        ))),
        col_type::FLOAT => Value::Float(f32::from_le_bytes(slice(d, 0, 4)?.try_into().unwrap())),
        col_type::DOUBLE => Value::Double(f64_at(d, 0)?),
        col_type::DATETIME => Value::DateTime(JetDateTime(f64_at(d, 0)?)),
        col_type::TEXT => Value::Text(decode_text(d)),
        col_type::MEMO => Value::Text(decode_text(&read_long_value(pages, d)?)),
        col_type::OLE => Value::Binary(read_long_value(pages, d)?),
        col_type::BINARY => Value::Binary(d.to_vec()),
        col_type::GUID => Value::Guid(Guid(slice(d, 0, 16)?.try_into().unwrap())),
        other => Value::Unknown {
            col_type: other,
            bytes: d.to_vec(),
        },
    })
}

/// Valeur longue (MEMO/OLE) : en-tête de 12 octets, données inline, sur une page ou en chaîne.
pub(crate) fn read_long_value(pages: &Pages, d: &[u8]) -> Result<Vec<u8>> {
    let h = u32_at(d, 0)?;
    let len = (h & 0x3FFF_FFFF) as usize;
    match h >> 30 {
        0b10 => Ok(slice(d, 12, len)?.to_vec()),
        0b01 => {
            let (page, row) = split_pointer(u32_at(d, 4)?);
            let (_, r) = row_bytes(pages, page, row)?;
            Ok(slice(r, 0, len)?.to_vec())
        }
        0b00 => {
            let mut out = Vec::with_capacity(len);
            let mut ptr = u32_at(d, 4)?;
            let mut hops = 0u32;
            while out.len() < len {
                if ptr == 0 {
                    return Err(Error::corrupt("chaîne de valeur longue interrompue"));
                }
                hops += 1;
                if hops > pages.count() {
                    return Err(Error::corrupt("chaîne de valeur longue cyclique"));
                }
                let (page, row) = split_pointer(ptr);
                let (_, r) = row_bytes(pages, page, row)?;
                ptr = u32_at(r, 0)?;
                out.extend_from_slice(&r[4..]);
            }
            out.truncate(len);
            Ok(out)
        }
        _ => Err(Error::corrupt("en-tête de valeur longue invalide")),
    }
}

/// Texte Jet 4 : UTF-16LE, ou « compression Unicode » si préfixe `FF FE`.
pub fn decode_text(d: &[u8]) -> String {
    if d.len() >= 2 && d[0] == 0xFF && d[1] == 0xFE {
        let mut out = String::new();
        let mut compressed = true;
        let mut start = 2;
        for i in 2..d.len() {
            if d[i] == 0 {
                push_segment(&mut out, &d[start..i], compressed);
                compressed = !compressed;
                start = i + 1;
            }
        }
        push_segment(&mut out, &d[start..], compressed);
        out
    } else {
        crate::bytes::utf16le(d)
    }
}

fn push_segment(out: &mut String, seg: &[u8], compressed: bool) {
    if compressed {
        out.extend(seg.iter().map(|&b| b as char));
    } else {
        out.push_str(&crate::bytes::utf16le(seg));
    }
}

#[cfg(test)]
mod tests {
    use super::decode_text;

    #[test]
    fn texte_non_compresse() {
        assert_eq!(decode_text(&[0x41, 0, 0x43, 0, 0x43, 0, 0x54, 0]), "ACCT");
    }

    #[test]
    fn texte_compresse_mixte() {
        let d = [
            0xFF, 0xFE, 0x39, 0x39, 0x39, 0x00, 0x2F, 0x20, 0x00, 0x39, 0x30, 0x30, 0x2C, 0x30,
            0x30, 0xA0, 0x00, 0xAC, 0x20, 0x00, 0x3B,
        ];
        assert_eq!(decode_text(&d), "999\u{202F}900,00\u{A0}€;");
    }

    #[test]
    fn texte_compresse_latin1() {
        let mut d = vec![0xFF, 0xFE];
        d.extend_from_slice(b"Commissions vers\xE9es");
        assert_eq!(decode_text(&d), "Commissions versées");
    }
}
