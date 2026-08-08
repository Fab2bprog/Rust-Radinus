// The application's own Oui/Non dialog.
//
// `window.confirm` cannot be used: Tauri's webview does not honour it — it
// returns nothing at all, which the calling code reads as "no", so the window
// simply refuses to close and the user is stuck (bug reported by Fabrice,
// 25/07/2026). The alternative would have been the official Tauri dialog
// plugin, i.e. a new dependency, which rule 6 of PLAN_ACTION.md forbids
// without his explicit authorization — so the dialog is built here instead,
// with the charter's own colours.
//
// It reproduces WinDev's `OuiNon`: a question, "Oui" and "Non", the answer as
// a boolean. Escape answers no, Enter answers yes, and the buttons are
// reachable with the keyboard.

/// Whether a question is on screen right now. Read from the document itself
/// rather than from a variable: what is displayed is the truth, and it cannot
/// get out of step with it or stay stuck after the window is hidden.
import { asMoneyField } from "./money-field";

export function questionIsOnScreen(): boolean {
  return document.querySelector(".dialog-overlay") !== null;
}

/// Asks `question` and resolves to the user's answer. Never rejects.
///
/// The two buttons are named by the caller: the dialog holds no word of its
/// own, so it says Oui/Non or Yes/No without knowing which (author's ruling,
/// 25/07/2026).
/// **Un panneau qui annonce, et n'a rien à demander.**
///
/// Un seul bouton, « OK ». C'est ce qu'il faut pour dire qu'un virement vient
/// d'être fait : la question est déjà tranchée, et proposer Oui / Non
/// laisserait croire qu'on peut encore revenir dessus (anomalie signalée par
/// Fabrice, 29/07/2026 — j'y avais mis un Oui et un bouton vide).
///
/// Entrée et Échap le referment tous les deux : il n'y a qu'une issue.
export function tell(message: string, okLabel: string): Promise<void> {
  return new Promise((resolve) => {
    const previousFocus = document.activeElement;

    const overlay = document.createElement("div");
    overlay.className = "dialog-overlay";
    overlay.role = "presentation";

    const box = document.createElement("div");
    box.className = "dialog";
    box.role = "alertdialog";
    box.ariaModal = "true";

    const text = document.createElement("p");
    text.className = "dialog__question";
    text.textContent = message;

    const buttons = document.createElement("div");
    buttons.className = "dialog__buttons";

    const ok = document.createElement("button");
    ok.type = "button";
    ok.className = "dialog__button dialog__button--primary";
    ok.textContent = okLabel;

    const close = (): void => {
      document.removeEventListener("keydown", onKeyDown, true);
      overlay.remove();
      if (previousFocus instanceof HTMLElement && previousFocus.isConnected) {
        previousFocus.focus();
      }
      resolve();
    };

    const onKeyDown = (event: KeyboardEvent): void => {
      if (event.key === "Escape" || event.key === "Enter") {
        event.preventDefault();
        event.stopPropagation();
        close();
      }
    };

    ok.addEventListener("click", () => close());
    overlay.addEventListener("mousedown", (event) => {
      if (event.target === overlay) {
        event.preventDefault();
      }
    });
    document.addEventListener("keydown", onKeyDown, true);

    buttons.append(ok);
    box.append(text, buttons);
    overlay.append(box);
    document.body.append(overlay);
    ok.focus();
  });
}

