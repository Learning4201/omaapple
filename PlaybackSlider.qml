import QtQuick
import qs.Commons

Item {
  id: root

  property real progress: 0.38
  property color foreground: Color.foreground
  property color track: Color.muted

  implicitHeight: Style.space(10)
  implicitWidth: 120

  Rectangle {
    anchors.verticalCenter: parent.verticalCenter
    width: parent.width
    height: 2
    color: Qt.rgba(root.track.r, root.track.g, root.track.b, 0.45)
  }

  Rectangle {
    anchors.verticalCenter: parent.verticalCenter
    width: Math.max(2, parent.width * Math.max(0, Math.min(1, root.progress)))
    height: 2
    color: root.foreground
  }
}
