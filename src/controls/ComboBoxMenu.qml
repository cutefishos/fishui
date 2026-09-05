import QtQuick
import FishUI 1.0 as FishUI

// The drop-down of FishUI.ComboBox. A popup window rather than an in-window
// Popup, so a long list is not clipped by the application window.
FishUI.MenuPopupWindow {
    id: control

    property var model: null
    property string textRole: ""
    // The chosen row: it carries the checkmark and is where the list opens.
    property int currentIndex: -1
    property int minimumWidth: 0

    signal selected(int index)

    // A list as tall as the screen has nowhere to sit below the field it
    // belongs to, and it never scrolls because everything fits. Half the work
    // area leaves room under the field and makes a long list scrollable.
    readonly property int maximumHeight: control.availableHeight > 0
        ? Math.max(Math.min(control.availableHeight, 240),
                   Math.round(control.availableHeight * 0.5))
        : 0

    popupContentItem: _contentItem
    contentTopMargin: _contentItem.verticalContentMargin

    FishUI.MenuSurface {
        id: _contentItem

        view: control
        blurEnabled: FishUI.Theme.blurEnabled
        maxHeight: control.maximumHeight
        minimumWidth: control.minimumWidth

        Repeater {
            model: control.model

            FishUI.MenuItem {
                text: {
                    if (!control.textRole)
                        return modelData

                    if (modelData && modelData[control.textRole] !== undefined)
                        return modelData[control.textRole]

                    return model[control.textRole]
                }
                // The row shows the current choice; it is never toggled by
                // the click itself.
                checked: index === control.currentIndex
                // Keeps the labels of the whole list on one column.
                reservesCheckColumn: true

                onTriggered: control.selected(index)
            }
        }
    }

    function popupAt(x, y) {
        _contentItem.ensureLayout()
        control.showAt(x, y)
        // Open on the current choice: highlighted, and scrolled to if the
        // list is longer than the screen.
        _contentItem.setCurrentIndex(control.currentIndex)
        _contentItem.centerCurrentRow()
    }

    // The pointer takes the highlight back from the keyboard as soon as it
    // moves over the list.
    onMouseMoved: {
        if (control.containsGlobalCursor())
            _contentItem.setCurrentIndex(-1)
    }

    onWheelMoved: function (angleDelta, pixelDelta) {
        _contentItem.scrollByWheel(angleDelta, pixelDelta)
    }

    onKeyPressed: function (key, modifiers) {
        switch (key) {
        case Qt.Key_Down:
            _contentItem.moveCurrentIndex(1)
            break
        case Qt.Key_Up:
            _contentItem.moveCurrentIndex(-1)
            break
        case Qt.Key_Home:
            _contentItem.setCurrentIndex(-1)
            _contentItem.moveCurrentIndex(1)
            break
        case Qt.Key_End:
            _contentItem.setCurrentIndex(-1)
            _contentItem.moveCurrentIndex(-1)
            break
        case Qt.Key_Return:
        case Qt.Key_Enter:
        case Qt.Key_Space:
            var row = _contentItem.currentRow()
            if (row && row.enabled)
                row.triggered()
            break
        case Qt.Key_Escape:
            control.dismissPopup()
            break
        }
    }

    onVisibleChanged: {
        if (!visible) {
            _contentItem.resetScroll()
            _contentItem.setCurrentIndex(-1)
        }
    }
}