export function askYesNo(
  question: string,
  yesLabel: string,
  noLabel: string,
): Promise<boolean> {
  return new Promise((resolve) => {
    const previousFocus = document.activeElement;

    const overlay = document.createElement("div");
    overlay.className = "dialog-overlay";
    overlay.role = "presentation";

    const box = document.createElement("div");
    box.className = "dialog";
    box.role = "alertdialog";
    box.ariaModal = "true";

    const text = document.createElement("p");
    text.className = "dialog__question";
    text.textContent = question;

    const buttons = document.createElement("div");
    buttons.className = "dialog__buttons";

    const yes = document.createElement("button");
    yes.type = "button";
    yes.className = "dialog__button dialog__button--primary";
    yes.textContent = yesLabel;

    const no = document.createElement("button");
    no.type = "button";
    no.className = "dialog__button";
    no.textContent = noLabel;

    const close = (answer: boolean): void => {
      document.removeEventListener("keydown", onKeyDown, true);
      overlay.remove();
      // Only if it is still there: giving focus to an element that has been
      // taken out of the document is one of the ways the webview crashes.
      if (previousFocus instanceof HTMLElement && previousFocus.isConnected) {
        previousFocus.focus();
      }
      resolve(answer);
    };

    const onKeyDown = (event: KeyboardEvent): void => {
      if (event.key === "Escape") {
        event.preventDefault();
        event.stopPropagation();
        close(false);
      } else if (event.key === "Enter") {
        event.preventDefault();
        event.stopPropagation();
        close(true);
      }
    };

    yes.addEventListener("click", () => close(true));
    no.addEventListener("click", () => close(false));
    // A click beside the box is not an answer: the question stays.
    overlay.addEventListener("mousedown", (event) => {
      if (event.target === overlay) {
        event.preventDefault();
      }
    });
    // Captured, so the window's own Enter/Escape handlers never see these.
    document.addEventListener("keydown", onKeyDown, true);

    buttons.append(yes, no);
    box.append(text, buttons);
    overlay.append(box);
    document.body.append(overlay);
    yes.focus();
  });
}

/// Replie une réponse sur ce qui compte pour la comparer : sans accents, sans
/// casse, sans blancs autour. Taper « oui », « Oui » ou « OUI » revient au
/// même — la barrière est d'avoir écrit le mot en entier, pas d'avoir trouvé
/// la bonne touche majuscule.
function folded(text: string): string {
  return text
    .normalize("NFD")
    .replace(/[̀-ͯ]/g, "")
    .trim()
    .toLowerCase();
}

/// Demande à l'utilisateur de **taper un mot** pour confirmer, et résout à vrai
/// seulement s'il l'a écrit.
///
/// La deuxième barrière des suppressions graves (décision de Fabrice,
/// 26/07/2026) : supprimer un compte bancaire emporte tout son historique, et
/// un Oui/Non se clique sans lire. Écrire le mot demande de s'arrêter.
///
/// Le mot est donné par l'appelant, jamais inventé ici : c'est celui du
/// dictionnaire, donc « oui » en français et « yes » en anglais, sans que ce
/// fichier ait à savoir dans quelle langue il travaille.
export function askForWord(
  question: string,
  expected: string,
  confirmLabel: string,
  cancelLabel: string,
): Promise<boolean> {
  return new Promise((resolve) => {
    const previousFocus = document.activeElement;

    const overlay = document.createElement("div");
    overlay.className = "dialog-overlay";
    overlay.role = "presentation";

    const box = document.createElement("div");
    box.className = "dialog";
    box.role = "alertdialog";
    box.ariaModal = "true";

    const text = document.createElement("p");
    text.className = "dialog__question";
    text.textContent = question;

    const typed = document.createElement("input");
    typed.type = "text";
    typed.className = "dialog__field";
    typed.autocomplete = "off";
    typed.spellcheck = false;
    typed.autocapitalize = "off";
    typed.setAttribute("autocorrect", "off");

    const buttons = document.createElement("div");
    buttons.className = "dialog__buttons";

    const confirm = document.createElement("button");
    confirm.type = "button";
    confirm.className = "dialog__button dialog__button--primary";
    confirm.textContent = confirmLabel;
    // Rien n'est confirmable tant que le mot n'est pas écrit : le bouton dit
    // de lui-même où l'on en est, sans qu'on ait à essayer.
    confirm.disabled = true;

    const cancel = document.createElement("button");
    cancel.type = "button";
    cancel.className = "dialog__button";
    cancel.textContent = cancelLabel;

    const written = (): boolean => folded(typed.value) === folded(expected);

    const close = (answer: boolean): void => {
      document.removeEventListener("keydown", onKeyDown, true);
      overlay.remove();
      if (previousFocus instanceof HTMLElement && previousFocus.isConnected) {
        previousFocus.focus();
      }
      resolve(answer);
    };

    const onKeyDown = (event: KeyboardEvent): void => {
      if (event.key === "Escape") {
        event.preventDefault();
        event.stopPropagation();
        close(false);
      } else if (event.key === "Enter") {
        event.preventDefault();
        event.stopPropagation();
        // Entrée ne confirme que si le mot est là. Sinon elle ne fait rien —
        // surtout pas « non » : on est en train d'écrire.
        if (written()) {
          close(true);
        }
      }
    };

    typed.addEventListener("input", () => {
      confirm.disabled = !written();
    });
    confirm.addEventListener("click", () => {
      if (written()) {
        close(true);
      }
    });
    cancel.addEventListener("click", () => close(false));
    overlay.addEventListener("mousedown", (event) => {
      if (event.target === overlay) {
        event.preventDefault();
      }
    });
    document.addEventListener("keydown", onKeyDown, true);

    buttons.append(confirm, cancel);
    box.append(text, typed, buttons);
    overlay.append(box);
    document.body.append(overlay);
    typed.focus();
  });
}

