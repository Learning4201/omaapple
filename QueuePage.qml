import QtQuick
import qs.Commons
import qs.Ui

Item {
  id: root

  property color foreground: Color.foreground
  property color muted: Color.muted

  Column {
    anchors.fill: parent
    spacing: Style.space(10)

    PanelSectionHeader {
      text: "Queue"
      foreground: root.foreground
    }

    Text {
      text: "Up next"
      textFormat: Text.PlainText
      color: root.foreground
      font.family: Style.font.family
      font.pixelSize: Style.font.title
    }

    Text {
      width: parent.width
      wrapMode: Text.WordWrap
      text: "Queue is empty. Playback and queue edits land in later PRs. This page is chrome only."
      textFormat: Text.PlainText
      color: root.muted
      font.family: Style.font.family
      font.pixelSize: Style.font.body
    }
  }
}
