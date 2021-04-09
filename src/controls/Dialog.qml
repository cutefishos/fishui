import QtQuick 2.12
import QtQuick.Controls 2.12 as QQC2
import QtQuick.Layout 1.12
import FishUI 1.0 as FishUI

QQC2.Popup {
    id: control

    property string title
    property string text
    property string leftButtonText
    property string rightButtonText

    property QtObject sourceItem: null

    signal rightButtonClicked()
    signal leftButtonClicked()

    anchors.centerIn: applicationWindow().overlay
    parent: applicationWindow().overlay

    modal: true
    closePolicy: QQC2.Popup.NoAutoClose

    height: 22 * 14
    width: 22 * 25

    contentItem: Item {
        ColumnLayout {
            anchors.fill: parent

            Text {
                text: control.title
            }

            Text {
                text: control.text
            }

            RowLayout {
                Button {
                    text: control.leftButtonText
                }

                Button {
                    text: control.rightButtonText
                }
            }
        }
    }
}