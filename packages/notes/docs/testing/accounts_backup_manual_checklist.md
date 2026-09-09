# Accounts Backup — Manual Testing Checklist

Manual QA checklist for the accounts (login items) export/import feature.
Complements the automated coverage in
`test/auth/data/login_items/export_import_accounts_usecase_test.dart` and
`test/auth/data/export_import_usecase_test.dart` — this list focuses on what
those tests can't reach: real UI flow, platform differences, the standalone
Python decrypt script, and manual verification that nothing sensitive leaks
into plaintext.

Related code: `ExportAccountsUsecaseImpl`, `ImportAccountsUsecaseImpl`,
`AccountsBackupBloc`, `ExportImportScreen`,
`packages/notes/lib/auth/data/backup_templates_accounts.dart`.

## Export accounts

- [ ] Empty vault → clear "no accounts to export" error, no crash
- [ ] 1 account with some fields blank (no username/notes) exports without error
- [ ] Many accounts (10+), including one locked item (undecryptable due to
      wrong PIN) — the locked one is silently skipped, doesn't abort the
      whole export
- [ ] Password validation: empty password blocked before the Ok button does
      anything; under 3 chars shows the min-length message; a valid password
      proceeds
- [ ] Custom file name: illegal characters (`\/:*?"<>|`) get stripped; a name
      of only dots/spaces is rejected; a trailing `.zip` isn't duplicated
- [ ] Default file name has a timestamp and starts with `accounts_backup_`
- [ ] Cancelling the password dialog does nothing, no crash
- [ ] **Real share sheet**: iOS/Android show the native share sheet with the
      zip attached; Web triggers a browser download with the right file
      name; macOS shows the native save-file dialog
- [ ] Success snackbar says **"Accounts exported successfully"**, not
      "Notes exported…" (this exact mix-up was caught and fixed once
      already — worth re-checking by hand)
- [ ] **Open the archive by hand**: in `accounts_export.json`, confirm
      title/username/password/url are NOT visible anywhere in plaintext —
      only the `d` tag appears in `tags`, everything else is inside the
      encrypted `content`

## Import accounts

- [ ] A valid backup restores all fields (title/username/password/url/notes,
      totp/image if set) into an empty vault
- [ ] Wrong password → clear "wrong password" error, nothing gets written
- [ ] Empty password is blocked before the file is even read
- [ ] A corrupted/truncated zip → "invalid file", not a crash
- [ ] **Cross-format check**: importing a *notes* backup through the
      *accounts* import flow (and vice versa) is rejected as invalid — not
      silently imported as garbage
- [ ] Collisions on real UI (not just unit tests): locally edit an account
      that shares a d-tag with the backup, run all three policies
      (`keepNewest` / `keepIncoming` / `keepExisting`), confirm the list
      shows the expected version after each
- [ ] Import with no active session → clear auth error, not a crash
- [ ] Cancelling the import dialog / cancelling the file picker leaves
      nothing partially written
- [ ] A large backup (50–100 accounts) imports without the progress bar
      stalling
- [ ] Success snackbar says "Accounts imported successfully", settings
      screen closes

## Cross-account / cross-device

- [ ] Export from account A, import into account B (after switching) —
      decrypts correctly under B's own vault identity
- [ ] Export on one platform (e.g. iOS), import on another (Android/Web) —
      the file format is platform-agnostic
- [ ] Re-exporting the same vault twice keeps the same vault pubkey on the
      events (not re-randomized per export)

## The standalone Python script (`decrypt_backup.py`)

Nothing automated ever runs this — it's an independent reimplementation of
the same crypto in Python, so it needs its own manual pass.

- [ ] Run with the correct password from the extracted folder — output JSON
      has readable title/username/password/url/notes/rev/updated_at
      matching what's in the app
- [ ] Run with the wrong password — reports "MAC verification failed" per
      item, then "All accounts failed — password likely wrong"
- [ ] `--output accounts.json` actually writes the file
- [ ] Running it directly against `backup.zip` (no manual extraction) works
- [ ] `pip install cryptography` in a clean virtualenv is really sufficient
- [ ] `BACKUP_README.md` renders correctly in a plain markdown viewer (code
      blocks, tables, no broken formatting)

## UI / localization

- [ ] The "Notes" and "Accounts" sections are visually distinct, each with
      its own `sectionTitle`
- [ ] While an accounts export/import is running, the notes items are
      disabled (and vice versa) — no way to kick off both at once
- [ ] The shared `ProgressHud` doesn't flicker or double-trigger switching
      between the two flows
- [ ] Switch the app language to RU and BG — check every new string
      (dialog titles, errors, hints, success snackbars) for missing-key
      fallback text

## Security spot-checks

- [ ] Actually try tapping Ok with an empty password in the export dialog —
      validation physically blocks it, not just discouraged
- [ ] Watch the console/logs during an import — the password never appears
      in plain text in any log line
