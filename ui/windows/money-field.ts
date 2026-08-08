// A field that holds money, and nothing else.
//
// **Written once, called by every window** (author's instruction, 25/07/2026):
// the fiche compte today, the fiche opération, the transfer between accounts,
// the budget and the cheques tomorrow. One place to correct, one behaviour for
// the user to learn.
//
// It refuses at the keyboard what cannot belong to an amount — a letter does
// not appear, a second decimal separator does not appear, a third decimal does
// not appear — so an incoherent field cannot be created in the first place.
// Pasting and dictation go through the same gate: they are input events like
// any other.
//
// The two sign keys are not characters at all but commands on the whole
// number, wherever the cursor is: `-` switches the sign, `+` makes it
// positive. See [`flipSignOf`].
//
// **That is not the only barrier, and it must not be.** The core re-reads
// every amount before writing and refuses rather than guessing: a field can be
// filled by something other than this class — a restored backup, an imported
// statement — and one barrier alone always ends up going around. What used to
// happen is why: an unreadable amount became 0,00 € in silence, and in a
// program that handles money a balance that silently becomes zero falsifies
// every balance of the account's life.
//
// On leaving the field, what was typed is written out properly: two decimals,
// thousands grouped, the separators of the current language.

import { t } from "./texts";

/// What a language uses to write an amount. Both come from the dictionary,
/// which comes from the core: the interface invents no format of its own.
function separators(): { thousands: string; decimal: string } {
  return {
    thousands: t("ui-thousands-separator"),
    decimal: t("ui-decimal-separator"),
  };
}

/// Whether `text` could still become an amount as it is being typed. Looser
/// than the core's reader on purpose: "12," and "-" are not amounts, but they
/// are amounts halfway through being typed, and refusing them would make the
/// field impossible to use.
export function couldBecomeAnAmount(text: string, decimal: string): boolean {
  if (text === "" || text === "-") {
    return true;
  }
  const body = text.startsWith("-") ? text.slice(1) : text;
  const parts = body.split(decimal);
  if (parts.length > 2) {
    return false;
  }
  const [whole, fraction = ""] = parts;
  if (!/^\d*$/.test(whole) || !/^\d*$/.test(fraction)) {
    return false;
  }
  if (whole === "" && fraction === "" && parts.length < 2) {
    return false;
  }
  // Two decimals is what a centime needs; a third is a slip of the finger,
  // and there is no reason to let it be typed.
  return fraction.length <= 2;
}

/// **A sign is not a character in an amount, it is a key that acts on the
/// whole number** (Fabrice, 26/07/2026). Neither one is inserted where the
/// cursor happens to be — « 12-34 » is not an amount, and nobody should have
/// to go back to the start of a field to change a figure's sign.
///
/// The two keys do not do the same thing, and that is deliberate:
///
///   * **`-` switches**: it makes the number negative, and typing it again
///     makes it positive — the same key undoes what it did;
///   * **`+` asserts**: it makes the number positive and leaves it positive,
///     however many times it is pressed. There is no way to press it and end
///     up with a debit by mistake.
export function flipSignOf(text: string): string {
  return text.startsWith("-") ? text.slice(1) : `-${text}`;
}

/// The amount made positive, whatever it was.
export function madePositive(text: string): string {
  return text.startsWith("-") ? text.slice(1) : text;
}

/// The event a money field fires when one of those two keys was used — even
/// when the text did not move, since pressing `+` on a positive number still
/// says something: the user means a positive amount.
///
/// It reports what the field did, not what it means. A window where the sign
/// also lives somewhere else — the Débit/Crédit combo of the fiche opération
/// — listens to it and keeps the two in step. Nothing is remembered on either
/// side: the event is the moment the sign was set, and the field is read as
/// it stands then.
export const SIGN_CHANGED = "radinus:sign-changed";

/// Writes an amount out: two decimals, thousands grouped.
export function writeAmount(text: string, thousands: string, decimal: string): string {
  const negative = text.trim().startsWith("-");
  const body = text.replace("-", "");
  const [whole = "", fraction = ""] = body.split(decimal);
  const units = whole.replace(/^0+(?=\d)/, "") || "0";
  const centimes = (fraction + "00").slice(0, 2);

  let grouped = "";
  for (let index = 0; index < units.length; index += 1) {
    if (index > 0 && (units.length - index) % 3 === 0) {
      grouped += thousands;
    }
    grouped += units[index];
  }

  const written = `${grouped}${decimal}${centimes}`;
  // Minus zero is zero.
  return negative && written.replace(/\D/g, "") !== "000" ? `-${written}` : written;
}

/// Turns a plain text input into a money field. Returns nothing: the field is
/// the input itself, so everything that already reads `.value` keeps working
/// — including the reserve that decides whether the fiche was modified.
export function asMoneyField(input: HTMLInputElement): void {
  input.classList.add("form__field--amount");
  input.inputMode = "decimal";
  input.autocomplete = "off";
  input.spellcheck = false;

  // Every way of putting text in a field goes through this: the keyboard,
  // pasting, dictation, dragging text in.
  input.addEventListener("beforeinput", (event) => {
    const { decimal } = separators();
    const inserted = (event as InputEvent).data ?? "";
    const start = input.selectionStart ?? input.value.length;
    const end = input.selectionEnd ?? input.value.length;
    const wouldBe =
      input.value.slice(0, start) + inserted + input.value.slice(end);

    // A deletion is always allowed: one has to be able to empty a field.
    if ((event as InputEvent).inputType.startsWith("delete")) {
      return;
    }

    // A sign on its own is one of the two keys above, not a character to
    // insert. It acts on the whole number wherever the cursor is, and the
    // cursor keeps the digit it was on — the text has simply gained or lost
    // one character in front of it. A sign arriving inside a longer text (a
    // paste of « -70 ») is not this: that is an amount, and it goes through
    // the normal gate below.
    if (inserted === "-" || inserted === "−" || inserted === "+") {
      event.preventDefault();
      const signed =
        inserted === "+" ? madePositive(input.value) : flipSignOf(input.value);
      const caret = Math.max(0, start + signed.length - input.value.length);
      input.value = signed;
      input.setSelectionRange(caret, caret);
      input.dispatchEvent(new Event("input", { bubbles: true }));
      input.dispatchEvent(new Event(SIGN_CHANGED, { bubbles: true }));
      return;
    }
    // A comma or a full stop both mean "here come the decimals", whichever
    // the keyboard produced.
    const normalized = wouldBe.replace(/[.,]/g, decimal);
    if (!couldBecomeAnAmount(normalized, decimal)) {
      event.preventDefault();
      return;
    }
    if (normalized !== wouldBe) {
      event.preventDefault();
      input.value = normalized;
      input.setSelectionRange(start + inserted.length, start + inserted.length);
      input.dispatchEvent(new Event("input", { bubbles: true }));
    }
  });

  // Leaving the field writes what is in it out properly.
  input.addEventListener("blur", () => {
    const { thousands, decimal } = separators();
    const written = writeAmount(input.value, thousands, decimal);
    if (written !== input.value) {
      input.value = written;
      input.dispatchEvent(new Event("input", { bubbles: true }));
    }
  });
}
