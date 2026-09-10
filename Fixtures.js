.pragma library

var recentlyPlayed = [
  { id: "1613600188", title: "Song one", artist: "Artist", duration: "3:12" },
  { id: "1613600189", title: "Song two", artist: "Artist", duration: "4:01" },
  { id: "1613600190", title: "Song three", artist: "Artist", duration: "2:48" }
]

var recentlyAdded = [
  { id: "1613600191", title: "New addition", artist: "Artist", duration: "3:40" }
]

var searchHits = [
  { id: "1001", title: "Catalog hit", artist: "Artist", duration: "3:05" },
  { id: "1002", title: "Catalog hit", artist: "Artist", duration: "4:22" }
]

var shortcutRows = [
  { keys: "Ctrl+F / /", action: "Search" },
  { keys: "Tab / F6", action: "Cycle sidebar / search / list / transport" },
  { keys: "Arrows, Enter", action: "Move / activate" },
  { keys: "Space", action: "Play / pause (later PR)" },
  { keys: "Ctrl+Left / Right", action: "Prev / next (later PR)" },
  { keys: "Shift+Left / Right", action: "Seek (later PR)" },
  { keys: "Ctrl+Up / Down", action: "Volume (later PR)" },
  { keys: "Ctrl+S / Ctrl+R", action: "Shuffle / repeat (later PR)" },
  { keys: "Alt+Shift+N", action: "Now playing" },
  { keys: "Ctrl+/", action: "Shortcut overlay" },
  { keys: "Esc", action: "Close mini-player / panel" }
]

var shortcutSnippet = "hl.unbind(\"SUPER + SHIFT + M\")\n"
  + "o.bind(\"SUPER + SHIFT + M\", \"OmaApple\",\n"
  + "  \"omarchy shell -q io.github.Learning4201.omaapple.player togglePlayer\")"

function navItems() {
  return [
    { id: "listen", label: "Listen Now" },
    { id: "library", label: "Library" },
    { id: "search", label: "Search" },
    { id: "queue", label: "Queue" },
    { id: "nowplaying", label: "Now playing" },
    { id: "settings", label: "Settings" }
  ]
}
