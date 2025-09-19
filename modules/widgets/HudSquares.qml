// File: HudSquares.qml (bind-only, no drag; toggle via Hyprland GlobalShortcut)
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

    GlobalShortcut {
    appid: "hud"; name: "toggle"; description: "Toggle HUD rectangle"
    onReleased: if (!toDeploy.running && !toUndeploy.running) {
        toggleAppOnce()
        if (!root.deployed) toDeploy.start(); else toUndeploy.start();
        }
    }

    Connections {
        target: Hyprland
        function onFocusedWorkspaceChanged() {
            if (root.deployed) { toggleAppOnce(); toUndeploy.start(); }
        }
    }

    
    // --- Params / State ---
    property PanelWindow panelWindow
    property string command: ""          // absolute path to toggle.sh
    property int s: 12
    property int gap: 12
    property int rectW: 700
    property int rectH: 1264
    property int shiftX: 356
    property int initX: 0
    property real offsetX: 0
    property int initY: Math.round((height - (2*s)) / 2)
    property int finalX: offsetX
    property int finalY: Math.round((height - rectH) / 2)
    property color hudColor: "#ffffff"
    property color hudColorDim: "#80ffffff"
    property bool showLines: true
    property bool stagger: true
    property int staggerStep: 60
    property int animDur: 360
    property real overshoot: 0.8
    property int expandTotal: (stagger ? 3 * staggerStep : 0) + animDur
    property bool deployed: false
    property bool expandPhase: true      // behaviors only during expand/contract
    property int leftMargin: panelWindow.leftMargin

    // --- Deploy: slide → expand ---
    SequentialAnimation {
        id: toDeploy
        ScriptAction { script: root.expandPhase = false }
        NumberAnimation { target: root; property: "offsetX"; from: initX; to: initX + shiftX; duration: 220; easing.type: Easing.OutCubic }
        ScriptAction { script: { root.expandPhase = true; root.deployed = true; } }
        onStopped: updateExclusiveZone()
    }

    // --- Undeploy: contract → pause → slide back ---
    SequentialAnimation {
        id: toUndeploy
        ScriptAction { script: { root.expandPhase = true; root.deployed = false; } }
        PauseAnimation { duration: expandTotal }
        ScriptAction { script: root.expandPhase = false }
        NumberAnimation { target: root; property: "offsetX"; from: initX + shiftX; to: initX; duration: 220; easing.type: Easing.InOutCubic }
        ScriptAction { script: root.expandPhase = true }
        onStopped: updateExclusiveZone()
    }

    // --- Four nodes (TL, TR, BR, BL via indices 0..3) ---
    Repeater {
        id: nodes
        model: 4
        delegate: Rectangle {
            id: node
            width: s; height: s; radius: 2; color: hudColor
            property bool isBottom: index >= 2
            property bool isRight: (index % 2) === 1
            property int stagIndex: deployed ? index : (3 - index)

            // Positions (compact vs expanded), whole rect slides via offsetX
            x: deployed ? (-leftMargin * 1.5 + (isRight ? (rectW - s) : 0))
                        : (offsetX + (isRight ? (s + gap) : 0))
            y: deployed ? (finalY + (isBottom ? (rectH - s) : 0))
                        : (initY  + (isBottom ? (s + gap) : 0))

            // Per-axis behavior only during expand/contract (staggered)
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

    // --- Lines (Canvas) ---
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

            function mid(it) { return it.mapToItem(lines, it.width / 2, it.height / 2); }
            var pa = mid(a), pb = mid(b), pc = mid(c), pd = mid(d);

            ctx.beginPath();
            ctx.moveTo(pa.x, pa.y); ctx.lineTo(pb.x, pb.y); ctx.lineTo(pc.x, pc.y); ctx.lineTo(pd.x, pd.y);
            ctx.closePath(); ctx.stroke();
        }
    }

    // --- (Kept for parity; not auto-invoked anymore) ---
    function updateExclusiveZone() {
        if (!panelWindow) { console.warn("panelWindow not set"); return; }
        panelWindow.exclusiveZone = deployed ? panelWindow.implicitWidth : 0;
    }

    // --- Fast app toggle (debounced) ---
    property double _lastToggleMs: 0
    function toggleAppOnce() {
        var now = Date.now();
        if (now - _lastToggleMs < 250) return;
        _lastToggleMs = now;
        Quickshell.execDetached([command]); // expects absolute path to toggle.sh
    }
}
