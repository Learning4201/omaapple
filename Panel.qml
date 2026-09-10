import QtQuick

// Scaffold panel. Host injects shell, manifest, and service.
// No pages, no transport, no claim of a listening loop.
Item {
  id: root

  property var shell: null
  property var manifest: null
  property var service: null
  property bool opened: false
}
