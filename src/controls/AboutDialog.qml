import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import Qt5Compat.GraphicalEffects
import FishUI 1.0 as FishUI

FishUI.Window {
    id: control

    width: 300
    height: contentHeight

    maximumWidth: control.width
    minimumWidth: control.width

    maximumHeight: contentHeight
    minimumHeight: contentHeight

    modality: Qt.WindowModal
    flags: Qt.Dialog | Qt.FramelessWindowHint

    minimizeButtonVisible: false
    visible: false

    property var iconSource
    property string name
    property string description
    property string link: "https://cutefishos.com"
    property var contentHeight: _mainLayout.implicitHeight + control.header.height * 2

    background.opacity: 0.6

    FishUI.WindowBlur {
        view: control
        geometry: Qt.rect(control.x, control.y, control.width, control.height)
        windowRadius: control.windowRadius
        enabled: true
    }

    ColumnLayout {
        id: _mainLayout
        anchors.fill: parent
        anchors.bottomMargin: control.header.height

        Image {
            width: 64
            height: 64
            source: control.iconSource
            sourceSize: Qt.size(64, 64)
            Layout.alignment: Qt.AlignHCenter
        }

        Item {
            height: FishUI.Units.largeSpacing
        }

        Label {
            text: control.name
            Layout.alignment: Qt.AlignHCenter
            font.pointSize: 14
        }

        Label {
            text: control.description
            Layout.alignment: Qt.AlignHCenter
        }

        Label {
            text: "<a href=\"%1\">%1</a>".arg(control.link)
            Layout.alignment: Qt.AlignHCenter
            linkColor: FishUI.Theme.highlightColor

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: Qt.openUrlExternally(control.link)
            }
        }

        Item {
            Layout.fillHeight: true
        }
    }
}
