//! Les pièces jointes d'une opération — portage de son bouton d'ajout et de
//! sa fenêtre de gestion (phase 17).
//!
//! **Un fichier ne porte jamais son nom sur le disque.** Il y est rangé sous
//! un GUID suivi de son extension d'origine — `76d1dbb03c8946f3887c9d9fb691d2e7.png`
//! —, et son vrai nom vit dans la base. C'est la ruse de l'auteur, et elle
//! règle d'un coup trois problèmes que personne ne voit venir : deux
//! « facture.pdf » ne se marchent plus dessus, les accents et les caractères
//! qu'un système de fichiers refuse disparaissent, et un nom de 300 caractères
//! ne fait plus échouer la copie.
//!
//! **La ligne est écrite avant le fichier**, comme chez lui : `HAjoute` puis
//! `fCopieFichier`. L'ordre inverse laisserait des fichiers que rien ne
//! désigne, et ceux-là ne se retrouvent jamais.
//!
//! **La somme de contrôle, elle, change.** L'auteur range un CRC-32 binaire
//! dans une colonne texte ; le passage par le JSON de ses sauvegardes lui fait
//! perdre un octet sur quatre — mesuré sur son archive d'essai, où elle ne
//! pèse plus que trois octets. Une empreinte amputée accuserait un fichier
//! intact. Les nouvelles pièces reçoivent donc un CRC-32 écrit en huit
//! caractères hexadécimaux, qui traverse le JSON sans rien perdre ; celles qui
//! viennent de 1.9.3 gardent la leur et ne sont jamais jugées dessus.

use crate::domain::NaiveDate;
use rusqlite::{Connection, Result as SqlResult};
use serde::{Deserialize, Serialize};
use std::io::{Read, Write};
use std::path::{Path, PathBuf};

/// Les dix-sept extensions que son sélecteur accepte, et rien d'autre.
///
/// Une liste fermée plutôt qu'une liste noire : ce qui n'est pas prévu est
/// refusé, et non l'inverse. Un utilisateur qui joint un exécutable à une
/// opération bancaire se prépare des ennuis qu'il n'a pas demandés.
pub const ALLOWED: &[&str] = &[
    "pdf", "jpeg", "jpg", "png", "bmp", "tiff", "gif", "webp", "xls", "xlsx", "doc", "docx",
    "odt", "rtf", "txt", "json", "xml",
];

/// Le type MIME d'une extension. Vide pour ce que nous ne connaissons pas —
/// la colonne existe, elle ne ment pas.
pub fn mime_of(extension: &str) -> &'static str {
    match extension.to_ascii_lowercase().as_str() {
        "pdf" => "application/pdf",
        "jpeg" | "jpg" => "image/jpeg",
        "png" => "image/png",
        "bmp" => "image/bmp",
        "tiff" => "image/tiff",
        "gif" => "image/gif",
        "webp" => "image/webp",
        "xls" => "application/vnd.ms-excel",
        "xlsx" => "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
        "doc" => "application/msword",
        "docx" => "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
        "odt" => "application/vnd.oasis.opendocument.text",
        "rtf" => "application/rtf",
        "txt" => "text/plain",
        "json" => "application/json",
        "xml" => "application/xml",
        _ => "",
    }
}

/// Une pièce jointe, telle que la fenêtre la montre.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct Attachment {
    pub id: i64,
    pub operation_id: i64,
    /// Le nom que le fichier portait quand on l'a joint.
    pub name: String,
    /// Le nom qu'il porte sur le disque : GUID + extension.
    pub guid_name: String,
    pub size: i64,
    pub mime: String,
    pub added: Option<NaiveDate>,
    pub checksum: String,
    pub note: String,
}

/// Ce qui peut rater.
#[derive(Debug)]
pub enum Failure {
    Database(rusqlite::Error),
    File(std::io::Error),
    /// Un refus adressé à l'utilisateur : la valeur est une clef Fluent.
    Refused(&'static str),
}

impl std::fmt::Display for Failure {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Failure::Database(error) => write!(f, "{error}"),
            Failure::File(error) => write!(f, "{error}"),
            Failure::Refused(key) => write!(f, "{key}"),
        }
    }
}

