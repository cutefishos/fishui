import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtGraphicalEffects 1.0
import MeuiKit 1.0 as Meui

Item {
    id: _toast
    //visible: open
    Layout.alignment: Qt.AlignBottom | Qt.AlignLeft
    width: open ? _layout.implicitWidth + (Meui.Units.largeSpacing * 2) : 0
    height: _layout.implicitHeight + (Meui.Units.largeSpacing * 2)
    clip: false

    Behavior on width {
        NumberAnimation {
            duration: 500
            easing.type: Easing.InOutCubic
        }
    }

    property string text: ""
    /**
        Possible types:
            - info: Gray toast
            - success: Green toast
            - warn: Yellow toast
            - error: Red toast
    */
    property string type: "error"
    property bool hasCloseButton: true
    property bool open: false

    onOpenChanged: {
        _timer.restart()
    }

    Timer {
        id: _timer
        interval: 5000
        running: false
        repeat: false
        onTriggered: _toast.open = false
    }

    function getColorFromType() {
        switch(_toast.type) {
            case "info":
                return Meui.Theme.blueColor
            case "success":
                return Meui.Theme.greenColor
            case "warn":
                return Meui.Theme.orangeColor
            case "error":
                return Meui.Theme.redColor
            default:
                console.log("Toast: invalid type")
                return;
        }
    }

    Rectangle {
        radius: Meui.Theme.bigRadius
        color: getColorFromType()
        anchors.fill: parent

        RowLayout {
            id: _layout
            anchors.fill: parent
            anchors.margins: Meui.Units.smallSpacing

            Image {
                // Icon for toast, determined by type
                width: 22
                height: width
                sourceSize.width: width
                sourceSize.height: height
                source: "qrc:/meui/kit/images/toast/${_toast.type}.svg"
                Layout.margins: Meui.Units.smallSpacing
            }

            Label {
                Layout.alignment: Qt.AlignVCenter
                text: _toast.text
                color: Meui.Theme.highlightedTextColor
            }

            Item {
                Layout.fillWidth: true
            }

            Image {
                visible: _toast.hasCloseButton
                Layout.leftMargin: Meui.Theme.largeSpacing
                width: 32
                height: 32
                source: "qrc:/meui/kit/images/toast/close.svg"

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton
                    onClicked: {
                        _toast.open = false
                    }
                }
            }
        }

        layer.enabled: true
        layer.effect: DropShadow {
            radius: 8.0
            samples: 17
            color: "#80000000"
        }
    }
}
