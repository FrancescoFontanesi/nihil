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
  property url topSrc:    Qt.resolvedUrl("./assets/top.png")
  property url bottomSrc: Qt.resolvedUrl("./assets/bottom.png")
  property url leftSrc:   Qt.resolvedUrl("./assets/left.png")
  property url rightSrc:  Qt.resolvedUrl("./assets/right.png")

  // 1) Edge reservation + (optional) drawing
  EdgeOverlayLayout {
    id: edgeLayout
    thickness: 64
    enableTop: true; enableBottom: true; enableLeft: true; enableRight: true
    topSource: topSrc; bottomSource: bottomSrc; leftSource: leftSrc; rightSource: rightSrc
    drawContent: true
  }

  // 2) Overlay (HUD + panel inside HUD rectangle)
  PanelWindow {

    property int leftMargin:-56

    id: hudWin
    color: "transparent"//'#38ffffff'
    mask: Region {}                     // click-through
    // Pick your edge and size; example shows right edge full-height.
    anchors { left: true; top: true; bottom: true }
    implicitWidth: 880
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
    margins{ left:leftMargin;bottom:14}
    
    HudSquares {
      id: hud
      anchors.fill: parent
      panelWindow: hudWin
      focus: false
      command: "/home/nihil/Extra/chatgpt-electron/toggle.sh"
      // Geometry (tune as needed)
      s: 8
      rectW: 804
      rectH: 1280
      shiftX: 380
    }

    
  }
}