impl std::error::Error for Failure {}

impl From<rusqlite::Error> for Failure {
    fn from(error: rusqlite::Error) -> Self {
        Failure::Database(error)
    }
}

impl From<std::io::Error> for Failure {
    fn from(error: std::io::Error) -> Self {
        Failure::File(error)
    }
}

// ---------------------------------------------------------------------------
// La somme de contrôle
// ---------------------------------------------------------------------------

/// Le CRC-32 des données, calculé au fil de l'eau.
///
/// L'algorithme d'IEEE 802.3, celui du zip et celui de `HA_CKSUM_32` : le
/// polynôme 0xEDB88320, réfléchi. Trente lignes valent mieux qu'une
/// dépendance de plus pour une chose que tout le monde sait faire.
pub struct Crc32(u32);

impl Default for Crc32 {
    fn default() -> Self {
        Self::new()
    }
}

impl Crc32 {
    pub fn new() -> Self {
        Self(0xFFFF_FFFF)
    }

    pub fn update(&mut self, bytes: &[u8]) {
        for byte in bytes {
            self.0 ^= *byte as u32;
            for _ in 0..8 {
                let carry = self.0 & 1;
                self.0 >>= 1;
                if carry != 0 {
                    self.0 ^= 0xEDB8_8320;
                }
            }
        }
    }

    pub fn finish(self) -> u32 {
        self.0 ^ 0xFFFF_FFFF
    }
}

/// La somme de contrôle d'un fichier, et sa taille, en une seule lecture.
///
/// Écrite en huit caractères hexadécimaux majuscules : lisible, comparable, et
/// surtout **transportable** — c'est tout ce qui manquait à celle de 1.9.3.
pub fn checksum_of(path: &Path) -> std::io::Result<(String, i64)> {
    let mut file = std::fs::File::open(path)?;
    let mut crc = Crc32::new();
    let mut size = 0i64;
    let mut buffer = vec![0u8; 64 * 1024];
    loop {
        let read = file.read(&mut buffer)?;
        if read == 0 {
            break;
        }
        crc.update(&buffer[..read]);
        size += read as i64;
    }
    Ok((format!("{:08X}", crc.finish()), size))
}

/// Une empreinte que nous savons juger.
///
/// Celles de 1.9.3 sont des octets bruts amputés par le JSON ; les nôtres font
/// huit caractères hexadécimaux. Juger un fichier sur une empreinte que l'on
/// ne sait pas relire reviendrait à accuser au hasard.
pub fn is_ours(checksum: &str) -> bool {
    checksum.len() == 8 && checksum.chars().all(|c| c.is_ascii_hexdigit())
}

/// Le fichier est-il resté ce qu'il était ?
///
/// `None` quand on ne peut pas le dire — empreinte illisible, venue de
/// 1.9.3 — plutôt qu'un `false` qui ferait peur pour rien.
pub fn is_intact(path: &Path, checksum: &str) -> Option<bool> {
    if !is_ours(checksum) {
        return None;
    }
    checksum_of(path)
        .ok()
        .map(|(found, _)| found.eq_ignore_ascii_case(checksum))
}

// ---------------------------------------------------------------------------
// La base
// ---------------------------------------------------------------------------

const COLUMNS: &str = "IDPiecesJointes, IDOperation, NomFichier, NomFichierGUID, \
     TailleFich, MiMeType, DateAjout, CheckSumInfo, NoteInfo";

fn read_row(row: &rusqlite::Row<'_>) -> SqlResult<Attachment> {
    Ok(Attachment {
        id: row.get(0)?,
        operation_id: row.get(1)?,
        name: row.get(2)?,
        guid_name: row.get(3)?,
        size: row.get(4)?,
        mime: row.get(5)?,
        added: row
            .get::<_, Option<String>>(6)?
            .and_then(|text| NaiveDate::parse_from_str(&text, "%Y-%m-%d").ok()),
        checksum: row.get(7)?,
        note: row.get(8)?,
    })
}

