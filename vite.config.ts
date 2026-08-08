import { defineConfig } from "vite";

// @ts-expect-error process is a nodejs global
const host = process.env.TAURI_DEV_HOST;

// https://vite.dev/config/
export default defineConfig(async () => ({

  // Every Radinus window is its own HTML page (macOS gets independent system
  // windows, not a MDI area -- 03_CHARTE_GRAPHIQUE.md 3.1), so each one is a
  // build entry point of its own.
  build: {
    rollupOptions: {
      input: {
        main: "index.html",
        "language-choice": "ui/windows/language-choice.html",
        "database-selector": "ui/windows/database-selector.html",
        "database-form": "ui/windows/database-form.html",
        "password-form": "ui/windows/password-form.html",
        preferences: "ui/windows/preferences.html",
        "about-author": "ui/windows/about-author.html",
        "about-radinus": "ui/windows/about-radinus.html",
        licence: "ui/windows/licence.html",
        "attachments-manager": "ui/windows/attachments-manager.html",
        "nomenclature-list": "ui/windows/nomenclature-list.html",
        "nomenclature-form": "ui/windows/nomenclature-form.html",
        "accounts-list": "ui/windows/accounts-list.html",
        "account-form": "ui/windows/account-form.html",
        balances: "ui/windows/balances.html",
        "operations-list": "ui/windows/operations-list.html",
        "operation-form": "ui/windows/operation-form.html",
        "sub-operation-form": "ui/windows/sub-operation-form.html",
        statistics: "ui/windows/statistics.html",
        dashboard: "ui/windows/dashboard.html",
        "balance-curves": "ui/windows/balance-curves.html",
        "quick-classification": "ui/windows/quick-classification.html",
        "statement-import": "ui/windows/statement-import.html",
        "statement-form": "ui/windows/statement-form.html",
        "csv-statement": "ui/windows/csv-statement.html",
        "chequebooks-list": "ui/windows/chequebooks-list.html",
        "chequebook-form": "ui/windows/chequebook-form.html",
        "cheques-list": "ui/windows/cheques-list.html",
        "cheque-form": "ui/windows/cheque-form.html",
        "cheque-operations": "ui/windows/cheque-operations.html",
        "operation-templates-list": "ui/windows/operation-templates-list.html",
        "operation-template-form": "ui/windows/operation-template-form.html",
        budget: "ui/windows/budget.html",
        transfer: "ui/windows/transfer.html",
        "recurring-list": "ui/windows/recurring-list.html",
        "recurring-form": "ui/windows/recurring-form.html",
        "recurring-calendar": "ui/windows/recurring-calendar.html",
        rib: "ui/windows/rib.html",
        journal: "ui/windows/journal.html",
        attachments: "ui/windows/attachments.html",
        "excel-import": "ui/windows/excel-import.html",
        "excel-fields": "ui/windows/excel-fields.html",
        "excel-association": "ui/windows/excel-association.html",
      },
    },
  },

  // Vite options tailored for Tauri development and only applied in `tauri dev` or `tauri build`
  //
  // 1. prevent Vite from obscuring rust errors
  clearScreen: false,
  // 2. tauri expects a fixed port, fail if that port is not available
  server: {
    port: 1420,
    strictPort: true,
    host: host || false,
    hmr: host
      ? {
          protocol: "ws",
          host,
          port: 1421,
        }
      : undefined,
    watch: {
      // 3. tell Vite to ignore watching `src-tauri`
      ignored: ["**/src-tauri/**"],
    },
  },
}));
