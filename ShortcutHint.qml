import QtQuick
import qs.Commons

Text {
  id: root

  property string keys: ""
  property string action: ""
  property color foreground: Color.foreground
  property color muted: Color.muted

  text: keys + "  " + action
  textFormat: Text.PlainText
  color: foreground
  font.family: Style.font.family
  font.pixelSize: Style.font.caption
}
