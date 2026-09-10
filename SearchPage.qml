import QtQuick
import qs.Commons
import qs.Ui
import "Fixtures.js" as Fixtures

Item {
  id: root

  property string searchText: ""
  property string searchType: "songs"
  property int selectedIndex: 0
  property color foreground: Color.foreground
  property color muted: Color.muted
  property Item searchFieldItem: searchField

  readonly property var hits: Fixtures.searchHits

  signal nowPlayingRequested()

  Column {
    anchors.fill: parent
    spacing: Style.space(10)

    PanelSectionHeader {
      text: "Search"
      foreground: root.foreground
    }

    TextField {
      id: searchField
      width: parent.width
      placeholderText: "Search songs, albums, artists…"
      text: root.searchText
      onTextChanged: root.searchText = text
    }

    Row {
      spacing: Style.space(8)
      Button {
        text: "Songs"
        bordered: root.searchType === "songs"
        selected: root.searchType === "songs"
        onClicked: root.searchType = "songs"
      }
      Button {
        text: "Albums"
        bordered: root.searchType === "albums"
        selected: root.searchType === "albums"
        onClicked: root.searchType = "albums"
      }
      Button {
        text: "Artists"
        bordered: root.searchType === "artists"
        selected: root.searchType === "artists"
        onClicked: root.searchType = "artists"
      }
      Button {
        text: "Playlists"
        bordered: root.searchType === "playlists"
        selected: root.searchType === "playlists"
        onClicked: root.searchType = "playlists"
      }
    }

    Column {
      width: parent.width
      Repeater {
        model: root.hits
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
  }
}