/// Demande **une ligne de texte**, et rend ce qui a été écrit.
///
/// Née pour l'identifiant FITID de F03 (Fabrice, 04/08/2026), et écrite sans
/// rien qui lui soit propre : elle demande une ligne, elle ne demande pas un
/// FITID. Une boîte qui saurait ce qu'est un FITID serait la vue en train de
/// juger une donnée, ce qu'elle ne fait nulle part ailleurs.
///
/// `current` est ce que le champ contient à l'ouverture — **vide quand il n'y
/// a rien**, et c'est un cas ordinaire : une opération saisie à la main n'a
/// pas d'identifiant, on peut lui en donner un.
///
/// Rend `null` quand on renonce, **et aussi quand le champ est laissé vide** :
/// ne rien écrire n'est pas une réponse, c'est la même règle que pour un
/// nombre ou un montant. Vider un identifiant se demande à l'option qui
/// l'efface, laquelle pose sa question avant.
export function askForText(
  question: string,
  current: string,
  confirmLabel: string,
  cancelLabel: string,
): Promise<string | null> {
  return new Promise((resolve) => {
    const previousFocus = document.activeElement;

    const overlay = document.createElement("div");
    overlay.className = "dialog-overlay";
    overlay.role = "presentation";

    const box = document.createElement("div");
    box.className = "dialog";
    box.role = "alertdialog";
    box.ariaModal = "true";

    const text = document.createElement("p");
    text.className = "dialog__question";
    text.textContent = question;

    const typed = document.createElement("input");
    typed.type = "text";
    typed.className = "dialog__field";
    typed.autocomplete = "off";
    typed.spellcheck = false;
    // Un identifiant de banque est une suite opaque de lettres et de chiffres :
    // le correcteur du système n'a rien à y faire, et une majuscule posée
    // d'office en changerait un.
    typed.autocapitalize = "off";
    typed.setAttribute("autocorrect", "off");
    typed.value = current;

    const buttons = document.createElement("div");
    buttons.className = "dialog__buttons";

    const confirm = document.createElement("button");
    confirm.type = "button";
    confirm.className = "dialog__button dialog__button--primary";
    confirm.textContent = confirmLabel;

    const cancel = document.createElement("button");
    cancel.type = "button";
    cancel.className = "dialog__button";
    cancel.textContent = cancelLabel;

    const close = (answer: string | null): void => {
      document.removeEventListener("keydown", onKeyDown, true);
      overlay.remove();
      if (previousFocus instanceof HTMLElement && previousFocus.isConnected) {
        previousFocus.focus();
      }
      resolve(answer);
    };

    const answer = (): void => {
      const written = typed.value.trim();
      close(written === "" ? null : written);
    };

    const onKeyDown = (event: KeyboardEvent): void => {
      if (event.key === "Escape") {
        event.preventDefault();
        event.stopPropagation();
        close(null);
      } else if (event.key === "Enter") {
        event.preventDefault();
        event.stopPropagation();
        answer();
      }
    };

    confirm.addEventListener("click", () => answer());
    cancel.addEventListener("click", () => close(null));
    overlay.addEventListener("mousedown", (event) => {
      if (event.target === overlay) {
        event.preventDefault();
      }
    });
    document.addEventListener("keydown", onKeyDown, true);

    buttons.append(confirm, cancel);
    box.append(text, typed, buttons);
    overlay.append(box);
    document.body.append(overlay);
    typed.focus();
    typed.select();
  });
}

