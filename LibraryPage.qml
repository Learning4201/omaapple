import QtQuick
import qs.Commons
import qs.Ui

Item {
  id: root

  property bool accountConnected: false
  property color foreground: Color.foreground
  property color muted: Color.muted

  signal connectRequested()

  Column {
    anchors.fill: parent
    spacing: Style.space(10)

    PanelSectionHeader {
      text: "Library"
      foreground: root.foreground
    }

    Text {
      text: "Your music"
      textFormat: Text.PlainText
      color: root.foreground
      font.family: Style.font.family
      font.pixelSize: Style.font.title
    }

    Row {
      spacing: Style.space(8)
      visible: root.accountConnected
      Button { text: "Songs"; bordered: true; selected: true }
      Button { text: "Albums"; bordered: true }
      Button { text: "Playlists"; bordered: true }
    }

    Rectangle {
      visible: !root.accountConnected
      width: Math.min(parent.width, Style.space(360))
      implicitHeight: ctaColumn.implicitHeight + Style.space(32)
      color: "transparent"
      border.width: 1
      border.color: root.foreground

      Column {
        id: ctaColumn
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: Style.space(16)
        spacing: Style.space(10)

        Text {
          width: parent.width
          wrapMode: Text.WordWrap
          text: "Catalog search works with a developer key. Library, Listen Now, and likes wait on Connect Apple Music."
          textFormat: Text.PlainText
          color: root.muted
          font.family: Style.font.family
          font.pixelSize: Style.font.body
        }
        Button {
          text: "Connect Apple Music"
          bordered: true
          onClicked: root.connectRequested()
        }
      }
    }
  }
}
