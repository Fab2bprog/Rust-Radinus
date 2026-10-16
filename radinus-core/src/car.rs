//! Carnet de ma voiture — F47 (Fabrice, 10/10/2026).
//!
//! « Il faudrait quelque chose qui gère l'historique de la voiture », avec ce
//! qu'il avait nommé d'emblée : « coût entretien, carburants, kilométrage,
//! coût résolution panne, coût changement pièces d'usure, coût changement
//! pneus, coûts révisions annuelles ». Puis, point par point :
//!
//! - **huit rubriques** : l'énergie (« carburant devient énergie »),
//!   l'entretien courant, la révision, les pièces d'usure, les pneus, les
//!   pannes, et — « oui pour l'assurance et le contrôle technique » — ces
//!   deux-là ; ni péage ni stationnement (« qu'on ait une petite voiture ou
//!   une Ferrari, ça coûte pareil ») ;
//! - **huit motorisations** : essence, diesel, GPL, E85 (« on peut ajouter
//!   E85 »), hybride, hybride rechargeable, électrique, hydrogène. Elles
//!   décident de l'unité de l'énergie — litres, kWh, kilos — et des pièces
//!   d'usure proposées au départ (« oui ») ;
//! - **la fiche** : immatriculation, première main, date de première mise en
//!   circulation, date et kilométrage d'acquisition — le point de départ de
//!   tous les comptes ;
//! - **la recharge à la maison** se chiffre au tarif d'électricité de F42,
//!   modifiable dans la fenêtre, et **gardé dans le fichier de la voiture**
//!   (« oui ça reste dans le fichier de la voiture ») ; chaque recharge garde
//!   le coût calculé le jour où elle est notée ;
//! - **l'état de santé de la batterie** (« oui ») ;
//! - **une ligne peut se remplir depuis une opération** (« oui mais
//!   facultatif ») — le contrôleur s'en charge, le carnet ne garde que la
//!   copie ;
//! - **les échéances**, dans la fenêtre seulement ;
//! - **un fichier JSON par voiture**, enregistré à la main, un rapport PDF et
//!   un classeur Excel (« oui aux 2 »). Rien n'entre dans la base.
//!
//! # Les comptes
//!
//! - Tout se compte **depuis l'acquisition** : la date et le compteur ce
//!   jour-là. Ce qui s'est passé avant n'est pas connu, et le carnet ne fait
//!   pas semblant.
//! - **La consommation se mesure de plein à plein** : la quantité des pleins
//!   qui suivent le premier, rapportée aux kilomètres entre le premier et le
//!   dernier. Pour une voiture E85 — qui reçoit aussi de l'essence —, chaque
//!   plein remplit ce que le plein d'avant a fait rouler : l'écart de compteur
//!   va au carburant d'avant.
//! - **La durée de vie d'une pièce ou d'un pneu** se lit entre deux
//!   changements ; pour une voiture de première main, la pièce d'origine a
//!   vécu de 0 km jusqu'au premier changement.
//! - **Le contrôle technique** suit la règle française : le premier dans les
//!   quatre ans de la mise en circulation, puis tous les deux ans ; une
//!   contre-visite, dans les deux mois.

use crate::appliance::{self, Tariff};
use crate::domain::NaiveDate;
use crate::i18n::{self, Language};
use crate::loan_charts::{self, axes, bounds_of, svg_open, text, ticks, Frame, Part as Slice};
use crate::money;
use crate::printing::{self, Failure};
use crate::sheets::{Sheet, SheetCell};
use std::collections::BTreeMap;
use time_compute::{Datelike, Months};

// --- Les nomenclatures ----------------------------------------------------------

/// La motorisation : elle décide de l'énergie et des pièces d'usure.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Engine {
    Petrol,
    Diesel,
    Lpg,
    E85,
    Hybrid,
    PlugIn,
    Electric,
    Hydrogen,
}

pub const ENGINES: [Engine; 8] = [
    Engine::Petrol,
    Engine::Diesel,
    Engine::Lpg,
    Engine::E85,
    Engine::Hybrid,
    Engine::PlugIn,
    Engine::Electric,
    Engine::Hydrogen,
];

impl Engine {
    pub fn key(self) -> &'static str {
        match self {
            Engine::Petrol => "petrol",
            Engine::Diesel => "diesel",
            Engine::Lpg => "lpg",
            Engine::E85 => "e85",
            Engine::Hybrid => "hybrid",
            Engine::PlugIn => "plug-in",
            Engine::Electric => "electric",
            Engine::Hydrogen => "hydrogen",
        }
    }

    pub fn from_key(key: &str) -> Option<Engine> {
        ENGINES.into_iter().find(|engine| engine.key() == key)
    }

    /// Les énergies qu'elle reçoit. Une voiture E85 prend aussi de l'essence ;
    /// une hybride rechargeable, de l'essence et du courant.
    pub fn energies(self) -> &'static [Energy] {
        match self {
            Engine::Petrol | Engine::Hybrid => &[Energy::Petrol],
            Engine::Diesel => &[Energy::Diesel],
            Engine::Lpg => &[Energy::Lpg, Energy::Petrol],
            Engine::E85 => &[Energy::E85, Energy::Petrol],
            Engine::PlugIn => &[Energy::Petrol, Energy::Electricity],
            Engine::Electric => &[Energy::Electricity],
            Engine::Hydrogen => &[Energy::Hydrogen],
        }
    }

    /// A-t-elle une batterie de traction dont on suit la santé ?
    pub fn battery(self) -> bool {
        matches!(self, Engine::PlugIn | Engine::Electric)
    }

    /// Se recharge-t-elle sur le secteur ?
    pub fn rechargeable(self) -> bool {
        self.energies().contains(&Energy::Electricity)
    }

    /// **Les pièces d'usure proposées au départ** (« oui »). Une électrique
    /// n'a ni courroie, ni embrayage, ni bougies ; un diesel a ses bougies de
    /// préchauffage et son filtre à particules.
    pub fn parts(self) -> &'static [&'static str] {
        match self {
            Engine::Diesel => &[
                "brake-pads", "brake-discs", "timing-belt", "clutch", "battery-12v", "shock-absorbers",
                "wipers", "glow-plugs", "particulate-filter",
            ],
            Engine::Petrol | Engine::Lpg | Engine::E85 => &[
                "brake-pads", "brake-discs", "timing-belt", "clutch", "battery-12v", "shock-absorbers",
                "wipers", "spark-plugs", "catalytic-converter",
            ],
            Engine::Hybrid | Engine::PlugIn => &[
                "brake-pads", "brake-discs", "timing-belt", "battery-12v", "shock-absorbers", "wipers",
                "spark-plugs",
            ],
            Engine::Electric => &["brake-pads", "brake-discs", "battery-12v", "shock-absorbers", "wipers"],
            Engine::Hydrogen => &[
                "brake-pads", "brake-discs", "battery-12v", "shock-absorbers", "wipers", "fuel-cell-filter",
            ],
        }
    }

    /// Le rythme de révision proposé : un an, deux pour une électrique ou une
    /// voiture à hydrogène. Il se règle sur la fiche.
    pub fn service_months(self) -> u32 {
        match self {
            Engine::Electric | Engine::Hydrogen => 24,
            _ => 12,
        }
    }
}

/// Toutes les pièces connues, quelle que soit la motorisation : une ligne
/// notée sous une autre motorisation garde son nom.
pub const KNOWN_PARTS: [&str; 13] = [
    "brake-pads",
    "brake-discs",
    "timing-belt",
    "clutch",
    "battery-12v",
    "shock-absorbers",
    "wipers",
    "spark-plugs",
    "glow-plugs",
    "particulate-filter",
    "catalytic-converter",
    "fuel-cell-filter",
    "exhaust",
];

/// L'énergie d'un plein ou d'une recharge, et son unité.
#[derive(Debug, Clone, Copy, PartialEq, Eq, PartialOrd, Ord)]
pub enum Energy {
    Petrol,
    Diesel,
    Lpg,
    E85,
    Electricity,
    Hydrogen,
}

pub const ENERGIES: [Energy; 6] =
    [Energy::Petrol, Energy::Diesel, Energy::Lpg, Energy::E85, Energy::Electricity, Energy::Hydrogen];

impl Energy {
    pub fn key(self) -> &'static str {
        match self {
            Energy::Petrol => "petrol",
            Energy::Diesel => "diesel",
            Energy::Lpg => "lpg",
            Energy::E85 => "e85",
            Energy::Electricity => "electricity",
            Energy::Hydrogen => "hydrogen",
        }
    }

    pub fn from_key(key: &str) -> Option<Energy> {
        ENERGIES.into_iter().find(|energy| energy.key() == key)
    }

    /// La clef de l'unité : `car-unit-litre`, `car-unit-kwh`, `car-unit-kg`.
    pub fn unit(self) -> &'static str {
        match self {
            Energy::Electricity => "kwh",
            Energy::Hydrogen => "kg",
            _ => "litre",
        }
    }
}

/// Les huit rubriques du carnet.
#[derive(Debug, Clone, Copy, PartialEq, Eq, PartialOrd, Ord)]
pub enum Rubric {
    Energy,
    Upkeep,
    Service,
    Wear,
    Tyres,
    Breakdown,
    Insurance,
    Inspection,
}

pub const RUBRICS: [Rubric; 8] = [
    Rubric::Energy,
    Rubric::Upkeep,
    Rubric::Service,
    Rubric::Wear,
    Rubric::Tyres,
    Rubric::Breakdown,
    Rubric::Insurance,
    Rubric::Inspection,
];

impl Rubric {
    pub fn key(self) -> &'static str {
        match self {
            Rubric::Energy => "energy",
            Rubric::Upkeep => "upkeep",
            Rubric::Service => "service",
            Rubric::Wear => "wear",
            Rubric::Tyres => "tyres",
            Rubric::Breakdown => "breakdown",
            Rubric::Insurance => "insurance",
            Rubric::Inspection => "inspection",
        }
    }

    pub fn from_key(key: &str) -> Option<Rubric> {
        RUBRICS.into_iter().find(|rubric| rubric.key() == key)
    }

    fn rank(self) -> usize {
        RUBRICS.iter().position(|rubric| *rubric == self).unwrap_or(0)
    }

    /// Sa couleur, la même dans l'anneau, les barres et le tableau.
    pub fn colour(self) -> &'static str {
        match self {
            Rubric::Energy => loan_charts::NAVY,
            Rubric::Upkeep => loan_charts::SKY,
            Rubric::Service => loan_charts::GOLD,
            Rubric::Wear => loan_charts::SLATE,
            Rubric::Tyres => loan_charts::SAND,
            Rubric::Breakdown => loan_charts::RED,
            Rubric::Insurance => loan_charts::GREEN,
            Rubric::Inspection => loan_charts::ORANGE,
        }
    }
}

/// Une recharge à la maison : en option Base, ou à l'heure pleine ou creuse.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Slot {
    Base,
    Peak,
    OffPeak,
}

impl Slot {
    pub fn key(self) -> &'static str {
        match self {
            Slot::Base => "base",
            Slot::Peak => "peak",
            Slot::OffPeak => "off-peak",
        }
    }

    pub fn from_key(key: &str) -> Option<Slot> {
        [Slot::Base, Slot::Peak, Slot::OffPeak].into_iter().find(|slot| slot.key() == key)
    }

    /// Le prix du kWh à ce moment-là, au tarif de la voiture.
    pub fn price(self, tariff: &Tariff) -> i64 {
        match self {
            Slot::Base => tariff.base,
            Slot::Peak => tariff.peak,
            Slot::OffPeak => tariff.off_peak,
        }
    }
}

/// Les pneus changés : à l'avant, à l'arrière, ou les quatre.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Axle {
    Front,
    Rear,
    All,
}

impl Axle {
    pub fn key(self) -> &'static str {
        match self {
            Axle::Front => "front",
            Axle::Rear => "rear",
            Axle::All => "all",
        }
    }

    pub fn from_key(key: &str) -> Option<Axle> {
        [Axle::Front, Axle::Rear, Axle::All].into_iter().find(|axle| axle.key() == key)
    }
}

/// Le résultat d'un contrôle technique.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Verdict {
    Pass,
    Counter,
}

impl Verdict {
    pub fn key(self) -> &'static str {
        match self {
            Verdict::Pass => "pass",
            Verdict::Counter => "counter",
        }
    }

    pub fn from_key(key: &str) -> Option<Verdict> {
        [Verdict::Pass, Verdict::Counter].into_iter().find(|verdict| verdict.key() == key)
    }
}

/// Une pièce d'usure : l'une de la liste de départ, par sa clef — elle se lit
/// dans chaque langue —, ou l'une de celles que l'on a ajoutées, par son nom.
#[derive(Debug, Clone, PartialEq, Eq, PartialOrd, Ord)]
pub enum Piece {
    Known(String),
    Custom(String),
}

impl Piece {
    /// Ce que la liste des pièces envoie : `known:clef` ou `custom:nom`.
    pub fn value(&self) -> String {
        match self {
            Piece::Known(key) => format!("known:{key}"),
            Piece::Custom(name) => format!("custom:{name}"),
        }
    }

    pub fn from_value(value: &str) -> Option<Piece> {
        if let Some(key) = value.strip_prefix("known:") {
            return KNOWN_PARTS.contains(&key).then(|| Piece::Known(key.to_string()));
        }
        let name = value.strip_prefix("custom:")?.trim();
        (!name.is_empty()).then(|| Piece::Custom(name.to_string()))
    }

    pub fn label(&self, language: Language) -> String {
        match self {
            Piece::Known(key) => i18n::text(language, &format!("car-part-{key}")),
            Piece::Custom(name) => name.clone(),
        }
    }
}

// --- Le carnet --------------------------------------------------------------------

