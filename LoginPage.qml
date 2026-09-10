import QtQuick
import Quickshell
import qs.Commons
import qs.Ui

// Developer MusicKit credentials. Apple ID authorize is a later PR.
Item {
  id: root

  property var auth: null
  property color foreground: Color.foreground
  property color muted: Color.muted
  property color urgent: Color.urgent

  implicitHeight: creds.implicitHeight
  implicitWidth: parent ? parent.width : 400

  Column {
    id: creds
    width: parent.width
    spacing: Style.space(8)

    PanelSectionHeader {
      text: "MusicKit credentials"
      foreground: root.foreground
    }

    Text {
      width: parent.width
      wrapMode: Text.WordWrap
      text: "v1 needs your own MusicKit key from the Apple Developer Program. OmaApple never ships a .p8."
      textFormat: Text.PlainText
      color: root.muted
      font.family: Style.font.family
      font.pixelSize: Style.font.caption
    }

    Button {
      text: "Open developer.apple.com"
      bordered: true
      onClicked: Quickshell.execDetached(["xdg-open", "https://developer.apple.com/account"])
    }

    Text {
      text: "Team ID"
      textFormat: Text.PlainText
      color: root.muted
      font.family: Style.font.family
      font.pixelSize: Style.font.caption
    }
    TextField {
      id: teamField
      width: parent.width
      text: root.auth ? root.auth.teamId : ""
      placeholderText: "10-character Team ID"
      onEditingFinished: if (root.auth) root.auth.saveTeam(text)
    }

    Text {
      text: "Key ID"
      textFormat: Text.PlainText
      color: root.muted
      font.family: Style.font.family
      font.pixelSize: Style.font.caption
    }
    TextField {
      id: keyField
      width: parent.width
      text: root.auth ? root.auth.keyId : ""
      placeholderText: "10-character Key ID"
      onEditingFinished: if (root.auth) root.auth.saveKey(text)
    }

    Row {
      spacing: Style.space(8)
      Button {
        text: "Import .p8"
        bordered: true
        onClicked: if (root.auth) root.auth.importP8()
      }
      Button {
        text: "Sign token"
        bordered: true
        onClicked: if (root.auth) root.auth.signRestToken()
      }
    }

    Text {
      width: parent.width
      wrapMode: Text.WordWrap
      text: "Or paste PEM"
      textFormat: Text.PlainText
      color: root.muted
      font.family: Style.font.family
      font.pixelSize: Style.font.caption
    }
    TextField {
      id: pemField
      width: parent.width
      placeholderText: "Paste the MusicKit PEM"
      echoMode: TextInput.Password
    }
    Button {
      text: "Store pasted key"
      onClicked: if (root.auth) root.auth.pastePem(pemField.text)
    }

    Text {
      width: parent.width
      wrapMode: Text.WordWrap
      visible: root.auth && root.auth.statusText !== ""
      text: root.auth ? root.auth.statusText : ""
      textFormat: Text.PlainText
      color: root.foreground
      font.family: Style.font.family
      font.pixelSize: Style.font.body
    }
    Text {
      width: parent.width
      wrapMode: Text.WordWrap
      visible: root.auth && root.auth.lastError !== ""
      text: root.auth ? root.auth.lastError : ""
      textFormat: Text.PlainText
      color: root.urgent
      font.family: Style.font.family
      font.pixelSize: Style.font.body
    }
  }
}
