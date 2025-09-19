
import QtQuick 2.15

// Edge strip semplificato: mostra un PNG con reveal da bordo.
Item {
    id: root

    // API
    property string edge: "top"          // "top"|"bottom"|"left"|"right"
    property url source: ""              // PNG path/URL
    property int fillMode: Image.Stretch  // Image.FillMode
    property bool autoShow: true
    property int autoShowDelay: 150

    // Contenitore animato
    Item {
        id: fx
        anchors.fill: parent
        opacity: 0.0
        x: (edge === "left")  ? -8 : (edge === "right") ?  8 : 0
        y: (edge === "top")   ? -8 : (edge === "bottom")?  8 : 0

        Behavior on opacity { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
        Behavior on x { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
        Behavior on y { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }

        Image {
            anchors.fill: parent
            source: root.source
            fillMode: root.fillMode
            smooth: true
            asynchronous: true
            cache: true
        }
    }

    function reveal() { fx.opacity = 1.0; fx.x = 0; fx.y = 0 }

    Component.onCompleted: if (autoShow) Qt.createQmlObject("import QtQuick 2.15; Timer{ interval:"+autoShowDelay+"; running:true; repeat:false; onTriggered: parent.reveal() }", root)
}
