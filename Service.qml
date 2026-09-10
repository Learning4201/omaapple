import QtQuick

// Shared state for the bar widget and the lazy full panel.
// Scaffold only: no network, no playback helper, no listening loop.
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
}
