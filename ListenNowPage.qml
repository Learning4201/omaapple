import QtQuick
import qs.Commons
import qs.Ui
import "Fixtures.js" as Fixtures

Item {
  id: root

  property bool accountConnected: false
  property string homeType: "played"
  property int selectedIndex: 0
  property color foreground: Color.foreground
  property color muted: Color.muted

  readonly property var tracks: homeType === "added"
    ? Fixtures.recentlyAdded : Fixtures.recentlyPlayed

  signal connectRequested()
  signal nowPlayingRequested()

  Column {
    anchors.fill: parent
    spacing: Style.space(10)

    PanelSectionHeader {
      text: "Listen Now"
      foreground: root.foreground
    }

    Text {
      text: "Recently " + (root.homeType === "added" ? "added" : "played")
      textFormat: Text.PlainText
      color: root.foreground
      font.family: Style.font.family
      font.pixelSize: Style.font.title
    }

    Row {
      spacing: Style.space(8)
      Button {
        text: "Played"
        bordered: root.homeType === "played"
        selected: root.homeType === "played"
        onClicked: root.homeType = "played"
      }
      Button {
        text: "Added"
        bordered: root.homeType === "added"
        selected: root.homeType === "added"
        onClicked: root.homeType = "added"
      }
    }

    Column {
      width: parent.width
      visible: root.accountConnected
      Repeater {
        model: root.tracks
        MediaRow {
          width: parent.width
          track: modelData
          selected: index === root.selectedIndex
          foreground: root.foreground
          muted: root.muted
          onActivated: {
            root.selectedIndex = index
            root.nowPlayingRequested()
          }
        }
      }
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
          text: "Listen Now waits on Connect Apple Music. Rows below are fixture chrome, not your library."
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

    Column {
      width: parent.width
      visible: !root.accountConnected
      Repeater {
        model: root.tracks
        MediaRow {
          width: parent.width
          track: modelData
          selected: index === root.selectedIndex
          foreground: root.foreground
          muted: root.muted
          onActivated: root.selectedIndex = index
        }
      }
    }
  }
}
