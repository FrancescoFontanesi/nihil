
import QtQuick 2.15
import Quickshell
import Quickshell.Wayland


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
        margins { top:-2; left: -api.thickness +2 ; right: -api.thickness+2 }
        implicitHeight: api.thickness 
        exclusiveZone: api.thickness
        aboveWindows:true
        mask: Region {}                    // nessuna area “cliccabile” → click-through
        color: "transparent"
        property bool drawContent: false // <— per questo fix: false


        EdgeStrip {
            anchors.fill: parent
            edge: "top"
            source: api.topSource
            fillMode: api.fillMode
            autoShow: api.autoShow
            autoShowDelay: api.autoShowDelay
        }
    }

    // --- BOTTOM ---
    PanelWindow {
        id: bottomPanel
        visible: api.enableBottom && !!api.bottomSource
        anchors { bottom: true; left: true; right: true }
        margins { top:-2; left: -api.thickness +2 ; right: -api.thickness+2 }
        implicitHeight: api.thickness 
        exclusiveZone: api.thickness
        aboveWindows:true
        mask: Region {}                    // nessuna area “cliccabile” → click-through
        color: "transparent"
        property bool drawContent: false // <— per questo fix: false



        EdgeStrip {
            anchors.fill: parent
            edge: "bottom"
            source: api.bottomSource
            fillMode: api.fillMode
            autoShow: api.autoShow
            autoShowDelay: api.autoShowDelay
        }
    }

    // --- LEFT ---
    PanelWindow {
        id: leftPanel
        visible: api.enableLeft && !!api.leftSource
        anchors { left: true; top: true; bottom: true }
        margins {left:-20; top: -api.thickness*0.2; bottom: -api.thickness*0.2;  }
        implicitWidth: api.thickness +32
        exclusiveZone: api.thickness
        mask: Region {}                    // nessuna area “cliccabile” → click-through
        color: "transparent"
        aboveWindows:true
        exclusionMode: ExclusionMode.Ignore
        property bool drawContent: false // <— per questo fix: false


        EdgeStrip {
            anchors.fill: parent
            edge: "left"
            source: api.leftSource
            fillMode: api.fillMode
            autoShow: api.autoShow
            autoShowDelay: api.autoShowDelay
        }
    }

    // --- RIGHT ---
    PanelWindow {
        id: rightPanel
        visible: api.enableRight && !!api.rightSource
        anchors { right: true; top: true; bottom: true }
        margins {right:-20; top: -api.thickness*0.2; bottom: -api.thickness*0.2;  }
        implicitWidth: api.thickness + 32
        exclusiveZone: api.thickness
        mask: Region {}                    // nessuna area “cliccabile” → click-through
        color: "transparent"
        aboveWindows:false
        property bool drawContent: false // <— per questo fix: false


        EdgeStrip {
            anchors.fill: parent
            edge: "right"
            source: api.rightSource
            fillMode: api.fillMode
            autoShow: api.autoShow
            autoShowDelay: api.autoShowDelay
        }
    }
}

