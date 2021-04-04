import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import MeuiKit 1.0 as Meui

Meui.PopupWindow {
    id: control

    default property alias content : _mainLayout.data

    Rectangle {
        id: _background
        anchors.fill: parent
        opacity: 0.6
        color: Meui.Theme.backgroundColor
        radius: Meui.Theme.mediumRadius

        Meui.WindowShadow {
            view: control
            geometry: Qt.rect(control.x, control.y, control.width, control.height)
            radius: _background.radius
        }

        Meui.WindowBlur {
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
