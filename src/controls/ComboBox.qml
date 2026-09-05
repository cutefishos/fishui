import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Controls.impl
import QtQuick.Templates as T
import FishUI 1.0 as FishUI

T.ComboBox {
    id: control

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding,
                             implicitIndicatorHeight + topPadding + bottomPadding)

    topInset: FishUI.Units.smallSpacing
    bottomInset: FishUI.Units.smallSpacing

    spacing: FishUI.Units.smallSpacing
    padding: FishUI.Units.smallSpacing
    leftPadding: FishUI.Units.largeSpacing
    rightPadding: FishUI.Units.largeSpacing

    property bool darkMode: FishUI.Theme.darkMode

    onDarkModeChanged: {
        updateTimer.restart()
    }

    // T.ComboBox only counts its model, and with it fills currentText and
    // displayText, once it has a delegate. The rows themselves are built by
    // the drop-down window below, so this one is never instantiated.
    delegate: Item {}

    indicator: Image {
        id: indicatorImage
        x: control.mirrored ? control.leftPadding : control.width - width - control.rightPadding
        y: control.topPadding + (control.availableHeight - height) / 2

        height: FishUI.Units.iconSizes.small
        width: height

        cache: false

        source: "image://icontheme/go-down"
        sourceSize.width: width
        sourceSize.height: height
    }

    Timer {
        id: updateTimer
        triggeredOnStart: true
        interval: 10

        onTriggered: {
            indicatorImage.source = ""
            indicatorImage.source = "image://icontheme/go-down"
        }
    }

    contentItem: T.TextField {
        padding: FishUI.Units.smallSpacing
        leftPadding: 0
        rightPadding: FishUI.Units.smallSpacing

        text: control.editable ? control.editText : control.displayText

        enabled: control.editable
        autoScroll: control.editable
        readOnly: control.down
        inputMethodHints: control.inputMethodHints
        validator: control.validator

        font: control.font
        color: control.enabled ? control.FishUI.Theme.textColor : control.FishUI.Theme.highlightColor
        selectionColor:  control.FishUI.Theme.highlightColor
        selectedTextColor: control.FishUI.Theme.highlightedTextColor
        verticalAlignment: Text.AlignVCenter
    }

    background: Rectangle {
        implicitWidth:  (FishUI.Units.iconSizes.medium * 3) + FishUI.Units.largeSpacing
        implicitHeight: FishUI.Units.iconSizes.medium + FishUI.Units.smallSpacing

        radius: FishUI.Theme.smallRadius
        color: FishUI.Theme.alternateBackgroundColor

        border.color: control.activeFocus || control.menuVisible ? FishUI.Theme.highlightColor : color
        border.width: 1
    }

    // The list lives in its own popup window: Qt 6.8's window popups for
    // ComboBox are dismissed by the compositor the moment they open, and an
    // in-window Popup is clipped by the application window.
    FishUI.ComboBoxMenu {
        id: _menu

        model: control.model
        textRole: control.textRole
        currentIndex: control.currentIndex
        minimumWidth: control.width

        onSelected: function (index) {
            control.currentIndex = index
            control.activated(index)
        }
    }

    // The drop-down window, for a caller that has to close it itself.
    readonly property alias menu: _menu
    readonly property bool menuVisible: _menu.visible

    function toggleMenu() {
        if (_menu.visible) {
            _menu.dismissPopup()
            return
        }

        _menu.transientParent = control.Window.window
        var pos = control.mapToGlobal(0, control.height + FishUI.Units.smallSpacing / 2)
        _menu.popupAt(pos.x, pos.y)
    }

    // The ComboBox opens its own list: T.ComboBox would only drive the popup
    // property, which is left unset here.
    MouseArea {
        anchors.fill: parent
        z: 1
        enabled: control.enabled && !control.editable
        acceptedButtons: Qt.LeftButton
        onPressed: control.toggleMenu()
    }

    Keys.onPressed: function (event) {
        switch (event.key) {
        case Qt.Key_Space:
        case Qt.Key_Return:
        case Qt.Key_Enter:
        case Qt.Key_Down:
            control.toggleMenu()
            event.accepted = true
            break
        }
    }
}
