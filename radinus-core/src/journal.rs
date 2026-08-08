//! Le journal des opérations techniques — phase 17.
//!
//! **Le journal de la dernière opération, et d'elle seule.** C'est ce que fait
//! l'original : `gtabMonLog.SupprimeTout()` ouvre chacune des trois procédures
//! techniques — sauvegarde, restauration, réparation —, si bien que le journal
//! ne raconte jamais qu'un traitement, le plus récent. Il ne s'accumule pas et
//! ne survit pas à la fermeture du logiciel : ce n'est pas une archive, c'est
//! le compte rendu de ce qui vient de se passer.
//!
//! Six colonnes, celles de son `Ajoute_Log` : l'étape, le fichier concerné, la
//! table concernée, le statut, l'erreur, et un commentaire libre. Une ligne
//! peut n'en remplir que deux — la plupart le font.
//!
//! Les phrases viennent de Fluent comme partout ailleurs (règle du 25/07/2026)
//! et non du code : un journal en français dans une base anglaise serait un
//! journal illisible pour celui qui le lit.

use crate::i18n::{self, Language};
use serde::{Deserialize, Serialize};

/// Une ligne du journal.
#[derive(Debug, Clone, Default, PartialEq, Eq, Serialize, Deserialize)]
pub struct Entry {
    pub step: String,
    pub file: String,
    pub table: String,
    pub status: String,
    pub error: String,
    pub comments: String,
}

/// Les cinq statuts de l'original, et rien d'autre.
///
/// `SUCCES`, `ECHEC` et `REPARE` qualifient une étape ; `EN COURS` et
/// `TERMINE` sont les deux marqueurs qui ouvrent et ferment un traitement.
/// Un sixième s'inventerait vite et ne voudrait rien dire.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Status {
    Success,
    Failure,
    Repaired,
    /// Le marqueur d'ouverture d'un traitement.
    Started,
    /// Le marqueur de clôture. **Sa présence est l'information** : un journal
    /// qui n'en porte pas raconte un traitement qui ne s'est pas terminé.
    Finished,
}

impl Status {
    fn key(self) -> &'static str {
        match self {
            Status::Success => "journal-status-success",
            Status::Failure => "journal-status-failure",
            Status::Repaired => "journal-status-repaired",
            Status::Started => "journal-status-started",
            Status::Finished => "journal-status-finished",
        }
    }
}

/// Le journal en cours d'écriture.
///
/// Il se remplit dans l'ordre du traitement : la première ligne est la
/// première chose faite, et la dernière la dernière. C'est ce qui permet de
/// voir **où** un traitement s'est arrêté quand il s'est arrêté.
#[derive(Debug, Clone)]
pub struct Journal {
    language: Language,
    entries: Vec<Entry>,
}

impl Journal {
    pub fn new(language: Language) -> Self {
        Self {
            language,
            entries: Vec::new(),
        }
    }

    /// Ajoute une ligne. `step` est une clef Fluent ; le reste est déjà écrit.
    pub fn add(
        &mut self,
        step: &str,
        table: &str,
        status: Status,
        error: &str,
        comments: &str,
    ) {
        self.entries.push(Entry {
            step: i18n::text(self.language, step),
            file: String::new(),
            table: table.to_string(),
            status: i18n::text(self.language, status.key()),
            error: error.to_string(),
            comments: comments.to_string(),
        });
    }

    /// La même chose, pour une étape qui porte sur un fichier plutôt que sur
    /// une table — la sauvegarde et la restauration en sont pleines.
    pub fn add_file(
        &mut self,
        step: &str,
        file: &str,
        status: Status,
        error: &str,
        comments: &str,
    ) {
        self.entries.push(Entry {
            step: i18n::text(self.language, step),
            file: file.to_string(),
            table: String::new(),
            status: i18n::text(self.language, status.key()),
            error: error.to_string(),
            comments: comments.to_string(),
        });
    }

    pub fn entries(&self) -> &[Entry] {
        &self.entries
    }

    pub fn into_entries(self) -> Vec<Entry> {
        self.entries
    }

    pub fn len(&self) -> usize {
        self.entries.len()
    }

    pub fn is_empty(&self) -> bool {
        self.entries.is_empty()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn une_ligne_porte_ses_six_colonnes() {
        let mut journal = Journal::new(Language::French);
        journal.add("journal-step-reindex", "Operation", Status::Success, "", "");
        let entry = &journal.entries()[0];
        assert!(!entry.step.is_empty());
        assert_eq!(entry.table, "Operation");
        assert!(!entry.status.is_empty());
    }

    /// Les statuts ne sont pas écrits dans le code : ils changent avec la
    /// langue de la base, comme toute phrase de Radinus.
    #[test]
    fn les_statuts_suivent_la_langue() {
        let mut french = Journal::new(Language::French);
        french.add("journal-step-reindex", "", Status::Failure, "", "");
        let mut english = Journal::new(Language::English);
        english.add("journal-step-reindex", "", Status::Failure, "", "");
        assert_ne!(french.entries()[0].step, english.entries()[0].step);
    }
}
