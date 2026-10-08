// Embedded text content for the Nostr keys backup ZIP.
// Stored as Dart constants instead of Flutter assets — see backup_templates.dart
// for why (iOS App.framework can't bundle a .py file).

const String kKeysDecryptBackupPy = r'''#!/usr/bin/env python3
"""
Decrypt a Nostr Notes keys backup and print the private keys (nsec).

Usage (run from the extracted backup folder):
    python3 decrypt_keys.py
    python3 decrypt_keys.py --output keys.json
    python3 decrypt_keys.py --password "your password"

You can also pass the path to the JSON (or ZIP) explicitly:
    python3 decrypt_keys.py keys_export.json
    python3 decrypt_keys.py backup.zip --password "your password"

Requirements:
    pip install cryptography        (or: pip install pycryptodome)

The output contains your PRIVATE KEYS in plain text. Anyone who sees an
nsec controls that Nostr account. Do not save the output anywhere you would
not store the keys themselves.
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

ARCHIVE_ENTRY = "keys_export.json"
PAYLOAD_TYPE = "nostr_keys"


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
    """
    ct_b64, rest = encoded.split("?iv=", 1)
    iv_b64, mac_b64 = rest.split("&mac=", 1)

    ciphertext = base64.b64decode(ct_b64)
    iv = base64.b64decode(iv_b64)
    stored_mac = base64.b64decode(mac_b64)

    expected_mac = hmac.new(key, ciphertext, hashlib.sha256).digest()
    if not hmac.compare_digest(expected_mac, stored_mac):
        raise ValueError("MAC verification failed — wrong password or corrupted backup")

    return _aes_cbc_decrypt(key, iv, ciphertext).decode("utf-8")


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
            "Decrypt a Nostr Notes keys backup and output the keys as JSON.\n"
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

    source = Path(args.input) if args.input else Path(__file__).parent / ARCHIVE_ENTRY

    if not source.exists():
        print(f"File not found: {source}", file=sys.stderr)
        print(
            "Run this script from the extracted backup folder, or pass the path explicitly.",
            file=sys.stderr,
        )
        sys.exit(1)

    payload = load_payload(source)

    if payload.get("type") != PAYLOAD_TYPE:
        print("This file is not a Nostr Notes keys backup.", file=sys.stderr)
        sys.exit(1)

    if payload.get("version") != 1:
        print(f"Warning: unknown backup version {payload.get('version')}", file=sys.stderr)

    exported_at = payload.get("exported_at")
    if exported_at:
        print(f"Backup created: {exported_at}", file=sys.stderr)

    for entry in payload["keys"]:
        label = f" ({entry['label']})" if entry.get("label") else ""
        print(f"Contains: {entry['npub']}{label}", file=sys.stderr)

    password = args.password
    if password is None:
        password = getpass.getpass("Backup password: ")

    key = pbkdf2_key(password, payload["salt"], payload["iterations"])

    keys = []
    for entry in payload["keys"]:
        try:
            nsec = decrypt_field(entry["nsec"], key)
        except Exception as exc:
            print(f"Could not decrypt {entry['npub']}: {exc}", file=sys.stderr)
            sys.exit(1)
        keys.append({"npub": entry["npub"], "label": entry.get("label"), "nsec": nsec})

    output_json = json.dumps(keys, indent=2, ensure_ascii=False)

    if args.output:
        Path(args.output).write_text(output_json, encoding="utf-8")
        print(f"Decrypted {len(keys)} key(s) → {args.output}", file=sys.stderr)
    else:
        print(output_json)


if __name__ == "__main__":
    main()
''';

const String kKeysBackupReadmeMd =
    r'''# Nostr Notes — Keys Backup Format & Decryption

This archive contains one or more **Nostr private keys (nsec)** exported from
**Nostr Notes**. It **always requires a password**: an nsec is your account
itself — whoever has it controls the account.

To restore, open the app, choose **Sign In → Load from File** and enter the
backup password. You can also decrypt the keys without the app using the
included Python script.

---

## Archive contents

| File | Description |
|---|---|
| `keys_export.json` | Your keys; each `nsec` is AES-encrypted, the `npub` is not |
| `decrypt_keys.py` | Python script to decrypt and print the keys |
| `BACKUP_README.md` | This file |

---

## Decrypting with the script

Python 3.7+ and the `cryptography` (or `pycryptodome`) package:

```bash
pip install cryptography
python3 decrypt_keys.py
```

The script prompts for the password unless `--password` is given. Use
`--output keys.json` to write the result to a file — it will contain your
private keys in plain text.

---

## JSON structure

```json
{
  "version": 1,
  "type": "nostr_keys",
  "exported_at": "2026-10-08T12:34:56.000Z",
  "salt": "a1b2c3...",
  "iterations": 600000,
  "keys": [
    { "npub": "npub1...", "label": "Main", "nsec": "<encrypted>" }
  ]
}
```

| Field | Description |
|---|---|
| `version` | Backup format version (currently `1`) |
| `type` | Always `nostr_keys` |
| `exported_at` | ISO-8601 UTC timestamp of when the backup was created |
| `salt` | Hex-encoded 16-byte random salt |
| `iterations` | PBKDF2 iteration count |
| `keys[].npub` | Public key — not secret, lets you see whose keys these are |
| `keys[].label` | Account name, if it had one (optional) |
| `keys[].nsec` | Encrypted private key |

---

## Manual decryption

1. **Derive the key**: PBKDF2-HMAC-SHA256 over the UTF-8 password, salt
   `hex_decode(salt)`, `iterations` rounds, 32-byte output.
2. **Split** each `nsec` field: `base64(ciphertext)?iv=base64(iv)&mac=base64(mac)`.
3. **Verify the MAC**: `HMAC-SHA256(key, ciphertext)` must equal `mac`; a
   mismatch means a wrong password or a corrupted file.
4. **Decrypt**: AES-256-CBC with the derived key and IV, then remove PKCS7
   padding. The result is the `nsec1...` string.

---

## Security notes

- The key is derived with **PBKDF2-SHA256** (`iterations` rounds) — choose a
  strong, unique password; a short one can be brute-forced offline.
- Every key is encrypted with its own random IV, and the HMAC detects tampering.
- The `npub` is stored in plain text on purpose: it is public and lets you
  recognise the backup without decrypting it.
- **Treat decrypted output as the keys themselves.** Never paste an nsec into
  a website or chat.
''';
