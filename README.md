# OmaApple

**Native Omarchy UI. Official Apple playback engine.**

```
OmaSpotify:  Quickshell UI  +  Spotify Web API  +  librespot (native decoder)
OmaApple:    Quickshell UI  +  Apple Music API  +  MusicKit JS in a hidden playback Chromium
```

The **product UI** is native QML inside `omarchy-shell`, themed to Omarchy, with a bar icon and a full player. **Playback is Apple's official web engine**, isolated and headless — not a themed copy of Apple's website, and not a native decoder. Linux has no MusicKit SDK, and Apple does not stream audio over the REST API.

This repository is the scaffold (PR 1). It validates as an Omarchy 4 plugin, shows a bar icon, and does **not** play audio yet.

## Install

```bash
omarchy plugin add https://github.com/Learning4201/omaapple.git --enable
```

Requires Omarchy 4 (Quattro). Playback and library sign-in (later PRs) also need:

- An Apple Music subscription
- Your own MusicKit key from the Apple Developer Program ($99/year if you are not already a member)

v1 will not ship a shared developer token.

## Keyboard shortcut

OmaApple never rewrites compositor config. Stock Omarchy binds **Super+Shift+M** to the Music app. Settings will offer the same three-way choice as OmaSpotify (Music app / full player / mini-player). To point that bind at OmaApple yourself:

```lua
hl.unbind("SUPER + SHIFT + M")
o.bind("SUPER + SHIFT + M", "OmaApple",
  "omarchy shell -q io.github.Learning4201.omaapple.player togglePlayer")
```

## What v1 will cover

Sign-in, catalog search, library (after Apple ID authorize), transport, queue, shuffle/repeat, bar mini-player, MPRIS, theme, keyboard. Listen Now is recently played and recently added only.

Not in v1: radio, lyrics, listening stats, AirPlay, lossless, add-to-library writes, a hosted token mint.

## Develop

```bash
./scripts/test.sh
```

Runs `omarchy plugin validate`, Qt 6 `qmllint`, and a forbidden-pattern scan.

## License

MIT. Independent project, not affiliated with Apple Inc. or Omarchy/Basecamp.

Apple, Apple Music, and MusicKit are trademarks of Apple Inc.
