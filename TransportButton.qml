import QtQuick
import qs.Commons
import qs.Ui

Button {
  id: root

  property string glyph: ""
  property bool primary: false

  bordered: primary
  implicitWidth: primary ? Style.space(32) : Style.space(28)
  implicitHeight: Style.space(28)
  text: glyph
}