/// **La fiche de la voiture.**
#[derive(Debug, Clone, PartialEq)]
pub struct Car {
    pub plate: String,
    pub make: String,
    pub model: String,
    pub engine: Engine,
    pub first_hand: bool,
    /// La date de première mise en circulation.
    pub registered: Option<NaiveDate>,
    pub acquired: Option<NaiveDate>,
    pub acquired_km: Option<u32>,
    /// Le tarif des recharges à la maison, gardé dans le fichier.
    pub tariff: Tariff,
    /// Le rythme des révisions : en mois (0, aucun) et, s'il est donné, en km.
    pub service_months: u32,
    pub service_km: Option<u32>,
    /// Les pièces ajoutées à la liste de départ, par leur nom.
    pub parts: Vec<String>,
}

impl Car {
    pub fn new(tariff: Tariff) -> Car {
        Car {
            plate: String::new(),
            make: String::new(),
            model: String::new(),
            engine: Engine::Petrol,
            first_hand: false,
            registered: None,
            acquired: None,
            acquired_km: None,
            tariff,
            service_months: Engine::Petrol.service_months(),
            service_km: None,
            parts: Vec::new(),
        }
    }

    /// Les pièces qu'offre la liste : celles de la motorisation, celles
    /// ajoutées, et celles que des lignes portent déjà.
    pub fn pieces(&self, entries: &[Entry]) -> Vec<Piece> {
        let mut out: Vec<Piece> =
            self.engine.parts().iter().map(|key| Piece::Known((*key).to_string())).collect();
        for name in &self.parts {
            let piece = Piece::Custom(name.clone());
            if !out.contains(&piece) {
                out.push(piece);
            }
        }
        for piece in entries.iter().filter_map(|entry| entry.part.clone()) {
            if !out.contains(&piece) {
                out.push(piece);
            }
        }
        out
    }

    /// « Peugeot 208 », ou ce qui en est connu.
    pub fn name(&self) -> String {
        [self.make.trim(), self.model.trim()]
            .into_iter()
            .filter(|part| !part.is_empty())
            .collect::<Vec<_>>()
            .join(" ")
    }
}

/// **Une ligne du carnet.** Ce qui ne concerne pas sa rubrique reste vide.
#[derive(Debug, Clone, PartialEq)]
pub struct Entry {
    pub id: u32,
    pub date: NaiveDate,
    pub km: Option<u32>,
    pub rubric: Rubric,
    /// Le montant payé — ou, pour une recharge à la maison, calculé le jour
    /// où elle a été notée, et gardé tel quel.
    pub amount: i64,
    pub garage: String,
    pub note: String,
    pub energy: Option<Energy>,
    /// Litres, kWh ou kilos.
    pub quantity: Option<f64>,
    /// Une recharge à la maison, et à quelle heure.
    pub home: Option<Slot>,
    pub part: Option<Piece>,
    pub axle: Option<Axle>,
    pub verdict: Option<Verdict>,
    /// Combien de mois couvre une prime d'assurance.
    pub months: Option<u32>,
    /// L'état de santé de la batterie de traction, en pourcent.
    pub battery: Option<f64>,
}

/// **Le carnet** : la fiche, les lignes, et ce qui n'a pas été enregistré.
#[derive(Debug, Clone, PartialEq)]
pub struct Logbook {
    pub car: Car,
    pub entries: Vec<Entry>,
    next: u32,
    /// Vrai dès qu'une chose a changé depuis le dernier enregistrement ou la
    /// dernière ouverture : la porte demande alors avant d'oublier.
    pub unsaved: bool,
}

impl Logbook {
    pub fn new(tariff: Tariff) -> Logbook {
        Logbook { car: Car::new(tariff), entries: Vec::new(), next: 1, unsaved: false }
    }

    /// Une ligne par sa clef.
    pub fn entry(&self, id: u32) -> Option<&Entry> {
        self.entries.iter().find(|entry| entry.id == id)
    }

    fn sort(&mut self) {
        self.entries.sort_by_key(|entry| (entry.date, entry.km, entry.id));
    }

    /// **Ajoute une ligne, ou remplace celle qui porte la même clef.** Rend
    /// sa clef. Une pièce nouvelle rejoint la liste de la voiture.
    pub fn put(&mut self, id: Option<u32>, mut entry: Entry) -> u32 {
        if let Some(Piece::Custom(name)) = &entry.part {
            if !self.car.parts.contains(name) {
                self.car.parts.push(name.clone());
            }
        }
        let id = match id.filter(|id| self.entry(*id).is_some()) {
            Some(id) => {
                entry.id = id;
                if let Some(kept) = self.entries.iter_mut().find(|kept| kept.id == id) {
                    *kept = entry;
                }
                id
            }
            None => {
                entry.id = self.next;
                self.next += 1;
                self.entries.push(entry);
                self.next - 1
            }
        };
        self.sort();
        self.unsaved = true;
        id
    }

    pub fn remove(&mut self, id: u32) -> bool {
        let before = self.entries.len();
        self.entries.retain(|entry| entry.id != id);
        let removed = self.entries.len() != before;
        self.unsaved |= removed;
        removed
    }

    /// Pose une fiche lue. La liste des pièces ajoutées ne vient pas des
    /// champs : elle est gardée.
    pub fn set_car(&mut self, mut car: Car) {
        car.parts = std::mem::take(&mut self.car.parts);
        if car != self.car {
            self.unsaved = true;
        }
        self.car = car;
    }

    /// Le compteur le plus haut connu.
    pub fn current_km(&self) -> Option<u32> {
        self.entries.iter().filter_map(|entry| entry.km).chain(self.car.acquired_km).max()
    }
}

// --- La saisie ----------------------------------------------------------------------

/// Ce qui ne se lit pas : le champ, et la clef de la phrase.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Refusal {
    pub field: &'static str,
    pub key: &'static str,
}

fn refused<T>(field: &'static str, key: &'static str) -> Result<T, Refusal> {
    Err(Refusal { field, key })
}

/// Les champs de la fiche, tels que tapés.
#[derive(Debug, Clone, Default, PartialEq, Eq, serde::Serialize, serde::Deserialize)]
#[serde(default)]
pub struct CarFields {
    pub plate: String,
    pub make: String,
    pub model: String,
    pub engine: String,
    pub first_hand: bool,
    /// Les dates en ISO, comme les donne un champ de date.
    pub registered: String,
    pub acquired: String,
    pub acquired_km: String,
    pub service_months: String,
    pub service_km: String,
    pub tariff: appliance::TariffFields,
}

/// Les champs d'une ligne, tels que tapés.
#[derive(Debug, Clone, Default, PartialEq, Eq, serde::Serialize, serde::Deserialize)]
#[serde(default)]
pub struct EntryFields {
    pub date: String,
    pub km: String,
    pub rubric: String,
    pub amount: String,
    pub garage: String,
    pub note: String,
    pub energy: String,
    pub quantity: String,
    /// `station` ou `home`.
    pub charge: String,
    /// `peak` ou `off-peak`, pour une recharge à la maison en heures pleines
    /// / heures creuses.
    pub slot: String,
    /// `known:clef`, `custom:nom`, ou `other` avec le nom dans `part_name`.
    pub part: String,
    pub part_name: String,
    pub axle: String,
    pub verdict: String,
    pub months: String,
    pub battery: String,
}

/// Les compteurs vont jusqu'à deux millions de kilomètres.
pub const KM_LIMIT: u32 = 2_000_000;

fn day(text: &str) -> Option<NaiveDate> {
    NaiveDate::parse_from_str(text.trim(), "%Y-%m-%d").ok()
}

fn kilometres(text: &str, field: &'static str) -> Result<Option<u32>, Refusal> {
    if text.trim().is_empty() {
        return Ok(None);
    }
    match appliance::parse_number(text) {
        Some(value) if value >= 0.0 && value.fract() == 0.0 && value <= f64::from(KM_LIMIT) => Ok(Some(value as u32)),
        _ => refused(field, "car-invalid-km"),
    }
}

/// **Lit la fiche.** Les dates ne sont pas dans le futur ; une voiture ne
/// s'acquiert pas avant d'avoir roulé.
pub fn read_car(fields: &CarFields, today: NaiveDate) -> Result<Car, Refusal> {
    let engine = Engine::from_key(&fields.engine).unwrap_or(Engine::Petrol);
    let optional_day = |text: &str, field: &'static str| -> Result<Option<NaiveDate>, Refusal> {
        if text.trim().is_empty() {
            return Ok(None);
        }
        match day(text) {
            Some(date) if date <= today => Ok(Some(date)),
            _ => refused(field, "car-invalid-date"),
        }
    };
    let registered = optional_day(&fields.registered, "registered")?;
    let acquired = optional_day(&fields.acquired, "acquired")?;
    if let (Some(registered), Some(acquired)) = (registered, acquired) {
        if acquired < registered {
            return refused("acquired", "car-invalid-acquired");
        }
    }
    let acquired_km = kilometres(&fields.acquired_km, "acquired-km")?;
    let service_months = if fields.service_months.trim().is_empty() {
        0
    } else {
        match appliance::parse_number(&fields.service_months) {
            Some(value) if value >= 0.0 && value.fract() == 0.0 && value <= 120.0 => value as u32,
            _ => return refused("service-months", "car-invalid-months"),
        }
    };
    let service_km = kilometres(&fields.service_km, "service-km")?.filter(|km| *km > 0);
    let tariff = appliance::read_tariff(&fields.tariff).map_err(|refusal| match refusal {
        appliance::Refusal::Peak => Refusal { field: "tariff-peak", key: "appliance-invalid-price" },
        appliance::Refusal::OffPeak => Refusal { field: "tariff-off-peak", key: "appliance-invalid-price" },
        appliance::Refusal::OffPeakHours => {
            Refusal { field: "tariff-hours", key: "appliance-invalid-off-peak-hours" }
        }
        _ => Refusal { field: "tariff-base", key: "appliance-invalid-price" },
    })?;
    Ok(Car {
        plate: fields.plate.trim().to_string(),
        make: fields.make.trim().to_string(),
        model: fields.model.trim().to_string(),
        engine,
        first_hand: fields.first_hand,
        registered,
        acquired,
        acquired_km,
        tariff,
        service_months,
        service_km,
        parts: Vec::new(),
    })
}

/// La fiche écrite dans ses champs.
pub fn car_fields(car: &Car, language: Language) -> CarFields {
    let iso = |date: Option<NaiveDate>| date.map(|date| date.to_string()).unwrap_or_default();
    CarFields {
        plate: car.plate.clone(),
        make: car.make.clone(),
        model: car.model.clone(),
        engine: car.engine.key().to_string(),
        first_hand: car.first_hand,
        registered: iso(car.registered),
        acquired: iso(car.acquired),
        acquired_km: car.acquired_km.map(|km| km.to_string()).unwrap_or_default(),
        service_months: if car.service_months == 0 { String::new() } else { car.service_months.to_string() },
        service_km: car.service_km.map(|km| km.to_string()).unwrap_or_default(),
        tariff: appliance::tariff_fields(&car.tariff, language),
    }
}

fn amount_of(text: &str) -> Result<i64, Refusal> {
    match money::parse_or_zero(text) {
        Ok(value) if value >= 0 => Ok(value),
        _ => refused("amount", "car-invalid-amount"),
    }
}

/// **Lit une ligne.** Chaque rubrique exige ce qui la fait compter : la
/// quantité d'un plein, la pièce changée, les pneus, le résultat d'un
/// contrôle, les mois couverts par une prime.
pub fn read_entry(fields: &EntryFields, car: &Car, today: NaiveDate) -> Result<Entry, Refusal> {
    let date = match day(&fields.date) {
        Some(date) if date <= today => date,
        _ => return refused("date", "car-invalid-date"),
    };
    let km = kilometres(&fields.km, "km")?;
    let Some(rubric) = Rubric::from_key(&fields.rubric) else {
        return refused("rubric", "car-invalid-rubric");
    };
    let mut entry = Entry {
        id: 0,
        date,
        km,
        rubric,
        amount: 0,
        garage: fields.garage.trim().to_string(),
        note: fields.note.trim().to_string(),
        energy: None,
        quantity: None,
        home: None,
        part: None,
        axle: None,
        verdict: None,
        months: None,
        battery: None,
    };
    match rubric {
        Rubric::Energy => {
            let energies = car.engine.energies();
            let energy = Energy::from_key(&fields.energy)
                .filter(|energy| energies.contains(energy))
                .unwrap_or(energies[0]);
            let quantity = match appliance::parse_number(&fields.quantity) {
                Some(value) if value > 0.0 && value <= 10_000.0 => value,
                _ => return refused("quantity", "car-invalid-quantity"),
            };
            entry.energy = Some(energy);
            entry.quantity = Some(quantity);
            if energy == Energy::Electricity && fields.charge == "home" {
                let slot = if !car.tariff.off_peak_option {
                    Slot::Base
                } else if fields.slot == "peak" {
                    Slot::Peak
                } else {
                    Slot::OffPeak
                };
                entry.home = Some(slot);
                entry.amount = (quantity * slot.price(&car.tariff) as f64).round() as i64;
            } else {
                entry.amount = amount_of(&fields.amount)?;
            }
        }
        _ => entry.amount = amount_of(&fields.amount)?,
    }
    match rubric {
        Rubric::Wear => {
            let piece = if fields.part == "other" {
                let name = fields.part_name.trim();
                if name.is_empty() {
                    return refused("part-name", "car-invalid-part");
                }
                // Un nom qui est celui d'une pièce de la liste la désigne.
                KNOWN_PARTS
                    .iter()
                    .find(|key| {
                        Language::all()
                            .into_iter()
                            .any(|language| i18n::text(language, &format!("car-part-{key}")).eq_ignore_ascii_case(name))
                    })
                    .map(|key| Piece::Known((*key).to_string()))
                    .unwrap_or_else(|| Piece::Custom(name.to_string()))
            } else {
                match Piece::from_value(&fields.part) {
                    Some(piece) => piece,
                    None => return refused("part", "car-invalid-part"),
                }
            };
            entry.part = Some(piece);
        }
        Rubric::Tyres => entry.axle = Some(Axle::from_key(&fields.axle).unwrap_or(Axle::All)),
        Rubric::Inspection => entry.verdict = Some(Verdict::from_key(&fields.verdict).unwrap_or(Verdict::Pass)),
        Rubric::Insurance => {
            entry.months = Some(if fields.months.trim().is_empty() {
                12
            } else {
                match appliance::parse_number(&fields.months) {
                    Some(value) if value >= 1.0 && value.fract() == 0.0 && value <= 36.0 => value as u32,
                    _ => return refused("months", "car-invalid-months"),
                }
            });
        }
        _ => {}
    }
    if car.engine.battery() && !fields.battery.trim().is_empty() {
        match appliance::parse_number(&fields.battery) {
            Some(value) if (0.0..=100.0).contains(&value) => entry.battery = Some(value),
            _ => return refused("battery", "car-invalid-battery"),
        }
    }
    Ok(entry)
}

