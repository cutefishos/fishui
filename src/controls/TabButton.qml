import QtQuick 2.15
import QtQml 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import FishUI 1.0 as FishUI

Item {
    id: control

    property bool checked: false
    property bool hovered: _mouseArea.containsMouse
    property bool pressed: _mouseArea.pressed

    property alias font: _label.font
    property string text: ""

    property var backgroundColor: FishUI.Theme.secondBackgroundColor
    property var hoveredColor: FishUI.Theme.darkMode ? Qt.lighter(FishUI.Theme.secondBackgroundColor, 1.3)
                                                     : Qt.darker(FishUI.Theme.secondBackgroundColor, 1.05)
    property var pressedColor: FishUI.Theme.darkMode ? Qt.lighter(FishUI.Theme.secondBackgroundColor, 1.1)
                                                     : Qt.darker(FishUI.Theme.secondBackgroundColor, 1.1)

    property alias background: hoveredRect

    signal clicked()
    signal closeClicked()

    MouseArea {
        id: _mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: control.clicked()
    }

    Rectangle {
        id: hoveredRect
        anchors.fill: parent
        anchors.leftMargin: FishUI.Units.smallSpacing / 2
        anchors.rightMargin: FishUI.Units.smallSpacing / 2
        anchors.topMargin: FishUI.Units.smallSpacing / 2
        color: control.hovered ? control.pressed ? pressedColor
                                                 : hoveredColor : backgroundColor
        opacity: 0.5
        border.width: 0
        radius: FishUI.Theme.smallRadius
    }

    Rectangle {
        id: checkedRect
        anchors.leftMargin: FishUI.Units.smallSpacing / 2
        anchors.rightMargin: FishUI.Units.smallSpacing / 2
        anchors.topMargin: FishUI.Units.smallSpacing / 2
        anchors.fill: parent
        color: FishUI.Theme.highlightColor
        opacity: _mouseArea.pressed ? 0.9 : 1
        border.width: 0
        visible: checked
        radius: FishUI.Theme.smallRadius
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: FishUI.Units.smallSpacing / 2
        anchors.rightMargin: FishUI.Units.smallSpacing / 2
        anchors.topMargin: FishUI.Units.smallSpacing / 2
        spacing: 0

        Label {
            id: _label
            text: control.text
            leftPadding: FishUI.Units.smallSpacing / 2
            Layout.fillWidth: true
            Layout.fillHeight: true
            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
            color: control.checked ? FishUI.Theme.highlightedTextColor
                                   : FishUI.Theme.textColor
            elide: Text.ElideMiddle
            wrapMode: Text.NoWrap
        }

        FishUI.TabCloseButton {
            enabled: control.checked
            Layout.preferredHeight: 24
            Layout.preferredWidth: 24
            size: 24
            source: !enabled ? "" : "qrc:/images/" + (FishUI.Theme.darkMode || control.checked ? "dark/" : "light/") + "close.svg"
            onClicked: control.closeClicked()
        }
    }
}
