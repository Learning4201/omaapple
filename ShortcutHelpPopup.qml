import QtQuick
import qs.Commons
import "Fixtures.js" as Fixtures

Rectangle {
  id: root

  property bool opened: false
  property color foreground: Color.foreground
  property color background: Color.background
  property color muted: Color.muted

  visible: opened
  color: Qt.rgba(background.r, background.g, background.b, 0.96)
  border.width: 1
  border.color: foreground

  Column {
    anchors.fill: parent
    anchors.margins: Style.space(20)
    spacing: Style.space(8)

    Text {
      text: "Keyboard"
      textFormat: Text.PlainText
      color: root.foreground
      font.family: Style.font.family
      font.pixelSize: Style.font.subtitle
      font.bold: true
    }

    Repeater {
      model: Fixtures.shortcutRows
      ShortcutHint {
        width: parent.width
        keys: modelData.keys
        action: modelData.action
        foreground: root.foreground
        muted: root.muted
      }
    }

    Text {
      text: "Transport is chrome only in this PR. Esc or Ctrl+/ closes this overlay."
      textFormat: Text.PlainText
      wrapMode: Text.WordWrap
      width: parent.width
      color: root.muted
      font.family: Style.font.family
      font.pixelSize: Style.font.caption
    }
  }
}
