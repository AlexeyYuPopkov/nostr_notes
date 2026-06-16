# Nostr Notes — Backup Format & Decryption

This archive contains your notes exported from **Nostr Notes**.  
You can decrypt and read them independently of the app using the included Python script.

---

## Archive contents

| File | Description |
|---|---|
| `notes_export.json` | Your notes in Nostr event format (content is encrypted if you set a password) |
| `decrypt_backup.py` | Python script to decrypt and extract notes |
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
python3 decrypt_backup.py --output notes.json
```

To pass the password directly (not recommended for security):

```bash
python3 decrypt_backup.py --password "your password" --output notes.json
```

The script will prompt for the password interactively if `--password` is not provided.

You can also point the script at a specific file:

```bash
python3 decrypt_backup.py notes_export.json --output notes.json
python3 decrypt_backup.py backup.zip --output notes.json   # ZIP still supported
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
| `encrypted` | `true` if a password was set during export |
| `exported_at` | ISO-8601 UTC timestamp of when the backup was created |
| `salt` | Hex-encoded 16-byte random salt (only when encrypted) |
| `iterations` | PBKDF2 iteration count (only when encrypted) |
| `events` | Array of Nostr events |

If `"encrypted": false`, the `content` and tags are already plain text.

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

### 2. Decrypt each field

Encrypted fields are: `content` (event body), `summary` tag value, `labels` tag value.

Each encrypted field has the format:

```
base64(ciphertext)?iv=base64(iv)&mac=base64(mac)
```

Decryption steps:

1. **Verify MAC**: `HMAC-SHA256(key, ciphertext)` must equal the stored `mac`.  
   A mismatch means the password is wrong or the file is corrupted.
2. **Decrypt**: AES-256-CBC with the derived key and the given IV.
3. **Remove padding**: PKCS7 (block size 16 bytes).

```python
import base64, hmac, hashlib
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
from cryptography.hazmat.primitives import padding

def decrypt_field(encoded, key):
    ct_b64, rest   = encoded.split("?iv=", 1)
    iv_b64, mac_b64 = rest.split("&mac=", 1)

    ciphertext  = base64.b64decode(ct_b64)
    iv          = base64.b64decode(iv_b64)
    stored_mac  = base64.b64decode(mac_b64)

    # Verify
    expected = hmac.new(key, ciphertext, hashlib.sha256).digest()
    assert hmac.compare_digest(expected, stored_mac), "Wrong password"

    # Decrypt
    cipher    = Cipher(algorithms.AES(key), modes.CBC(iv))
    decryptor = cipher.decryptor()
    padded    = decryptor.update(ciphertext) + decryptor.finalize()

    unpadder  = padding.PKCS7(128).unpadder()
    return (unpadder.update(padded) + unpadder.finalize()).decode("utf-8")
```

### 3. Note structure

Each decrypted event is a [NIP-01](https://github.com/nostr-protocol/nostr/blob/master/01.md) Nostr event of kind `30023`.  
The note fields map as follows:

| Nostr field | Note field |
|---|---|
| `content` | Note body (Markdown) |
| tag `["summary", …]` | Auto-generated summary |
| tag `["labels", …]` | Comma-separated labels |
| tag `["d", …]` | Unique note ID |
| `created_at` | Unix timestamp of last publish |
| tag `["init_at", …]` | Unix timestamp of first creation |

---

## Security notes

- The key is derived with **600 000 PBKDF2-SHA256 iterations** — brute-forcing a strong password is computationally infeasible.
- Each field is encrypted with a **unique random IV**, so identical content produces different ciphertexts.
- The **HMAC-SHA256 MAC** ensures integrity: any tampering is detected before decryption.
- An unencrypted export (no password) stores notes as plain Nostr JSON — anyone with the file can read them.
