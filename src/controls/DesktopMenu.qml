/*
 * Copyright (C) 2021 CutefishOS Team.
 *
 * Author:     revenmartin <revenmartin@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
 
import QtQuick 2.15
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import FishUI 1.0 as FishUI

FishUI.MenuPopupWindow {
    id: control

    property bool blurEnabled: FishUI.Theme.blurEnabled

    default property alias content : _mainLayout.data

    popupContentItem: _contentItem

    // Lets the popup align its first row with the item that opened it.
    contentTopMargin: _contentItem.verticalContentMargin

    Item {
        id: _contentItem

        readonly property int contentMargin: Math.max(4, FishUI.Units.smallSpacing - 2)
        readonly property int verticalContentMargin: Math.round(contentMargin * 1.5)
        // A menu with more rows than the screen is tall scrolls instead of
        // running off the edge.
        readonly property int maxHeight: control.availableHeight > 0 ? control.availableHeight : 0
        implicitWidth: _mainLayout.implicitWidth + contentMargin * 2
        implicitHeight: maxHeight > 0 ? Math.min(_mainLayout.implicitHeight + verticalContentMargin * 2, maxHeight)
                                      : _mainLayout.implicitHeight + verticalContentMargin * 2
        width: implicitWidth
        height: implicitHeight

        Rectangle {
            id: _background
            anchors.fill: parent
            color: Qt.rgba(FishUI.Theme.secondBackgroundColor.r,
                           FishUI.Theme.secondBackgroundColor.g,
                           FishUI.Theme.secondBackgroundColor.b,
                           control.blurEnabled && !control.submenu ? 0.86 : 1)
            radius: FishUI.Theme.windowRadius
            border.color: _background.borderColor
            border.width: 1 / FishUI.Units.devicePixelRatio
            border.pixelAligned: FishUI.Units.devicePixelRatio > 1 ? false : true

            property var borderColor: FishUI.Theme.darkMode ? Qt.rgba(255, 255, 255, 0.3)
                                                            : Qt.rgba(0, 0, 0, 0.2)

            FishUI.WindowShadow {
                view: control
                radius: _background.radius
                strength: 0.4
                enabled: true
            }

            FishUI.WindowBlur {
                view: control
                windowRadius: _background.radius
                enabled: control.blurEnabled && !control.submenu
            }
        }

        Flickable {
            id: _flickable

            x: _contentItem.contentMargin
            y: _contentItem.verticalContentMargin
            width: _mainLayout.implicitWidth
            height: _contentItem.height - _contentItem.verticalContentMargin * 2
            contentWidth: width
            contentHeight: _mainLayout.implicitHeight
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            // A menu scrolls by the wheel alone. Flicking would give it
            // momentum, and rows still sliding under the pointer swallow the
            // click that was meant for one of them.
            interactive: false

            readonly property bool scrollable: contentHeight > height

            ColumnLayout {
                id: _mainLayout
                width: _flickable.width
                height: implicitHeight
                spacing: 1
            }
        }

        // The wheel scrolls a menu that does not fit, one step at a time.
        WheelHandler {
            enabled: _flickable.scrollable

            onWheel: function (event) {
                var step = event.angleDelta.y / 120 * 60
                if (step === 0)
                    step = event.pixelDelta.y

                _flickable.contentY = Math.max(0, Math.min(_flickable.contentHeight - _flickable.height,
                                                           _flickable.contentY - step))
            }
        }

        // Scroll indicator for the rare menu that does not fit on screen.
        Rectangle {
            width: 3
            radius: width / 2
            x: _contentItem.width - _contentItem.contentMargin - width
            y: _flickable.y + _flickable.height * (_flickable.contentY / _flickable.contentHeight)
            height: Math.max(24, _flickable.height * (_flickable.height / _flickable.contentHeight))
            visible: _flickable.scrollable
            color: FishUI.Theme.darkMode ? Qt.rgba(255, 255, 255, 0.35)
                                         : Qt.rgba(0, 0, 0, 0.25)
        }
    }

    // ------------------------------------------------------------------
    // Keyboard navigation
    //
    // Only the root popup takes the keyboard grab, so every key event of an
    // open menu chain is delivered to it. It forwards the event to the
    // deepest open submenu - the one the user is actually looking at -
    // instead of relying on window focus, which no compositor hands to a
    // submenu popup that was opened from hover.
    // ------------------------------------------------------------------

    // Row that the keyboard highlights, as an index into menuRows().
    property int currentIndex: -1

    // The menu is being driven from the keyboard: the pointer is somewhere
    // else entirely, so the hover-based submenu dismissal has to stand down
    // until the pointer moves again.
    property bool keyboardNavigation: false

    // Left in a root menu and Right on a row without a submenu are not ours
    // to handle: a menu bar uses them to walk to the neighbouring menu.
    signal keyNavigationLeft()
    signal keyNavigationRight()

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

    function currentRow() {
        var rows = control.menuRows()
        return control.currentIndex >= 0 && control.currentIndex < rows.length
                ? rows[control.currentIndex] : null
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
        if (!_flickable.scrollable)
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

    // The deepest open popup of this chain; it is the one keys apply to.
    function leafMenu() {
        var rows = control.menuRows()
        for (var i = 0; i < rows.length; ++i) {
            var child = rows[i].childMenu
            if (child && child.visible)
                return child.leafMenu()
        }
        return control
    }

    function closeSubmenus() {
        var rows = control.menuRows()
        for (var i = 0; i < rows.length; ++i) {
            var child = rows[i].childMenu
            if (child && child.visible) {
                child.closeSubmenus()
                child.dismissPopup()
            }
        }
    }

    // Hand the menu back to the pointer: drop the keyboard highlight of the
    // whole chain so that the hovered row is the only highlighted one.
    function clearKeyboardState() {
        control.keyboardNavigation = false
        var rows = control.menuRows()
        for (var i = 0; i < rows.length; ++i) {
            var child = rows[i].childMenu
            if (child && child.visible)
                child.clearKeyboardState()
        }
        control.setCurrentIndex(-1)
    }

    function openCurrentSubmenu() {
        var row = control.currentRow()
        if (!row || !row.childMenu)
            return false

        control.keyboardNavigation = true
        row.childMenu.keyboardNavigation = true
        row.childMenu.parentItem = row
        row.childMenu.popupSubMenu()
        row.childMenu.moveCurrentIndex(1)
        return true
    }

    function activateCurrentRow() {
        var row = control.currentRow()
        if (!row || !row.enabled)
            return

        if (row.childMenu) {
            control.openCurrentSubmenu()
            return
        }

        row.triggered()
    }

    // Key events are reported by the popup window itself. Whichever popup of
    // the chain the compositor happens to give them to, they are handled by
    // the one that is open deepest - the menu the user is looking at.
    onKeyPressed: function (key, modifiers) {
        var menu = control.leafMenu()
        if (menu !== control) {
            menu.handleKey(key)
            return
        }

        control.handleKey(key)
    }

    function handleKey(key) {
        switch (key) {
        case Qt.Key_Down:
            control.keyboardNavigation = true
            control.moveCurrentIndex(1)
            break
        case Qt.Key_Up:
            control.keyboardNavigation = true
            control.moveCurrentIndex(-1)
            break
        case Qt.Key_Right:
            if (control.openCurrentSubmenu())
                break
            if (control.submenu)
                break
            control.keyNavigationRight()
            break
        case Qt.Key_Left:
            if (control.submenu) {
                control.dismissPopup()
                break
            }
            control.keyNavigationLeft()
            break
        case Qt.Key_Return:
        case Qt.Key_Enter:
        case Qt.Key_Space:
            control.activateCurrentRow()
            break
        case Qt.Key_Home:
            control.keyboardNavigation = true
            control.setCurrentIndex(-1)
            control.moveCurrentIndex(1)
            break
        case Qt.Key_End:
            control.keyboardNavigation = true
            control.setCurrentIndex(-1)
            control.moveCurrentIndex(-1)
            break
        case Qt.Key_Escape:
            if (control.submenu)
                control.dismissPopup()
            else
                control.dismissAllPopups()
            break
        }
    }

    // Real pointer movement over the menu wins over the keyboard highlight.
    // Movement elsewhere is ignored: while a menu is open it owns the pointer
    // grab and sees every motion on the screen, including the jitter of a
    // pointer that is nowhere near the menu.
    onMouseMoved: {
        if (control.popupChainContainsGlobalCursor())
            control.clearKeyboardState()
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

    function open() {
        control.ensureLayout()
        control.show()
    }

    function popup() {
        control.ensureLayout()
        control.show()
    }

    function popupAt(x, y) {
        control.ensureLayout()
        control.showAt(x, y)
    }

    function popupSubMenu() {
        control.ensureLayout()
        control.show()
    }

    // A submenu closes immediately after the pointer has actually entered
    // and then left it. The timer only covers the short handoff gap between
    // the parent popup and this popup.
    property bool pointerEntered: false

    onPointerInsideChanged: {
        if (!control.submenu || control.keyboardNavigation)
            return

        if (control.pointerInside) {
            pointerEntered = true
        } else if (pointerEntered) {
            pointerEntered = false
            if (!control.containsGlobalCursor() &&
                    !control.parentItemContainsGlobalCursor() &&
                    !control.parentPopupContainsGlobalCursor()) {
                control.dismissPopup()
            }
        }
    }

    onVisibleChanged: {
        if (!visible) {
            _flickable.contentY = 0
            pointerEntered = false
            keyboardNavigation = false
            setCurrentIndex(-1)
        }
    }

    property Timer submenuDismissTimer: Timer {
        interval: 160
        repeat: true
        running: control.visible

        onTriggered: {
            if (!control.parentItem) {
                stop()
                return
            }

            // A submenu opened with the arrow keys has no pointer anywhere
            // near it; only hover-opened submenus close on hover leaving.
            if (control.keyboardNavigation)
                return

            if (!control.pointerInside &&
                    !control.parentItemHovered() &&
                    !control.parentItemContainsGlobalCursor()) {
                control.dismissPopup()
            }
        }
    }
}