/// Les pièces jointes d'une opération, dans l'ordre où elles ont été ajoutées.
pub fn list(conn: &Connection, operation_id: i64) -> SqlResult<Vec<Attachment>> {
    let mut statement = conn.prepare(&format!(
        "SELECT {COLUMNS} FROM PiecesJointes
          WHERE IDOperation = ?1
          ORDER BY IDPiecesJointes"
    ))?;
    let found = statement
        .query_map([operation_id], read_row)?
        .collect::<SqlResult<_>>();
    found
}

/// Une pièce jointe par sa clef.
pub fn get(conn: &Connection, id: i64) -> SqlResult<Option<Attachment>> {
    let mut statement = conn.prepare(&format!(
        "SELECT {COLUMNS} FROM PiecesJointes WHERE IDPiecesJointes = ?1"
    ))?;
    let mut found = statement.query_map([id], read_row)?;
    found.next().transpose()
}

/// Combien de pièces porte une opération.
pub fn count_for(conn: &Connection, operation_id: i64) -> SqlResult<i64> {
    conn.query_row(
        "SELECT COUNT(*) FROM PiecesJointes WHERE IDOperation = ?1",
        [operation_id],
        |row| row.get(0),
    )
}

/// Le chemin d'une pièce jointe dans le dossier des pièces jointes.
pub fn path_in(folder: &Path, guid_name: &str) -> PathBuf {
    folder.join(guid_name)
}

/// Le nom physique d'un fichier : un GUID brut suivi de son extension.
///
/// Trente-deux chiffres hexadécimaux tirés de SQLite, comme les GUID des
/// règles périodiques, et exactement la forme qu'ont les siens.
fn guid_name(conn: &Connection, extension: &str) -> SqlResult<String> {
    let guid: String = conn.query_row("SELECT lower(hex(randomblob(16)))", [], |row| row.get(0))?;
    Ok(if extension.is_empty() {
        guid
    } else {
        format!("{guid}.{extension}")
    })
}

/// L'extension d'un chemin, en minuscules, sans le point.
fn extension_of(path: &Path) -> String {
    path.extension()
        .and_then(|extension| extension.to_str())
        .unwrap_or_default()
        .to_ascii_lowercase()
}

/// Joint `source` à l'opération, en copiant le fichier dans `folder`.
///
/// L'ordre est celui de son bouton : les vérifications, la somme de contrôle,
/// **la ligne**, puis la copie. Si la copie échoue, la ligne est retirée —
/// c'est la seule liberté prise avec son code, qui laisse dans ce cas une
/// pièce jointe sans fichier, invisible et impossible à ouvrir.
pub fn add(
    conn: &Connection,
    operation_id: i64,
    source: &Path,
    folder: &Path,
    today: NaiveDate,
) -> Result<Attachment, Failure> {
    if !source.is_file() {
        return Err(Failure::Refused("attachment-refusal-missing"));
    }
    let extension = extension_of(source);
    if !ALLOWED.contains(&extension.as_str()) {
        return Err(Failure::Refused("attachment-refusal-extension"));
    }
    let exists: i64 = conn.query_row(
        "SELECT COUNT(*) FROM Operation WHERE IDOperation = ?1",
        [operation_id],
        |row| row.get(0),
    )?;
    if exists == 0 {
        return Err(Failure::Refused("attachment-refusal-operation"));
    }

    let (checksum, size) = checksum_of(source)?;
    let name = source
        .file_name()
        .and_then(|name| name.to_str())
        .unwrap_or_default()
        .to_string();
    let guid_name = guid_name(conn, &extension)?;
    let id: i64 = conn.query_row(
        "SELECT COALESCE(MAX(IDPiecesJointes), 0) + 1 FROM PiecesJointes",
        [],
        |row| row.get(0),
    )?;

    conn.execute(
        "INSERT INTO PiecesJointes
         (IDPiecesJointes, IDOperation, NomFichier, NomFichierGUID, PathRelFichier,
          TailleFich, MiMeType, DateAjout, CheckSumInfo, NoteInfo)
         VALUES (?1, ?2, ?3, ?4, '', ?5, ?6, ?7, ?8, '')",
        rusqlite::params![
            id,
            operation_id,
            name,
            guid_name,
            size,
            mime_of(&extension),
            today.format("%Y-%m-%d").to_string(),
            checksum
        ],
    )?;

    std::fs::create_dir_all(folder)?;
    if let Err(error) = std::fs::copy(source, path_in(folder, &guid_name)) {
        // La ligne ne survit pas à une copie ratée : une pièce jointe sans
        // fichier ne s'ouvre pas, ne s'exporte pas, et ne se comprend pas.
        conn.execute("DELETE FROM PiecesJointes WHERE IDPiecesJointes = ?1", [id])?;
        return Err(Failure::File(error));
    }

    Ok(Attachment {
        id,
        operation_id,
        name,
        guid_name,
        size,
        mime: mime_of(&extension).to_string(),
        added: Some(today),
        checksum,
        note: String::new(),
    })
}