/// Une ligne écrite dans ses champs, pour qu'on la reprenne.
pub fn entry_fields(entry: &Entry, language: Language) -> EntryFields {
    let number = |value: f64| appliance::decimal(value, if value.fract() == 0.0 { 0 } else { 2 }, language)
        .replace(money::separators(language).0, "");
    EntryFields {
        date: entry.date.to_string(),
        km: entry.km.map(|km| km.to_string()).unwrap_or_default(),
        rubric: entry.rubric.key().to_string(),
        amount: money::format_plain(entry.amount, language),
        garage: entry.garage.clone(),
        note: entry.note.clone(),
        energy: entry.energy.map(|energy| energy.key().to_string()).unwrap_or_default(),
        quantity: entry.quantity.map(number).unwrap_or_default(),
        charge: if entry.home.is_some() { "home" } else { "station" }.to_string(),
        slot: entry.home.map(|slot| slot.key().to_string()).unwrap_or_default(),
        part: entry.part.as_ref().map(Piece::value).unwrap_or_default(),
        part_name: String::new(),
        axle: entry.axle.map(|axle| axle.key().to_string()).unwrap_or_default(),
        verdict: entry.verdict.map(|verdict| verdict.key().to_string()).unwrap_or_default(),
        months: entry.months.map(|months| months.to_string()).unwrap_or_default(),
        battery: entry.battery.map(number).unwrap_or_default(),
    }
}

// --- Les comptes --------------------------------------------------------------------

/// Le point de départ : la date et le compteur de l'acquisition, ou à défaut
/// la première ligne. Une voiture de première main part de zéro.
fn start(book: &Logbook, today: NaiveDate) -> (NaiveDate, Option<u32>) {
    let first_day = book.entries.first().map(|entry| entry.date);
    let date = book.car.acquired.or(first_day).or(book.car.registered).unwrap_or(today);
    let km = book.car.acquired_km.or_else(|| {
        if book.car.first_hand {
            Some(0)
        } else {
            book.entries.iter().filter_map(|entry| entry.km).min()
        }
    });
    (date, km)
}

/// Les mois écoulés, au jour près : trente jours et demi font un mois.
fn months_between(from: NaiveDate, to: NaiveDate) -> f64 {
    ((to - from).num_days().max(0) as f64 / 30.4375).max(0.0)
}

/// La consommation d'une énergie, et ce qu'elle a coûté.
#[derive(Debug, Clone, PartialEq)]
pub struct EnergyUse {
    pub energy: Energy,
    pub quantity: f64,
    pub amount: i64,
    pub fills: usize,
    /// Aux cent kilomètres, quand deux pleins avec compteur l'encadrent.
    pub per_100: Option<f64>,
    /// Le coût au kilomètre, sur les mêmes pleins, en micro-unités.
    pub per_km: Option<f64>,
}

/// **De plein à plein.** Pour une énergie seule — ou deux à la fois, comme
/// une hybride rechargeable qui brûle et décharge sur les mêmes kilomètres —,
/// la quantité des pleins qui suivent le premier compté, sur l'écart de
/// compteur entre le premier et le dernier.
fn series(entries: &[&Entry], energy: Energy) -> (Option<f64>, Option<f64>) {
    let fills: Vec<&&Entry> = entries.iter().filter(|entry| entry.energy == Some(energy)).collect();
    let Some(first) = fills.iter().position(|entry| entry.km.is_some()) else {
        return (None, None);
    };
    let Some(last) = fills.iter().rposition(|entry| entry.km.is_some()) else {
        return (None, None);
    };
    let span = match (fills[first].km, fills[last].km) {
        (Some(a), Some(b)) if b > a => f64::from(b - a),
        _ => return (None, None),
    };
    let quantity: f64 = fills[first + 1..=last].iter().filter_map(|entry| entry.quantity).sum();
    let amount: i64 = fills[first + 1..=last].iter().map(|entry| entry.amount).sum();
    (Some(quantity / span * 100.0), Some(amount as f64 / span))
}

/// **Une voiture E85 boit ce qu'on lui donne** : chaque plein remplit ce que
/// le plein d'avant a fait rouler. L'écart de compteur et la quantité vont
/// donc au carburant du plein d'avant.
fn alternating(entries: &[&Entry], energy: Energy) -> (Option<f64>, Option<f64>) {
    let fills: Vec<&&Entry> = entries.iter().filter(|entry| entry.km.is_some()).collect();
    let (mut span, mut quantity, mut amount) = (0.0, 0.0, 0_i64);
    for pair in fills.windows(2) {
        let (before, after) = (pair[0], pair[1]);
        if before.energy != Some(energy) {
            continue;
        }
        if let (Some(a), Some(b), Some(q)) = (before.km, after.km, after.quantity) {
            if b > a {
                span += f64::from(b - a);
                quantity += q;
                // Ce qu'a coûté le carburant brûlé : la quantité au prix du
                // plein d'avant.
                let price = match before.quantity {
                    Some(bought) if bought > 0.0 => before.amount as f64 / bought,
                    _ => 0.0,
                };
                amount += (q * price).round() as i64;
            }
        }
    }
    if span <= 0.0 {
        return (None, None);
    }
    (Some(quantity / span * 100.0), Some(amount as f64 / span))
}

/// L'énergie, rubrique par énergie.
pub fn energy_uses(book: &Logbook) -> Vec<EnergyUse> {
    let fills: Vec<&Entry> = book.entries.iter().filter(|entry| entry.rubric == Rubric::Energy).collect();
    let mut out = Vec::new();
    for energy in ENERGIES {
        let own: Vec<&&Entry> = fills.iter().filter(|entry| entry.energy == Some(energy)).collect();
        if own.is_empty() {
            continue;
        }
        let (per_100, per_km) = if book.car.engine == Engine::E85 && energy != Energy::Electricity {
            let liquids: Vec<&Entry> = fills.iter().copied().filter(|entry| entry.energy != Some(Energy::Electricity)).collect();
            alternating(&liquids, energy)
        } else {
            series(&fills, energy)
        };
        out.push(EnergyUse {
            energy,
            quantity: own.iter().filter_map(|entry| entry.quantity).sum(),
            amount: own.iter().map(|entry| entry.amount).sum(),
            fills: own.len(),
            per_100,
            per_km,
        });
    }
    out
}

/// Ce qu'une pièce ou un train de pneus a duré.
#[derive(Debug, Clone, PartialEq)]
pub struct Life {
    pub name: String,
    pub changes: usize,
    pub amount: i64,
    pub last_date: NaiveDate,
    pub last_km: Option<u32>,
    /// La durée moyenne entre deux changements, en km.
    pub life: Option<u32>,
    /// Le compteur du prochain changement.
    pub next_km: Option<u32>,
}

/// **Les vies successives d'une pièce** : l'écart de compteur entre deux
/// changements — et, en première main, de zéro au premier.
fn life_of(name: String, changes: &[&Entry], first_hand: bool) -> Option<Life> {
    let last = changes.last()?;
    let counted: Vec<u32> = changes.iter().filter_map(|entry| entry.km).collect();
    let mut lives: Vec<u32> = counted.windows(2).filter(|pair| pair[1] > pair[0]).map(|pair| pair[1] - pair[0]).collect();
    if first_hand {
        if let Some(first) = counted.first().filter(|km| **km > 0) {
            lives.insert(0, *first);
        }
    }
    let life = (!lives.is_empty()).then(|| (lives.iter().map(|km| u64::from(*km)).sum::<u64>() / lives.len() as u64) as u32);
    Some(Life {
        name,
        changes: changes.len(),
        amount: changes.iter().map(|entry| entry.amount).sum(),
        last_date: last.date,
        last_km: last.km,
        life,
        next_km: match (counted.last(), life) {
            (Some(km), Some(life)) => Some(km + life),
            _ => None,
        },
    })
}

/// Les pièces d'usure, une par une, dans l'ordre de la liste.
pub fn part_lives(book: &Logbook, language: Language) -> Vec<Life> {
    book.car
        .pieces(&book.entries)
        .into_iter()
        .filter_map(|piece| {
            let changes: Vec<&Entry> =
                book.entries.iter().filter(|entry| entry.rubric == Rubric::Wear && entry.part.as_ref() == Some(&piece)).collect();
            life_of(piece.label(language), &changes, book.car.first_hand)
        })
        .collect()
}

/// Les pneus : l'avant et l'arrière, chacun avec les changements des quatre.
/// Quand on n'a jamais changé que les quatre ensemble, une seule ligne.
pub fn tyre_lives(book: &Logbook, language: Language) -> Vec<Life> {
    let tyres: Vec<&Entry> = book.entries.iter().filter(|entry| entry.rubric == Rubric::Tyres).collect();
    if tyres.is_empty() {
        return Vec::new();
    }
    if tyres.iter().all(|entry| entry.axle == Some(Axle::All)) {
        return life_of(i18n::text(language, "car-axle-all"), &tyres, book.car.first_hand).into_iter().collect();
    }
    [Axle::Front, Axle::Rear]
        .into_iter()
        .filter_map(|axle| {
            let changes: Vec<&Entry> =
                tyres.iter().copied().filter(|entry| entry.axle == Some(axle) || entry.axle == Some(Axle::All)).collect();
            life_of(i18n::text(language, &format!("car-axle-{}", axle.key())), &changes, book.car.first_hand)
        })
        .collect()
}

/// **Les chiffres du carnet.**
#[derive(Debug, Clone, PartialEq)]
pub struct Summary {
    pub since: NaiveDate,
    pub start_km: Option<u32>,
    pub current_km: Option<u32>,
    /// Les kilomètres parcourus depuis le départ.
    pub driven: Option<u32>,
    pub total: i64,
    pub by_rubric: [i64; 8],
    pub months: f64,
    pub per_month: Option<i64>,
    /// Le coût au kilomètre, en micro-unités, décimales comprises.
    pub per_km: Option<f64>,
    /// Les kilomètres par jour, pour situer une échéance en km.
    pub km_per_day: Option<f64>,
    pub breakdowns: usize,
}

pub fn summary(book: &Logbook, today: NaiveDate) -> Summary {
    let (since, start_km) = start(book, today);
    let current_km = book.current_km().or(start_km);
    let driven = match (start_km, current_km) {
        (Some(a), Some(b)) if b > a => Some(b - a),
        _ => None,
    };
    let mut by_rubric = [0_i64; 8];
    for entry in &book.entries {
        by_rubric[entry.rubric.rank()] += entry.amount;
    }
    let total: i64 = by_rubric.iter().sum();
    let months = months_between(since, today);
    // Les kilomètres par jour se lisent sur ce que le compteur a noté : du
    // départ à la dernière ligne qui porte un compteur.
    let last_counted = book.entries.iter().filter(|entry| entry.km.is_some()).map(|entry| entry.date).max();
    let km_per_day = match (driven, last_counted) {
        (Some(driven), Some(last)) if (last - since).num_days() >= 30 => {
            Some(f64::from(driven) / (last - since).num_days() as f64)
        }
        _ => None,
    };
    Summary {
        since,
        start_km,
        current_km,
        driven,
        total,
        by_rubric,
        months,
        per_month: (months >= 1.0 && total > 0).then(|| (total as f64 / months).round() as i64),
        per_km: driven.filter(|_| total > 0).map(|driven| total as f64 / f64::from(driven)),
        km_per_day,
        breakdowns: book.entries.iter().filter(|entry| entry.rubric == Rubric::Breakdown).count(),
    }
}

/// Les dépenses par année civile, rubrique par rubrique.
pub fn by_year(book: &Logbook) -> BTreeMap<i32, [i64; 8]> {
    let mut out: BTreeMap<i32, [i64; 8]> = BTreeMap::new();
    for entry in &book.entries {
        out.entry(entry.date.year()).or_default()[entry.rubric.rank()] += entry.amount;
    }
    out
}

// --- Les échéances --------------------------------------------------------------------

/// Où en est une échéance.
#[derive(Debug, Clone, Copy, PartialEq, Eq, PartialOrd, Ord)]
pub enum Tone {
    /// Dépassée.
    Late,
    /// Dans les deux mois, ou les mille kilomètres.
    Soon,
    Later,
    /// On ne peut pas la dater.
    Unknown,
}

impl Tone {
    pub fn key(self) -> &'static str {
        match self {
            Tone::Late => "late",
            Tone::Soon => "soon",
            Tone::Later => "later",
            Tone::Unknown => "unknown",
        }
    }
}

