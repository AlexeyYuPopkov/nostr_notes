#!/usr/bin/env python3
"""
Decrypt a Nostr Notes backup.

Usage (run from the extracted backup folder):
    python3 decrypt_backup.py
    python3 decrypt_backup.py --output notes.json
    python3 decrypt_backup.py --password "your password"

You can also pass the path to the JSON (or ZIP) explicitly:
    python3 decrypt_backup.py notes_export.json
    python3 decrypt_backup.py backup.zip --password "your password"

Requirements:
    pip install cryptography
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

ARCHIVE_ENTRY = "notes_export.json"


def pbkdf2_key(password: str, salt_hex: str, iterations: int) -> bytes:
    salt = bytes.fromhex(salt_hex)
    return hashlib.pbkdf2_hmac("sha256", password.encode("utf-8"), salt, iterations, dklen=32)


def _aes_cbc_decrypt(key: bytes, iv: bytes, ciphertext: bytes) -> bytes:
    """AES-256-CBC + PKCS7 unpadding. Tries 'cryptography', then 'pycryptodome'."""
    # --- attempt 1: cryptography ---
    try:
        from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
        from cryptography.hazmat.primitives import padding as cp

        dec = Cipher(algorithms.AES(key), modes.CBC(iv)).decryptor()
        padded = dec.update(ciphertext) + dec.finalize()
        u = cp.PKCS7(128).unpadder()
        return u.update(padded) + u.finalize()
    except ImportError:
        pass

    # --- attempt 2: pycryptodome ---
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
    """Return a copy of the Nostr event with decrypted content and tags."""
    result = dict(event)

    result["content"] = decrypt_field(event.get("content", ""), key)

    new_tags = []
    for tag in event.get("tags", []):
        if isinstance(tag, list) and len(tag) >= 2 and tag[0] in ("summary", "labels"):
            new_tag = list(tag)
            new_tag[1] = decrypt_field(tag[1], key)
            new_tags.append(new_tag)
        else:
            new_tags.append(tag)
    result["tags"] = new_tags

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
            "Decrypt a Nostr Notes backup and output the notes as JSON.\n"
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
        help="Backup password (omit to be prompted; irrelevant for unencrypted backups)",
    )
    parser.add_argument(
        "--output", "-o",
        help="Write decrypted JSON to this file (default: print to stdout)",
    )
    args = parser.parse_args()

    # Resolve input path.
    if args.input:
        source = Path(args.input)
    else:
        source = Path(__file__).parent / ARCHIVE_ENTRY

    if not source.exists():
        print(f"File not found: {source}", file=sys.stderr)
        print(
            f"Run this script from the extracted backup folder, or pass the path explicitly.",
            file=sys.stderr,
        )
        sys.exit(1)

    # Load payload.
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

    # Decrypt events (or pass through if not encrypted).
    if not payload.get("encrypted"):
        events = payload["events"]
        print("Backup is not encrypted.", file=sys.stderr)
    else:
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
                note_id = event.get("id", "?")
                print(f"Warning: could not decrypt event {note_id}: {exc}", file=sys.stderr)
                events.append(event)
                errors += 1

        if errors and errors == len(payload["events"]):
            print("\nAll events failed — the password is likely wrong.", file=sys.stderr)
            sys.exit(1)

    # Output.
    output_json = json.dumps(events, indent=2, ensure_ascii=False)

    if args.output:
        Path(args.output).write_text(output_json, encoding="utf-8")
        print(f"Decrypted {len(events)} note(s) → {args.output}", file=sys.stderr)
    else:
        print(output_json)


if __name__ == "__main__":
    main()
