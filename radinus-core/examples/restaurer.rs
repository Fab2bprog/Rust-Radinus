//! Restores a Radinus backup into a database, replacing everything it holds.
//!
//! The Fichier > Restauration menu entry belongs to a later phase; this is
//! the same code (`backup::restore_file_into`) reachable from a terminal, so
//! a database can be put back to a known state without waiting for it.
//!
//!     cargo run -p radinus-core --example restaurer -- <sauvegarde.zip> <base.sqlite>
//!
//! The database is **overwritten**: every table the archive carries is
//! emptied and rewritten (author's ruling, 25/07/2026 — "la restauration
//! écrase totalement les données présentes dans la base").

use std::path::PathBuf;

fn main() {
    let mut args = std::env::args().skip(1);
    let (Some(zip), Some(db)) = (args.next(), args.next()) else {
        eprintln!("usage : restaurer <sauvegarde.zip> <base.sqlite>");
        std::process::exit(2);
    };
    let zip = PathBuf::from(zip);
    let db = PathBuf::from(db);

    let mut conn = radinus_core::database::open_existing_database(&db, None)
        .unwrap_or_else(|e| panic!("base illisible ({}) : {e}", db.display()))
        .conn;

    let report = radinus_core::backup::restore_file_into(&mut conn, &zip)
        .unwrap_or_else(|e| panic!("restauration impossible : {e}"));

    println!("Restauration terminée depuis {}", zip.display());
    println!("{report:#?}");
}
