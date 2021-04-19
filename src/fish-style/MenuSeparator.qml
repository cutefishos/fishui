import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Templates 2.12 as T
import FishUI 1.0 as FishUI

T.MenuSeparator {
    id: control

    implicitHeight: FishUI.Units.largeSpacing + separator.height
    width: parent.width

    background: Rectangle {
        id: separator
        anchors.centerIn: control
        width: control.width - FishUI.Units.largeSpacing * 2
        height: 1
        color: FishUI.Theme.textColor
        opacity: 0.3
    }
}