/// Demande un **nombre entier**, et ne laisse rien d'autre entrer.
///
/// La deuxième barrière d'une saisie chiffrée, après celle du clavier : le
/// champ refuse les lettres, les signes et les espaces au moment où on les
/// tape — comme le champ monétaire — et l'appelant ramène ensuite la valeur
/// dans ses bornes. Radinus n'a pas d'année 1800 : on lui impose 1950 plutôt
/// que de la refuser (règle de Fabrice, 26/07/2026).
///
/// Résout au nombre saisi, ou à `null` si l'on renonce. Les bornes ne sont
/// **pas** appliquées ici : c'est le noyau qui les connaît, et c'est lui qui
/// ramène la valeur dedans.
export function askForWholeNumber(
  question: string,
  current: number,
  digits: number,
  confirmLabel: string,
  cancelLabel: string,
): Promise<number | null> {
  return new Promise((resolve) => {
    const previousFocus = document.activeElement;

    const overlay = document.createElement("div");
    overlay.className = "dialog-overlay";
    overlay.role = "presentation";

    const box = document.createElement("div");
    box.className = "dialog";
    box.role = "alertdialog";
    box.ariaModal = "true";

    const text = document.createElement("p");
    text.className = "dialog__question";
    text.textContent = question;

    const typed = document.createElement("input");
    typed.type = "text";
    typed.className = "dialog__field";
    typed.inputMode = "numeric";
    typed.autocomplete = "off";
    typed.spellcheck = false;
    typed.value = String(current);

    // Rien qui ne soit un chiffre n'entre, et pas plus de chiffres qu'il n'en
    // faut. Le collage et la dictée passent par la même porte : ce sont des
    // événements de saisie comme les autres.
    typed.addEventListener("beforeinput", (event) => {
      const inserted = (event as InputEvent).data ?? "";
      if ((event as InputEvent).inputType.startsWith("delete")) {
        return;
      }
      const start = typed.selectionStart ?? typed.value.length;
      const end = typed.selectionEnd ?? typed.value.length;
      const wouldBe = typed.value.slice(0, start) + inserted + typed.value.slice(end);
      if (!/^\d*$/.test(wouldBe) || wouldBe.length > digits) {
        event.preventDefault();
      }
    });

    const buttons = document.createElement("div");
    buttons.className = "dialog__buttons";

    const confirm = document.createElement("button");
    confirm.type = "button";
    confirm.className = "dialog__button dialog__button--primary";
    confirm.textContent = confirmLabel;

    const cancel = document.createElement("button");
    cancel.type = "button";
    cancel.className = "dialog__button";
    cancel.textContent = cancelLabel;

    const close = (answer: number | null): void => {
      document.removeEventListener("keydown", onKeyDown, true);
      overlay.remove();
      if (previousFocus instanceof HTMLElement && previousFocus.isConnected) {
        previousFocus.focus();
      }
      resolve(answer);
    };

    const answer = (): void => {
      const written = typed.value.trim();
      // Un champ vide n'est pas une réponse : on n'a rien dit.
      close(written === "" ? null : Number(written));
    };

    const onKeyDown = (event: KeyboardEvent): void => {
      if (event.key === "Escape") {
        event.preventDefault();
        event.stopPropagation();
        close(null);
      } else if (event.key === "Enter") {
        event.preventDefault();
        event.stopPropagation();
        answer();
      }
    };

    confirm.addEventListener("click", () => answer());
    cancel.addEventListener("click", () => close(null));
    overlay.addEventListener("mousedown", (event) => {
      if (event.target === overlay) {
        event.preventDefault();
      }
    });
    document.addEventListener("keydown", onKeyDown, true);

    buttons.append(confirm, cancel);
    box.append(text, typed, buttons);
    overlay.append(box);
    document.body.append(overlay);
    typed.focus();
    typed.select();
  });
}