/// Une échéance : quoi, quand en date et en km, et la date où l'on
/// l'attend — la plus proche des deux.
#[derive(Debug, Clone, PartialEq)]
pub struct Deadline {
    pub what: DeadlineKind,
    pub date: Option<NaiveDate>,
    pub km: Option<u32>,
    /// La date où le rythme du compteur l'amène, pour une échéance en km.
    pub reached: Option<NaiveDate>,
    pub tone: Tone,
}

#[derive(Debug, Clone, PartialEq)]
pub enum DeadlineKind {
    Service,
    Inspection { counter: bool },
    /// Aucun contrôle noté, et le premier est déjà passé.
    InspectionUnknown,
    Insurance,
    Part(String),
    Tyres(String),
}

const SOON_DAYS: i64 = 61;
const SOON_KM: u32 = 1_000;

fn add_months(day: NaiveDate, months: u32) -> NaiveDate {
    day.checked_add_months(Months::new(months)).unwrap_or(day)
}

fn deadline(
    what: DeadlineKind,
    date: Option<NaiveDate>,
    km: Option<u32>,
    current_km: Option<u32>,
    km_per_day: Option<f64>,
    today: NaiveDate,
) -> Deadline {
    let reached = match (km, current_km, km_per_day) {
        (Some(km), Some(current), Some(rate)) if rate > 0.0 && km > current => {
            Some(today + time_compute::Duration::days((f64::from(km - current) / rate).round() as i64))
        }
        (Some(km), Some(current), _) if km <= current => Some(today),
        _ => None,
    };
    let late = date.is_some_and(|date| date < today) || matches!((km, current_km), (Some(km), Some(current)) if current >= km);
    let soon = date.is_some_and(|date| (date - today).num_days() <= SOON_DAYS)
        || matches!((km, current_km), (Some(km), Some(current)) if km - current.min(km) <= SOON_KM)
        || reached.is_some_and(|reached| (reached - today).num_days() <= SOON_DAYS);
    let tone = if late {
        Tone::Late
    } else if soon {
        Tone::Soon
    } else if date.is_none() && km.is_none() {
        Tone::Unknown
    } else {
        Tone::Later
    };
    Deadline { what, date, km, reached, tone }
}

/// **Les échéances**, les dépassées d'abord, puis par date.
pub fn deadlines(book: &Logbook, today: NaiveDate, language: Language) -> Vec<Deadline> {
    let summary = summary(book, today);
    let (current, rate) = (summary.current_km, summary.km_per_day);
    let last = |rubric: Rubric| book.entries.iter().rev().find(|entry| entry.rubric == rubric);
    let mut out = Vec::new();

    // La révision : depuis la dernière, ou depuis le départ.
    if book.car.service_months > 0 || book.car.service_km.is_some() {
        let (from_date, from_km) = match last(Rubric::Service) {
            Some(entry) => (Some(entry.date), entry.km),
            None => match (book.car.acquired, book.car.first_hand, book.car.registered) {
                (_, true, Some(registered)) => (Some(registered), Some(0)),
                (Some(acquired), _, _) => (Some(acquired), book.car.acquired_km),
                _ => (None, None),
            },
        };
        if let Some(from_date) = from_date {
            let date = (book.car.service_months > 0).then(|| add_months(from_date, book.car.service_months));
            let km = match (from_km, book.car.service_km) {
                (Some(from), Some(every)) => Some(from + every),
                _ => None,
            };
            out.push(deadline(DeadlineKind::Service, date, km, current, rate, today));
        }
    }

    // Le contrôle technique, à la française.
    match last(Rubric::Inspection) {
        Some(entry) => {
            let counter = entry.verdict == Some(Verdict::Counter);
            let date = add_months(entry.date, if counter { 2 } else { 24 });
            out.push(deadline(DeadlineKind::Inspection { counter }, Some(date), None, current, rate, today));
        }
        None => {
            if let Some(registered) = book.car.registered {
                let first = add_months(registered, 48);
                if first >= today {
                    out.push(deadline(DeadlineKind::Inspection { counter: false }, Some(first), None, current, rate, today));
                } else {
                    out.push(Deadline {
                        what: DeadlineKind::InspectionUnknown,
                        date: None,
                        km: None,
                        reached: None,
                        tone: Tone::Unknown,
                    });
                }
            }
        }
    }

    // L'assurance : la fin de la dernière prime.
    if let Some(entry) = last(Rubric::Insurance) {
        let date = add_months(entry.date, entry.months.unwrap_or(12));
        out.push(deadline(DeadlineKind::Insurance, Some(date), None, current, rate, today));
    }

    // Les pièces et les pneus, d'après leur vie réelle.
    for life in part_lives(book, language) {
        if life.next_km.is_some() {
            out.push(deadline(DeadlineKind::Part(life.name), None, life.next_km, current, rate, today));
        }
    }
    for life in tyre_lives(book, language) {
        if life.next_km.is_some() {
            out.push(deadline(DeadlineKind::Tyres(life.name), None, life.next_km, current, rate, today));
        }
    }

    out.sort_by_key(|deadline| (deadline.tone, deadline.date.or(deadline.reached)));
    out
}

// --- L'écriture -----------------------------------------------------------------------

/// Un choix d'une liste : sa valeur et son nom.
#[derive(Debug, Clone, PartialEq, Eq, serde::Serialize)]
pub struct Choice {
    pub key: String,
    pub label: String,
}

/// **Les listes de la fenêtre**, qui suivent la motorisation.
#[derive(Debug, Clone, PartialEq, Eq, serde::Serialize)]
pub struct Choices {
    pub engines: Vec<Choice>,
    pub rubrics: Vec<Choice>,
    /// Les énergies de la motorisation ; `unit` est le nom de leur unité.
    pub energies: Vec<EnergyChoice>,
    pub parts: Vec<Choice>,
    pub axles: Vec<Choice>,
    pub verdicts: Vec<Choice>,
    pub charges: Vec<Choice>,
    pub slots: Vec<Choice>,
    pub rechargeable: bool,
    pub battery: bool,
    pub off_peak: bool,
    pub sign: String,
    pub price_unit: String,
}

#[derive(Debug, Clone, PartialEq, Eq, serde::Serialize)]
pub struct EnergyChoice {
    pub key: String,
    pub label: String,
    pub unit: String,
}

fn choice(key: &str, label: String) -> Choice {
    Choice { key: key.to_string(), label }
}

pub fn choices(book: &Logbook, language: Language) -> Choices {
    let text = |key: &str| i18n::text(language, key);
    let engine = book.car.engine;
    let sign = money::sign();
    Choices {
        engines: ENGINES.iter().map(|engine| choice(engine.key(), text(&format!("car-engine-{}", engine.key())))).collect(),
        rubrics: RUBRICS.iter().map(|rubric| choice(rubric.key(), text(&format!("car-rubric-{}", rubric.key())))).collect(),
        energies: engine
            .energies()
            .iter()
            .map(|energy| EnergyChoice {
                key: energy.key().to_string(),
                label: text(&format!("car-energy-{}", energy.key())),
                unit: text(&format!("car-unit-{}", energy.unit())),
            })
            .collect(),
        parts: book
            .car
            .pieces(&book.entries)
            .iter()
            .map(|piece| choice(&piece.value(), piece.label(language)))
            .chain(std::iter::once(choice("other", text("car-part-other"))))
            .collect(),
        axles: [Axle::All, Axle::Front, Axle::Rear]
            .iter()
            .map(|axle| choice(axle.key(), text(&format!("car-axle-{}", axle.key()))))
            .collect(),
        verdicts: [Verdict::Pass, Verdict::Counter]
            .iter()
            .map(|verdict| choice(verdict.key(), text(&format!("car-verdict-{}", verdict.key()))))
            .collect(),
        charges: ["station", "home"].iter().map(|key| choice(key, text(&format!("car-charge-{key}")))).collect(),
        slots: [Slot::OffPeak, Slot::Peak]
            .iter()
            .map(|slot| choice(slot.key(), text(&format!("car-slot-{}", slot.key()))))
            .collect(),
        rechargeable: engine.rechargeable(),
        battery: engine.battery(),
        off_peak: book.car.tariff.off_peak_option,
        price_unit: i18n::message_of(language, "appliance-unit-price", &[("sign", &sign)], &[]),
        sign,
    }
}

/// Une date comme ailleurs dans Radinus.
pub fn date_text(day: NaiveDate) -> String {
    day.format("%d/%m/%Y").to_string()
}

/// « 85 000 km ».
pub fn km_text(km: u32, language: Language) -> String {
    i18n::message_of(language, "car-km", &[("value", &appliance::decimal(f64::from(km), 0, language))], &[])
}

/// Un prix fin — au litre, au kilomètre — avec trois décimales.
pub fn fine(micro: f64, language: Language) -> String {
    let value = appliance::decimal(micro / money::UNIT as f64, 3, language);
    let sign = money::sign();
    if money::sign_comes_first(language) {
        format!("{sign}{value}")
    } else {
        format!("{value} {sign}")
    }
}

fn number(value: f64, language: Language) -> String {
    appliance::decimal(value, if value.fract() == 0.0 { 0 } else if value >= 100.0 { 1 } else { 2 }, language)
}

fn quantity_text(quantity: f64, energy: Energy, language: Language) -> String {
    i18n::message_of(
        language,
        "car-quantity",
        &[("value", &number(quantity, language)), ("unit", &i18n::text(language, &format!("car-unit-{}", energy.unit())))],
        &[],
    )
}

/// Ce qu'une ligne a de particulier, en quelques mots.
pub fn detail(entry: &Entry, language: Language) -> String {
    let text = |key: &str| i18n::text(language, key);
    let mut parts = Vec::new();
    if let (Some(energy), Some(quantity)) = (entry.energy, entry.quantity) {
        parts.push(text(&format!("car-energy-{}", energy.key())));
        parts.push(quantity_text(quantity, energy, language));
        if let Some(slot) = entry.home {
            parts.push(text("car-charge-home"));
            if slot != Slot::Base {
                parts.push(text(&format!("car-slot-{}", slot.key())));
            }
        }
    }
    if let Some(piece) = &entry.part {
        parts.push(piece.label(language));
    }
    if let Some(axle) = entry.axle {
        parts.push(text(&format!("car-axle-{}", axle.key())));
    }
    if let Some(verdict) = entry.verdict {
        parts.push(text(&format!("car-verdict-{}", verdict.key())));
    }
    if let Some(months) = entry.months {
        parts.push(i18n::message_of(language, "car-months", &[], &[("months", i64::from(months))]));
    }
    if let Some(battery) = entry.battery {
        parts.push(i18n::message_of(language, "car-detail-battery", &[("value", &number(battery, language))], &[]));
    }
    parts.join(" · ")
}

/// Une ligne de l'historique, écrite — et ses champs, pour la reprendre.
#[derive(Debug, Clone, PartialEq, Eq, serde::Serialize)]
pub struct Row {
    pub id: u32,
    pub date: String,
    pub km: String,
    pub rubric: String,
    pub rubric_key: String,
    pub colour: String,
    pub detail: String,
    pub amount: String,
    pub garage: String,
    pub note: String,
    pub fields: EntryFields,
}

#[derive(Debug, Clone, PartialEq, Eq, serde::Serialize)]
pub struct Tile {
    pub label: String,
    pub value: String,
}

/// Une rubrique dans le tableau de la synthèse.
#[derive(Debug, Clone, PartialEq, Eq, serde::Serialize)]
pub struct RubricLine {
    pub key: String,
    pub label: String,
    pub amount: String,
    pub share: String,
    pub per_km: String,
    pub colour: String,
}

#[derive(Debug, Clone, PartialEq, Eq, serde::Serialize)]
pub struct EnergyLine {
    pub label: String,
    pub quantity: String,
    pub amount: String,
    pub price: String,
    pub consumption: String,
    pub per_km: String,
}

#[derive(Debug, Clone, PartialEq, Eq, serde::Serialize)]
pub struct LifeLine {
    pub name: String,
    pub changes: String,
    pub amount: String,
    pub last: String,
    pub life: String,
    pub next: String,
}

#[derive(Debug, Clone, PartialEq, Eq, serde::Serialize)]
pub struct DeadlineLine {
    pub label: String,
    pub when: String,
    pub tone: String,
    pub badge: String,
}

/// **Tout ce que la fenêtre affiche, déjà écrit.**
#[derive(Debug, Clone, PartialEq, Eq, serde::Serialize)]
pub struct Written {
    pub title: String,
    pub headline: String,
    pub tiles: Vec<Tile>,
    pub rubrics: Vec<RubricLine>,
    pub total: String,
    pub energy: Vec<EnergyLine>,
    pub parts: Vec<LifeLine>,
    pub tyres: Vec<LifeLine>,
    pub battery: Vec<String>,
    pub deadlines: Vec<DeadlineLine>,
    pub deadlines_empty: String,
    pub rows: Vec<Row>,
    pub years: String,
    pub donut: String,
    pub notes: Vec<String>,
}

const NONE: &str = "—";

fn share(part: i64, whole: i64, language: Language) -> String {
    if whole <= 0 || part <= 0 {
        return String::new();
    }
    let value = (part as f64 / whole as f64 * 100.0).round();
    i18n::message_of(language, "loan-percent", &[("value", &format!("{value:.0}"))], &[])
}

/// Le titre : « Peugeot 208 · AB-123-CD », ou ce qui en est connu.
pub fn title(car: &Car, language: Language) -> String {
    let name = car.name();
    match (name.is_empty(), car.plate.is_empty()) {
        (true, true) => i18n::text(language, "car-unnamed"),
        (false, true) => name,
        (true, false) => car.plate.clone(),
        (false, false) => format!("{name} · {}", car.plate),
    }
}

