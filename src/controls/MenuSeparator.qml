import QtQuick
import QtQuick.Controls
import QtQuick.Templates as T
import QtQuick.Layouts 1.12

import FishUI 1.0 as FishUI

T.MenuSeparator {
    id: control

    implicitHeight: visible ? 5 : 0
    height: implicitHeight
    Layout.fillWidth: true

    background: Rectangle {
        id: separator
        anchors.centerIn: control
        width: control.width - FishUI.Units.largeSpacing * 2
        height: 1 / FishUI.Dpi.ratio
        color: FishUI.Theme.darkMode ? Qt.rgba(255, 255, 255, 0.14)
                                    : Qt.rgba(0, 0, 0, 0.1)
    }
}
