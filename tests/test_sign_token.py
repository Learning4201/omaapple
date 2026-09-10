#!/usr/bin/env python3
"""Sign a throwaway P-256 key and check JWT header/payload (no live Apple)."""
from __future__ import annotations

import base64
import json
import os
import subprocess
import sys
import tempfile


def b64url_decode(part: str) -> bytes:
    pad = "=" * ((4 - len(part) % 4) % 4)
    return base64.urlsafe_b64decode(part + pad)


def main() -> int:
    root = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
    signer = os.path.join(root, "scripts", "sign-developer-token.py")
    work = tempfile.mkdtemp(prefix="omaapple-jwt-")
    try:
        key = os.path.join(work, "key.pem")
        subprocess.check_call(
            ["openssl", "ecparam", "-name", "prime256v1", "-genkey", "-noout", "-out", key],
            stderr=subprocess.DEVNULL,
        )
        pem = open(key, "rb").read()
        token = subprocess.check_output(
            [
                sys.executable,
                signer,
                "--team",
                "ABCDE12345",
                "--kid",
                "FGHIJ67890",
                "--purpose",
                "rest",
                "--ttl",
                "3600",
            ],
            input=pem,
        ).decode("ascii")
        parts = token.split(".")
        if len(parts) != 3:
            print("expected three JWT parts", file=sys.stderr)
            return 1
        header = json.loads(b64url_decode(parts[0]))
        payload = json.loads(b64url_decode(parts[1]))
        if header.get("alg") != "ES256":
            print("alg", header, file=sys.stderr)
            return 1
        if header.get("kid") != "FGHIJ67890":
            print("kid", header, file=sys.stderr)
            return 1
        if payload.get("iss") != "ABCDE12345":
            print("iss", payload, file=sys.stderr)
            return 1
        if "origin" in payload:
            print("REST JWT must omit origin", file=sys.stderr)
            return 1

        musickit = subprocess.check_output(
            [
                sys.executable,
                signer,
                "--team",
                "ABCDE12345",
                "--kid",
                "FGHIJ67890",
                "--purpose",
                "musickit",
            ],
            input=pem,
        ).decode("ascii")
        mk_payload = json.loads(b64url_decode(musickit.split(".")[1]))
        origins = mk_payload.get("origin") or []
        if "https://music.apple.com" not in origins:
            print("musickit origin missing", mk_payload, file=sys.stderr)
            return 1
        print("sign-developer-token ok")
        return 0
    finally:
        try:
            os.remove(key)
            os.rmdir(work)
        except OSError:
            pass


if __name__ == "__main__":
    raise SystemExit(main())