fn life_line(life: &Life, language: Language) -> LifeLine {
    let km = |km: Option<u32>| km.map(|km| km_text(km, language));
    LifeLine {
        name: life.name.clone(),
        changes: life.changes.to_string(),
        amount: money::format(life.amount, language),
        last: [Some(date_text(life.last_date)), km(life.last_km)].into_iter().flatten().collect::<Vec<_>>().join(" · "),
        life: km(life.life).unwrap_or_else(|| NONE.to_string()),
        next: km(life.next_km).unwrap_or_else(|| NONE.to_string()),
    }
}

fn deadline_line(deadline: &Deadline, language: Language) -> DeadlineLine {
    let text = |key: &str| i18n::text(language, key);
    let label = match &deadline.what {
        DeadlineKind::Service => text("car-deadline-service"),
        DeadlineKind::Inspection { counter: false } | DeadlineKind::InspectionUnknown => text("car-deadline-inspection"),
        DeadlineKind::Inspection { counter: true } => text("car-deadline-counter"),
        DeadlineKind::Insurance => text("car-deadline-insurance"),
        DeadlineKind::Part(name) | DeadlineKind::Tyres(name) => name.clone(),
    };
    let date = deadline.date.map(date_text).unwrap_or_default();
    let km = deadline.km.map(|km| km_text(km, language)).unwrap_or_default();
    let when = match (&deadline.what, deadline.date, deadline.km, deadline.reached) {
        (DeadlineKind::InspectionUnknown, ..) => text("car-when-inspection-unknown"),
        (_, Some(_), Some(_), _) => i18n::message_of(language, "car-when-date-km", &[("date", &date), ("km", &km)], &[]),
        (_, Some(_), None, _) => i18n::message_of(language, "car-when-date", &[("date", &date)], &[]),
        (_, None, Some(_), Some(reached)) => i18n::message_of(
            language,
            "car-when-km-reached",
            &[("km", &km), ("month", &i18n::month_and_year(language, reached))],
            &[],
        ),
        (_, None, Some(_), None) => i18n::message_of(language, "car-when-km", &[("km", &km)], &[]),
        _ => String::new(),
    };
    DeadlineLine {
        label,
        when,
        tone: deadline.tone.key().to_string(),
        badge: match deadline.tone {
            Tone::Late | Tone::Soon => text(&format!("car-tone-{}", deadline.tone.key())),
            _ => String::new(),
        },
    }
}

/// **Écrit le carnet.**
pub fn write(book: &Logbook, today: NaiveDate, language: Language) -> Written {
    let text = |key: &str| i18n::text(language, key);
    let amount = |value: i64| money::format(value, language);
    let summary = summary(book, today);
    let uses = energy_uses(book);

    let headline = if book.entries.is_empty() {
        text("car-headline-empty")
    } else {
        let since = i18n::month_and_year(language, summary.since);
        match (summary.driven, summary.per_km) {
            (Some(driven), Some(per_km)) => i18n::message_of(
                language,
                "car-headline-km",
                &[
                    ("since", &since),
                    ("total", &amount(summary.total)),
                    ("km", &km_text(driven, language)),
                    ("cost", &fine(per_km, language)),
                ],
                &[],
            ),
            _ => i18n::message_of(language, "car-headline", &[("since", &since), ("total", &amount(summary.total))], &[]),
        }
    };

    // La consommation montrée en tuile : celle de l'énergie principale de la
    // motorisation, la première de sa liste qui se mesure.
    let main = book
        .car
        .engine
        .energies()
        .iter()
        .find_map(|energy| uses.iter().find(|used| used.energy == *energy && used.per_100.is_some()));
    let energy_per_km: Option<f64> = {
        let measured: Vec<f64> = uses.iter().filter_map(|used| used.per_km).collect();
        (!measured.is_empty()).then(|| measured.iter().sum())
    };
    let tiles = vec![
        Tile { label: text("car-tile-total"), value: amount(summary.total) },
        Tile { label: text("car-tile-month"), value: summary.per_month.map_or_else(|| NONE.to_string(), amount) },
        Tile { label: text("car-tile-km"), value: summary.per_km.map_or_else(|| NONE.to_string(), |value| fine(value, language)) },
        Tile {
            label: text("car-tile-driven"),
            value: summary.driven.map_or_else(|| NONE.to_string(), |km| km_text(km, language)),
        },
        Tile {
            label: text("car-tile-consumption"),
            value: main.map_or_else(
                || NONE.to_string(),
                |used| {
                    i18n::message_of(
                        language,
                        "car-per-100",
                        &[
                            ("value", &appliance::decimal(used.per_100.unwrap_or(0.0), 1, language)),
                            ("unit", &text(&format!("car-unit-{}", used.energy.unit()))),
                        ],
                        &[],
                    )
                },
            ),
        },
        Tile {
            label: text("car-tile-energy-km"),
            value: energy_per_km.map_or_else(|| NONE.to_string(), |value| fine(value, language)),
        },
    ];

    let rubrics: Vec<RubricLine> = RUBRICS
        .iter()
        .map(|rubric| {
            let spent = summary.by_rubric[rubric.rank()];
            RubricLine {
                key: rubric.key().to_string(),
                label: text(&format!("car-rubric-{}", rubric.key())),
                amount: amount(spent),
                share: share(spent, summary.total, language),
                per_km: match summary.driven {
                    Some(driven) if spent > 0 => fine(spent as f64 / f64::from(driven), language),
                    _ => String::new(),
                },
                colour: rubric.colour().to_string(),
            }
        })
        .collect();

    let energy = uses
        .iter()
        .map(|used| {
            let unit = text(&format!("car-unit-{}", used.energy.unit()));
            EnergyLine {
                label: text(&format!("car-energy-{}", used.energy.key())),
                quantity: quantity_text(used.quantity, used.energy, language),
                amount: amount(used.amount),
                price: if used.quantity > 0.0 {
                    i18n::message_of(
                        language,
                        "car-per-unit",
                        &[("price", &fine(used.amount as f64 / used.quantity, language)), ("unit", &unit)],
                        &[],
                    )
                } else {
                    NONE.to_string()
                },
                consumption: used.per_100.map_or_else(
                    || NONE.to_string(),
                    |value| {
                        i18n::message_of(
                            language,
                            "car-per-100",
                            &[("value", &appliance::decimal(value, 1, language)), ("unit", &unit)],
                            &[],
                        )
                    },
                ),
                per_km: used.per_km.map_or_else(|| NONE.to_string(), |value| fine(value, language)),
            }
        })
        .collect();

    let battery = book
        .entries
        .iter()
        .filter_map(|entry| {
            entry.battery.map(|value| {
                let when = [Some(date_text(entry.date)), entry.km.map(|km| km_text(km, language))]
                    .into_iter()
                    .flatten()
                    .collect::<Vec<_>>()
                    .join(" · ");
                i18n::message_of(language, "car-battery-line", &[("when", &when), ("value", &number(value, language))], &[])
            })
        })
        .collect();

    let rows = book
        .entries
        .iter()
        .rev()
        .map(|entry| Row {
            id: entry.id,
            date: date_text(entry.date),
            km: entry.km.map(|km| appliance::decimal(f64::from(km), 0, language)).unwrap_or_default(),
            rubric: text(&format!("car-rubric-{}", entry.rubric.key())),
            rubric_key: entry.rubric.key().to_string(),
            colour: entry.rubric.colour().to_string(),
            detail: detail(entry, language),
            amount: amount(entry.amount),
            garage: entry.garage.clone(),
            note: entry.note.clone(),
            fields: entry_fields(entry, language),
        })
        .collect();

    let parts_donut: Vec<Slice> = RUBRICS
        .iter()
        .filter(|rubric| summary.by_rubric[rubric.rank()] > 0)
        .map(|rubric| Slice {
            label: text(&format!("car-rubric-{}", rubric.key())),
            amount: summary.by_rubric[rubric.rank()],
            written: amount(summary.by_rubric[rubric.rank()]),
            colour: rubric.colour(),
        })
        .collect();

    let mut notes = vec![text("car-note-since"), text("car-note-consumption")];
    if book.car.engine == Engine::E85 {
        notes.push(text("car-note-e85"));
    }
    if book.car.engine.rechargeable() {
        notes.push(text("car-note-home"));
    }
    notes.push(text("car-note-inspection"));

    Written {
        title: title(&book.car, language),
        headline,
        tiles,
        rubrics,
        total: amount(summary.total),
        energy,
        parts: part_lives(book, language).iter().map(|life| life_line(life, language)).collect(),
        tyres: tyre_lives(book, language).iter().map(|life| life_line(life, language)).collect(),
        battery,
        deadlines: deadlines(book, today, language).iter().map(|deadline| deadline_line(deadline, language)).collect(),
        deadlines_empty: text("car-deadlines-empty"),
        rows,
        years: years_chart(&by_year(book), language),
        donut: loan_charts::donut(&parts_donut, &amount(summary.total), &text("car-donut-caption")),
        notes,
    }
}

/// **Les barres des années**, chaque rubrique empilée dans sa couleur.
pub fn years_chart(years: &BTreeMap<i32, [i64; 8]>, language: Language) -> String {
    let (width, height) = (680.0, 250.0);
    let mut out = svg_open(width, height, "loan-chart--bars");
    let totals: Vec<i64> = years.values().map(|year| year.iter().sum()).collect();
    let (low, high) = bounds_of(totals.iter().copied());
    let marks = ticks(low, high);
    let frame = Frame {
        left: 96.0,
        right: width - 12.0,
        top: 14.0,
        bottom: height - 34.0,
        low: *marks.first().unwrap_or(&low),
        high: *marks.last().unwrap_or(&high),
    };
    axes(&mut out, &frame, &marks, language);
    let slot = (frame.right - frame.left) / years.len().max(1) as f64;
    let thickness = (slot * 0.62).min(48.0);
    let every = years.len().div_ceil(12).max(1);
    for (rank, (year, amounts)) in years.iter().enumerate() {
        let x = frame.left + slot * rank as f64 + (slot - thickness) / 2.0;
        let mut base = 0_i64;
        for rubric in RUBRICS {
            let value = amounts[rubric.rank()];
            if value <= 0 {
                continue;
            }
            let (top, bottom) = (frame.y(base + value), frame.y(base));
            out.push_str(&format!(
                "<rect x=\"{x:.1}\" y=\"{top:.1}\" width=\"{thickness:.1}\" height=\"{:.1}\" fill=\"{}\">\
                 <title>{year} — {} — {}</title></rect>",
                (bottom - top).max(0.5),
                rubric.colour(),
                loan_charts::escape(&i18n::text(language, &format!("car-rubric-{}", rubric.key()))),
                loan_charts::escape(&money::format(value, language)),
            ));
            base += value;
        }
        if rank % every == 0 {
            out.push_str(&text(x + thickness / 2.0, height - 12.0, 12.0, loan_charts::MUTED, "middle", "normal", &year.to_string()));
        }
    }
    out.push_str("</svg>");
    out
}

/// **Ce que la fenêtre reçoit après chaque geste** : la fiche, les listes,
/// le carnet écrit, et s'il reste à enregistrer.
#[derive(Debug, Clone, PartialEq, Eq, serde::Serialize)]
pub struct View {
    pub car: CarFields,
    pub choices: Choices,
    pub written: Written,
    pub unsaved: bool,
    pub empty: bool,
}

pub fn view(book: &Logbook, today: NaiveDate, language: Language) -> View {
    View {
        car: car_fields(&book.car, language),
        choices: choices(book, language),
        written: write(book, today, language),
        unsaved: book.unsaved,
        empty: book.entries.is_empty() && book.car == Car { tariff: book.car.tariff, ..Car::new(book.car.tariff) },
    }
}

// --- Une ligne depuis une opération -------------------------------------------------------

/// Une dépense du compte, qu'on peut reprendre dans le carnet (« oui mais
/// facultatif ») : ce que la liste montre, et les champs qu'elle remplit.
#[derive(Debug, Clone, PartialEq, Eq, serde::Serialize)]
pub struct Taken {
    pub id: i64,
    pub text: String,
    pub fields: EntryFields,
}

/// Combien de dépenses la liste montre au plus : les plus récentes.
pub const TAKEN_LIMIT: i64 = 300;

/// **Les dépenses d'un compte**, les plus récentes d'abord. Le carnet n'en
/// garde que la copie : la date, le montant, le tiers comme garage, le
/// libellé comme note. Rien ne lie la ligne à l'opération ensuite.
pub fn expenses(
    conn: &rusqlite::Connection,
    account_id: i64,
    today: NaiveDate,
    language: Language,
) -> rusqlite::Result<Vec<Taken>> {
    let mut statement = conn.prepare(
        "SELECT o.IDOperation, o.Date, o.Libelle, o.Montant, COALESCE(t.Libelle, '')
         FROM Operation o LEFT JOIN Tiers t ON t.IDTiers = o.IDTiers
         WHERE o.IDCompte = ?1 AND o.IDOperationParent = 0 AND o.Montant < 0
           AND o.Date IS NOT NULL AND o.Date <= ?2
         ORDER BY o.Date DESC, o.IDOperation DESC
         LIMIT ?3",
    )?;
    let rows = statement.query_map(
        rusqlite::params![account_id, today.format("%Y-%m-%d").to_string(), TAKEN_LIMIT],
        |row| {
            Ok((
                row.get::<_, i64>(0)?,
                row.get::<_, String>(1)?,
                row.get::<_, String>(2)?,
                row.get::<_, i64>(3)?,
                row.get::<_, String>(4)?,
            ))
        },
    )?;
    let mut out = Vec::new();
    for row in rows {
        let (id, day_text, label, amount, payee) = row?;
        let Some(date) = day(&day_text) else {
            continue;
        };
        let spent = -amount;
        let text = [date_text(date), label.trim().to_string(), payee.trim().to_string(), money::format(spent, language)]
            .into_iter()
            .filter(|part| !part.is_empty())
            .collect::<Vec<_>>()
            .join(" · ");
        out.push(Taken {
            id,
            text,
            fields: EntryFields {
                date: date.to_string(),
                amount: money::format_plain(spent, language),
                garage: payee.trim().to_string(),
                note: label.trim().to_string(),
                ..EntryFields::default()
            },
        });
    }
    Ok(out)
}

