import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Templates 2.12 as T
import FishUI 1.0 as FishUI

T.MenuSeparator {
    id: control

    implicitHeight: FishUI.Units.smallSpacing + separator.height
    width: parent.width

    background: Rectangle {
        id: separator
        anchors.centerIn: control
        width: control.width - FishUI.Units.largeSpacing
        height: 1
        color: FishUI.Theme.textColor
        opacity: 0.3
    }
}