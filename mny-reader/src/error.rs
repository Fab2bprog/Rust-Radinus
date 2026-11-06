//! Erreurs de la bibliothèque.

use std::io;

/// Résultat utilisé dans toute la bibliothèque.
pub type Result<T> = std::result::Result<T, Error>;

/// Erreurs possibles lors de la lecture d'un fichier `.mny`.
#[derive(Debug, thiserror::Error)]
pub enum Error {
    /// Erreur d'entrée/sortie lors de la lecture du fichier.
    #[error("erreur d'entrée/sortie : {0}")]
    Io(#[from] io::Error),

    /// La taille du fichier n'est pas un multiple de 4096 ou le fichier est trop petit.
    #[error(
        "taille de fichier invalide ({0} octets) : attendu un multiple de 4096, au moins 3 pages"
    )]
    InvalidFileSize(usize),

    /// La signature `"MSISAM Database"` est absente : ce n'est pas un fichier Money.
    #[error("ce fichier n'est pas un fichier Microsoft Money (signature MSISAM absente)")]
    NotMoneyFile,

    /// Version du format autre que Jet 4.
    #[error("version de format non prise en charge : {0} (seule la version 1 / Jet 4 est gérée)")]
    UnsupportedVersion(u32),

    /// Le mot de passe fourni (ou son absence) ne correspond pas au fichier.
    #[error("mot de passe incorrect")]
    WrongPassword,

    /// Les pages déchiffrées ne sont pas cohérentes (clé incorrecte ou fichier corrompu).
    #[error("déchiffrement incohérent : la page 1 n'est pas une page de données (mot de passe incorrect ?)")]
    DecryptionCheckFailed,

    /// Numéro de page hors du fichier.
    #[error("page {0} hors du fichier")]
    PageOutOfRange(u32),

    /// Structure binaire invalide.
    #[error("structure invalide : {0}")]
    Corrupt(String),

    /// Table inconnue.
    #[error("table introuvable : {0}")]
    TableNotFound(String),
}

impl Error {
    pub(crate) fn corrupt(msg: impl Into<String>) -> Self {
        Error::Corrupt(msg.into())
    }
}