// --- Le carnet en fichier ----------------------------------------------------------------

/// Ce qui dit, en tête du fichier, qu'il s'agit d'un carnet de voiture.
pub const FILE_MARK: &str = "radinus-carnet-voiture";
/// La version du format : un fichier plus récent est refusé plutôt que lu à
/// moitié.
pub const FILE_VERSION: u32 = 1;

#[derive(Debug, Clone, PartialEq, serde::Serialize, serde::Deserialize)]
struct FileTariff {
    off_peak_option: bool,
    /// Les prix du kWh, écrits à la façon neutre : 0.2001.
    base: f64,
    peak: f64,
    off_peak: f64,
    off_peak_hours: u32,
}

#[derive(Debug, Clone, PartialEq, serde::Serialize, serde::Deserialize)]
struct FileCar {
    #[serde(default)]
    plate: String,
    #[serde(default)]
    make: String,
    #[serde(default)]
    model: String,
    engine: String,
    #[serde(default)]
    first_hand: bool,
    #[serde(default)]
    registered: Option<String>,
    #[serde(default)]
    acquired: Option<String>,
    #[serde(default)]
    acquired_km: Option<u32>,
    #[serde(default)]
    service_months: u32,
    #[serde(default)]
    service_km: Option<u32>,
    tariff: FileTariff,
    #[serde(default)]
    parts: Vec<String>,
}

#[derive(Debug, Clone, PartialEq, serde::Serialize, serde::Deserialize)]
struct FileEntry {
    date: String,
    #[serde(default)]
    km: Option<u32>,
    rubric: String,
    /// Le montant, écrit à la façon neutre : 65.4.
    amount: f64,
    #[serde(default)]
    garage: String,
    #[serde(default)]
    note: String,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    energy: Option<String>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    quantity: Option<f64>,
    /// L'heure d'une recharge à la maison.
    #[serde(default, skip_serializing_if = "Option::is_none")]
    home: Option<String>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    part: Option<String>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    axle: Option<String>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    verdict: Option<String>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    months: Option<u32>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    battery: Option<f64>,
}

#[derive(Debug, Clone, PartialEq, serde::Serialize, serde::Deserialize)]
struct File {
    format: String,
    version: u32,
    car: FileCar,
    entries: Vec<FileEntry>,
}

fn neutral(micro: i64) -> f64 {
    micro as f64 / money::UNIT as f64
}

fn micro(value: f64) -> i64 {
    (value * money::UNIT as f64).round() as i64
}

/// **Le carnet en JSON** : la fiche et toutes les lignes, les montants écrits
/// à la façon neutre — un carnet tenu en français se rouvre en anglais.
pub fn to_file(book: &Logbook) -> String {
    let car = &book.car;
    let file = File {
        format: FILE_MARK.to_string(),
        version: FILE_VERSION,
        car: FileCar {
            plate: car.plate.clone(),
            make: car.make.clone(),
            model: car.model.clone(),
            engine: car.engine.key().to_string(),
            first_hand: car.first_hand,
            registered: car.registered.map(|day| day.to_string()),
            acquired: car.acquired.map(|day| day.to_string()),
            acquired_km: car.acquired_km,
            service_months: car.service_months,
            service_km: car.service_km,
            tariff: FileTariff {
                off_peak_option: car.tariff.off_peak_option,
                base: neutral(car.tariff.base),
                peak: neutral(car.tariff.peak),
                off_peak: neutral(car.tariff.off_peak),
                off_peak_hours: car.tariff.off_peak_hours,
            },
            parts: car.parts.clone(),
        },
        entries: book
            .entries
            .iter()
            .map(|entry| FileEntry {
                date: entry.date.to_string(),
                km: entry.km,
                rubric: entry.rubric.key().to_string(),
                amount: neutral(entry.amount),
                garage: entry.garage.clone(),
                note: entry.note.clone(),
                energy: entry.energy.map(|energy| energy.key().to_string()),
                quantity: entry.quantity,
                home: entry.home.map(|slot| slot.key().to_string()),
                part: entry.part.as_ref().map(Piece::value),
                axle: entry.axle.map(|axle| axle.key().to_string()),
                verdict: entry.verdict.map(|verdict| verdict.key().to_string()),
                months: entry.months,
                battery: entry.battery,
            })
            .collect(),
    };
    serde_json::to_string_pretty(&file).unwrap_or_default()
}

/// Pourquoi un fichier ne s'ouvre pas.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum FileRefusal {
    NotALogbook,
    TooRecent,
}

impl FileRefusal {
    pub fn key(self) -> &'static str {
        match self {
            FileRefusal::NotALogbook => "car-file-not-logbook",
            FileRefusal::TooRecent => "car-file-too-recent",
        }
    }
}

/// **Rouvre un carnet.** Une ligne illisible — une date abîmée, une rubrique
/// inconnue — est laissée de côté plutôt que de refuser tout le carnet.
pub fn from_file(text: &str) -> Result<Logbook, FileRefusal> {
    let file: File = serde_json::from_str(text).map_err(|_| FileRefusal::NotALogbook)?;
    if file.format != FILE_MARK {
        return Err(FileRefusal::NotALogbook);
    }
    if file.version > FILE_VERSION {
        return Err(FileRefusal::TooRecent);
    }
    let read_day = |text: &Option<String>| text.as_deref().and_then(day);
    let tariff = Tariff {
        off_peak_option: file.car.tariff.off_peak_option,
        base: micro(file.car.tariff.base),
        peak: micro(file.car.tariff.peak),
        off_peak: micro(file.car.tariff.off_peak),
        off_peak_hours: file.car.tariff.off_peak_hours.min(24),
    };
    let mut book = Logbook::new(tariff);
    book.car = Car {
        plate: file.car.plate,
        make: file.car.make,
        model: file.car.model,
        engine: Engine::from_key(&file.car.engine).unwrap_or(Engine::Petrol),
        first_hand: file.car.first_hand,
        registered: read_day(&file.car.registered),
        acquired: read_day(&file.car.acquired),
        acquired_km: file.car.acquired_km.filter(|km| *km <= KM_LIMIT),
        tariff,
        service_months: file.car.service_months.min(120),
        service_km: file.car.service_km.filter(|km| *km > 0 && *km <= KM_LIMIT),
        parts: file.car.parts.into_iter().filter(|name| !name.trim().is_empty()).collect(),
    };
    for line in file.entries {
        let (Some(date), Some(rubric)) = (day(&line.date), Rubric::from_key(&line.rubric)) else {
            continue;
        };
        let entry = Entry {
            id: 0,
            date,
            km: line.km.filter(|km| *km <= KM_LIMIT),
            rubric,
            amount: micro(line.amount).max(0),
            garage: line.garage,
            note: line.note,
            energy: line.energy.as_deref().and_then(Energy::from_key),
            quantity: line.quantity.filter(|quantity| *quantity > 0.0),
            home: line.home.as_deref().and_then(Slot::from_key),
            part: line.part.as_deref().and_then(Piece::from_value),
            axle: line.axle.as_deref().and_then(Axle::from_key),
            verdict: line.verdict.as_deref().and_then(Verdict::from_key),
            months: line.months.filter(|months| (1..=36).contains(months)),
            battery: line.battery.filter(|value| (0.0..=100.0).contains(value)),
        };
        book.put(None, entry);
    }
    book.unsaved = false;
    Ok(book)
}

// --- Le classeur et le rapport ----------------------------------------------------------

/// La fiche en quelques couples.
fn car_pairs(car: &Car, language: Language) -> Vec<(String, String)> {
    let text = |key: &str| i18n::text(language, key);
    let day = |date: Option<NaiveDate>| date.map(date_text).unwrap_or_else(|| NONE.to_string());
    let mut pairs = vec![
        (text("car-field-plate"), if car.plate.is_empty() { NONE.to_string() } else { car.plate.clone() }),
        (text("car-field-make"), if car.make.is_empty() { NONE.to_string() } else { car.make.clone() }),
        (text("car-field-model"), if car.model.is_empty() { NONE.to_string() } else { car.model.clone() }),
        (text("car-field-engine"), text(&format!("car-engine-{}", car.engine.key()))),
        (text("car-field-first-hand"), text(if car.first_hand { "ui-yes" } else { "ui-no" })),
        (text("car-field-registered"), day(car.registered)),
        (text("car-field-acquired"), day(car.acquired)),
        (
            text("car-field-acquired-km"),
            car.acquired_km.map(|km| km_text(km, language)).unwrap_or_else(|| NONE.to_string()),
        ),
    ];
    let mut every = Vec::new();
    if car.service_months > 0 {
        every.push(i18n::message_of(language, "car-months", &[], &[("months", i64::from(car.service_months))]));
    }
    if let Some(km) = car.service_km {
        every.push(km_text(km, language));
    }
    pairs.push((text("car-field-service"), if every.is_empty() { NONE.to_string() } else { every.join(" / ") }));
    if car.engine.rechargeable() {
        let price = |micro: i64| fine(micro as f64, language);
        let tariff = if car.tariff.off_peak_option {
            format!("{} / {}", price(car.tariff.peak), price(car.tariff.off_peak))
        } else {
            price(car.tariff.base)
        };
        pairs.push((text("car-tariff-title"), tariff));
    }
    pairs
}

fn history_header(language: Language) -> Vec<String> {
    [
        "car-column-date",
        "car-column-km",
        "car-column-rubric",
        "car-column-detail",
        "car-column-amount",
        "car-column-garage",
        "car-column-note",
    ]
    .iter()
    .map(|key| i18n::text(language, key))
    .collect()
}

/// **Le classeur** : « Carnet », toutes les lignes ; « Synthèse », la fiche
/// et les chiffres. Des valeurs, pas des formules.
pub fn book(book: &Logbook, today: NaiveDate, language: Language) -> Vec<Sheet> {
    let text = |key: &str| i18n::text(language, key);
    let written = write(book, today, language);

    let mut history = Sheet::new(text("car-sheet-history"));
    history.header_rows = 1;
    history.widths = vec![12.0, 12.0, 20.0, 40.0, 14.0, 24.0, 40.0];
    history.rows.push(history_header(language).into_iter().map(|name| SheetCell::text(name).with_bold(true)).collect());
    for entry in &book.entries {
        history.rows.push(vec![
            SheetCell::text(date_text(entry.date)),
            entry.km.map_or_else(SheetCell::empty, |km| SheetCell::number(f64::from(km))),
            SheetCell::text(text(&format!("car-rubric-{}", entry.rubric.key()))),
            SheetCell::text(detail(entry, language)),
            SheetCell::money(entry.amount),
            SheetCell::text(entry.garage.clone()),
            SheetCell::text(entry.note.clone()),
        ]);
    }
    history.rows.push(vec![
        SheetCell::text(text("car-total")).with_bold(true),
        SheetCell::empty(),
        SheetCell::empty(),
        SheetCell::empty(),
        SheetCell::money(book.entries.iter().map(|entry| entry.amount).sum()).with_bold(true),
        SheetCell::empty(),
        SheetCell::empty(),
    ]);

    let mut synthesis = Sheet::new(text("car-sheet-summary"));
    synthesis.widths = vec![36.0, 44.0];
    let mut push = |name: String, value: String, bold: bool| {
        synthesis.rows.push(vec![SheetCell::text(name).with_bold(true), SheetCell::text(value).with_bold(bold)]);
    };
    for (name, value) in car_pairs(&book.car, language) {
        push(name, value, false);
    }
    push(String::new(), String::new(), false);
    push(text("car-summary-title"), written.headline.clone(), true);
    for tile in &written.tiles {
        push(tile.label.clone(), tile.value.clone(), false);
    }
    push(String::new(), String::new(), false);
    push(text("car-rubrics-title"), String::new(), false);
    for line in &written.rubrics {
        push(line.label.clone(), line.amount.clone(), false);
    }
    if !written.energy.is_empty() {
        push(String::new(), String::new(), false);
        push(text("car-energy-title"), String::new(), false);
        for line in &written.energy {
            push(line.label.clone(), [line.quantity.clone(), line.consumption.clone(), line.price.clone()].join(" · "), false);
        }
    }
    if !written.deadlines.is_empty() {
        push(String::new(), String::new(), false);
        push(text("car-deadlines-title"), String::new(), false);
        for line in &written.deadlines {
            push(line.label.clone(), line.when.clone(), false);
        }
    }
    vec![history, synthesis]
}

