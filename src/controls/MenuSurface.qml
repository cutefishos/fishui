import QtQuick
import QtQuick.Layouts
import FishUI 1.0 as FishUI

// The inside of a popup-window menu: frame, blur and shadow, a column of rows
// that scrolls when it does not fit, and the row navigation that goes with it.
// The window around it is FishUI.MenuPopupWindow; DesktopMenu and the ComboBox
// drop-down both fill theirs with this.
Item {
    id: control

    default property alias content: _mainLayout.data

    // The popup window this surface fills. Shadow and blur belong to the
    // window, not to an item inside it.
    property var view: null
    property bool blurEnabled: false
    // How tall the surface may become; 0 leaves it unconstrained.
    property int maxHeight: 0
    // A drop-down is never narrower than the control it hangs off.
    property int minimumWidth: 0
    // Row the keyboard highlights, as an index into menuRows().
    property int currentIndex: -1

    readonly property int contentMargin: Math.max(4, FishUI.Units.smallSpacing - 2)
    // Lets a popup align its first row with the item that opened it.
    readonly property int verticalContentMargin: Math.round(contentMargin * 1.5)
    readonly property bool scrollable: _flickable.contentHeight > _flickable.height

    implicitWidth: Math.max(control.minimumWidth, _mainLayout.implicitWidth + contentMargin * 2)
    implicitHeight: maxHeight > 0 ? Math.min(_mainLayout.implicitHeight + verticalContentMargin * 2, maxHeight)
                                  : _mainLayout.implicitHeight + verticalContentMargin * 2
    // The window is sized from the implicit size above, but it is the window
    // that has the last word: a compositor may hand a popup a different size
    // than it asked for. Following it keeps the frame and the rows filling the
    // popup instead of leaving a blank strip.
    width: control.view ? control.view.width : implicitWidth
    height: control.view ? control.view.height : implicitHeight

    Rectangle {
        id: _background
        anchors.fill: parent
        color: Qt.rgba(FishUI.Theme.secondBackgroundColor.r,
                       FishUI.Theme.secondBackgroundColor.g,
                       FishUI.Theme.secondBackgroundColor.b,
                       control.blurEnabled ? 0.86 : 1)
        radius: FishUI.Theme.windowRadius
        border.color: _background.borderColor
        border.width: 1 / FishUI.Dpi.ratio
        border.pixelAligned: FishUI.Dpi.ratio > 1 ? false : true

        property var borderColor: FishUI.Theme.darkMode ? Qt.rgba(255, 255, 255, 0.3)
                                                        : Qt.rgba(0, 0, 0, 0.2)

        FishUI.WindowShadow {
            view: control.view
            radius: _background.radius
            strength: 0.4
            enabled: !!control.view
        }

        FishUI.WindowBlur {
            view: control.view
            windowRadius: _background.radius
            enabled: !!control.view && control.blurEnabled
        }
    }

    Flickable {
        id: _flickable

        x: control.contentMargin
        y: control.verticalContentMargin
        width: control.width - control.contentMargin * 2
        height: control.height - control.verticalContentMargin * 2
        contentWidth: width
        contentHeight: _mainLayout.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        // A menu scrolls by the wheel alone. Flicking would give it momentum,
        // and rows still sliding under the pointer swallow the click that was
        // meant for one of them.
        interactive: false

        ColumnLayout {
            id: _mainLayout
            width: _flickable.width
            height: implicitHeight
            spacing: 1
        }
    }

    // Scroll indicator for the rare menu that does not fit on screen.
    Rectangle {
        width: 3
        radius: width / 2
        x: control.width - control.contentMargin - width
        y: _flickable.y + _flickable.height * (_flickable.contentY / _flickable.contentHeight)
        height: Math.max(24, _flickable.height * (_flickable.height / _flickable.contentHeight))
        visible: control.scrollable
        color: FishUI.Theme.darkMode ? Qt.rgba(255, 255, 255, 0.35)
                                     : Qt.rgba(0, 0, 0, 0.25)
    }

    // One wheel notch is 120 eighths of a degree and moves the menu by two
    // rows; a touchpad reports pixels and moves it by exactly those.
    function scrollByWheel(angleDelta, pixelDelta) {
        if (!control.scrollable)
            return

        var step = pixelDelta.y
        if (step === 0)
            step = angleDelta.y / 120 * 60
        if (step === 0)
            return

        control.scrollBy(step)
    }

    function scrollBy(step) {
        control.scrollTo(_flickable.contentY - step)
    }

    function resetScroll() {
        _flickable.contentY = 0
    }

    // The popup takes its size from the layout's implicit size, and a menu
    // whose rows come from a model has not laid them out yet when it is asked
    // to show. The first pass computes that implicit size, which the layout's
    // own width and height bindings adopt; the second puts the rows at their
    // places inside it. Without both, such a menu maps at the size of an empty
    // popup with all of its rows stacked on top of each other.
    function ensureLayout() {
        _mainLayout.ensurePolished()
        _mainLayout.ensurePolished()
    }

    function isMenuRow(item) {
        return !!item && item.visible &&
                item.text !== undefined && item.highlighted !== undefined
    }

    // The rows of this menu, in visual order. A row created by a Loader (a
    // menu built from a model) is unwrapped to the item it loaded.
    function menuRows() {
        var rows = []
        var children = _mainLayout.children
        for (var i = 0; i < children.length; ++i) {
            var child = children[i]
            if (control.isMenuRow(child)) {
                rows.push(child)
            } else if (child && child.visible && child.item !== undefined &&
                       control.isMenuRow(child.item)) {
                rows.push(child.item)
            }
        }
        return rows
    }

    // The row under a point in global coordinates, or -1. Hit testing lives
    // here because Qt Quick sends no hover to a row while a button is held,
    // so the pointer has to be followed by hand.
    function rowAtGlobal(globalPos) {
        var rows = control.menuRows()
        for (var i = 0; i < rows.length; ++i) {
            var local = rows[i].mapFromGlobal(globalPos.x, globalPos.y)
            if (rows[i].contains(Qt.point(local.x, local.y)))
                return i
        }
        return -1
    }

    function currentRow() {
        var rows = control.menuRows()
        return control.currentIndex >= 0 && control.currentIndex < rows.length
                ? rows[control.currentIndex] : null
    }

    function indexOfRow(row) {
        var rows = control.menuRows()
        for (var i = 0; i < rows.length; ++i) {
            if (rows[i] === row)
                return i
        }
        return -1
    }

    function applyHighlight() {
        var rows = control.menuRows()
        for (var i = 0; i < rows.length; ++i)
            rows[i].highlighted = (i === control.currentIndex)
    }

    function setCurrentIndex(index) {
        control.currentIndex = index
        control.applyHighlight()
        control.ensureCurrentVisible()
    }

    // Keep the keyboard selection inside the visible part of a menu that
    // scrolls.
    function ensureCurrentVisible() {
        if (!control.scrollable)
            return

        var row = control.currentRow()
        if (!row)
            return

        var top = row.mapToItem(_mainLayout, 0, 0).y
        var bottom = top + row.height

        if (top < _flickable.contentY)
            _flickable.contentY = top
        else if (bottom > _flickable.contentY + _flickable.height)
            _flickable.contentY = bottom - _flickable.height
    }

    // Put the current row in the middle of a list that scrolls. A drop-down
    // opens on the chosen row, and one sitting against the top or bottom edge
    // reads as the end of the list.
    function centerCurrentRow() {
        if (!control.scrollable)
            return

        var row = control.currentRow()
        if (!row)
            return

        var top = row.mapToItem(_mainLayout, 0, 0).y
        control.scrollTo(top + row.height / 2 - _flickable.height / 2)
    }

    function scrollTo(y) {
        _flickable.contentY = Math.max(0, Math.min(_flickable.contentHeight - _flickable.height, y))
    }

    // Walk to the next selectable row, wrapping around at both ends.
    function moveCurrentIndex(step) {
        var rows = control.menuRows()
        if (rows.length === 0)
            return

        var index = control.currentIndex
        for (var i = 0; i < rows.length; ++i) {
            index = (index + step + rows.length * 2) % rows.length
            if (rows[index].enabled) {
                control.setCurrentIndex(index)
                return
            }
        }
    }
}
