//@ pragma StateDir /home/nihil/Extra/.local/share/QuickshellStateDir

import QtQuick 2.12
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import QtQml 2.15

Item {
    id: root
    anchors.fill: parent
    focus: false

    // ======== PARAMS / STATE ========
    property PanelWindow panelWindow
    property string command: ""          // percorso assoluto a toggle.sh

    // Geometria
    property int s: 12
    property int gap: 12
    property int rectW: 700
    property int rectH: 1264
    property int shiftX: 356
    property int initX: 0
    property real offsetX: initX
    property int initY: Math.round((height - (2*s)) / 2)
    property int finalY: Math.round((height - rectH) / 2)

    // Stile
    property color hudColor: "#ffffff"
    property color hudColorDim: "#80ffffff"
    property bool showLines: true

    // Animazioni
    property bool stagger: true
    property int staggerStep: 60
    property int animDur: 360
    property real overshoot: 0.8
    property int expandTotal: (stagger ? 3 * staggerStep : 0) + animDur

    // Stato UI/animazione
    property bool visualOpen: false   // solo UI (nodi agli angoli)
    property bool sliding: false      // vero solo durante lo slide orizzontale
    property bool expandPhase: true   // abilita i Behavior su x/y
    property int leftMargin: panelWindow ? panelWindow.leftMargin : 0

    // ======== HOTKEY: toggle sincronizzato ========
    GlobalShortcut {
        appid: "hud"; name: "toggle"; description: "Toggle HUD rectangle"
        onReleased: {
            if (toDeploy.running || toUndeploy.running) return
            if (!root.visualOpen) {    // OPEN sequenza
                toDeploy.start()
                toggleAppOnce()
            } else {                   // CLOSE sequenza
                toUndeploy.start()
                toggleAppOnce()
            }
        }
    }

    // ======== WORKSPACE CHANGE: chiudi solo l’HUD (no toggle app qui) ========
    Connections {
        target: Hyprland
        function onFocusedWorkspaceChanged() {
            if (toDeploy.running || toUndeploy.running) return
            if (root.visualOpen) {
                // chiudi UI: contract + slide back
                toUndeploy.start()
            }
        }
    }

    // ======== ANIMATIONS ========
    // OPEN: slide compatto (initX -> initX+shiftX) → poi expand ai 4 angoli
    SequentialAnimation {
        id: toDeploy
        ScriptAction { script: { root.sliding = true; root.expandPhase = false; root.visualOpen = false } }
        NumberAnimation { target: root; property: "offsetX"; from: initX; to: initX + shiftX; duration: 220; easing.type: Easing.OutCubic }
        ScriptAction { script: { root.sliding = false; root.expandPhase = true; root.visualOpen = true } }
        onStopped: updateExclusiveZone()
    }

    // CLOSE: contract ai compatti (a x=offsetX) → poi slide back (initX+shiftX -> initX)
    SequentialAnimation {
        id: toUndeploy
        // 1) contract (x/y animati via Behavior perché expandPhase=true)
        ScriptAction { script: { root.expandPhase = true; root.visualOpen = false } }
        PauseAnimation { duration: expandTotal }
        // 2) slide back
        ScriptAction { script: { root.sliding = true; root.expandPhase = false } }
        NumberAnimation { target: root; property: "offsetX"; from: initX + shiftX; to: initX; duration: 220; easing.type: Easing.InOutCubic }
        ScriptAction { script: { root.sliding = false; root.expandPhase = true } }
        onStopped: updateExclusiveZone()
    }

    // ======== 4 NODI (TL, TR, BR, BL) ========
    Repeater {
        id: nodes
        model: 4
        delegate: Rectangle {
            width: s; height: s; radius: 2; color: hudColor
            property bool isBottom: index >= 2
            property bool isRight: (index % 2) === 1
            property int  stagIndex: visualOpen ? index : (3 - index)

            // Posizioni:
            // - se visualOpen: agli angoli del rettangolo finale
            // - altrimenti: compatti, sempre basati su offsetX (così slide/idle coincidono)
            x: visualOpen
               ? ((6-leftMargin) + (isRight ? (rectW - s) : 0))
               : (offsetX + (isRight ? (s + gap) : 0))

            y: visualOpen
               ? (4+finalY + (isBottom ? (rectH - s) : 0))
               : (initY  + (isBottom ? (s + gap) : 0))

            // Animazioni di contract/expand solo quando expandPhase è attivo
            Behavior on x {
                enabled: expandPhase
                SequentialAnimation {
                    PauseAnimation { duration: stagger ? stagIndex * staggerStep : 0 }
                    NumberAnimation { duration: animDur; easing.type: Easing.OutBack; easing.overshoot: overshoot }
                }
            }
            Behavior on y {
                enabled: expandPhase
                SequentialAnimation {
                    PauseAnimation { duration: stagger ? stagIndex * staggerStep : 0 }
                    NumberAnimation { duration: animDur; easing.type: Easing.OutBack; easing.overshoot: overshoot }
                }
            }

            onXChanged: lines.requestPaint()
            onYChanged: lines.requestPaint()
        }
    }

    // ======== OUTLINE ========
    Canvas {
        id: lines
        anchors.fill: parent
        visible: showLines
        onPaint: {
            var a = nodes.itemAt(0), b = nodes.itemAt(1), c = nodes.itemAt(3), d = nodes.itemAt(2);
            if (!a || !b || !c || !d) return;
            var ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);
            ctx.lineWidth = 2; ctx.lineJoin = "round"; ctx.lineCap = "round"; ctx.strokeStyle = hudColorDim;
            function mid(it) { return it.mapToItem(lines, it.width/2, it.height/2); }
            var pa = mid(a), pb = mid(b), pc = mid(c), pd = mid(d);
            ctx.beginPath();
            ctx.moveTo(pa.x, pa.y); ctx.lineTo(pb.x, pb.y); ctx.lineTo(pc.x, pc.y); ctx.lineTo(pd.x, pd.y);
            ctx.closePath(); ctx.stroke();
        }
    }

    // ======== EXCLUSIVE ZONE ========
    function updateExclusiveZone() {
        if (!panelWindow) { console.warn("panelWindow not set"); return; }
        panelWindow.exclusiveZone = visualOpen ? panelWindow.implicitWidth : 0;
    }

    // ======== APP TOGGLE (debounced) ========
    property double _lastToggleMs: 0
    property int cmdDebounceMs: 300   // leggermente più alto per sicurezza
    function toggleAppOnce() {
        var now = Date.now()
        if (now - _lastToggleMs < cmdDebounceMs) return
        _lastToggleMs = now
        if (command && command.length) Quickshell.execDetached([command])
        else console.warn("toggle command not set")
    }
}