/// **Le dossier de la voiture** en PDF : la fiche, la synthèse, les
/// échéances, l'énergie, les pièces et les pneus, les graphiques, et tout
/// l'historique — de quoi le montrer à la revente.
pub fn pdf(book: &Logbook, today: NaiveDate, language: Language) -> std::result::Result<Vec<u8>, Failure> {
    let written = write(book, today, language);
    let text = |key: &str| i18n::text(language, key);
    let q = |value: &str| printing::quoted(value);
    let mut out = String::new();
    for (name, value) in [
        ("famille", printing::FAMILY.to_string()),
        ("langue", language.tag().to_string()),
        ("logo", printing::LOGO_PATH.to_string()),
        ("titre", text("window-car-title")),
        ("sous-titre", written.title.clone()),
        ("avertissement", text("car-disclaimer")),
        ("titre-fiche", text("car-sheet-title")),
        ("titre-synthese", text("car-summary-title")),
        ("titre-echeances", text("car-deadlines-title")),
        ("titre-rubriques", text("car-rubrics-title")),
        ("titre-energie", text("car-energy-title")),
        ("titre-pieces", text("car-parts-title")),
        ("titre-pneus", text("car-tyres-title")),
        ("titre-batterie", text("car-battery-title")),
        ("titre-annees", text("car-years-title")),
        ("titre-anneau", text("car-donut-title")),
        ("titre-historique", text("car-history-title")),
        ("phrase", written.headline.clone()),
        ("aucune-echeance", written.deadlines_empty.clone()),
        ("annees-svg", written.years.clone()),
        ("anneau-svg", written.donut.clone()),
        ("total-mot", text("car-total")),
        ("total", written.total.clone()),
    ] {
        out.push_str(&format!("#let {name} = {}\n", q(&value)));
    }
    let list = |out: &mut String, name: &str, rows: Vec<Vec<String>>| {
        out.push_str(&format!("#let {name} = (\n"));
        for row in rows {
            // Une seule case : la virgule finale en fait un tableau, et non
            // une chaîne entre parenthèses.
            out.push_str(&format!("  ({},),\n", row.iter().map(|cell| q(cell)).collect::<Vec<_>>().join(", ")));
        }
        out.push_str(")\n");
    };
    list(&mut out, "fiche", car_pairs(&book.car, language).into_iter().map(|(a, b)| vec![a, b]).collect());
    list(&mut out, "tuiles", written.tiles.iter().map(|tile| vec![tile.label.clone(), tile.value.clone()]).collect());
    list(
        &mut out,
        "echeances",
        written.deadlines.iter().map(|line| vec![line.label.clone(), line.when.clone(), line.badge.clone()]).collect(),
    );
    list(
        &mut out,
        "colonnes-rubriques",
        vec![["car-column-rubric", "car-column-amount", "car-column-share", "car-column-per-km"].iter().map(|key| text(key)).collect()],
    );
    list(
        &mut out,
        "rubriques",
        written
            .rubrics
            .iter()
            .map(|line| vec![line.label.clone(), line.amount.clone(), line.share.clone(), line.per_km.clone()])
            .collect(),
    );
    list(
        &mut out,
        "colonnes-energie",
        vec![[
            "car-column-energy",
            "car-column-quantity",
            "car-column-amount",
            "car-column-price",
            "car-column-consumption",
            "car-column-per-km",
        ]
        .iter()
        .map(|key| text(key))
        .collect()],
    );
    list(
        &mut out,
        "energie",
        written
            .energy
            .iter()
            .map(|line| {
                vec![
                    line.label.clone(),
                    line.quantity.clone(),
                    line.amount.clone(),
                    line.price.clone(),
                    line.consumption.clone(),
                    line.per_km.clone(),
                ]
            })
            .collect(),
    );
    list(
        &mut out,
        "colonnes-vies",
        vec![[
            "car-column-part",
            "car-column-changes",
            "car-column-amount",
            "car-column-last",
            "car-column-life",
            "car-column-next",
        ]
        .iter()
        .map(|key| text(key))
        .collect()],
    );
    let lives = |lines: &[LifeLine]| -> Vec<Vec<String>> {
        lines
            .iter()
            .map(|line| {
                vec![
                    line.name.clone(),
                    line.changes.clone(),
                    line.amount.clone(),
                    line.last.clone(),
                    line.life.clone(),
                    line.next.clone(),
                ]
            })
            .collect()
    };
    list(&mut out, "pieces", lives(&written.parts));
    list(&mut out, "pneus", lives(&written.tyres));
    list(&mut out, "batterie", written.battery.iter().map(|line| vec![line.clone()]).collect());
    list(&mut out, "colonnes-historique", vec![history_header(language)]);
    list(
        &mut out,
        "historique",
        book.entries
            .iter()
            .map(|entry| {
                vec![
                    date_text(entry.date),
                    entry.km.map(|km| appliance::decimal(f64::from(km), 0, language)).unwrap_or_default(),
                    text(&format!("car-rubric-{}", entry.rubric.key())),
                    detail(entry, language),
                    money::format(entry.amount, language),
                    entry.garage.clone(),
                    entry.note.clone(),
                ]
            })
            .collect(),
    );
    list(&mut out, "notes", written.notes.iter().map(|note| vec![note.clone()]).collect());
    out.push_str(TEMPLATE);
    printing::compose(out, "radinus-voiture")
}

const TEMPLATE: &str = r##"
#let nuit = rgb("#24506e")
#let encre = rgb("#1d2b34")
#let gris = rgb("#6b7a88")
#let filet = rgb("#e3e8ed")
#let fond = rgb("#f4f6f8")
#let dore = rgb("#c39a3c")
#let rouge = rgb("#cf4436")

#set text(font: famille, size: 9pt, fill: encre, lang: langue)
#set par(leading: 0.55em, spacing: 0.9em)
#set page(
  paper: "a4",
  margin: (left: 42pt, right: 42pt, top: 42pt, bottom: 58pt),
  footer: context {
    set text(size: 7.5pt, fill: gris)
    line(length: 100%, stroke: 0.5pt + filet)
    v(4pt)
    grid(columns: (1fr, auto), avertissement,
      [#counter(page).display() / #counter(page).final().first()])
  },
)

#let svg(source, largeur) = image(bytes(source), format: "svg", width: largeur)

#let titre-section(texte) = {
  v(14pt)
  block(below: 8pt, {
    text(size: 13pt, weight: "bold", fill: nuit, texte)
    v(-6pt)
    line(length: 36pt, stroke: 2pt + dore)
  })
}

#let tuile(intitule, valeur) = block(
  width: 100%, fill: fond, radius: 6pt, inset: (x: 10pt, y: 10pt),
  {
    text(size: 7.5pt, fill: gris, upper(intitule))
    v(2pt)
    text(size: 13pt, weight: "bold", fill: nuit, valeur)
  },
)

#let tableau(colonnes, lignes, alignements, largeurs: none) = table(
  columns: if largeurs == none {
    colonnes.at(0).enumerate().map(((i, c)) => if i == 0 { 1fr } else { auto })
  } else { largeurs },
  stroke: none,
  inset: (x: 6pt, y: 4pt),
  align: (x, y) => alignements.at(x),
  fill: (x, y) => if y == 0 { nuit } else if calc.even(y) { fond } else { white },
  table.header(..colonnes.at(0).map(c => text(fill: white, weight: "bold", c))),
  ..lignes.flatten(),
)

#block(width: 100%, fill: nuit, radius: 8pt, inset: (x: 16pt, y: 14pt), grid(
  columns: (auto, 1fr), column-gutter: 14pt, align: horizon,
  box(fill: white, radius: 6pt, inset: 4pt, image(logo, height: 46pt)),
  {
    text(size: 22pt, weight: "bold", fill: white, titre)
    v(-4pt)
    text(size: 10pt, fill: rgb("#d5e2ec"), sous-titre)
  },
))

#titre-section(titre-fiche)
#table(columns: (auto, 1fr), stroke: none, inset: (x: 0pt, y: 3.5pt), column-gutter: 14pt,
  ..fiche.map(c => (text(fill: gris, c.at(0)), text(weight: "bold", c.at(1)))).flatten())

#titre-section(titre-synthese)
#block(width: 100%, fill: fond, radius: (right: 6pt), stroke: (left: 5pt + dore), inset: (x: 14pt, y: 10pt),
  text(size: 12pt, weight: "bold", fill: nuit, phrase))
#v(6pt)
#grid(columns: (1fr, 1fr, 1fr), column-gutter: 8pt, row-gutter: 8pt,
  ..tuiles.map(t => tuile(t.at(0), t.at(1))))

#titre-section(titre-echeances)
#if echeances.len() == 0 [#text(fill: gris, aucune-echeance)] else {
  table(columns: (auto, 1fr, auto), stroke: none, inset: (x: 0pt, y: 3.5pt), column-gutter: 14pt,
    ..echeances.map(e => (text(weight: "bold", e.at(0)), e.at(1), text(weight: "bold", fill: rouge, e.at(2)))).flatten())
}

#titre-section(titre-rubriques)
#tableau(colonnes-rubriques, rubriques, (left, right, right, right))
#table(columns: (1fr, auto), stroke: none, inset: (x: 6pt, y: 4pt),
  text(weight: "bold", total-mot), text(weight: "bold", fill: nuit, total))

#if energie.len() > 0 {
  titre-section(titre-energie)
  tableau(colonnes-energie, energie, (left, right, right, right, right, right))
}

#if pieces.len() > 0 {
  titre-section(titre-pieces)
  tableau(colonnes-vies, pieces, (left, right, right, left, right, right))
}

#if pneus.len() > 0 {
  titre-section(titre-pneus)
  tableau(colonnes-vies, pneus, (left, right, right, left, right, right))
}

#if batterie.len() > 0 {
  titre-section(titre-batterie)
  for ligne in batterie { [• #ligne.at(0)]; linebreak() }
}

#if historique.len() > 0 {
  v(10pt)
  block(width: 100%, stroke: 0.6pt + filet, radius: 6pt, inset: 12pt, breakable: false, {
    text(size: 10pt, weight: "bold", fill: nuit, titre-annees)
    v(6pt)
    align(center, svg(annees-svg, 440pt))
  })
  v(6pt)
  block(width: 100%, stroke: 0.6pt + filet, radius: 6pt, inset: 12pt, breakable: false, {
    text(size: 10pt, weight: "bold", fill: nuit, titre-anneau)
    v(6pt)
    align(center, svg(anneau-svg, 330pt))
  })
}

#titre-section(titre-historique)
#{
  set text(size: 8pt)
  tableau(colonnes-historique, historique, (left, right, left, left, right, left, left),
    largeurs: (auto, auto, auto, 1.4fr, auto, 0.8fr, 1fr))
}

#v(6pt)
#block({
  set text(size: 8pt, fill: gris)
  for note in notes { [• #note.at(0)]; linebreak() }
})
"##;

#[cfg(test)]
mod tests {
    use super::*;

    const EURO: i64 = money::UNIT;

    fn date(text: &str) -> NaiveDate {
        NaiveDate::parse_from_str(text, "%Y-%m-%d").unwrap()
    }

    fn today() -> NaiveDate {
        date("2026-10-10")
    }

    fn fields(rubric: &str, day: &str, km: &str, amount: &str) -> EntryFields {
        EntryFields {
            date: day.into(),
            km: km.into(),
            rubric: rubric.into(),
            amount: amount.into(),
            ..EntryFields::default()
        }
    }

    fn fill(day: &str, km: &str, litres: &str, amount: &str) -> EntryFields {
        EntryFields { quantity: litres.into(), ..fields("energy", day, km, amount) }
    }

    fn put(book: &mut Logbook, typed: EntryFields) {
        let entry = read_entry(&typed, &book.car, today()).unwrap();
        book.put(None, entry);
    }

    /// Une 208 essence de première main, avec quelques années de carnet.
    fn sample() -> Logbook {
        let mut book = Logbook::new(appliance::BLUE_TARIFF);
        book.car = Car {
            plate: "AB-123-CD".into(),
            make: "Peugeot".into(),
            model: "208".into(),
            first_hand: true,
            registered: Some(date("2020-03-15")),
            acquired: Some(date("2020-03-15")),
            acquired_km: Some(10),
            ..Car::new(appliance::BLUE_TARIFF)
        };
        for typed in [
            fill("2026-07-01", "71000", "40", "70"),
            fill("2026-07-20", "71600", "36", "63"),
            fill("2026-08-10", "72200", "36", "63"),
            EntryFields { part: "known:brake-pads".into(), ..fields("wear", "2022-05-02", "30010", "180") },
            EntryFields { part: "known:brake-pads".into(), ..fields("wear", "2024-08-01", "60010", "190") },
            EntryFields { axle: "all".into(), ..fields("tyres", "2021-11-02", "30000", "400") },
            EntryFields { axle: "front".into(), ..fields("tyres", "2023-09-01", "55000", "220") },
            fields("service", "2025-06-01", "66000", "250"),
            EntryFields { verdict: "pass".into(), ..fields("inspection", "2024-03-10", "52000", "78") },
            EntryFields { months: "12".into(), ..fields("insurance", "2026-01-01", "", "540") },
            EntryFields { note: "Démarreur".into(), ..fields("breakdown", "2024-11-12", "62000", "320,50") },
        ] {
            put(&mut book, typed);
        }
        book
    }

    /// **Chaque rubrique exige ce qui la fait compter.**
    #[test]
    fn une_ligne_se_lit_ou_se_refuse() {
        let car = Car::new(appliance::BLUE_TARIFF);
        let refusal = |typed: EntryFields| read_entry(&typed, &car, today()).unwrap_err();
        assert_eq!(refusal(fill("2026-07-01", "100", "", "70")).key, "car-invalid-quantity");
        assert_eq!(refusal(fill("2027-07-01", "100", "40", "70")).key, "car-invalid-date");
        assert_eq!(refusal(fill("2026-07-01", "cent", "40", "70")).field, "km");
        assert_eq!(refusal(fields("wear", "2026-07-01", "", "70")).key, "car-invalid-part");
        assert_eq!(refusal(fields("energy-bis", "2026-07-01", "", "70")).key, "car-invalid-rubric");
        assert_eq!(refusal(EntryFields { months: "40".into(), ..fields("insurance", "2026-07-01", "", "70") }).key, "car-invalid-months");
        // Un nom tapé qui est celui d'une pièce de la liste la désigne.
        let typed = EntryFields { part: "other".into(), part_name: "embrayage".into(), ..fields("wear", "2026-07-01", "", "70") };
        assert_eq!(read_entry(&typed, &car, today()).unwrap().part, Some(Piece::Known("clutch".into())));
        // Une pièce nouvelle rejoint la liste de la voiture.
        let mut book = Logbook::new(appliance::BLUE_TARIFF);
        let typed = EntryFields { part: "other".into(), part_name: "Rotule".into(), ..fields("wear", "2026-07-01", "", "70") };
        put(&mut book, typed);
        assert_eq!(book.car.parts, vec!["Rotule".to_string()]);
        assert!(book.unsaved);
        assert!(choices(&book, Language::French).parts.iter().any(|part| part.key == "custom:Rotule"));
    }