/// Une question dont la réponse est un **montant** — la `Saisie()` de
/// WinDev, pour « Définir le solde initial pointé » (F08, menu Outils).
///
/// Le champ est un champ d'argent de Radinus, pas un champ de texte : il
/// refuse à la frappe ce qui ne peut pas être un montant et se met en forme
/// en sortant, exactement comme les cases de la fiche. Rendre la chaîne
/// plutôt qu'un nombre est voulu — c'est le noyau qui lit un montant, jamais
/// la fenêtre, et lui seul sait refuser ce qui n'en est pas un.
///
/// Rend `null` quand on renonce, ou quand le champ est laissé vide : ne rien
/// écrire n'est pas une réponse.
export function askForAmount(
  question: string,
  current: string,
  confirmLabel: string,
  cancelLabel: string,
): Promise<string | null> {
  return new Promise((resolve) => {
    const previousFocus = document.activeElement;

    const overlay = document.createElement("div");
    overlay.className = "dialog-overlay";
    overlay.role = "presentation";

    const box = document.createElement("div");
    box.className = "dialog";
    box.role = "alertdialog";
    box.ariaModal = "true";

    const text = document.createElement("p");
    text.className = "dialog__question";
    // La question porte des retours à la ligne : le noyau l'écrit en
    // plusieurs lignes, et une boîte qui les aplatirait la rendrait illisible.
    text.style.whiteSpace = "pre-line";
    text.textContent = question;

    const typed = document.createElement("input");
    typed.type = "text";
    typed.className = "dialog__field";
    typed.autocomplete = "off";
    typed.spellcheck = false;
    typed.value = current;
    asMoneyField(typed);

    const buttons = document.createElement("div");
    buttons.className = "dialog__buttons";

    const confirm = document.createElement("button");
    confirm.type = "button";
    confirm.className = "dialog__button dialog__button--primary";
    confirm.textContent = confirmLabel;

    const cancel = document.createElement("button");
    cancel.type = "button";
    cancel.className = "dialog__button";
    cancel.textContent = cancelLabel;

    const close = (answer: string | null): void => {
      document.removeEventListener("keydown", onKeyDown, true);
      overlay.remove();
      if (previousFocus instanceof HTMLElement && previousFocus.isConnected) {
        previousFocus.focus();
      }
      resolve(answer);
    };

    const answer = (): void => {
      const written = typed.value.trim();
      close(written === "" ? null : written);
    };

    const onKeyDown = (event: KeyboardEvent): void => {
      if (event.key === "Escape") {
        event.preventDefault();
        event.stopPropagation();
        close(null);
      } else if (event.key === "Enter") {
        event.preventDefault();
        event.stopPropagation();
        answer();
      }
    };

    confirm.addEventListener("click", () => answer());
    cancel.addEventListener("click", () => close(null));
    overlay.addEventListener("mousedown", (event) => {
      if (event.target === overlay) {
        event.preventDefault();
      }
    });
    document.addEventListener("keydown", onKeyDown, true);

    buttons.append(confirm, cancel);
    box.append(text, typed, buttons);
    overlay.append(box);
    document.body.append(overlay);
    typed.focus();
    typed.select();
  });
}

/// La réponse d'une question à **trois issues**.
export type ThreeWays = "first" | "second" | "stay";

