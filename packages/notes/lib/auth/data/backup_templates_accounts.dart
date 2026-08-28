// Embedded text content for the accounts export ZIP.
// Stored as Dart constants instead of Flutter assets — see backup_templates.dart
// for why (iOS App.framework can't bundle a .py file).

const String kAccountsDecryptBackupPy = r'''#!/usr/bin/env python3
"""
Decrypt a Nostr Notes accounts (password manager) backup.

Usage (run from the extracted backup folder):
    python3 decrypt_backup.py
    python3 decrypt_backup.py --output accounts.json
    python3 decrypt_backup.py --password "your password"

You can also pass the path to the JSON (or ZIP) explicitly:
    python3 decrypt_backup.py accounts_export.json
    python3 decrypt_backup.py backup.zip --password "your password"

Requirements:
    pip install cryptography

This backup ALWAYS requires a password — it contains your account
passwords, so an unencrypted export was never offered.
"""

import argparse
import base64
import getpass
import hashlib
import hmac
import json
import sys
import zipfile
from pathlib import Path

ARCHIVE_ENTRY = "accounts_export.json"


def pbkdf2_key(password: str, salt_hex: str, iterations: int) -> bytes:
    salt = bytes.fromhex(salt_hex)
    return hashlib.pbkdf2_hmac("sha256", password.encode("utf-8"), salt, iterations, dklen=32)


def _aes_cbc_decrypt(key: bytes, iv: bytes, ciphertext: bytes) -> bytes:
    """AES-256-CBC + PKCS7 unpadding. Tries 'cryptography', then 'pycryptodome'."""
    try:
        from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
        from cryptography.hazmat.primitives import padding as cp

        dec = Cipher(algorithms.AES(key), modes.CBC(iv)).decryptor()
        padded = dec.update(ciphertext) + dec.finalize()
        u = cp.PKCS7(128).unpadder()
        return u.update(padded) + u.finalize()
    except ImportError:
        pass

    try:
        from Crypto.Cipher import AES
        from Crypto.Util.Padding import unpad

        return unpad(AES.new(key, AES.MODE_CBC, iv).decrypt(ciphertext), 16)
    except ImportError:
        pass

    print(
        "No AES library available. Install one of:\n"
        "    pip install cryptography\n"
        "    pip install pycryptodome",
        file=sys.stderr,
    )
    sys.exit(1)


def decrypt_field(encoded: str, key: bytes) -> str:
    """Decrypt a single AES-256-CBC field.

    Expected format: base64(ciphertext)?iv=base64(iv)&mac=base64(mac)
    Returns the plaintext string.
    """
    if not encoded:
        return encoded

    try:
        ct_b64, rest = encoded.split("?iv=", 1)
        iv_b64, mac_b64 = rest.split("&mac=", 1)
    except ValueError:
        return encoded

    ciphertext = base64.b64decode(ct_b64)
    iv = base64.b64decode(iv_b64)
    stored_mac = base64.b64decode(mac_b64)

    expected_mac = hmac.new(key, ciphertext, hashlib.sha256).digest()
    if not hmac.compare_digest(expected_mac, stored_mac):
        raise ValueError("MAC verification failed — wrong password or corrupted backup")

    return _aes_cbc_decrypt(key, iv, ciphertext).decode("utf-8")


def decrypt_event(event: dict, key: bytes) -> dict:
    """Return a copy of the event with `content` replaced by the decrypted,
    parsed account payload (title/username/password/url/notes/…)."""
    result = dict(event)
    decrypted = decrypt_field(event.get("content", ""), key)
    try:
        result["content"] = json.loads(decrypted)
    except json.JSONDecodeError:
        result["content"] = decrypted
    return result


def load_payload(source: Path) -> dict:
    """Load the backup payload from a JSON file or a ZIP archive."""
    if source.suffix.lower() == ".zip":
        try:
            with zipfile.ZipFile(source) as zf:
                with zf.open(ARCHIVE_ENTRY) as f:
                    return json.load(f)
        except KeyError:
            print(f"'{ARCHIVE_ENTRY}' not found inside {source}.", file=sys.stderr)
            sys.exit(1)
    else:
        with open(source, encoding="utf-8") as f:
            return json.load(f)


def main() -> None:
    parser = argparse.ArgumentParser(
        description=(
            "Decrypt a Nostr Notes accounts backup and output the accounts as JSON.\n"
            "Run without arguments from the extracted backup folder."
        ),
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    parser.add_argument(
        "input",
        nargs="?",
        help=(
            f"Path to {ARCHIVE_ENTRY} or a .zip backup file. "
            f"Defaults to {ARCHIVE_ENTRY} in the same folder as this script."
        ),
    )
    parser.add_argument(
        "--password", "-p",
        help="Backup password (omit to be prompted)",
    )
    parser.add_argument(
        "--output", "-o",
        help="Write decrypted JSON to this file (default: print to stdout)",
    )
    args = parser.parse_args()

    if args.input:
        source = Path(args.input)
    else:
        source = Path(__file__).parent / ARCHIVE_ENTRY

    if not source.exists():
        print(f"File not found: {source}", file=sys.stderr)
        print(
            "Run this script from the extracted backup folder, or pass the path explicitly.",
            file=sys.stderr,
        )
        sys.exit(1)

    try:
        payload = load_payload(source)
    except FileNotFoundError:
        print(f"File not found: {source}", file=sys.stderr)
        sys.exit(1)

    if payload.get("version") != 1:
        print(f"Warning: unknown backup version {payload.get('version')}", file=sys.stderr)

    exported_at = payload.get("exported_at")
    if exported_at:
        print(f"Backup created: {exported_at}", file=sys.stderr)

    password = args.password
    if password is None:
        password = getpass.getpass("Backup password: ")

    key = pbkdf2_key(password, payload["salt"], payload["iterations"])

    events = []
    errors = 0
    for event in payload["events"]:
        try:
            events.append(decrypt_event(event, key))
        except Exception as exc:
            item_id = event.get("id") or next(
                (t[1] for t in event.get("tags", []) if t and t[0] == "d"), "?"
            )
            print(f"Warning: could not decrypt account {item_id}: {exc}", file=sys.stderr)
            events.append(event)
            errors += 1

    if errors and errors == len(payload["events"]):
        print("\nAll accounts failed — the password is likely wrong.", file=sys.stderr)
        sys.exit(1)

    output_json = json.dumps(events, indent=2, ensure_ascii=False)

    if args.output:
        Path(args.output).write_text(output_json, encoding="utf-8")
        print(f"Decrypted {len(events)} account(s) → {args.output}", file=sys.stderr)
    else:
        print(output_json)


if __name__ == "__main__":
    main()
''';

