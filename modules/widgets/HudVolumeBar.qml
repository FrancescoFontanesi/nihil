import QtQuick 2.12
import Quickshell
import Quickshell.Io
import QtQml 2.15

Item {
    id: root
    focus: false

    property int s: 10
    property int rectW: 300
    property int rectH: 80
    property int topMargin: 24
    property color hudColor:    "#ffffff"
    property color hudColorDim: "#80ffffff"
    property bool  showLines: true

    property int  percent: 0
    property bool muted: false
    property int  pollMs: 1000
    property var  volumeCmd: ["bash","-lc","wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{m=$0; v=$2; gsub(/Volume:/,\"\",v); printf \"%d %s\\n\", v*100, (index(m,\"MUTED\")?\"muted\":\"on\") }'"]

    // Icon properties
    property url iconSource: Qt.resolvedUrl("../../assets/volume.png")   
    property int iconSize: 24
    property color iconTint: "#ffffff"

    readonly property int cx:  Math.round((width  - rectW) / 2)
    readonly property int yTop: topMargin

    width:  rectW + 2*s
    height: rectH + topMargin + s + (iconSource==""?0:iconSize+8)

    Repeater {
        id: nodes
        model: 4
        delegate: Rectangle {
            width: s; height: s; radius: 0; color: hudColor
            property bool isBottom: index >= 2
            property bool isRight : (index % 2) === 1
            x: root.cx + (isRight ? (rectW - s) : 0)
            y: root.yTop + (isBottom ? (rectH - s) : 0)
            onXChanged: lines.requestPaint()
            onYChanged: lines.requestPaint()
        }
    }
    Canvas {
        id: lines
        anchors.fill: parent
        visible: showLines
        onPaint: {
            var a = nodes.itemAt(0), b = nodes.itemAt(1), c = nodes.itemAt(3), d = nodes.itemAt(2);
            if (!a || !b || !c || !d) return;
            var ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);
            ctx.lineWidth = 2; ctx.strokeStyle = hudColorDim;
            function mid(it){ return it.mapToItem(lines, it.width/2, it.height/2); }
            var pa = mid(a), pb = mid(b), pc = mid(c), pd = mid(d);
            ctx.beginPath(); ctx.moveTo(pa.x, pa.y); ctx.lineTo(pb.x, pb.y); ctx.lineTo(pc.x, pc.y); ctx.lineTo(pd.x, pd.y);
            ctx.closePath(); ctx.stroke();
        }
    }

    Rectangle {
        id: frame
        x: root.cx + s + 8
        y: root.yTop + s + 8
        width:  rectW - (2*s + 16)
        height: rectH - (2*s + 16)
            
        radius: 8
        color: '#11ff0000'
        border.color: hudColor
        border.width: 4


        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            x: 6
            height: Math.max(parent.height - 12, 4)
            width: Math.max(0, Math.round((parent.width - 12) * root.percent / 100))
            radius: 8
            color: muted ? "#ff5555" : "#ffffff"
            Behavior on width { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
        }
    }

    Image {
        visible: iconSource !== ""
        source: iconSource
        width: iconSize; height: iconSize
        x: frame.x + 100
        y: frame.y + frame.height + 12
        fillMode: Image.PreserveAspectFit
        layer.enabled: true
    }

    Process {
        id: p
        command: volumeCmd
        running: false
        stdout: SplitParser {
            onRead: data => {
                var t = (data || "").toString().trim().split(/\s+/)
                var v = parseInt(t[0], 10)
                if (!isNaN(v)) root.percent = Math.max(0, Math.min(100, v))
                if (t.length > 1) root.muted = (t[1].toLowerCase().indexOf("mut") === 0)
            }
        }
    }
    Timer {
        interval: root.pollMs; running: true; repeat: true; triggeredOnStart: true
        onTriggered: if (!p.running) p.running = true
    }
}
