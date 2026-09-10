#!/usr/bin/env python3
"""Sign an Apple Music developer JWT.

Reads the MusicKit .p8 from stdin. Prints only the compact JWT to stdout.
Never logs the key or the token.
"""
from __future__ import annotations

import argparse
import base64
import json
import os
import subprocess
import sys
import tempfile
import time


def b64url(data: bytes) -> str:
    return base64.urlsafe_b64encode(data).rstrip(b"=").decode("ascii")


def der_ecdsa_to_rs(der: bytes) -> bytes:
    """Convert OpenSSL ECDSA DER signature to JOSE r||s (32+32 bytes)."""
    if len(der) < 8 or der[0] != 0x30:
        raise ValueError("openssl signature was not an ECDSA DER sequence")
    seq_len = der[1]
    if seq_len & 0x80:
        raise ValueError("unexpected long-form ECDSA sequence")
    i = 2

    def take_int() -> int:
        nonlocal i
        if der[i] != 0x02:
            raise ValueError("ECDSA integer tag missing")
        i += 1
        n = der[i]
        i += 1
        raw = der[i : i + n]
        i += n
        return int.from_bytes(raw, "big")

    r = take_int()
    s = take_int()
    return r.to_bytes(32, "big") + s.to_bytes(32, "big")


def sign_input(p8: bytes, signing_input: bytes) -> bytes:
    runtime = os.environ.get("XDG_RUNTIME_DIR") or "/tmp"
    fd, path = tempfile.mkstemp(prefix="omaapple-p8-", dir=runtime)
    try:
        os.write(fd, p8)
        os.close(fd)
        fd = -1
        os.chmod(path, 0o600)
        der = subprocess.check_output(
            ["openssl", "dgst", "-sha256", "-sign", path],
            input=signing_input,
            stderr=subprocess.DEVNULL,
        )
        return der_ecdsa_to_rs(der)
    finally:
        if fd >= 0:
            os.close(fd)
        try:
            os.remove(path)
        except OSError:
            pass


def main() -> int:
    parser = argparse.ArgumentParser(add_help=True)
    parser.add_argument("--team", required=True, help="Apple Team ID (iss)")
    parser.add_argument("--kid", required=True, help="MusicKit key id")
    parser.add_argument(
        "--purpose",
        choices=("rest", "musickit"),
        default="rest",
    )
    parser.add_argument("--ttl", type=int, default=2592000, help="seconds, max 15777000")
    args = parser.parse_args()

    team = args.team.strip()
    kid = args.kid.strip()
    if len(team) != 10 or len(kid) != 10:
        print("sign-developer-token: team and kid must be 10 characters", file=sys.stderr)
        return 2

    ttl = max(60, min(int(args.ttl), 15777000))
    p8 = sys.stdin.buffer.read()
    if b"PRIVATE KEY" not in p8:
        print("sign-developer-token: stdin was not a PEM private key", file=sys.stderr)
        return 3

    now = int(time.time())
    header = {"alg": "ES256", "kid": kid}
    payload = {"iss": team, "iat": now, "exp": now + ttl}
    if args.purpose == "musickit":
        payload["origin"] = [
            "https://beta.music.apple.com",
            "https://music.apple.com",
        ]

    signing_input = (
        b64url(json.dumps(header, separators=(",", ":")).encode("ascii"))
        + "."
        + b64url(json.dumps(payload, separators=(",", ":")).encode("ascii"))
    ).encode("ascii")
    sig = sign_input(p8, signing_input)
    sys.stdout.write(signing_input.decode("ascii") + "." + b64url(sig))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
