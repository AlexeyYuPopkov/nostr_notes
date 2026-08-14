---
name: self-documenting-code
description: Write code that explains itself through naming and structure instead of prose. Use when adding or reviewing any Dart/Flutter code in this repo — it defines when a comment is warranted and when a name, constant, or extracted function should carry the meaning instead.
---
# Self-Documenting Code

The default is **no comment**. A comment is a fallback for meaning that cannot live in the code — not a normal part of writing it.

## Contents
- [Make the code carry it](#make-the-code-carry-it)
- [When a comment earns its place](#when-a-comment-earns-its-place)
- [Never write these](#never-write-these)
- [Doc comments](#doc-comments)
- [Review checklist](#review-checklist)

## Make the code carry it

Before writing a comment, try each of these in order. Most explanatory comments disappear at the first or second step.

**Name the value.** A magic number with a comment becomes a named constant.

```dart
// Bad
// icon is a bit smaller than the ring so it fits inside
size: size.width - 10,

// Good
static const _iconSizeRatio = 0.6;
size: size.shortestSide * _iconSizeRatio,
```

**Name the condition.** A boolean expression that needed a comment becomes a named local.

```dart
// Bad
// don't auto-unlock if the user explicitly exited on this same account
if (current is Auth && current.pubkey == keys.publicKey && !current.authologinIfPossible) {

// Good
final alreadyOptedOut = current is Auth &&
    current.pubkey == keys.publicKey &&
    !current.authologinIfPossible;
if (alreadyOptedOut) {
```

**Name the step.** If a block needs a header comment to be readable, extract it into a function whose name is that comment.

```dart
// Bad
// cancel every relay subscription and close the status subject
subA?.cancel();
subB?.cancel();
subject.close();

// Good
await _releaseRelayResources();
```

**Let types state the rule.** Sealed classes, enums, and non-nullable fields express constraints that a comment can only ask readers to remember. `Session`/`Auth`/`Unlocked` and `RelayStatus` already do this — extend that pattern rather than documenting valid values in prose.

## When a comment earns its place

Only for information the code genuinely cannot hold:

- **Why, never what.** A tradeoff, an ordering requirement, a deliberate deviation.
  ```dart
  // Overlay.initialEntries is consumed once, at the Overlay's initState — a
  // fresh entry per build would never be inserted nor disposed.
  late final _childEntry = OverlayEntry(builder: (_) => widget.child);
  ```
- **External quirks and upstream bugs**, with a concrete reference so the note can be retired.
  ```dart
  // flutter_slidable 4.0.3: SlidableController.dispose() (controller.dart:371)
  // leaves these four notifiers undisposed. Drop once the package ships a fix.
  ```
- **Non-obvious lifecycle or async semantics** — what a stream replays, what closing does, what runs synchronously.

A justified comment is still short. One line is the norm; a paragraph means the design likely needs the explanation more than the reader does.

## Never write these

- **Paraphrase of the next line.** `// increment the counter` above `counter++`.
- **Commented-out code.** Delete it — git has the history. This repo has accumulated several dead blocks (`_PinIconBadge`, disabled `onTap` params); remove them when you touch the surrounding code rather than adding more.
- **Changelog or attribution.** `// added by ...`, `// fixed the crash` — that belongs in the commit message.
- **Bare `TODO`.** Either state the condition that resolves it, or leave it out.
- **Banner dividers inside a class** to compensate for it being too large — split the class instead. (Section markers separating top-level test fixtures from mocks are fine.)

## Doc comments

`///` is for a public contract that the signature does not already state: units, side effects, ordering guarantees, what `null` or an empty collection means, what the caller must dispose.

```dart
// Bad — restates the name, adds nothing
/// Returns the relay statuses.
Stream<Map<String, RelayStatus>> get statuses;

// Good — states what the signature cannot
/// Replays the current status of every configured relay to each new
/// subscriber, then emits on change. A relay missing from the map has not
/// reported yet. Closed by [dispose].
Stream<Map<String, RelayStatus>> get statuses;
```

Do not add `///` to every public member reflexively. A method named `removeAccount(String pubkey)` that removes an account needs nothing.

## Review checklist

For each comment in a diff:

1. Would a rename, a constant, or an extracted function remove the need for it? Do that instead.
2. Does it say *what* the code does? Delete it.
3. Does it restate a name? Delete it.
4. Is it commented-out code or a changelog note? Delete it.
5. Does it explain *why*, an external quirk, or a non-obvious contract? Keep it — and shorten it to the point.
