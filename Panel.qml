import QtQuick
import Quickshell
import qs.Commons
import qs.Ui
import "Fixtures.js" as Fixtures

Item {
  id: root

  property var shell: null
  property var manifest: null
  property var service: null
  property bool opened: false
  property bool closingFromHost: false
  property bool shortcutHelpOpen: false
  property string currentTab: service ? service.currentTab : "listen"
  property var fixtureTrack: Fixtures.recentlyPlayed[0]

  readonly property string pluginId: manifest && manifest.id
    ? String(manifest.id) : "io.github.Learning4201.omaapple"
  readonly property color foreground: Color.foreground
  readonly property color background: Color.background
  readonly property color muted: Color.muted
  readonly property var navItems: Fixtures.navItems()
  readonly property bool accountConnected: service ? service.accountConnected : false

  function open(payload) {
    closingFromHost = false
    opened = true
    var tab = payload && payload.tab ? String(payload.tab) : ""
    if (tab) chooseTab(tab)
    Qt.callLater(function() {
      if (focusScope) focusScope.forceActiveFocus()
    })
  }

  function close() {
    shortcutHelpOpen = false
    closingFromHost = true
    opened = false
    closingFromHost = false
  }

  function requestClose() {
    if (shell && typeof shell.hide === "function") shell.hide(pluginId)
    else close()
  }

  function chooseTab(tab) {
    currentTab = tab
    if (service && service.chooseTab) service.chooseTab(tab)
  }

  function focusSearch() {
    chooseTab("search")
    Qt.callLater(function() {
      if (searchPage.searchFieldItem) searchPage.searchFieldItem.forceActiveFocus()
    })
  }

  function handleKey(event) {
    if (!event) return false
    if (event.key === Qt.Key_Escape) {
      if (shortcutHelpOpen) {
        shortcutHelpOpen = false
        event.accepted = true
        return true
      }
      requestClose()
      event.accepted = true
      return true
    }
    if (event.modifiers & Qt.ControlModifier && event.key === Qt.Key_Slash) {
      shortcutHelpOpen = !shortcutHelpOpen
      event.accepted = true
      return true
    }
    if (event.modifiers & Qt.ControlModifier && event.key === Qt.Key_F) {
      focusSearch()
      event.accepted = true
      return true
    }
    if (event.key === Qt.Key_Slash && !(event.modifiers & Qt.ControlModifier)) {
      focusSearch()
      event.accepted = true
      return true
    }
    if (event.key === Qt.Key_F6 || event.key === Qt.Key_Tab) {
      cycleTab(event.modifiers & Qt.ShiftModifier ? -1 : 1)
      event.accepted = true
      return true
    }
    if ((event.modifiers & Qt.AltModifier) && (event.modifiers & Qt.ShiftModifier)
        && event.key === Qt.Key_N) {
      chooseTab("nowplaying")
      event.accepted = true
      return true
    }
    return false
  }

  function cycleTab(delta) {
    var items = navItems
    var idx = 0
    for (var i = 0; i < items.length; i++) {
      if (items[i].id === currentTab) { idx = i; break }
    }
    var next = (idx + delta + items.length) % items.length
    chooseTab(items[next].id)
  }

  FloatingWindow {
    id: window
    visible: root.opened
    title: "OmaApple"
    color: root.background
    implicitWidth: 980
    implicitHeight: 720
    minimumSize: Qt.size(700, 560)

    onVisibleChanged: {
      if (!visible && root.opened && !root.closingFromHost) root.requestClose()
    }

    FocusScope {
      id: focusScope
      anchors.fill: parent
      focus: true
      Keys.priority: Keys.BeforeItem
      Keys.onPressed: function(event) { root.handleKey(event) }

      Column {
        anchors.fill: parent

        Row {
          width: parent.width
          height: parent.height - Style.space(72)

          Column {
            width: Style.space(148)
            height: parent.height
            spacing: Style.space(4)

            Item { width: 1; height: Style.space(12) }

            Repeater {
              model: root.navItems
              Button {
                width: Style.space(132)
                x: Style.space(8)
                text: modelData.label
                bordered: root.currentTab === modelData.id
                selected: root.currentTab === modelData.id
                onClicked: root.chooseTab(modelData.id)
              }
            }
          }

          Rectangle {
            width: 1
            height: parent.height
            color: Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.12)
          }

          Item {
            width: parent.width - Style.space(148) - 1
            height: parent.height

            ListenNowPage {
              anchors.fill: parent
              anchors.margins: Style.space(16)
              visible: root.currentTab === "listen"
              accountConnected: root.accountConnected
              foreground: root.foreground
              muted: root.muted
              onConnectRequested: root.chooseTab("settings")
              onNowPlayingRequested: root.chooseTab("nowplaying")
            }
            LibraryPage {
              anchors.fill: parent
              anchors.margins: Style.space(16)
              visible: root.currentTab === "library"
              accountConnected: root.accountConnected
              foreground: root.foreground
              muted: root.muted
              onConnectRequested: root.chooseTab("settings")
            }
            SearchPage {
              id: searchPage
              anchors.fill: parent
              anchors.margins: Style.space(16)
              visible: root.currentTab === "search"
              foreground: root.foreground
              muted: root.muted
              onNowPlayingRequested: root.chooseTab("nowplaying")
            }
            QueuePage {
              anchors.fill: parent
              anchors.margins: Style.space(16)
              visible: root.currentTab === "queue"
              foreground: root.foreground
              muted: root.muted
            }
            NowPlayingPage {
              anchors.fill: parent
              visible: root.currentTab === "nowplaying"
              track: root.fixtureTrack
              foreground: root.foreground
              muted: root.muted
            }
            SettingsPage {
              anchors.fill: parent
              anchors.margins: Style.space(16)
              visible: root.currentTab === "settings"
              service: root.service
              foreground: root.foreground
              muted: root.muted
              urgent: Color.urgent
              otherApplePlugins: root.service ? root.service.otherApplePlugins : false
            }
          }
        }

        Rectangle {
          width: parent.width
          height: 1
          color: Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.12)
        }

        Item {
          width: parent.width
          height: Style.space(71)

          Row {
            anchors.fill: parent
            anchors.leftMargin: Style.space(14)
            anchors.rightMargin: Style.space(14)
            spacing: Style.space(12)

            Rectangle {
              width: Style.space(52)
              height: Style.space(52)
              anchors.verticalCenter: parent.verticalCenter
              color: "transparent"
              border.width: 1
              border.color: root.foreground
            }

            Column {
              width: Math.max(80, parent.width - Style.space(52) - Style.space(220))
              anchors.verticalCenter: parent.verticalCenter
              spacing: Style.space(6)
              Text {
                text: "Nothing playing"
                textFormat: Text.PlainText
                color: root.foreground
                font.family: Style.font.family
                font.pixelSize: Style.font.body
              }
              Text {
                text: "Transport is inert until playback PRs"
                textFormat: Text.PlainText
                color: root.muted
                font.family: Style.font.family
                font.pixelSize: Style.font.caption
              }
              PlaybackSlider {
                width: parent.width
                foreground: root.foreground
                track: root.muted
              }
            }

            Row {
              spacing: Style.space(8)
              anchors.verticalCenter: parent.verticalCenter
              TransportButton { glyph: "shuf" }
              TransportButton { glyph: "prev" }
              TransportButton { glyph: "play"; primary: true }
              TransportButton { glyph: "next" }
              TransportButton { glyph: "rep" }
            }
          }
        }
      }

      ShortcutHelpPopup {
        anchors.fill: parent
        anchors.margins: Style.space(48)
        opened: root.shortcutHelpOpen
        foreground: root.foreground
        background: root.background
        muted: root.muted
      }
    }
  }
}
