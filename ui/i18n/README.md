# Interface texts

There is nothing here, and there will not be.

Everything the user reads lives in `radinus-core/i18n/fr.ftl` and `en.ftl` —
one source, in both languages, for the business messages **and** for every
word the windows, the Oui/Non dialog, the window titles and the menu bar say
(author's ruling, 25/07/2026: "le logiciel fonctionne avec Fluent en français
et en anglais dès le début").

A window asks Rust for its whole vocabulary as it loads (`ui_texts`) and shows
what it is given. It holds no sentence of its own, so a sentence cannot exist
in one language only.

The `fr.json` / `en.json` files this folder used to announce were never filled:
two dictionaries in two formats would have been two places to forget.
