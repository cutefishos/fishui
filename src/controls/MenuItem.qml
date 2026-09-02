import QtQuick
import QtQuick.Templates as T
import QtQuick.Controls
import QtQuick.Controls.impl
import QtQuick.Layouts 1.12
import QtQuick.Window

import FishUI 1.0 as FishUI

T.MenuItem {
    id: control

    // DesktopMenu uses a separate popup window for submenus. Regular Menu
    // instances continue to use the Qt Quick Controls subMenu property.
    property var childMenu: null
    // Whether the item opens a submenu. A menu that creates its submenu
    // popups lazily overrides this so the arrow is drawn before the popup
    // exists.
    property bool hasChildMenu: !!control.subMenu || !!control.childMenu
    readonly property bool hasIcon: control.icon.name.length > 0 || control.icon.source.toString().length > 0
    readonly property bool submenuOpen: !!control.childMenu && control.childMenu.visible
    readonly property bool active: control.enabled && (control.hovered || control.highlighted ||
                                                       control.pressed || control.submenuOpen)
    property color hoveredColor: Qt.rgba(FishUI.Theme.highlightColor.r,
                                         FishUI.Theme.highlightColor.g,
                                         FishUI.Theme.highlightColor.b,
                                         FishUI.Theme.darkMode ? 0.82 : 0.9)
    property color pressedColor: Qt.rgba(FishUI.Theme.highlightColor.r,
                                         FishUI.Theme.highlightColor.g,
                                         FishUI.Theme.highlightColor.b,
                                         FishUI.Theme.darkMode ? 0.95 : 0.78)

    implicitWidth: Math.max(146, implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: visible ? 30 : 0
    height: implicitHeight

    // ColumnLayout otherwise keeps each row at its own preferred width. All
    // rows must share the menu width so their hover backgrounds line up.
    Layout.fillWidth: true

    verticalPadding: FishUI.Units.smallSpacing
    hoverEnabled: true
    topPadding: FishUI.Units.smallSpacing
    bottomPadding: FishUI.Units.smallSpacing
    leftPadding: FishUI.Units.smallSpacing + 2
    rightPadding: FishUI.Units.smallSpacing + 2
    spacing: FishUI.Units.smallSpacing

    icon.width: control.hasIcon ? FishUI.Units.iconSizes.smallMedium : 0
    icon.height: control.hasIcon ? FishUI.Units.iconSizes.smallMedium : 0

    // Only a single-colour glyph is recoloured to match the row. A full colour
    // icon keeps its own colours - tinting one paints it over as a solid block
    // of text colour, which is all a filled icon has left to show.
    readonly property bool monochromeIcon: FishUI.Theme.isMonochromeIcon(control.icon.name)

    icon.color: !control.monochromeIcon ? "transparent"
                                        : control.enabled ? (control.active ? FishUI.Theme.highlightedTextColor
                                                                            : FishUI.Theme.textColor)
                                                          : FishUI.Theme.disabledTextColor

    contentItem: IconLabel {
        readonly property real arrowPadding: control.hasChildMenu && control.arrow ? control.arrow.width + control.spacing : 0
        // Only checked items reserve a checkmark column. Items without icons
        // stay compact instead of inheriting an empty leading icon column.
        readonly property real indicatorPadding: control.checked && control.indicator ? control.indicator.width + control.spacing : 0
        // This is the only intentional change from the previous layout: give
        // labels a small extra inset without moving the submenu arrow.
        leftPadding: !control.mirrored ? indicatorPadding + 4 : arrowPadding
        rightPadding: control.mirrored ? indicatorPadding : arrowPadding

        spacing: control.spacing
        mirrored: control.mirrored
        display: control.display
        alignment: Qt.AlignLeft

        icon: control.icon
        text: control.text
        font: control.font
        color: control.enabled ? control.active ? FishUI.Theme.highlightedTextColor :
               FishUI.Theme.textColor : FishUI.Theme.disabledTextColor
    }

    indicator: Text {
        x: control.mirrored ? control.width - width - control.rightPadding : control.leftPadding
        y: (control.height - height) / 2
        visible: control.checkable && control.checked
        text: "✓"
        font.pixelSize: 15
        color: control.active ? FishUI.Theme.highlightedTextColor : FishUI.Theme.highlightColor
    }

    arrow: Text {
        x: control.mirrored ? control.leftPadding : control.width - width - control.rightPadding
        y: 0
        width: 16
        height: control.height
        visible: control.hasChildMenu
        text: "›"
        font.pixelSize: 21
        font.weight: Font.Light
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        color: control.active ? FishUI.Theme.highlightedTextColor : FishUI.Theme.disabledTextColor
    }

    background: Rectangle {
        implicitWidth: 146
        implicitHeight: 30
        radius: FishUI.Theme.smallRadius
        opacity: 1

        x: Math.max(4, FishUI.Units.smallSpacing - 2)
        y: 1
        width: control.width - Math.max(4, FishUI.Units.smallSpacing - 2) * 2
        height: control.height - 2

        color: control.pressed ? control.pressedColor :
               control.active ? control.hoveredColor : "transparent"
    }

    onHoveredChanged: {
        if (!childMenu)
            return

        if (hovered) {
            childMenu.parentItem = control
            childMenu.popupSubMenu()
        }
    }

    onTriggered: {
        if (control.childMenu)
            return

        if (control.Window.window && control.Window.window.dismissAllPopups)
            control.Window.window.dismissAllPopups()
    }
}