/// Demande une question dont il y a trois réponses, et non deux.
///
/// La porte de la classification rapide en avait besoin (décision de Fabrice,
/// 27/07/2026) : quitter avec des modifications en attente offre trois sorties
/// — enregistrer, abandonner, rester — et un Oui/Non n'aurait pas su les dire.
/// Réduire à deux aurait forcé un choix entre perdre le travail sans le vouloir
/// et écrire sans l'avoir demandé.
///
/// **Échap répond « rester »**, comme partout ailleurs : la touche qui annule
/// ne doit jamais rien détruire ni rien écrire. Entrée répond la première, qui
/// est celle que l'on met en avant.
export function askThreeWays(
  question: string,
  firstLabel: string,
  secondLabel: string,
  stayLabel: string,
): Promise<ThreeWays> {
  return new Promise((resolve) => {
    const previousFocus = document.activeElement;

    const overlay = document.createElement("div");
    overlay.className = "dialog-overlay";
    overlay.role = "presentation";

    const box = document.createElement("div");
    box.className = "dialog";
    box.role = "alertdialog";
    box.ariaModal = "true";

    const text = document.createElement("p");
    text.className = "dialog__question";
    text.textContent = question;

    const buttons = document.createElement("div");
    buttons.className = "dialog__buttons";

    const close = (answer: ThreeWays): void => {
      document.removeEventListener("keydown", onKeyDown, true);
      overlay.remove();
      if (previousFocus instanceof HTMLElement && previousFocus.isConnected) {
        previousFocus.focus();
      }
      resolve(answer);
    };

    const onKeyDown = (event: KeyboardEvent): void => {
      if (event.key === "Escape") {
        event.preventDefault();
        event.stopPropagation();
        close("stay");
      } else if (event.key === "Enter") {
        event.preventDefault();
        event.stopPropagation();
        close("first");
      }
    };

    const made: HTMLButtonElement[] = [];
    for (const [label, answer, primary] of [
      [firstLabel, "first", true],
      [secondLabel, "second", false],
      [stayLabel, "stay", false],
    ] as const) {
      const button = document.createElement("button");
      button.type = "button";
      button.className = primary
        ? "dialog__button dialog__button--primary"
        : "dialog__button";
      button.textContent = label;
      button.addEventListener("click", () => close(answer));
      buttons.append(button);
      made.push(button);
    }

    overlay.addEventListener("mousedown", (event) => {
      if (event.target === overlay) {
        event.preventDefault();
      }
    });
    document.addEventListener("keydown", onKeyDown, true);

    box.append(text, buttons);
    overlay.append(box);
    document.body.append(overlay);
    made[0].focus();
  });
}

/// Demande de **choisir dans une liste**, et résout au choix, ou à `null` si
/// l'on renonce.
///
/// Un fichier OFX peut porter plusieurs comptes ; Radinus n'en importe qu'un,
/// celui que l'utilisateur désigne (règle de Fabrice, 27/07/2026). C'est la
/// seule question de l'importation à laquelle il n'y a pas de réponse
/// déductible : le fichier ne dit pas lequel des comptes on avait en tête.
/// `selected` ouvre la liste sur une valeur plutôt que sur la première : le
/// choix d'une imprimante s'ouvre sur celle par défaut du système, comme le
/// ferait le dialogue d'impression qu'aucun des trois webviews n'expose.
export function askForChoice(
  question: string,
  choices: string[],
  confirmLabel: string,
  cancelLabel: string,
  selected?: string,
): Promise<string | null> {
  return new Promise((resolve) => {
    const previousFocus = document.activeElement;

    const overlay = document.createElement("div");
    overlay.className = "dialog-overlay";
    overlay.role = "presentation";

    const box = document.createElement("div");
    box.className = "dialog";
    box.role = "alertdialog";
    box.ariaModal = "true";

    const text = document.createElement("p");
    text.className = "dialog__question";
    text.textContent = question;

    const list = document.createElement("select");
    list.className = "dialog__field";
    for (const choice of choices) {
      const entry = document.createElement("option");
      entry.value = choice;
      entry.textContent = choice;
      list.append(entry);
    }
    if (selected !== undefined && choices.includes(selected)) {
      list.value = selected;
    }

    const buttons = document.createElement("div");
    buttons.className = "dialog__buttons";

    const confirm = document.createElement("button");
    confirm.type = "button";
    confirm.className = "dialog__button dialog__button--primary";
    confirm.textContent = confirmLabel;

    const cancel = document.createElement("button");
    cancel.type = "button";
    cancel.className = "dialog__button";
    cancel.textContent = cancelLabel;

    const close = (answer: string | null): void => {
      document.removeEventListener("keydown", onKeyDown, true);
      overlay.remove();
      if (previousFocus instanceof HTMLElement && previousFocus.isConnected) {
        previousFocus.focus();
      }
      resolve(answer);
    };

    const onKeyDown = (event: KeyboardEvent): void => {
      if (event.key === "Escape") {
        event.preventDefault();
        event.stopPropagation();
        close(null);
      } else if (event.key === "Enter") {
        event.preventDefault();
        event.stopPropagation();
        close(list.value);
      }
    };

    confirm.addEventListener("click", () => close(list.value));
    cancel.addEventListener("click", () => close(null));
    overlay.addEventListener("mousedown", (event) => {
      if (event.target === overlay) {
        event.preventDefault();
      }
    });
    document.addEventListener("keydown", onKeyDown, true);

    buttons.append(confirm, cancel);
    box.append(text, list, buttons);
    overlay.append(box);
    document.body.append(overlay);
    list.focus();
  });
}

