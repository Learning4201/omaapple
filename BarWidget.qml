import QtQuick
import Quickshell.Io
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "io.github.Learning4201.omaapple"

  property bool popupOpen: false
  property bool popoutSwitchClosing: false

  readonly property var apple: root.bar && root.bar.shell
    ? root.bar.shell.serviceFor("io.github.Learning4201.omaapple") : null
  readonly property bool miniPlayerEnabled: String(root.setting("showMiniPlayer", "On")) !== "Off"
  readonly property bool showTrackTitle: String(root.setting("showTrackTitle", "On")) !== "Off"
  readonly property string barText: {
    if (!apple || !apple.hasMedia || !showTrackTitle) return ""
    return apple.title || ""
  }
  readonly property bool opened: popupOpen
  readonly property color foreground: root.bar ? root.bar.foreground : Color.foreground

  implicitWidth: vertical ? barSize : row.implicitWidth + Style.space(12)
  implicitHeight: barSize

  function open() { popupOpen = true }
  function close() { popupOpen = false }
  function toggle() {
    if (miniPlayerEnabled) popupOpen ? close() : open()
    else openFullPanel()
  }
  function closeForPopoutSwitch() {
    popoutSwitchClosing = true
    close()
    Qt.callLater(function() { root.popoutSwitchClosing = false })
  }

  function shortcutPlayer() {
    return String(root.setting("shortcutPlayer", "Omarchy Music app"))
  }

  function openFullPanel() {
    close()
    if (!bar || !bar.shell || typeof bar.shell.summon !== "function") return
    bar.shell.summon(root.moduleName, "{}")
  }

  function toggleMiniPlayerShortcut() {
    if (!bar || typeof bar.summonBarWidget !== "function") return "unavailable"
    if (typeof bar.isBarWidgetOpen === "function" && bar.isBarWidgetOpen(moduleName)
        && typeof bar.hideBarWidget === "function") {
      return bar.hideBarWidget(moduleName) ? "closed" : "unavailable"
    }
    return bar.summonBarWidget(moduleName) ? "opened" : "unavailable"
  }

  function toggleFullPlayerShortcut() {
    var host = bar ? bar.shell : null
    if (!host || typeof host.summon !== "function") return "unavailable"
    if (typeof host.isPluginOpen === "function" && host.isPluginOpen(moduleName)
        && typeof host.hide === "function") {
      host.hide(moduleName)
      return "closed"
    }
    return host.summon(moduleName, "{}") ? "opened" : "unavailable"
  }

  function toggleConfiguredPlayerShortcut() {
    var target = shortcutPlayer()
    if (target === "Full player") return toggleFullPlayerShortcut()
    if (target === "Mini player") return toggleMiniPlayerShortcut()
    if (!bar || typeof bar.run !== "function") return "unavailable"
    bar.run("omarchy launch spotify")
    return "launched"
  }

  Row {
    id: row
    anchors.centerIn: parent
    spacing: Style.space(6)

    OpticalGlyph {
      id: glyph
      width: Style.bar.iconCanvas
      height: Style.bar.iconCanvas
      text: "󰝚"
      fontFamily: root.bar && root.bar.fontFamily ? root.bar.fontFamily : Style.font.family
      fontSize: Style.bar.iconFont
      color: root.foreground
    }

    Text {
      visible: !root.vertical && barText !== ""
      text: root.barText
      textFormat: Text.PlainText
      color: root.foreground
      font.family: Style.font.family
      font.pixelSize: Style.font.body
      elide: Text.ElideRight
    }
  }

  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.LeftButton
    cursorShape: Qt.PointingHandCursor
    onClicked: root.toggle()
  }

  IpcHandler {
    target: root.moduleName + ".player"

    function togglePlayer(): string {
      return root.toggleConfiguredPlayerShortcut()
    }
    function toggleMiniPlayer(): string {
      return root.toggleMiniPlayerShortcut()
    }
    function toggleFullPlayer(): string {
      return root.toggleFullPlayerShortcut()
    }
  }

  KeyboardPanel {
    id: popup
    anchorItem: root
    bar: root.bar
    owner: root
    open: root.popupOpen
    contentWidth: fittedContentWidth(Style.space(280))
    contentHeight: fittedContentHeight(miniColumn.implicitHeight)

    Column {
      id: miniColumn
      width: Style.space(256)
      spacing: Style.space(10)

      Row {
        width: parent.width
        spacing: Style.space(10)

        Rectangle {
          width: Style.space(52)
          height: Style.space(52)
          color: "transparent"
          border.width: 1
          border.color: root.foreground
        }

        Column {
          width: Math.max(40, parent.width - Style.space(62))
          anchors.verticalCenter: parent.verticalCenter
          spacing: 2
          Text {
            width: parent.width
            text: root.apple && root.apple.hasMedia ? root.apple.title : "Track title"
            textFormat: Text.PlainText
            elide: Text.ElideRight
            color: root.foreground
            font.family: Style.font.family
            font.pixelSize: Style.font.body
          }
          Text {
            width: parent.width
            text: root.apple && root.apple.hasMedia ? root.apple.artist : "Artist · Album"
            textFormat: Text.PlainText
            elide: Text.ElideRight
            color: Color.muted
            font.family: Style.font.family
            font.pixelSize: Style.font.caption
          }
        }
      }

      PlaybackSlider {
        width: parent.width
        foreground: root.foreground
        track: Color.muted
      }

      Row {
        spacing: Style.space(8)
        TransportButton { glyph: "prev" }
        TransportButton { glyph: "play"; primary: true }
        TransportButton { glyph: "next" }
        TransportButton { glyph: "shuf" }
        TransportButton { glyph: "rep" }
      }

      Button {
        text: "Open full player"
        bordered: true
        onClicked: root.openFullPanel()
      }
    }
  }
}
