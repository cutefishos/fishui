import QtQuick 2.12
import QtQuick.Window 2.3
import QtQuick.Controls 2.4
import FishUI 1.0 as FishUI

Item {
    id: control

    property var size: 32
    height: size
    width: size

    property color hoveredColor: FishUI.Theme.darkMode ? Qt.lighter(FishUI.Theme.backgroundColor, 1.5)
                                                   : Qt.darker(FishUI.Theme.backgroundColor, 1.2)
    property color pressedColor: FishUI.Theme.darkMode ? Qt.lighter(FishUI.Theme.backgroundColor, 1.3)
                                                     : Qt.darker(FishUI.Theme.backgroundColor, 1.3)
    property alias source: image.source
    signal clicked()

    Rectangle {
        id: background
        anchors.fill: parent
        anchors.margins: size * 0.1
        radius: control.height / 2
        color: mouseArea.pressed ? pressedColor : mouseArea.containsMouse ? control.hoveredColor : "transparent"
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true

        onClicked: control.clicked()
    }

    Image {
        id: image
        objectName: "image"
        anchors.fill: parent
        fillMode: Image.PreserveAspectFit
        sourceSize: Qt.size(width, height)
        cache: true
        asynchronous: false
    }
}
