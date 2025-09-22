import QtQuick 2.12
import QtQuick.Controls 2.12 
import QtQuick.Layouts 1.12


Item {
    id: root
    anchors.fill: parent
    focus: false

    // ---- Geometry / style ----
    property int    s: 12                 // node size
    property int    gap: 12               // compact gap
    property int    rectW: 420            // compact width
    property int    rectH: 80             // compact height
    property int    expandH: 360          // extra height when expanded
    property int    topMargin: 24         // distance from top screen edge
    property color  hudColor: "#ffffff"
    property color  hudColorDim: "#80ffffff"

    // ---- State / anim ----
    property bool   expanded: false
    property bool   expandPhase: true
    property int    animDur: 280
    property bool   stagger: true
    property int    staggerStep: 60
    property real   overshoot: 0.8

    // derived
    readonly property int cx: Math.round((width - rectW) / 2)          // centered x
    readonly property int yTop: topMargin
    readonly property int yBottomCompact: yTop + rectH - s
    readonly property int yBottomExpanded: yTop + rectH + expandH - s

    // ---- sequencing: only bottom nodes move on expand/contract ----
    SequentialAnimation {
        id: toExpand
        ScriptAction { script: root.expandPhase = true }
        // (top nodes static; bottom nodes animated via Behavior below by flipping 'expanded')
        ScriptAction { script: root.expanded = true }
        onStopped: {}  // hook if you need
    }
    SequentialAnimation {
        id: toContract
        ScriptAction { script: root.expandPhase = true }
        ScriptAction { script: root.expanded = false }
        onStopped: {}
    }

    // ---- Clickable area (over the compact rectangle) ----
    MouseArea {
        id: clicker
        x: root.cx
        y: root.yTop
        width: rectW
        height: rectH
        acceptedButtons: Qt.LeftButton
        onClicked: if (!toExpand.running && !toContract.running) expanded ? toContract.start() : toExpand.start()
    }


    // ---- Time label (always centered at the top rectangle) ----
    Text {
        id: clockText
        text: Qt.formatTime(new Date(), "HH:mm:ss")
        font.pixelSize: 22
        color: hudColor
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: topMargin + Math.round((rectH - height) / 2) 
        layer.enabled: true
    }
    Timer { interval: 1000; running: true; repeat: true; onTriggered: clockText.text = Qt.formatTime(new Date(), "HH:mm:ss") }

    // ---- 4 nodes corners (TL, TR, BR, BL via indices 0..3) ----
    Repeater {
        id: nodes
        model: 4
        delegate: Rectangle {
            id: node
            width: s; height: s; radius: 2; color: hudColor
            property bool isBottom: (index >= 2)
            property bool isRight: (index % 2) === 1
            property int stagIndex: expanded ? index : (3 - index)

            // positions: top nodes fixed; bottom nodes slide down/up
            x: root.cx + (isRight ? (rectW - s) : 0)
            y: isBottom
               ? (expanded ? root.yBottomExpanded : root.yBottomCompact)
               : root.yTop

            // animate bottom nodes only during expand/contract
            Behavior on y {
                enabled: expandPhase && isBottom
                SequentialAnimation {
                    PauseAnimation { duration: stagger ? stagIndex * staggerStep : 0 }
                    NumberAnimation {
                        duration: animDur
                        easing.type: Easing.OutBack
                        easing.overshoot: overshoot
                    }
                }
            }

            onXChanged: lines.requestPaint()
            onYChanged: lines.requestPaint()
        }
    }

    // ---- outline lines ----
    Canvas {
        id: lines
        anchors.fill: parent
        onPaint: {
            var a = nodes.itemAt(0), b = nodes.itemAt(1), c = nodes.itemAt(3), d = nodes.itemAt(2);
            if (!a || !b || !c || !d) return;
            var ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);
            ctx.lineWidth = 2; ctx.lineJoin = "round"; ctx.lineCap = "round"; ctx.strokeStyle = hudColorDim;

            function mid(it){ return it.mapToItem(lines, it.width/2, it.height/2); }
            var pa = mid(a), pb = mid(b), pc = mid(c), pd = mid(d);

            ctx.beginPath();
            ctx.moveTo(pa.x, pa.y); ctx.lineTo(pb.x, pb.y);
            ctx.lineTo(pc.x, pc.y); ctx.lineTo(pd.x, pd.y);
            ctx.closePath(); ctx.stroke();
        }
    }
}