const String kAccountsBackupReadmeMd =
    r'''# Nostr Notes — Accounts Backup Format & Decryption

This archive contains your saved accounts (logins) exported from **Nostr Notes**.
It **always requires a password** — unlike a notes backup, this file can contain
your actual account passwords, so an unencrypted export was never offered.

You can decrypt and read it independently of the app using the included Python script.

---

## Archive contents

| File | Description |
|---|---|
| `accounts_export.json` | Your accounts in Nostr event format, `content` AES-encrypted |
| `decrypt_backup.py` | Python script to decrypt and extract accounts |
| `BACKUP_README.md` | This file |

---

## Decrypting with the script

### Requirements

Python 3.7+ and the `cryptography` package:

```bash
pip install cryptography
```

### Usage

Run the script from this folder (no arguments needed):

```bash
python3 decrypt_backup.py
```

To save the output to a file:

```bash
python3 decrypt_backup.py --output accounts.json
```

The script will prompt for the password interactively if `--password` is not provided.

You can also point the script at a specific file:

```bash
python3 decrypt_backup.py accounts_export.json --output accounts.json
python3 decrypt_backup.py backup.zip --output accounts.json   # ZIP still supported
```

---

## JSON structure

```json
{
  "version": 1,
  "encrypted": true,
  "exported_at": "2026-06-16T12:34:56.000Z",
  "salt": "a1b2c3...",
  "iterations": 600000,
  "events": [ ... ]
}
```

| Field | Description |
|---|---|
| `version` | Backup format version (currently `1`) |
| `encrypted` | Always `true` for accounts |
| `exported_at` | ISO-8601 UTC timestamp of when the backup was created |
| `salt` | Hex-encoded 16-byte random salt |
| `iterations` | PBKDF2 iteration count |
| `events` | Array of Nostr events, kind `31023` |

---

## Manual decryption

### 1. Derive the AES key

Algorithm: **PBKDF2-HMAC-SHA256**

- Password: your backup password (UTF-8)
- Salt: `hex_decode(payload.salt)` — 16 bytes
- Iterations: `payload.iterations` (600 000)
- Output length: 32 bytes

```python
import hashlib
key = hashlib.pbkdf2_hmac(
    "sha256",
    password.encode("utf-8"),
    bytes.fromhex(salt_hex),
    iterations,
    dklen=32,
)
```

### 2. Decrypt the `content` field

Unlike a notes backup (separate `content`/`summary`/`labels` fields), an
account's *entire* payload — title, username, password, url, notes — is
JSON-encoded and encrypted as a single `content` field, mirroring how it's
already stored NIP-44-encrypted on the wire.

```
base64(ciphertext)?iv=base64(iv)&mac=base64(mac)
```

Decryption steps:

1. **Verify MAC**: `HMAC-SHA256(key, ciphertext)` must equal the stored `mac`.
   A mismatch means the password is wrong or the file is corrupted.
2. **Decrypt**: AES-256-CBC with the derived key and the given IV.
3. **Remove padding**: PKCS7 (block size 16 bytes).
4. **Parse as JSON** — the result is the account payload object.

```python
import base64, hmac, hashlib, json
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
from cryptography.hazmat.primitives import padding

def decrypt_field(encoded, key):
    ct_b64, rest    = encoded.split("?iv=", 1)
    iv_b64, mac_b64 = rest.split("&mac=", 1)

    ciphertext = base64.b64decode(ct_b64)
    iv         = base64.b64decode(iv_b64)
    stored_mac = base64.b64decode(mac_b64)

    expected = hmac.new(key, ciphertext, hashlib.sha256).digest()
    assert hmac.compare_digest(expected, stored_mac), "Wrong password"

    cipher    = Cipher(algorithms.AES(key), modes.CBC(iv))
    decryptor = cipher.decryptor()
    padded    = decryptor.update(ciphertext) + decryptor.finalize()

    unpadder = padding.PKCS7(128).unpadder()
    plaintext = (unpadder.update(padded) + unpadder.finalize()).decode("utf-8")
    return json.loads(plaintext)
```

### 3. Account payload structure

Each decrypted `content` is a JSON object:

| Field | Description |
|---|---|
| `v` | Payload format version |
| `title` | Account/site name |
| `username` | Login username or email |
| `password` | The saved password |
| `url` | Website URL |
| `notes` | Free-text notes |
| `updated_at` | Unix timestamp of last edit (optional) |
| `image` | Icon reference (optional) |
| `totp` | Reserved for TOTP secrets (optional) |
| `rev` | Content-save counter |

The event's own `tags` carry only the `d` tag — the account's unique ID.
Everything else lives inside the encrypted `content`, matching how the app
stores it on relays: no plaintext tag reveals which service an account
belongs to.

---

## Security notes

- The key is derived with **600 000 PBKDF2-SHA256 iterations** — brute-forcing a strong password is computationally infeasible.
- The whole account payload is encrypted with a **unique random IV**, so identical accounts produce different ciphertexts.
- The **HMAC-SHA256 MAC** ensures integrity: any tampering is detected before decryption.
- **Choose a strong, unique backup password.** This file, once decrypted, contains your real account passwords in plain text — treat the decrypted output at least as carefully as a password manager's own database.
''';
