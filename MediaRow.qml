import QtQuick
import qs.Commons
import qs.Ui

Item {
  id: root

  property var track: ({})
  property bool selected: false
  property color foreground: Color.foreground
  property color muted: Color.muted
  property string fontFamily: Style.font.family

  signal activated()

  implicitHeight: Style.space(44)
  width: parent ? parent.width : 200

  Button {
    anchors.fill: parent
    bordered: root.selected
    selected: root.selected
    onClicked: root.activated()

    Row {
      anchors.fill: parent
      anchors.leftMargin: Style.space(8)
      anchors.rightMargin: Style.space(8)
      spacing: Style.space(10)

      Rectangle {
        width: Style.space(32)
        height: Style.space(32)
        anchors.verticalCenter: parent.verticalCenter
        color: "transparent"
        border.width: 1
        border.color: root.foreground
      }

      Column {
        width: Math.max(40, parent.width - Style.space(32) - Style.space(56) - Style.space(20))
        anchors.verticalCenter: parent.verticalCenter
        spacing: 2

        Text {
          width: parent.width
          text: root.track && root.track.title ? root.track.title : ""
          textFormat: Text.PlainText
          elide: Text.ElideRight
          color: root.foreground
          font.family: root.fontFamily
          font.pixelSize: Style.font.body
        }
        Text {
          width: parent.width
          text: root.track && root.track.artist ? root.track.artist : ""
          textFormat: Text.PlainText
          elide: Text.ElideRight
          color: root.muted
          font.family: root.fontFamily
          font.pixelSize: Style.font.caption
        }
      }

      Text {
        anchors.verticalCenter: parent.verticalCenter
        text: root.track && root.track.duration ? root.track.duration : ""
        textFormat: Text.PlainText
        color: root.muted
        font.family: root.fontFamily
        font.pixelSize: Style.font.caption
      }
    }
  }
}
