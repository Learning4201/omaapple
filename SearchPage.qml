import QtQuick
import qs.Commons
import qs.Ui
import "Api.js" as Api
import "Fixtures.js" as Fixtures

Item {
  id: root

  property var service: null
  property string searchText: ""
  property string searchType: "songs"
  property int selectedIndex: 0
  property var liveHits: []
  property string searchError: ""
  property color foreground: Color.foreground
  property color muted: Color.muted
  property Item searchFieldItem: searchField

  readonly property bool live: service && service.auth && service.auth.developerReady
  readonly property var hits: live && liveHits && liveHits.length ? liveHits : (live ? [] : Fixtures.searchHits)

  signal nowPlayingRequested()
  signal detailRequested(var item)

  function runSearch() {
    if (!live) return
    if (!searchText.trim()) {
      liveHits = []
      searchError = ""
      return
    }
    service.api.searchCatalog(service.storefront, searchText.trim(),
      Api.searchTypes(searchType), function(status, payload, error) {
        if (error) {
          root.searchError = error
          root.liveHits = []
          return
        }
        root.searchError = ""
        root.liveHits = Api.catalogResults(payload, Api.searchTypes(root.searchType))
      })
  }

  Timer {
    id: debounce
    interval: 350
    repeat: false
    onTriggered: root.runSearch()
  }

  Column {
    anchors.fill: parent
    spacing: Style.space(10)

    PanelSectionHeader {
      text: "Search"
      foreground: root.foreground
    }

    Text {
      visible: !root.live
      width: parent.width
      wrapMode: Text.WordWrap
      text: "Fixture results until a MusicKit token is signed in Settings."
      textFormat: Text.PlainText
      color: root.muted
      font.family: Style.font.family
      font.pixelSize: Style.font.caption
    }

    TextField {
      id: searchField
      width: parent.width
      placeholderText: "Search songs, albums, artists…"
      text: root.searchText
      onTextChanged: {
        root.searchText = text
        debounce.restart()
      }
    }

    Row {
      spacing: Style.space(8)
      Repeater {
        model: ["songs", "albums", "artists", "playlists"]
        Button {
          text: modelData.charAt(0).toUpperCase() + modelData.slice(1)
          bordered: root.searchType === modelData
          selected: root.searchType === modelData
          onClicked: {
            root.searchType = modelData
            root.runSearch()
          }
        }
      }
    }

    Text {
      visible: root.searchError !== ""
      width: parent.width
      wrapMode: Text.WordWrap
      text: root.searchError
      textFormat: Text.PlainText
      color: Color.urgent
      font.family: Style.font.family
      font.pixelSize: Style.font.caption
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
            root.detailRequested(modelData)
          }
        }
      }
    }
  }
}
