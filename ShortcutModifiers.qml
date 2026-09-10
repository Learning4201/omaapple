import QtQuick

QtObject {
  function isHintModifierKey(key) {
    return key === Qt.Key_Control || key === Qt.Key_Shift
      || key === Qt.Key_Alt || key === Qt.Key_Meta
  }
}