/// **Remplace** le document d'une pièce jointe par un autre.
///
/// La ligne survit — même clef, même opération —, mais tout ce qui décrit le
/// document change : son nom, son poids, son type, son empreinte, et son nom
/// physique. Un nouveau GUID plutôt que l'ancien réutilisé : si la copie
/// échoue à mi-chemin, l'ancien fichier est encore entier sur le disque, et
/// rien n'est perdu.
///
/// Rend la pièce telle qu'elle est devenue, et **le chemin de l'ancien
/// fichier**, que l'appelant enverra à la corbeille.
pub fn replace(
    conn: &Connection,
    id: i64,
    source: &Path,
    folder: &Path,
    today: NaiveDate,
) -> Result<(Attachment, PathBuf), Failure> {
    let Some(previous) = get(conn, id)? else {
        return Err(Failure::Refused("attachment-gone"));
    };
    if !source.is_file() {
        return Err(Failure::Refused("attachment-refusal-missing"));
    }
    let extension = extension_of(source);
    if !ALLOWED.contains(&extension.as_str()) {
        return Err(Failure::Refused("attachment-refusal-extension"));
    }

    let (checksum, size) = checksum_of(source)?;
    let name = source
        .file_name()
        .and_then(|name| name.to_str())
        .unwrap_or_default()
        .to_string();
    let guid_name = guid_name(conn, &extension)?;

    std::fs::create_dir_all(folder)?;
    // Le nouveau fichier d'abord : tant qu'il n'est pas là, la ligne continue
    // de désigner l'ancien, qui s'ouvre encore.
    std::fs::copy(source, path_in(folder, &guid_name))?;

    conn.execute(
        "UPDATE PiecesJointes
            SET NomFichier = ?1, NomFichierGUID = ?2, TailleFich = ?3,
                MiMeType = ?4, DateAjout = ?5, CheckSumInfo = ?6
          WHERE IDPiecesJointes = ?7",
        rusqlite::params![
            name,
            guid_name,
            size,
            mime_of(&extension),
            today.format("%Y-%m-%d").to_string(),
            checksum,
            id
        ],
    )?;

    Ok((
        Attachment {
            id,
            operation_id: previous.operation_id,
            name,
            guid_name,
            size,
            mime: mime_of(&extension).to_string(),
            added: Some(today),
            checksum,
            note: previous.note,
        },
        path_in(folder, &previous.guid_name),
    ))
}

/// Retire la ligne et rend le chemin du fichier, que l'appelant enverra à la
/// corbeille.
///
/// **Le noyau ne touche pas à la corbeille** : elle n'est pas la même chose
/// sous macOS, sous Windows et sous Linux, et c'est une affaire de système
/// (voir `src-tauri/src/system.rs`). Il rend le chemin, et le contrôleur s'en
/// charge.
pub fn remove(conn: &Connection, id: i64, folder: &Path) -> SqlResult<Option<PathBuf>> {
    let Some(attachment) = get(conn, id)? else {
        return Ok(None);
    };
    conn.execute("DELETE FROM PiecesJointes WHERE IDPiecesJointes = ?1", [id])?;
    Ok(Some(path_in(folder, &attachment.guid_name)))
}

