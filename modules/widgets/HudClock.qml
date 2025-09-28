import QtQuick 2.12

Item {
    id: root
    anchors.fill: parent
    focus: false

    // --- Geometry / style ---
    property int  s: 12                 // node size
    property int  gap: 12               // gap in compact form
    property int  rectW: 420            // width of the rectangle
    property int  rectH: 80             // height of the rectangle
    property int  topMargin: 24         // distance from top edge
    property color hudColor: "#ffffff"
    property color hudColorDim: "#80ffffff"

    // Derived positions
    readonly property int cx: Math.round((width - rectW) / 2) // centered x
    readonly property int yTop: topMargin

    // --- Time & Date (locale) ---
    property string timeText: Qt.formatTime(new Date(), "HH:mm")
    property string dateText: Qt.locale().toString(new Date(), "ddd dd MMM") // es: lun 23 set

    Timer {
        interval: 1000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: {
            timeText = Qt.formatTime(new Date(), "HH:mm")
            // aggiorno anche la data: costa pochissimo e gestisce il cambio giorno
            dateText = Qt.locale().toString(new Date(), "ddd dd MMM")
        }
    }

    // --- Time + Date labels (centrati nel rettangolo) ---

    Rectangle{
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: topMargin + 5
        implicitWidth: root.rectW -10
        implicitHeight: root.rectH -10
        color: "#6e000000"

        Row {
            spacing: 8
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            Text {
                id: timeLabel
                text: root.timeText
                font.pixelSize: 24
                color: hudColor
                horizontalAlignment: Text.AlignHCenter
            }
            Text {
                id: dateLabel
                text: root.dateText
                font.pixelSize: 24
                color: hudColor
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }

    // --- Four corner nodes (TL, TR, BR, BL) ---
    Repeater {
        id: nodes
        model: 4
        delegate: Rectangle {
            width: s; height: s; radius: 2; color: hudColor
            property bool isBottom: index >= 2
            property bool isRight: (index % 2) === 1

            x: root.cx + (isRight ? (rectW - s) : 0)
            y: root.yTop + (isBottom ? (rectH - s) : 0)

            onXChanged: lines.requestPaint()
            onYChanged: lines.requestPaint()
        }
    }

    // --- Outline lines connecting nodes ---
    Canvas {
        id: lines
        anchors.fill: parent
        onPaint: {
            var a = nodes.itemAt(0), b = nodes.itemAt(1), c = nodes.itemAt(3), d = nodes.itemAt(2);
            if (!a || !b || !c || !d) return;

            var ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);
            ctx.lineWidth = 2;
            ctx.lineJoin = "round";
            ctx.lineCap = "round";
            ctx.strokeStyle = hudColorDim;

            function mid(it){ return it.mapToItem(lines, it.width/2, it.height/2); }
            var pa = mid(a), pb = mid(b), pc = mid(c), pd = mid(d);

            ctx.beginPath();
            ctx.moveTo(pa.x, pa.y);
            ctx.lineTo(pb.x, pb.y);
            ctx.lineTo(pc.x, pc.y);
            ctx.lineTo(pd.x, pd.y);
            ctx.closePath();
            ctx.stroke();
        }
    }
}
