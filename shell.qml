// File: shell.qml
//@ pragma UseQApplication
import QtQuick 2.15
import Quickshell
import Quickshell.Wayland
import "./modules/layout"
import "./modules/widgets"

ShellRoot {
  id: root

  // Edge assets (adjust to your paths)
  property url topSrc:    Qt.resolvedUrl("./assets/top.svg")
  property url bottomSrc: Qt.resolvedUrl("./assets/bottom.svg")
  property url leftSrc:   Qt.resolvedUrl("./assets/left.svg")
  property url rightSrc:  Qt.resolvedUrl("./assets/right.svg")

  // 1) Edge reservation + (optional) drawing
  EdgeOverlayLayout {
    thickness: 64
    enableTop: true; enableBottom: true; enableLeft: true; enableRight: true
    topSource: topSrc; bottomSource: bottomSrc; leftSource: leftSrc; rightSource: rightSrc
    drawContent: true
  }

  // 2) Overlay (HUD + panel inside HUD rectangle)
  PanelWindow {

    property int leftMargin:-32

    id: hudWin
    color: "transparent"
    mask: Region {}                     // click-through
    // Pick your edge and size; example shows right edge full-height.
    anchors { left: true; top: true; bottom: true }
    implicitWidth: 850
    implicitHeight: 1500
    // CRITICAL: do not reserve; overlap other reserved panels
    exclusiveZone: 0 
    exclusionMode: ExclusionMode.Ignore
    // Draw above normal windows
    aboveWindows: true
    // Ensure we sit in the overlay layer (above Top where your borders live)
    Component.onCompleted: {
    if (hudWin.WlrLayershell) hudWin.WlrLayershell.layer = WlrLayer.Overlay
    }
    margins{ left:leftMargin;top:-16;bottom:-16}
    HudSquares {
      id: hud
      anchors.fill: parent
      panelWindow: hudWin
      focus: false
      command: "/home/nihil/Extra/chatgpt-electron/toggle.sh"
      // Geometry (tune as needed)
      s: 8
      rectW: 800
      rectH: 1278
      shiftX: 356
    }
  }
}
