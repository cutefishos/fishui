import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import FishUI 1.0 as FishUI

FishUI.Window {
    id: control

    property string text
    property string cancelText: qsTr("Cancel")
    property string confirmText: qsTr("Confirm")
    property bool destructive: false
    property bool confirmEnabled: true

    signal accepted()
    signal rejected()

    flags: Qt.Dialog | Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
    modality: Qt.WindowModal
    visible: false
    minimizeButtonVisible: false
    contentTopMargin: 0
    windowRadius: 16
    windowButtonsTopMargin: 8
    windowButtonsRightMargin: 8
    header.height: 44
    background.color: FishUI.Theme.secondBackgroundColor

    readonly property int dialogWidth: Math.max(336, actions.implicitWidth + 32)
    readonly property int dialogHeight: layout.implicitHeight + 32
    // The labels are given this width outright: sized by the layout instead,
    // they are first measured unwrapped and the window is mapped one text line
    // too short, then grows a frame later.
    readonly property int textWidth: dialogWidth - 32 - 32

    width: dialogWidth
    height: dialogHeight
    minimumWidth: dialogWidth
    maximumWidth: dialogWidth
    minimumHeight: dialogHeight
    maximumHeight: dialogHeight

    property bool _accepted: false

    // Let wrapped text and layout sizing settle before mapping the window.
    Component.onCompleted: Qt.callLater(function() {
        control.show()
        control.raise()
        control.requestActivate()
    })

    DragHandler {
        parent: control.contentItem
        target: null
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
        grabPermissions: PointerHandler.CanTakeOverFromItems
                         | PointerHandler.CanTakeOverFromHandlersOfDifferentType
                         | PointerHandler.ApprovesTakeOverByAnything
        onActiveChanged: if (active) control.helper.startSystemMove(control)
    }

    function accept() {
        if (!confirmEnabled)
            return
        _accepted = true
        accepted()
        close()
    }

    onClosing: {
        if (!_accepted)
            rejected()
    }
    onVisibleChanged: {
        if (visible) {
            _accepted = false
            cancelButton.forceActiveFocus()
        }
    }

    Shortcut {
        sequence: "Escape"
        onActivated: control.close()
    }

    ColumnLayout {
        id: layout
        anchors.fill: parent
        anchors.margins: 16
        spacing: 16

        Column {
            Layout.fillWidth: true
            Layout.rightMargin: 32
            spacing: 4

            QQC2.Label {
                width: control.textWidth
                text: control.title
                textFormat: Text.PlainText
                font.pixelSize: 14
                font.weight: Font.DemiBold
                color: FishUI.Theme.textColor
                wrapMode: Text.Wrap
            }

            QQC2.Label {
                width: control.textWidth
                text: control.text
                textFormat: Text.PlainText
                font.pixelSize: 14
                color: FishUI.Theme.disabledTextColor
                wrapMode: Text.Wrap
                lineHeight: 20
                lineHeightMode: Text.FixedHeight
                visible: text.length > 0
            }
        }

        RowLayout {
            id: actions
            Layout.alignment: Qt.AlignRight
            spacing: 8

            FishUI.ConfirmDialogButton {
                id: cancelButton
                text: control.cancelText
                focus: true
                onClicked: control.close()
            }

            FishUI.ConfirmDialogButton {
                text: control.confirmText
                primary: true
                destructive: control.destructive
                enabled: control.confirmEnabled
                onClicked: control.accept()
            }
        }
    }
}
