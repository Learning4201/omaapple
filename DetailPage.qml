import QtQuick
import qs.Commons
import qs.Ui

Item {
  id: root

  property var item: ({})
  property color foreground: Color.foreground
  property color muted: Color.muted

  Column {
    anchors.fill: parent
    spacing: Style.space(10)

    PanelSectionHeader {
      text: "Catalog"
      foreground: root.foreground
    }

    Text {
      width: parent.width
      wrapMode: Text.WordWrap
      text: root.item && root.item.title ? root.item.title : "No item"
      textFormat: Text.PlainText
      color: root.foreground
      font.family: Style.font.family
      font.pixelSize: Style.font.title
    }
    Text {
      width: parent.width
      wrapMode: Text.WordWrap
      text: root.item && root.item.artist ? root.item.artist : ""
      textFormat: Text.PlainText
      color: root.muted
      font.family: Style.font.family
      font.pixelSize: Style.font.body
    }
    Text {
      text: root.item && root.item.id ? ("Catalog id " + root.item.id) : ""
      textFormat: Text.PlainText
      color: root.muted
      font.family: Style.font.family
      font.pixelSize: Style.font.caption
    }

    Button {
      text: "Play (disabled until playback PRs)"
      enabled: false
    }
  }
}