    /// **La recharge à la maison se chiffre au tarif de la voiture**, le jour
    /// où on la note, et garde ce coût.
    #[test]
    fn la_recharge_a_la_maison_se_chiffre_au_tarif() {
        let mut book = Logbook::new(appliance::BLUE_TARIFF);
        book.car.engine = Engine::Electric;
        let typed = EntryFields { charge: "home".into(), energy: "electricity".into(), ..fill("2026-07-01", "1000", "40", "") };
        let entry = read_entry(&typed, &book.car, today()).unwrap();
        // 40 kWh au prix Base.
        assert_eq!(entry.amount, 40 * appliance::BLUE_TARIFF.base);
        assert_eq!(entry.home, Some(Slot::Base));
        book.put(None, entry);
        // En heures creuses, au prix des heures creuses.
        book.car.tariff.off_peak_option = true;
        let entry = read_entry(&typed, &book.car, today()).unwrap();
        assert_eq!(entry.amount, 40 * appliance::BLUE_TARIFF.off_peak);
        // Changer le tarif ne réécrit pas la ligne déjà notée.
        assert_eq!(book.entries[0].amount, 40 * appliance::BLUE_TARIFF.base);
        // Une électrique ne prend pas d'essence : l'énergie est ramenée à la
        // sienne.
        let typed = EntryFields { energy: "petrol".into(), ..fill("2026-07-01", "1000", "40", "12") };
        assert_eq!(read_entry(&typed, &book.car, today()).unwrap().energy, Some(Energy::Electricity));
    }

    /// **De plein à plein** : 72 litres sur 1 200 km.
    #[test]
    fn la_consommation_se_mesure_de_plein_a_plein() {
        let book = sample();
        let uses = energy_uses(&book);
        assert_eq!(uses.len(), 1);
        let petrol = &uses[0];
        assert_eq!(petrol.energy, Energy::Petrol);
        assert!((petrol.per_100.unwrap() - 6.0).abs() < 1e-9);
        // 126 € sur 1 200 km.
        assert!((petrol.per_km.unwrap() - 126.0 * EURO as f64 / 1200.0).abs() < 1.0);
        assert_eq!(petrol.amount, 196 * EURO);
    }

    /// **Une voiture E85 boit ce qu'on lui donne** : chaque écart de compteur
    /// va au carburant du plein d'avant.
    #[test]
    fn l_e85_et_l_essence_se_comptent_a_part() {
        let mut book = Logbook::new(appliance::BLUE_TARIFF);
        book.car.engine = Engine::E85;
        put(&mut book, EntryFields { energy: "e85".into(), ..fill("2026-07-01", "1000", "40", "40") });
        put(&mut book, EntryFields { energy: "petrol".into(), ..fill("2026-07-10", "1500", "30", "54") });
        put(&mut book, EntryFields { energy: "e85".into(), ..fill("2026-07-20", "1900", "25", "25") });
        let uses = energy_uses(&book);
        let of = |energy: Energy| uses.iter().find(|used| used.energy == energy).unwrap();
        // 500 km à l'E85, refaits avec 30 litres.
        assert!((of(Energy::E85).per_100.unwrap() - 6.0).abs() < 1e-9);
        // 400 km à l'essence, refaits avec 25 litres.
        assert!((of(Energy::Petrol).per_100.unwrap() - 6.25).abs() < 1e-9);
        // 30 litres d'E85 à 1 € le litre, sur 500 km.
        assert!((of(Energy::E85).per_km.unwrap() - 30.0 * EURO as f64 / 500.0).abs() < 1.0);
    }

    /// **Les vies des pièces et des pneus**, et les échéances qu'elles
    /// donnent.
    #[test]
    fn les_pieces_les_pneus_et_les_echeances() {
        let book = sample();
        let parts = part_lives(&book, Language::French);
        let pads = parts.iter().find(|life| life.name == "Plaquettes de frein").unwrap();
        // Première main : 0 → 30 010, puis 30 010 → 60 010.
        assert_eq!(pads.changes, 2);
        assert_eq!(pads.life, Some(30_005));
        assert_eq!(pads.next_km, Some(90_015));
        let tyres = tyre_lives(&book, Language::French);
        assert_eq!(tyres.len(), 2);
        // L'avant : les quatre à 30 000, l'avant à 55 000.
        assert_eq!(tyres[0].life, Some(27_500));
        assert_eq!(tyres[0].next_km, Some(82_500));
        assert_eq!(tyres[1].next_km, Some(60_000));

        let found = deadlines(&book, today(), Language::French);
        let find = |what: &DeadlineKind| found.iter().find(|deadline| &deadline.what == what).unwrap().clone();
        let service = find(&DeadlineKind::Service);
        assert_eq!(service.date, Some(date("2026-06-01")));
        assert_eq!(service.tone, Tone::Late);
        let inspection = find(&DeadlineKind::Inspection { counter: false });
        assert_eq!(inspection.date, Some(date("2026-03-10")));
        let insurance = find(&DeadlineKind::Insurance);
        assert_eq!(insurance.date, Some(date("2027-01-01")));
        assert_eq!(insurance.tone, Tone::Later);
        // Les pneus arrière, à 60 000 km : le compteur est à 72 200.
        let rear = find(&DeadlineKind::Tyres("Pneus arrière".into()));
        assert_eq!(rear.tone, Tone::Late);
        // Les dépassées d'abord.
        assert!(found.windows(2).all(|pair| pair[0].tone <= pair[1].tone));

        // Une contre-visite, dans les deux mois.
        let mut counter = book.clone();
        put(&mut counter, EntryFields { verdict: "counter".into(), ..fields("inspection", "2026-09-20", "72300", "78") });
        let found = deadlines(&counter, today(), Language::French);
        let next = found.iter().find(|deadline| deadline.what == DeadlineKind::Inspection { counter: true }).unwrap();
        assert_eq!(next.date, Some(date("2026-11-20")));
        assert_eq!(next.tone, Tone::Soon);

        // Sans contrôle noté, le premier vient quatre ans après la mise en
        // circulation — ou ne se date pas s'il est passé.
        let mut young = Logbook::new(appliance::BLUE_TARIFF);
        young.car.registered = Some(date("2024-01-15"));
        let found = deadlines(&young, today(), Language::French);
        assert!(found.iter().any(|deadline| deadline.date == Some(date("2028-01-15"))));
        young.car.registered = Some(date("2010-01-15"));
        let found = deadlines(&young, today(), Language::French);
        assert!(found.iter().any(|deadline| deadline.what == DeadlineKind::InspectionUnknown));
    }

    /// **La synthèse** compte depuis l'acquisition.
    #[test]
    fn la_synthese_compte_depuis_l_acquisition() {
        let book = sample();
        let summary = summary(&book, today());
        assert_eq!(summary.since, date("2020-03-15"));
        assert_eq!(summary.driven, Some(72_190));
        let total = 196 * EURO + 370 * EURO + 620 * EURO + 250 * EURO + 78 * EURO + 540 * EURO + 320_500_000;
        assert_eq!(summary.total, total);
        assert_eq!(summary.by_rubric[Rubric::Wear.rank()], 370 * EURO);
        assert_eq!(summary.breakdowns, 1);
        let written = write(&book, today(), Language::French);
        assert_eq!(written.title, "Peugeot 208 · AB-123-CD");
        assert!(written.headline.starts_with("Depuis mars 2020"), "{}", written.headline);
        assert_eq!(written.rows.len(), book.entries.len());
        // L'historique se lit du plus récent au plus ancien.
        assert_eq!(written.rows[0].date, "10/08/2026");
        assert!(written.years.contains("2026"));
        assert_eq!(by_year(&book).len(), 6);
    }

    /// **Le carnet en fichier** : enregistré, rouvert, il est le même.
    #[test]
    fn le_carnet_se_relit() {
        let mut book = sample();
        book.car.engine = Engine::PlugIn;
        book.car.tariff.off_peak_option = true;
        put(
            &mut book,
            EntryFields {
                energy: "electricity".into(),
                charge: "home".into(),
                slot: "peak".into(),
                battery: "97,5".into(),
                ..fill("2026-08-20", "72400", "8,5", "")
            },
        );
        let text = to_file(&book);
        assert!(text.contains("\"format\": \"radinus-carnet-voiture\""));
        let opened = from_file(&text).unwrap();
        assert!(!opened.unsaved);
        assert_eq!(opened.car, book.car);
        assert_eq!(opened.entries.len(), book.entries.len());
        for (a, b) in opened.entries.iter().zip(&book.entries) {
            assert_eq!((a.date, a.km, a.rubric, a.amount, a.home, a.battery), (b.date, b.km, b.rubric, b.amount, b.home, b.battery));
            assert_eq!((&a.part, a.axle, a.verdict, a.months, a.quantity), (&b.part, b.axle, b.verdict, b.months, b.quantity));
        }
        assert_eq!(from_file("{}"), Err(FileRefusal::NotALogbook));
        let newer = text.replace("\"version\": 1", "\"version\": 9");
        assert_eq!(from_file(&newer), Err(FileRefusal::TooRecent));
        // Une ligne abîmée est laissée de côté, le reste s'ouvre.
        let damaged = text.replacen("\"rubric\": \"energy\"", "\"rubric\": \"???\"", 1);
        assert_eq!(from_file(&damaged).unwrap().entries.len(), book.entries.len() - 1);
    }

    #[test]
    fn la_fiche_se_lit() {
        let typed = CarFields {
            plate: " AB-123-CD ".into(),
            engine: "electric".into(),
            registered: "2021-05-01".into(),
            acquired: "2020-05-01".into(),
            tariff: appliance::tariff_fields(&appliance::BLUE_TARIFF, Language::French),
            ..CarFields::default()
        };
        assert_eq!(read_car(&typed, today()).unwrap_err().key, "car-invalid-acquired");
        let typed = CarFields { acquired: "2022-01-10".into(), acquired_km: "12 000".into(), service_months: "24".into(), ..typed };
        let car = read_car(&typed, today()).unwrap();
        assert_eq!(car.plate, "AB-123-CD");
        assert_eq!(car.engine, Engine::Electric);
        assert_eq!(car.acquired_km, Some(12_000));
        assert_eq!(car_fields(&car, Language::French).acquired_km, "12000");
        let mut book = Logbook::new(appliance::BLUE_TARIFF);
        book.set_car(car);
        assert!(book.unsaved);
        let choices = choices(&book, Language::French);
        assert!(choices.rechargeable && choices.battery);
        assert!(!choices.parts.iter().any(|part| part.key == "known:clutch"));
    }

    /// **Le classeur et le dossier PDF** se composent.
    #[test]
    fn le_classeur_et_le_dossier_se_composent() {
        let book = sample();
        let sheets = super::book(&book, today(), Language::French);
        assert_eq!(sheets.len(), 2);
        // L'en-tête, les onze lignes, le total.
        assert_eq!(sheets[0].rows.len(), 13);
        let path = std::env::temp_dir().join("radinus-carnet-essai.xlsx");
        crate::sheets::write_book(&sheets, &path).expect("le classeur s'écrit");
        let _ = std::fs::remove_file(path);
        let bytes = pdf(&book, today(), Language::French).expect("le dossier se compose");
        assert!(bytes.starts_with(b"%PDF"));
        let empty = Logbook::new(appliance::BLUE_TARIFF);
        assert!(pdf(&empty, today(), Language::French).is_ok());
    }

    /// **Une ligne depuis une opération** : les dépenses du compte, les plus
    /// récentes d'abord, filles et recettes exclues.
    #[test]
    fn les_depenses_d_un_compte_se_reprennent() {
        let conn = rusqlite::Connection::open_in_memory().unwrap();
        crate::database::schema::migrate(&conn).unwrap();
        crate::database::seed::seed_initial_data(&conn).unwrap();
        conn.execute(
            "INSERT INTO Compte (IDCompte, Libelle, IDTypeCompte, IDBanques, SoldeBanque, SoldeReel, SoldeFinal, CompteCloture)
             VALUES (1, 'CCP', 1, 1, 0, 0, 0, 0)",
            [],
        )
        .unwrap();
        conn.execute("INSERT INTO Tiers (IDTiers, Libelle) VALUES (77, 'Garage du Centre')", []).unwrap();
        for (id, day, amount, parent, payee) in [
            (1, "2026-03-01", -250 * EURO, 0, 77),
            (2, "2026-04-01", 1_000 * EURO, 0, 0),
            (3, "2026-05-01", -65_400_000, 0, 0),
            (4, "2026-05-01", -30 * EURO, 3, 0),
            (5, "2027-01-01", -10 * EURO, 0, 0),
        ] {
            conn.execute(
                "INSERT INTO Operation (IDOperation, Libelle, Date, Montant, IDCompte, IDStatutOperation, IDOperationParent, IDTiers)
                 VALUES (?1, ?2, ?3, ?4, 1, 1, ?5, ?6)",
                rusqlite::params![id, format!("OP {id}"), day, amount, parent, payee],
            )
            .unwrap();
        }
        let taken = expenses(&conn, 1, today(), Language::French).unwrap();
        assert_eq!(taken.iter().map(|one| one.id).collect::<Vec<_>>(), vec![3, 1]);
        assert_eq!(taken[0].fields.amount, "65,40");
        assert_eq!(taken[1].fields.garage, "Garage du Centre");
        assert_eq!(taken[1].fields.date, "2026-03-01");
        assert!(taken[1].text.starts_with("01/03/2026 · OP 1 · Garage du Centre"), "{}", taken[1].text);
    }
}