/// Les noms physiques de toutes les pièces jointes de la base — de quoi les
/// mettre dans une sauvegarde.
pub fn all_files(conn: &Connection) -> SqlResult<Vec<String>> {
    let mut statement =
        conn.prepare("SELECT NomFichierGUID FROM PiecesJointes ORDER BY IDPiecesJointes")?;
    let found = statement
        .query_map([], |row| row.get::<_, String>(0))?
        .collect::<SqlResult<_>>();
    found
}

/// Écrit `bytes` dans le dossier des pièces jointes sous `guid_name` — ce que
/// fait une restauration en sortant les fichiers de l'archive.
pub fn restore_file(folder: &Path, guid_name: &str, bytes: &[u8]) -> std::io::Result<()> {
    std::fs::create_dir_all(folder)?;
    let mut file = std::fs::File::create(path_in(folder, guid_name))?;
    file.write_all(bytes)
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::database;
    use std::sync::atomic::{AtomicU32, Ordering};

    static COUNTER: AtomicU32 = AtomicU32::new(0);

    fn scratch(label: &str) -> PathBuf {
        let n = COUNTER.fetch_add(1, Ordering::SeqCst);
        let path = std::env::temp_dir().join(format!("radinus_pj_{label}_{n}"));
        std::fs::remove_dir_all(&path).ok();
        std::fs::remove_file(&path).ok();
        path
    }

    fn base() -> Connection {
        let conn = Connection::open_in_memory().expect("base");
        database::schema::migrate(&conn).expect("schéma");
        database::seed::seed_initial_data(&conn).expect("valeurs");
        conn.execute("INSERT INTO Compte (IDCompte, Libelle) VALUES (1, 'CCP')", [])
            .expect("compte");
        conn.execute(
            "INSERT INTO Operation (IDOperation, Libelle, Date, Montant, IDCompte, IDStatutOperation)
             VALUES (1, 'ACHAT', '2026-01-05', -1000000, 1, 1)",
            [],
        )
        .expect("opération");
        conn
    }

    fn a_file(name: &str, contents: &[u8]) -> PathBuf {
        let folder = scratch("src");
        std::fs::create_dir_all(&folder).expect("dossier");
        let file = folder.join(name);
        std::fs::write(&file, contents).expect("écriture");
        file
    }

    fn today() -> NaiveDate {
        NaiveDate::from_ymd_opt(2026, 8, 1).expect("date")
    }

    /// La valeur de référence du CRC-32 : « 123456789 » donne CBF43926, c'est
    /// le vecteur d'essai de la norme.
    #[test]
    fn le_crc32_donne_la_valeur_de_reference() {
        let mut crc = Crc32::new();
        crc.update(b"123456789");
        assert_eq!(format!("{:08X}", crc.finish()), "CBF43926");
    }

    #[test]
    fn une_piece_jointe_est_rangee_sous_son_guid() {
        let conn = base();
        let source = a_file("Facture EDF.pdf", b"%PDF-1.4 ...");
        let folder = scratch("folder");
        let added = add(&conn, 1, &source, &folder, today()).expect("ajout");

        assert_eq!(added.name, "Facture EDF.pdf");
        assert!(added.guid_name.ends_with(".pdf"));
        assert_eq!(added.guid_name.len(), 36, "32 chiffres, un point, pdf");
        assert_eq!(added.mime, "application/pdf");
        assert_eq!(added.size, 12);
        assert!(path_in(&folder, &added.guid_name).is_file());
        std::fs::remove_dir_all(&folder).ok();
    }

    /// **La liste est fermée.** Ce qui n'est pas prévu est refusé, et non
    /// l'inverse.
    #[test]
    fn une_extension_hors_liste_est_refusee() {
        let conn = base();
        let source = a_file("virus.exe", b"MZ");
        let folder = scratch("folder");
        let outcome = add(&conn, 1, &source, &folder, today());
        assert!(matches!(
            outcome,
            Err(Failure::Refused("attachment-refusal-extension"))
        ));
        assert_eq!(count_for(&conn, 1).expect("compte"), 0);
    }

    #[test]
    fn une_operation_inexistante_refuse_la_piece() {
        let conn = base();
        let source = a_file("note.txt", b"bonjour");
        let folder = scratch("folder");
        let outcome = add(&conn, 99, &source, &folder, today());
        assert!(matches!(
            outcome,
            Err(Failure::Refused("attachment-refusal-operation"))
        ));
    }

    /// La somme de contrôle sert à quelque chose : un fichier modifié se voit.
    #[test]
    fn une_piece_modifiee_se_voit() {
        let conn = base();
        let source = a_file("note.txt", b"bonjour");
        let folder = scratch("folder");
        let added = add(&conn, 1, &source, &folder, today()).expect("ajout");
        let stored = path_in(&folder, &added.guid_name);

        assert_eq!(is_intact(&stored, &added.checksum), Some(true));
        std::fs::write(&stored, b"bonsoir").expect("modification");
        assert_eq!(is_intact(&stored, &added.checksum), Some(false));
        std::fs::remove_dir_all(&folder).ok();
    }

    /// Une empreinte venue de 1.9.3 est illisible pour nous : on ne juge pas.
    #[test]
    fn une_empreinte_de_1_9_3_ne_juge_personne() {
        let source = a_file("note.txt", b"bonjour");
        assert_eq!(is_intact(&source, "#\u{3}="), None);
        assert!(!is_ours("#\u{3}="));
        assert!(is_ours("CBF43926"));
    }

    /// **Remplacer garde la ligne et change tout le reste.** La clef ne bouge
    /// pas — l'opération porte toujours la même pièce —, mais le document,
    /// lui, est un autre, et l'ancien fichier est rendu pour la corbeille.
    #[test]
    fn remplacer_change_le_document_et_garde_la_ligne() {
        let conn = base();
        let first = a_file("ancienne.txt", b"bonjour");
        let folder = scratch("folder");
        let added = add(&conn, 1, &first, &folder, today()).expect("ajout");

        let second = a_file("nouvelle.pdf", b"%PDF-1.4 nouvelle piece");
        let (changed, old) = replace(&conn, added.id, &second, &folder, today()).expect("remplacement");

        assert_eq!(changed.id, added.id, "la clef ne bouge pas");
        assert_eq!(changed.operation_id, 1);
        assert_eq!(changed.name, "nouvelle.pdf");
        assert_eq!(changed.mime, "application/pdf");
        assert_ne!(changed.guid_name, added.guid_name, "un nouveau nom physique");
        assert_ne!(changed.checksum, added.checksum);
        assert_eq!(count_for(&conn, 1).expect("compte"), 1);

        // L'ancien fichier est encore là : c'est à l'appelant de le jeter.
        assert!(old.is_file());
        assert!(path_in(&folder, &changed.guid_name).is_file());
        std::fs::remove_dir_all(&folder).ok();
    }

    #[test]
    fn retirer_une_piece_rend_le_chemin_de_son_fichier() {
        let conn = base();
        let source = a_file("note.txt", b"bonjour");
        let folder = scratch("folder");
        let added = add(&conn, 1, &source, &folder, today()).expect("ajout");

        let path = remove(&conn, added.id, &folder)
            .expect("retrait")
            .expect("chemin");
        assert!(path.is_file(), "le noyau ne touche pas au fichier");
        assert_eq!(count_for(&conn, 1).expect("compte"), 0);
        std::fs::remove_dir_all(&folder).ok();
    }

    /// Effacer l'opération emporte ses pièces jointes : la table est en
    /// cascade depuis la phase 1.
    #[test]
    fn effacer_l_operation_emporte_ses_lignes() {
        let conn = base();
        conn.execute("PRAGMA foreign_keys = ON", []).expect("clefs");
        let source = a_file("note.txt", b"bonjour");
        let folder = scratch("folder");
        add(&conn, 1, &source, &folder, today()).expect("ajout");
        conn.execute("DELETE FROM Operation WHERE IDOperation = 1", [])
            .expect("suppression");
        assert_eq!(count_for(&conn, 1).expect("compte"), 0);
        std::fs::remove_dir_all(&folder).ok();
    }
}
