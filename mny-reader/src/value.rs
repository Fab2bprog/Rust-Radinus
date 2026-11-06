//! Valeurs décodées (spécification, document 03).

use std::fmt;

use chrono::{Duration, NaiveDate, NaiveDateTime};

/// Codes de type Jet (`col_type`).
pub mod col_type {
    pub const BOOL: u8 = 1;
    pub const BYTE: u8 = 2;
    pub const INT16: u8 = 3;
    pub const INT32: u8 = 4;
    pub const MONEY: u8 = 5;
    pub const FLOAT: u8 = 6;
    pub const DOUBLE: u8 = 7;
    pub const DATETIME: u8 = 8;
    pub const BINARY: u8 = 9;
    pub const TEXT: u8 = 10;
    pub const OLE: u8 = 11;
    pub const MEMO: u8 = 12;
    pub const GUID: u8 = 15;
    pub const NUMERIC: u8 = 16;
    pub const INT64: u8 = 19;

    /// Nom lisible d'un code de type.
    pub fn name(code: u8) -> &'static str {
        match code {
            BOOL => "BOOL",
            BYTE => "BYTE",
            INT16 => "INT16",
            INT32 => "INT32",
            MONEY => "MONEY",
            FLOAT => "FLOAT",
            DOUBLE => "DOUBLE",
            DATETIME => "DATETIME",
            BINARY => "BINARY",
            TEXT => "TEXT",
            OLE => "OLE",
            MEMO => "MEMO",
            GUID => "GUID",
            NUMERIC => "NUMERIC",
            INT64 => "INT64",
            _ => "UNKNOWN",
        }
    }
}

/// Valeur d'une cellule.
#[derive(Debug, Clone, PartialEq)]
pub enum Value {
    /// NULL (bit du null-mask à 0, ou colonne absente de la ligne).
    Null,
    Bool(bool),
    Byte(u8),
    Int16(i16),
    Int32(i32),
    Int64(i64),
    /// Montant exact en dix-millièmes d'unité.
    Money(Money),
    Float(f32),
    Double(f64),
    /// Date Jet brute (jours depuis 1899-12-30).
    DateTime(JetDateTime),
    Text(String),
    /// BINARY et OLE.
    Binary(Vec<u8>),
    Guid(Guid),
    /// Type non pris en charge : octets bruts.
    Unknown {
        col_type: u8,
        bytes: Vec<u8>,
    },
    /// Valeur illisible (structure corrompue) ; le message décrit l'erreur.
    Invalid(String),
}

impl Value {
    pub fn is_null(&self) -> bool {
        matches!(self, Value::Null)
    }
}

/// Montant MONEY : entier signé en 1/10 000 d'unité.
#[derive(Debug, Clone, Copy, PartialEq, Eq, PartialOrd, Ord, Hash)]
pub struct Money(pub i64);

impl Money {
    /// Valeur en dix-millièmes.
    pub fn raw(self) -> i64 {
        self.0
    }
    /// Conversion approchée en `f64` (affichage uniquement).
    pub fn to_f64(self) -> f64 {
        self.0 as f64 / 10_000.0
    }
}

impl fmt::Display for Money {
    /// Format exact à 4 décimales : `-1234.5600`.
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        let neg = self.0 < 0;
        let a = self.0.unsigned_abs();
        write!(
            f,
            "{}{}.{:04}",
            if neg { "-" } else { "" },
            a / 10_000,
            a % 10_000
        )
    }
}

/// Date-heure Jet brute : nombre de jours depuis 1899-12-30 00:00:00 (sans fuseau).
#[derive(Debug, Clone, Copy, PartialEq, PartialOrd)]
pub struct JetDateTime(pub f64);

impl JetDateTime {
    /// Valeur utilisée par Money pour « pas de date » (10000-02-28).
    pub const MONEY_NO_DATE: f64 = 2_958_524.0;
    /// 9999-12-31, dernier jour représentable par `chrono`.
    pub const MAX_REPRESENTABLE: f64 = 2_958_465.0;

    /// `true` si la valeur dépasse 9999-12-31 (dont la sentinelle Money « pas de date »).
    pub fn is_beyond_year_9999(self) -> bool {
        self.0 > Self::MAX_REPRESENTABLE + 0.999_999_999
    }

    /// Conversion en date-heure naïve, arrondie à la milliseconde.
    /// Renvoie `None` si la valeur n'est pas représentable (NaN, au-delà de 9999-12-31…).
    pub fn to_naive(self) -> Option<NaiveDateTime> {
        let d = self.0;
        if !d.is_finite() || self.is_beyond_year_9999() || d < -657_434.0 {
            return None;
        }
        let mut days = d.trunc() as i64;
        let mut ms = ((d - d.trunc()).abs() * 86_400_000.0).round() as i64;
        if ms >= 86_400_000 {
            days += 1;
            ms -= 86_400_000;
        }
        let base = NaiveDate::from_ymd_opt(1899, 12, 30)?.and_hms_opt(0, 0, 0)?;
        base.checked_add_signed(Duration::days(days))?
            .checked_add_signed(Duration::milliseconds(ms))
    }
}

/// GUID (16 octets, disposition Microsoft).
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub struct Guid(pub [u8; 16]);

impl fmt::Display for Guid {
    /// Format `{XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX}`.
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        let b = &self.0;
        let d1 = u32::from_le_bytes([b[0], b[1], b[2], b[3]]);
        let d2 = u16::from_le_bytes([b[4], b[5]]);
        let d3 = u16::from_le_bytes([b[6], b[7]]);
        write!(f, "{{{d1:08X}-{d2:04X}-{d3:04X}-{:02X}{:02X}-", b[8], b[9])?;
        for x in &b[10..16] {
            write!(f, "{x:02X}")?;
        }
        write!(f, "}}")
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn money_affichage() {
        assert_eq!(Money(-12_345_600).to_string(), "-1234.5600");
        assert_eq!(Money(5).to_string(), "0.0005");
        assert_eq!(Money(-5).to_string(), "-0.0005");
        assert_eq!(Money(i64::MIN).to_string(), "-922337203685477.5808");
    }

    #[test]
    fn dates() {
        let f = |v: f64| {
            JetDateTime(v)
                .to_naive()
                .unwrap()
                .format("%Y-%m-%d %H:%M:%S%.3f")
                .to_string()
        };
        assert_eq!(f(40481.580300925925), "2010-10-30 13:55:38.000");
        assert_eq!(f(45993.28393851852), "2025-12-02 06:48:52.288");
        assert_eq!(f(40481.85914216435), "2010-10-30 20:37:09.883");
        assert_eq!(f(0.0), "1899-12-30 00:00:00.000");
        assert_eq!(f(2.0), "1900-01-01 00:00:00.000");
        assert_eq!(f(-1.25), "1899-12-29 06:00:00.000");
        assert_eq!(f(2958465.0), "9999-12-31 00:00:00.000");
        assert!(JetDateTime(JetDateTime::MONEY_NO_DATE).to_naive().is_none());
        assert!(JetDateTime(JetDateTime::MONEY_NO_DATE).is_beyond_year_9999());
    }

    #[test]
    fn guid() {
        let g = Guid([
            0xBE, 0x5C, 0x21, 0xAD, 0xFE, 0x26, 0xFA, 0x3F, 0x84, 0xB2, 0x6E, 0x60, 0x01, 0xFE,
            0xD7, 0xDD,
        ]);
        assert_eq!(g.to_string(), "{AD215CBE-26FE-3FFA-84B2-6E6001FED7DD}");
    }
}
