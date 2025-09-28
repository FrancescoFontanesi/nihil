
import QtQuick 2.15
import Quickshell
import Quickshell.Wayland
import "../widgets"

// Layout: 4 PanelWindow ai bordi (32px) che mostrano PNG con reveal.
Item {
    id: api

    // Size
    property int thickness: 32

    // Sources per lato
    property url topSource: ""
    property url bottomSource: ""
    property url leftSource: ""
    property url rightSource: ""

    // Rendering
    property int fillMode: Image.Stretch
    property bool drawContent: false // <— per questo fix: false

    // Toggle lati
    property bool enableTop: true
    property bool enableBottom: true
    property bool enableLeft: true
    property bool enableRight: true

    // Reveal
    property bool autoShow: true
    property int autoShowDelay: 150

    // --- TOP ---
    PanelWindow {
        id: topPanel
        visible: api.enableTop && !!api.topSource
        anchors { top: true; left: true; right: true }
        margins { top:-8; left: -api.thickness -8  ; right: -api.thickness -8 }
        implicitHeight: api.thickness 
        exclusiveZone: api.thickness
        aboveWindows:true
        mask: Region {}                    // nessuna area “cliccabile” → click-through
        color: "transparent"
        property bool drawContent: false // <— per questo fix: false

        HudClock {
            anchors.top: parent.top
            anchors.margins: {bottom: -6}
            s: 6
            rectH:40
            rectW:344
        }

        HudWorkSpaces {
            x: parent.width/2 - 490
            groupSpacing: parent.width/2 
            y: 14
        }



        EdgeStrip {
            anchors.fill: parent
            edge: "top"
            source: api.topSource
            fillMode: api.fillMode
             
        }
    }

    // --- BOTTOM ---
    PanelWindow {
        id: bottomPanel
        visible: api.enableBottom && !!api.bottomSource
        anchors { bottom: true; left: true; right: true }
        margins { bottom:-8; left: -api.thickness -7 ; right: -api.thickness-7 }
        implicitHeight: api.thickness 
        exclusiveZone: api.thickness
        aboveWindows:true
        mask: Region {}                    // nessuna area “cliccabile” → click-through
        color: "transparent"
        property bool drawContent: false // <— per questo fix: false

    
        HudBattery {
            id: battery
            anchors.centerIn: parent
            barWidth: 340
            barHeight: 32
            segments: barWidth / 12
            gap: 4
            radius: 8
        }

        HudVolumeBar {
            id: volume
            s:4
            x: parent.width/2 +240
            y:-10
            iconSize: 24
            rectW: 260
            rectH: 24
            showLines: true
            hudColorDim: "#80ffffff"
        }

        HudbrightnessBar {
            id: brightness
            s:4
            x: parent.width/2 - 510
            y:-10
            iconSize: 24
            rectW: 260
            rectH: 24
            showLines: true
            hudColorDim: "#80ffffff"
        }

        
        
        



        EdgeStrip {
            anchors.fill: parent
            edge: "bottom"
            source: api.bottomSource
            fillMode: api.fillMode
             
        }
    }

    // --- LEFT ---
    PanelWindow {
        id: leftPanel
        visible: api.enableLeft && !!api.leftSource
        anchors { left: true; top: true; bottom: true }
        margins {left:-2; top: -api.thickness*0.3; bottom: -api.thickness*0.3;  }
        implicitWidth: api.thickness +8
        exclusiveZone: api.thickness +3
        mask: Region {}                    // nessuna area “cliccabile” → click-through
        color: "transparent"
        aboveWindows:true
        exclusionMode: ExclusionMode.Ignore
        property bool drawContent: false 


        EdgeStrip {
            anchors.fill: parent
            edge: "left"
            source: api.leftSource
            fillMode: api.fillMode
        }
    }

    // --- RIGHT ---
    PanelWindow {
        id: rightPanel
        visible: api.enableRight && !!api.rightSource
        anchors { right: true; top: true; bottom: true }
        margins {top: -api.thickness*0.3; bottom: -api.thickness*0.3; right:-2; }
        implicitWidth: api.thickness +8
        exclusiveZone: api.thickness +3
        mask: Region {}                    // nessuna area “cliccabile” → click-through
        color: "transparent"
        aboveWindows:true
        property bool drawContent: false // <— per questo fix: false


        EdgeStrip {
            anchors.fill: parent
            edge: "right"
            source: api.rightSource
            fillMode: api.fillMode
             
        }
    }
}

