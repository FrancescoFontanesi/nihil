//@ pragma StateDir /home/nihil/Extra/.local/share/QuickshellStateDir

import QtQuick 2.12
import Quickshell
import Quickshell.Hyprland
import QtQml 2.15

Item {
    id: lock
    anchors.fill: parent
    focus: false

    // ======== PARAMS / STATE ========
    property PanelWindow panelWindow

    // Geometria
    property int s: 12
    property int gap: 12
    property int rectW: 700
    property int rectH: 1264
    property int shiftX: 356                 // ampiezza slide (positiva)
    property int initX: 0                    // base X iniziale del cluster compatto
    property real offsetX: 0                 // 0..shiftX durante lo slide
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
    property bool visualOpen: false         // solo UI (nodi agli angoli)
    property bool expandPhase: true         // abilita i Behavior su x/y

    // Margine destro sicuro (se esiste)
    property int rightMargin: panelWindow && panelWindow.rightMargin !== undefined ? panelWindow.rightMargin : 0

    // Base X del rettangolo aperto (ancorato a destra, 6px di margine)
    readonly property int baseOpenLeft: (width - 6 - rectW + rightMargin)

    // ======== HOTKEY: toggle (solo HUD) ========
    GlobalShortcut {
        appid: "lock"
        name: "toggle"
        description: "Toggle HUD rectangle (right-to-left)"
        onReleased: {
            if (toDeployLock.running || toUndeployLock.running) return
            if (!lock.visualOpen) toDeployLock.start()
            else toUndeployLock.start()
        }
    }

    // ======== WORKSPACE CHANGE: chiudi solo l’HUD ========
    Connections {
        target: Hyprland
        function onFocusedWorkspaceChanged() {
            if (toDeployLock.running || toUndeployLock.running) return
            if (lock.visualOpen) toUndeployLock.start()
        }
    }

    // ======== ANIMATIONS ========
    // OPEN: slide compatto (offsetX: 0→shiftX) da destra verso sinistra → poi expand angoli
    SequentialAnimation {
        id: toDeployLock
        ScriptAction { script: { lock.expandPhase = false; lock.visualOpen = false; lock.offsetX = 0; panelWindow.clickThrough = false; } }
        NumberAnimation { target: lock; property: "offsetX"; from: 0; to: shiftX; duration: 220; easing.type: Easing.OutCubic }
        ScriptAction { script: { lock.expandPhase = true; lock.visualOpen = true } }
        onStopped: updateExclusiveZone()
    }

    // CLOSE: contract (angoli→compatto) → slide back (offsetX: shiftX→0)
    SequentialAnimation {
        id: toUndeployLock
        ScriptAction { script: { lock.expandPhase = true; lock.visualOpen = false } }
        PauseAnimation { duration: expandTotal }
        ScriptAction { script: { lock.expandPhase = false } }
        NumberAnimation { target: lock; property: "offsetX"; from: shiftX; to: 0; duration: 220; easing.type: Easing.InOutCubic }
        ScriptAction { script: { lock.expandPhase = true } }
        onStopped: { updateExclusiveZone(); panelWindow.clickThrough = true;}

    }

    // ======== 4 NODI (TL, TR, BR, BL) ========
    Repeater {
        id: nodesLock
        model: 4
        delegate: Rectangle {
            width: s; height: s; radius: 2; color: hudColor
            property bool isBottom: index >= 2
            property bool isRight : (index % 2) === 1
            property int  stagIndex: visualOpen ? index : (3 - index)

            // Posizioni:
            // - OPEN: agli angoli del rettangolo finale (ancorato a destra)
            // - CLOSED/SLIDE: cluster compatto basato su initX e scorrimento verso sinistra (initX - offsetX)
            x: visualOpen
               ? (baseOpenLeft + (isRight ? (rectW - s) : 0))
               : (initX - offsetX + (isRight ? (s + gap) : 0))

            y: visualOpen
               ? (finalY + (isBottom ? (rectH - s) : 0))
               : (initY  + (isBottom ? (s + gap) : 0))

            // Animazioni di contract/expand (non durante lo slide)
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

            onXChanged: linesLock.requestPaint()
            onYChanged: linesLock.requestPaint()
        }
    }

    // ======== CONTROLS (centro del rettangolo) ========
    Rectangle {
        id: controls
        z: 1
        visible: visualOpen
        color: "transparent"
        x: baseOpenLeft
        y: finalY
        width: rectW
        height: rectH
        clip: true

        HudLockButton {
            id: lockActions
            x: baseOpenLeft  -4    // for right-side HUD; for left HUD use your left-anchored x
            y: finalY - 300
            width: rectW
            height: rectH
            iconSize: 120
            opacity: lock.visualOpen ? 1 : 0
            visible: lock.visualOpen || opacity > 0.001   // resta visibile durante il fade-out
            Behavior on opacity { NumberAnimation { duration: 1000; easing.type: Easing.OutCubic}}
        }
    }

    // ======== OUTLINE ========
    Canvas {
        id: linesLock
        anchors.fill: parent
        visible: lock.showLines
        onPaint: {
            var a = nodesLock.itemAt(0), b = nodesLock.itemAt(1), c = nodesLock.itemAt(3), d = nodesLock.itemAt(2);
            if (!a || !b || !c || !d) return;
            var ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);
            ctx.lineWidth = 2; ctx.lineJoin = "round"; ctx.lineCap = "round"; ctx.strokeStyle = hudColorDim;
            function mid(it) { return it.mapToItem(linesLock, it.width/2, it.height/2); }
            var pa = mid(a), pb = mid(b), pc = mid(c), pd = mid(d);
            ctx.beginPath();
            ctx.moveTo(pa.x, pa.y); ctx.lineTo(pb.x, pb.y); ctx.lineTo(pc.x, pc.y); ctx.lineTo(pd.x, pd.y);
            ctx.closePath(); ctx.stroke();
        }
    }
     function updateExclusiveZone() {
        if (!panelWindow) { console.warn("panelWindow not set"); return; }
        panelWindow.exclusiveZone = visualOpen ? panelWindow.implicitWidth : 0;
    }
}
