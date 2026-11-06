//! Couche Jet 4 : catalogue, tables et lignes.

pub(crate) mod page;
pub(crate) mod row;
pub(crate) mod tdef;

pub use row::decode_text;
pub use tdef::Column;
