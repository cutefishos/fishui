import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import FishUI 1.0 as FishUI

TextField {
    id: control
    
    property list<QtObject> rightActions
    
    rightPadding: FishUI.Units.smallSpacing + rightActionsRow.width
    Row {
        id: rightActionsRow
        padding: FishUI.Units.smallSpacing
        layoutDirection: Qt.RightToLeft
        anchors.right: parent.right
        anchors.rightMargin: FishUI.Units.smallSpacing
        anchors.verticalCenter: parent.verticalCenter
        height: control.implicitHeight - 2 * FishUI.Units.smallSpacing
        Repeater {
            model: control.rightActions
            Icon {
                implicitWidth: FishUI.Units.iconSizes.small
                implicitHeight: FishUI.Units.iconSizes.small
   
                anchors.verticalCenter: parent.verticalCenter
   
                source: modelData.icon.name.length > 0 ? modelData.icon.name : modelData.icon.source
                visible: modelData.visible
                enabled: modelData.enabled
                MouseArea {
                    id: actionArea
                    anchors.fill: parent
                    onClicked: modelData.trigger()
                    cursorShape: Qt.PointingHandCursor
                }
            }
        }
    }
    
}
