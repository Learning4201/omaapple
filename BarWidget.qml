import QtQuick
import qs.Commons
import qs.Ui

// Scaffold bar slot. Icon only; no now-playing text and no transport.
BarWidget {
  id: root
  moduleName: "io.github.Learning4201.omaapple"

  readonly property var apple: root.bar && root.bar.shell
    ? root.bar.shell.serviceFor("io.github.Learning4201.omaapple") : null

  implicitWidth: vertical ? barSize : glyph.width
  implicitHeight: barSize

  OpticalGlyph {
    id: glyph
    anchors.centerIn: parent
    width: Style.bar.iconCanvas
    height: Style.bar.iconCanvas
    text: "󰝚"
    fontFamily: root.bar && root.bar.fontFamily ? root.bar.fontFamily : Style.font.family
    fontSize: Style.bar.iconFont
    color: root.bar ? root.bar.foreground : Color.foreground
  }
}
