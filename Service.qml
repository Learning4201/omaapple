import QtQuick

Item {
  id: root

  visible: false
  width: 0
  height: 0

  property var shell: null
  property var manifest: null
  property var pluginRegistry: null

  readonly property string pluginId: manifest && manifest.id
    ? String(manifest.id) : "io.github.Learning4201.omaapple"
  readonly property string pluginDir: manifest && manifest.__sourceDir
    ? String(manifest.__sourceDir) : ""

  readonly property var defaultSettingValues: ({
    idleShutdownMinutes: 15,
    showMiniPlayer: "On",
    shortcutPlayer: "Omarchy Music app",
    shortcutHints: "On",
    showTrackTitle: "On",
    showArtistName: "Off",
    showPausedTrack: "On",
    scrollBarText: "Off",
    scrollSpeed: "1",
    maxBarTextWidth: "240",
    playbackHost: "chromium-apple-origin"
  })

  property var settings: defaultSettingValues
  property string currentTab: "listen"
  property bool accountConnected: false
  property bool shortcutHintsEnabled: String(setting("shortcutHints", "On")) !== "Off"
  property string title: ""
  property string artist: ""
  property bool playing: false
  property bool hasMedia: title !== ""
  property string storefront: "us"
  property var detailItem: null

  readonly property string shortcutPlayer: String(setting("shortcutPlayer", "Omarchy Music app"))
  readonly property string playbackHost: String(setting("playbackHost", "chromium-apple-origin"))
  readonly property int idleShutdownMinutes: Math.max(0, Math.min(1440,
    Math.floor(Number(setting("idleShutdownMinutes", 15)) || 0)))
  readonly property bool showMiniPlayer: String(setting("showMiniPlayer", "On")) !== "Off"
  readonly property bool otherApplePlugins: detectOtherApplePlugins()
  readonly property var auth: authManager
  readonly property var api: musicApi

  function setting(name, fallback) {
    if (settings && settings[name] !== undefined && settings[name] !== null)
      return settings[name]
    if (defaultSettingValues[name] !== undefined) return defaultSettingValues[name]
    return fallback
  }

  function detectOtherApplePlugins() {
    var ids = ["melonamin.apple-music", "iuliansafta.apple-music", "pestov.apple-music"]
    if (!pluginRegistry || typeof pluginRegistry.isEnabled !== "function")
      return false
    for (var i = 0; i < ids.length; i++) {
      try {
        if (pluginRegistry.isEnabled(ids[i])) return true
      } catch (e) { }
    }
    return false
  }

  function chooseTab(tab) {
    currentTab = String(tab || "listen")
  }

  AuthManager {
    id: authManager
    pluginDir: root.pluginDir
  }

  AppleMusicApi {
    id: musicApi
    auth: authManager
  }

  onPluginDirChanged: if (pluginDir) authManager.restore()
  Component.onCompleted: if (pluginDir) authManager.restore()
}
