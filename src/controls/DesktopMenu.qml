import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import FishUI 1.0 as FishUI

FishUI.MenuPopupWindow {
    id: control

    default property alias content : _mainLayout.data

    FishUI.RoundedRect {
        id: _background
        anchors.fill: parent
        // opacity: 0.6
        // color: FishUI.Theme.backgroundColor
        radius: FishUI.Theme.hugeRadius
        backgroundOpacity: 0.6

        FishUI.WindowShadow {
            view: control
            geometry: Qt.rect(control.x, control.y, control.width, control.height)
            radius: _background.radius
        }

        FishUI.WindowBlur {
            view: control
            geometry: Qt.rect(control.x, control.y, control.width, control.height)
            windowRadius: _background.radius
            enabled: true
        }
    }

    ColumnLayout {
        id: _mainLayout
        anchors.fill: parent
        anchors.topMargin: 8
        anchors.bottomMargin: 8
    }

    function open() {
        control.show()
    }

    function popup() {
        control.show()
    }
}
