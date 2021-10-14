import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtGraphicalEffects 1.0
import FishUI 1.0 as FishUI

FishUI.Window {
    id: control

    width: 300
    height: 300

    modality: Qt.WindowModal

    visible: false

    property var iconSource
    property string name
    property string description

    ColumnLayout {
        anchors.fill: parent
        anchors.topMargin: FishUI.Units.largeSpacing * 2

        Image {
            width: 64
            height: 64
            source: control.iconSource
            sourceSize: Qt.size(64, 64)
            Layout.alignment: Qt.AlignHCenter
        }

        Item {
            height: FishUI.Units.largeSpacing * 2
        }

        Label {
            text: control.name
            Layout.alignment: Qt.AlignHCenter
        }

        Label {
            text: control.description
            Layout.alignment: Qt.AlignHCenter
        }

        Item {
            Layout.fillHeight: true
        }
    }
}
