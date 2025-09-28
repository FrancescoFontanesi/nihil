import QtQuick 2.12
import Quickshell

Item {
    id: root

    // Public API
    property int  iconSize: 64
    property real hoverScale: 1.2
    // Override this to customize entries; each item is { icon: url, cmd: string[] }
    property var  items: [
        { icon: Qt.resolvedUrl("../../assets/reboot.png"),   cmd: ["systemctl","reboot"] },
        { icon: Qt.resolvedUrl("../../assets/shutdown.png"), cmd: ["systemctl","poweroff"] },
        { icon: Qt.resolvedUrl("../../assets/lock.png"),     cmd: ["loginctl", "lock-session"] }
    ]

    // Even spacing across available height
    readonly property int _count: (items && items.length) ? items.length : 0
    readonly property int _spacing: {
        if (_count <= 1) return 0
        var free = height - (_count * iconSize)
        return Math.max(8, Math.floor(free / (_count - 1)))
    }

    // Column that fills parent and distributes icons evenly
    Column {
        id: col
        anchors.fill: parent
        spacing: _spacing /2

        Repeater {
            model: root.items
            delegate: Item {
                id: wrapper
                width: Math.min(200, Math.round(parent.width * 0.6))
                height: iconSize
                anchors.horizontalCenter: parent.horizontalCenter
                transformOrigin: Item.Center
                scale: 1.0

                Behavior on scale { NumberAnimation { duration: 1000; easing.type: Easing.OutCubic } }

                Image {
                    id: iconImg
                    anchors.centerIn: parent
                    source: modelData.icon
                    sourceSize.width: iconSize
                    sourceSize.height: iconSize
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    transformOrigin: Item.Center
                    rotation: 0
                    // rotation anim (auto-reverses)
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: {
                        wrapper.scale = root.hoverScale     // scale up
                    }
                    onExited: {
                        wrapper.scale = 1.0                 // scale back
                    }
                    onClicked: {
                        if (modelData.cmd && modelData.cmd.length)
                            Quickshell.execDetached(modelData.cmd)
                    }
                }

            }
        }
    }
}
