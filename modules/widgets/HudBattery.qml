import QtQuick 2.12
import Quickshell.Io 

Item {
    id: root

    // --- CONFIG UI ---
    property int segments: 10
    property int barWidth: 260
    property int barHeight: 28
    property int radius: 8
    property int gap: 4
    property color frameColor: "#80ffffff"
    property color emptyColor: "#30ffffff"
    property color textColor: "#ffffff"


    property int percent: 0
    property bool charging: false

    function levelColor(p) {
        if (charging) return "#c3e9ff" // azzurrino in carica
        if (p >= 65) return "#ffffff"  // bianco pieno
        if (p >= 35) return "#ffffff"
        if (p >= 20) return "#ff0000"
        return "#ffffff"              // rosso
    }

    Timer {
        interval: 150000   // 5 minuti
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: batteryProcess.running = true
    }

    Process {
        id: batteryProcess
        command: ["/home/nihil/.config/hypr/scripts/battery.sh"]
        running: false

        stdout: SplitParser {
            onRead: (data) => {
                try {
                    const obj = JSON.parse(data)
                    if (obj.percent !== undefined)
                        root.percent = Math.max(0, Math.min(100, obj.percent))
                    if (obj.charging !== undefined)
                        root.charging = !!obj.charging
                } catch(e) {
                    console.warn("Battery JSON parse error:", data)
                }
            }
        }
    }



    // --- UI LAYOUT ---
    width: barWidth
    height: barHeight + 20

    Rectangle {
        id: frame
        anchors.horizontalCenter: parent.horizontalCenter
        width: barWidth
        height: barHeight
        radius: root.radius
        color: "transparent"
        border.color: frameColor
        border.width: 1

        // segmenti
        Row {
            id: row
            anchors.fill: parent
            anchors.margins: 4
            spacing: gap

            Repeater {
                model: segments
                delegate: Rectangle {
                    width: (row.width - (segments - 1) * gap) / segments
                    height: row.height
                    radius: Math.min(root.radius * 0.6, height/4)
                    color: (index < Math.round(root.percent / (100/segments)))
                           ? levelColor(root.percent)
                           : emptyColor
                }
            }
        }

        // “tappo” batteria a destra
        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            width: 6; height: barHeight * 0.55
            radius: 3
            x: parent.width + 2
            color: frameColor
        }
    }

    // testo percentuale
    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: frame.bottom
        anchors.topMargin: 6
        text: (charging ? "+" : "") + root.percent + "%"
        color: textColor
        font.pixelSize: 12
    }
}
