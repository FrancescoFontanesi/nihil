
import QtQuick 2.15


Item {
    id: root

    // API
    property string edge: "top"          // "top"|"bottom"|"left"|"right"
    property url source: ""              // PNG path/URL
    property int fillMode: Image.Stretch  // Image.FillMode

    // Contenitore animato
    Item {
        id: fx
        anchors.fill: parent
        opacity: 1
        x: (edge === "left")  ? -8 : (edge === "right") ?  8 : 0
        y: (edge === "top")   ? -8 : (edge === "bottom")?  8 : 0

        Image {
            anchors.fill: parent
            source: root.source
            fillMode: root.fillMode
            smooth: true
            asynchronous: true
            cache: true
        }
    }
}
