import QtQuick
import qs.Commons
import qs.Ui
import "Fixtures.js" as Fixtures

Item {
  id: root

  property var service: null
  property color foreground: Color.foreground
  property color muted: Color.muted
  property color urgent: Color.urgent
  property bool otherApplePlugins: false

  Column {
    anchors.fill: parent
    spacing: Style.space(8)

    PanelSectionHeader {
      text: "Settings"
      foreground: root.foreground
    }

    Text {
      text: "OmaApple"
      textFormat: Text.PlainText
      color: root.foreground
      font.family: Style.font.family
      font.pixelSize: Style.font.title
    }

    Rectangle {
      visible: root.otherApplePlugins
      width: parent.width
      implicitHeight: warnText.implicitHeight + Style.space(16)
      color: "transparent"
      border.width: 1
      border.color: root.urgent

      Text {
        id: warnText
        anchors.fill: parent
        anchors.margins: Style.space(8)
        wrapMode: Text.WordWrap
        text: "Two Apple Music Chromiums are running. OmaApple will not disable the other plugin."
        textFormat: Text.PlainText
        color: root.urgent
        font.family: Style.font.family
        font.pixelSize: Style.font.caption
      }
    }

    LoginPage {
      width: parent.width
      auth: root.service ? root.service.auth : null
      foreground: root.foreground
      muted: root.muted
      urgent: root.urgent
    }

    Repeater {
      model: [
        { label: "Reconnect", value: "Authorize again (later PR)" },
        { label: "Keyboard shortcut opens", value: root.service ? String(root.service.shortcutPlayer) : "Omarchy Music app" },
        { label: "Playback origin", value: root.service ? String(root.service.playbackHost) : "chromium-apple-origin" },
        { label: "Sleep empty player", value: root.service ? String(root.service.idleShutdownMinutes) + " minutes" : "15 minutes" }
      ]

      Row {
        width: parent.width
        spacing: Style.space(12)
        Text {
          width: parent.width * 0.45
          text: modelData.label
          textFormat: Text.PlainText
          color: root.muted
          font.family: Style.font.family
          font.pixelSize: Style.font.body
        }
        Text {
          width: parent.width * 0.5
          text: modelData.value
          textFormat: Text.PlainText
          horizontalAlignment: Text.AlignRight
          color: root.foreground
          font.family: Style.font.family
          font.pixelSize: Style.font.body
          wrapMode: Text.WordWrap
        }
      }
    }

    PanelSeparator { foreground: root.foreground }

    Text {
      text: "Super+Shift+M snippet (paste into your Hyprland bindings; this plugin never writes them)"
      textFormat: Text.PlainText
      wrapMode: Text.WordWrap
      width: parent.width
      color: root.muted
      font.family: Style.font.family
      font.pixelSize: Style.font.caption
    }

    TextEdit {
      width: parent.width
      readOnly: true
      wrapMode: TextEdit.Wrap
      text: Fixtures.shortcutSnippet
      color: root.foreground
      font.family: Style.font.family
      font.pixelSize: Style.font.caption
      selectedTextColor: Color.background
      selectionColor: root.foreground
    }
  }
}