/// Demande **un mot de passe**, et rend ce qui a été tapé.
///
/// Née le 05/08/2026 avec le chiffrement des bases. Elle ne diffère de
/// [`askForText`] que par une chose, et cette chose est tout : le champ est de
/// type `password`, donc ce qui est tapé ne s'affiche pas et le gestionnaire
/// de mots de passe du système sait de quoi il s'agit.
///
/// Rend `null` quand on renonce **et quand le champ est laissé vide** : un mot
/// de passe vide n'est pas un mot de passe, c'est l'absence de réponse. La
/// base à laquelle on renonce reste simplement fermée.
///
/// La boîte ne porte aucun mot d'elle-même : la question et les deux boutons
/// lui sont donnés, comme partout ailleurs dans ce fichier.
export function askForPassword(
  question: string,
  confirmLabel: string,
  cancelLabel: string,
): Promise<string | null> {
  return new Promise((resolve) => {
    const previousFocus = document.activeElement;

    const overlay = document.createElement("div");
    overlay.className = "dialog-overlay";
    overlay.role = "presentation";

    const box = document.createElement("div");
    box.className = "dialog";
    box.role = "alertdialog";
    box.ariaModal = "true";

    const text = document.createElement("p");
    text.className = "dialog__question";
    text.textContent = question;

    const typed = document.createElement("input");
    typed.type = "password";
    typed.className = "dialog__field";
    typed.autocomplete = "current-password";
    typed.spellcheck = false;

    const buttons = document.createElement("div");
    buttons.className = "dialog__buttons";

    const confirm = document.createElement("button");
    confirm.type = "button";
    confirm.className = "dialog__button dialog__button--primary";
    confirm.textContent = confirmLabel;
    confirm.disabled = true;

    const cancel = document.createElement("button");
    cancel.type = "button";
    cancel.className = "dialog__button";
    cancel.textContent = cancelLabel;

    const close = (answer: string | null): void => {
      document.removeEventListener("keydown", onKeyDown, true);
      overlay.remove();
      if (previousFocus instanceof HTMLElement && previousFocus.isConnected) {
        previousFocus.focus();
      }
      resolve(answer);
    };

    const give = (): void => {
      if (typed.value === "") {
        return;
      }
      close(typed.value);
    };

    const onKeyDown = (event: KeyboardEvent): void => {
      if (event.key === "Escape") {
        event.preventDefault();
        event.stopPropagation();
        close(null);
      } else if (event.key === "Enter") {
        event.preventDefault();
        event.stopPropagation();
        give();
      }
    };

    typed.addEventListener("input", () => {
      confirm.disabled = typed.value === "";
    });
    confirm.addEventListener("click", () => give());
    cancel.addEventListener("click", () => close(null));
    overlay.addEventListener("mousedown", (event) => {
      if (event.target === overlay) {
        event.preventDefault();
      }
    });
    document.addEventListener("keydown", onKeyDown, true);

    buttons.append(confirm, cancel);
    box.append(text, typed, buttons);
    overlay.append(box);
    document.body.append(overlay);
    typed.focus();
  });
}
