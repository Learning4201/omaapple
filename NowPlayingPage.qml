import QtQuick
import qs.Commons

Item {
  id: root

  property var track: ({})
  property color foreground: Color.foreground
  property color muted: Color.muted

  Column {
    anchors.centerIn: parent
    spacing: Style.space(14)

    Rectangle {
      width: Style.space(180)
      height: Style.space(180)
      anchors.horizontalCenter: parent.horizontalCenter
      color: "transparent"
      border.width: 1
      border.color: root.foreground
    }

    Text {
      anchors.horizontalCenter: parent.horizontalCenter
      text: root.track && root.track.title ? root.track.title : "Nothing playing"
      textFormat: Text.PlainText
      color: root.foreground
      font.family: Style.font.family
      font.pixelSize: Style.font.subtitle
    }
    Text {
      anchors.horizontalCenter: parent.horizontalCenter
      text: root.track && root.track.artist ? root.track.artist : ""
      textFormat: Text.PlainText
      color: root.muted
      font.family: Style.font.family
      font.pixelSize: Style.font.body
    }

    PlaybackSlider {
      width: Style.space(220)
      anchors.horizontalCenter: parent.horizontalCenter
      foreground: root.foreground
      track: root.muted
    }
  }
}
