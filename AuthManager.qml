import QtQuick
import Quickshell
import Quickshell.Io

Item {
  id: root

  visible: false
  width: 0
  height: 0

  required property string pluginDir

  property string teamId: ""
  property string keyId: ""
  property bool hasP8: false
  property string restToken: ""
  property string musicUserToken: ""
  property string lastError: ""
  property string statusText: ""
  property bool busy: false
  readonly property bool developerReady: restToken !== ""

  property string pendingStoreKind: ""
  property string pendingStoreLabel: "OmaApple"
  property string pendingStoreValue: ""
  property string pendingLookupKind: ""
  property string signPem: ""

  signal credentialsChanged()
  signal testFinished(bool ok, string message)

  function scripts() {
    return String(pluginDir || "") + "/scripts"
  }

  function restore() {
    lookupKind("team-id")
  }

  function lookupKind(kind) {
    if (lookupProc.running) return
    pendingLookupKind = kind
    lookupProc.command = [scripts() + "/keyring-lookup.sh", kind]
    lookupProc.running = true
  }

  function handleLookup(kind, value) {
    var text = String(value || "").replace(/\s+$/, "")
    if (kind === "team-id") {
      if (text) teamId = text
      lookupKind("key-id")
      return
    }
    if (kind === "key-id") {
      if (text) keyId = text
      lookupKind("musickit-p8")
      return
    }
    if (kind === "musickit-p8") {
      hasP8 = text !== ""
      if (hasP8 && teamId && keyId) signRestToken()
    }
  }

  function saveTeam(value) {
    teamId = String(value || "").trim()
    if (teamId) storeKind("team-id", "OmaApple Team ID", teamId)
    credentialsChanged()
  }

  function saveKey(value) {
    keyId = String(value || "").trim()
    if (keyId) storeKind("key-id", "OmaApple Key ID", keyId)
    credentialsChanged()
  }

  function storeKind(kind, label, value) {
    pendingStoreKind = kind
    pendingStoreLabel = label
    pendingStoreValue = value
    storeProc.command = [scripts() + "/keyring-store.sh", kind, label]
    storeProc.running = true
  }

  function importP8() {
    if (importProc.running) return
    lastError = ""
    statusText = "Opening file picker…"
    importProc.running = true
  }

  function pastePem(pem) {
    var text = String(pem || "")
    if (text.indexOf("PRIVATE KEY") < 0) {
      lastError = "Paste a MusicKit PEM private key"
      statusText = ""
      return
    }
    storeP8(text)
  }

  function storeP8(pem) {
    busy = true
    pendingStoreKind = "musickit-p8"
    pendingStoreLabel = "OmaApple MusicKit key"
    pendingStoreValue = pem
    storeProc.command = [scripts() + "/keyring-store.sh", "musickit-p8", "OmaApple MusicKit key"]
    storeProc.running = true
  }

  function signRestToken() {
    if (!hasP8 || !teamId || !keyId) {
      lastError = "Team ID, Key ID, and .p8 are all required"
      busy = false
      return
    }
    if (lookupProc.running || signProc.running) return
    busy = true
    statusText = "Signing developer token…"
    pendingLookupKind = "sign-p8"
    lookupProc.command = [scripts() + "/keyring-lookup.sh", "musickit-p8"]
    lookupProc.running = true
  }

  function startSign(pem) {
    signPem = pem
    signProc.command = [
      "python3", scripts() + "/sign-developer-token.py",
      "--team", teamId, "--kid", keyId, "--purpose", "rest"
    ]
    signProc.running = true
  }

  Process {
    id: lookupProc
    stdout: StdioCollector {
      id: lookupOut
      waitForEnd: true
    }
    stderr: StdioCollector { waitForEnd: true }
    onExited: function(code) {
      var kind = root.pendingLookupKind
      root.pendingLookupKind = ""
      var text = code === 0 ? String(lookupOut.text || "") : ""
      if (kind === "sign-p8") {
        if (!text) {
          root.busy = false
          root.lastError = "No MusicKit key in the keyring"
          return
        }
        root.startSign(text)
        return
      }
      root.handleLookup(kind, text)
    }
  }

  Process {
    id: storeProc
    stdinEnabled: true
    stdout: StdioCollector { waitForEnd: true }
    stderr: StdioCollector { waitForEnd: true }
    onStarted: {
      write(root.pendingStoreValue)
      stdinEnabled = false
    }
    onExited: function(code) {
      var kind = root.pendingStoreKind
      root.pendingStoreValue = ""
      stdinEnabled = true
      if (kind === "musickit-p8") {
        root.hasP8 = code === 0
        root.busy = false
        if (code !== 0) {
          root.lastError = "Could not store the key in the keyring"
          return
        }
        root.statusText = "Key stored. You may delete the downloaded file."
        root.signRestToken()
      }
    }
  }

  Process {
    id: importProc
    command: [root.scripts() + "/import-p8.sh"]
    stdout: StdioCollector {
      id: importOut
      waitForEnd: true
    }
    stderr: StdioCollector { waitForEnd: true }
    onExited: function(code) {
      if (code !== 0) {
        root.statusText = "No file selected"
        return
      }
      root.storeP8(String(importOut.text || ""))
    }
  }

  Process {
    id: signProc
    stdinEnabled: true
    stdout: StdioCollector {
      id: signOut
      waitForEnd: true
    }
    stderr: StdioCollector { waitForEnd: true }
    onStarted: {
      write(root.signPem)
      root.signPem = ""
      stdinEnabled = false
    }
    onExited: function(code) {
      root.busy = false
      stdinEnabled = true
      if (code !== 0) {
        root.restToken = ""
        root.lastError = "Could not sign a developer token"
        root.statusText = ""
        return
      }
      root.restToken = String(signOut.text || "").replace(/\s+$/, "")
      root.lastError = ""
      root.statusText = "Developer token ready. Search the catalog."
      root.credentialsChanged()
    }
  }
}
