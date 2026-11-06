---
name: form-validation
description: Project rules for validating user input in forms — always Flutter's `Form` + `TextFormField.validator`, errors from a Bloc/Riverpod state (async checks, server or relay rejection, wrong password) through a state-dependent or composed validator, a Save button that reflects unsaved changes rather than validity, rules as pure functions outside widgets, localized messages and tests. Use when adding or changing a form, a text field with an error message, a validator, a Save/Next/Submit button, or an input rule (URL, key, password, file name) in packages/notes, packages/chat or packages/common.
---

# Form validation

Validation answers one question: **is this field's value valid?** It always goes through Flutter's `Form` + `GlobalKey<FormState>` + `TextFormField.validator` ([cookbook](https://docs.flutter.dev/cookbook/forms/validation)). Validity is not stored in Bloc/Riverpod state and doesn't decide whether buttons are enabled.

Exceptions are possible but not pre-approved. If a form can't follow this skill, explain why in the PR.

## Base pattern

Reference: `BackupPasswordDialog` (`packages/notes/lib/common/presentation/dialogs/backup_password_dialog.dart`).

```dart
final _formKey = GlobalKey<FormState>(debugLabel: '_ProfileFormState');

Form(
  key: _formKey,
  autovalidateMode: AutovalidateMode.onUserInteraction,
  child: TextFormField(
    controller: _pictureController,
    validator: (value) => PictureUrl.isValidOrEmpty(value ?? '')
        ? null
        : context.l10n.profilePictureInvalid,
  ),
);

void _onSave() {
  if (_formKey.currentState?.validate() ?? false) {
    // read trimmed values and submit
  }
}
```

- Validate in two places: while typing with `autovalidateMode: AutovalidateMode.onUserInteraction` (errors appear after the first edit, not on an untouched form), and on submit with `validate()`. Submit only when `validate()` returns `true`.
- The form key is an instance field of the `State`. Don't make it `static`: two instances of the screen would share one key.
- A validator returns a localized message (`context.l10n...`) or `null`. Never hard-code the text.
- `inputFormatters` *prevent* input that can never be valid (`FilteringTextInputFormatter.deny(RegExp(r'\s'))`, `LengthLimitingTextInputFormatter`). Validators *explain* what is wrong.
- Shared field widgets (`OnboardingTextFormField` in `packages/common`) accept and forward `validator`. Don't add a parallel way to pass errors such as an `errorText` parameter.

## The Save button is not validation

The Save/Submit button answers a different question: **is there anything to save?**

- It is enabled when the current draft differs from the saved state (`hasChanges`: `draft.trimmed() != saved`). It is also disabled while saving is in progress.
- It is enabled even when a field is invalid. Pressing it runs `validate()`, which shows the errors and stops the submit.
- Don't put field validity into `canSave`, `isValid` flags or similar state getters.

## Errors from state: async checks and external rejections

Some errors come from outside the field: an async check, a usecase/relay rejection, or "wrong password" after decryption. They live in the Bloc/Riverpod state but still reach the UI **through the validator**.

**State-dependent validator** — when the field has no local rules:

```dart
final error = ref.watch(importProvider.select((s) => s.data.passwordError));

TextFormField(
  validator: (_) => switch (error) {
    WrongPasswordError() => l10n.importWrongPassword,
    null => null,
  },
);
```

**Composed validators** — local rules and the state error on the same field. Local rules run first, and the first non-null message wins:

```dart
typedef FieldValidator = String? Function(String? value);

FieldValidator composeValidators(List<FieldValidator> validators) =>
    (value) => validators
        .map((validate) => validate(value))
        .firstWhere((error) => error != null, orElse: () => null);

validator: composeValidators([
  (value) => PictureUrl.isValidOrEmpty(value ?? '') ? null : l10n.profilePictureInvalid,
  (_) => pictureRejected ? l10n.profilePictureRejected : null,
]),
```

Rules for state errors:
- The state stores a typed error (a sealed class or exception), never a message string. The widget maps it to l10n.
- **Show it:** a new error arrives through a rebuild, but a validator that isn't triggered shows nothing. Re-validate in the listener: `ref.listen` / `BlocListener` → `_formKey.currentState?.validate()` when the error appears.
- **Clear it:** the error belongs to the value it was raised for. The field's `onChanged` calls the state holder (`provider.onPasswordChanged(value)`), which drops the error. Otherwise the field stays red after the user has fixed it.
- Put `composeValidators` in `packages/common` once a second form needs it.

## Where the rule lives

- The rule is a pure function or value object in `domain/`. Examples: `PictureUrl.isValidOrEmpty` (`packages/chat/lib/auth/settings/domain/models/picture_url.dart`), `ExportKeysUsecase.minPasswordLength`. The validator only maps its result to a message.
- The validator guards the UI, not the data. The usecase or value object still enforces the same rule and throws a typed exception (for example `ProfileException`) when handed invalid input.
- Limits are named constants (`_maxFileNameLength`), not magic numbers inside the validator.
- Trim before validating and submitting. The function name or its `///` says whether empty is "valid: nothing set" (`isValidOrEmpty`) or "required".
- A rule used by both apps goes to `packages/common`. See the `feature-layout` skill.

## Accessibility and tests

- Each field gets `Semantics(identifier: ...)`, with the id a `static const` on the screen (`ProfileScreen.pictureFieldSemanticsId`), so tests and Marionette can find it.
- Unit-test the rule function directly: valid, invalid, empty and whitespace-only input, plus boundaries. Test `composeValidators` once, with its order.
- Cover the screen in a BDD or widget test: an error appears after typing, Save with an invalid field shows the error and publishes nothing, a state error appears and clears on edit, and a valid Save succeeds. Find fields by semantics id and assert on visible messages, not on validator closures.
