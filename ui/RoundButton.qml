import QtQuick.Layouts 1.4
import QtQuick 2.9
import QtQuick.Controls 2.12 as Controls
import QtGraphicalEffects 1.0
import org.kde.kirigami 2.10 as Kirigami
        
Controls.RoundButton {
    id: button
    highlighted: focus ? 1 : 0
    z: 1000
    property alias imageSource: btnImage.source
    property alias textSource: btnText.text
    property bool buttonEnabled: true
    property var imageWidth: parent.width > 600 ? Kirigami.Units.iconSizes.medium : Kirigami.Units.iconSizes.small
    opacity: buttonEnabled ? 1 : 0.35 
    
    background: Rectangle {
        radius: 200
        color: Qt.rgba(0, 0, 0, 0.75)
        border.width: 1
        border.color: "white"
        layer.enabled: true
        layer.effect: DropShadow {
            transparentBorder: true
            horizontalOffset: 2
            verticalOffset: 1
        }
    }
    
    contentItem: Item {
        RowLayout {
            anchors.fill: parent
            Image {
                id: btnImage
                Layout.preferredWidth: imageWidth
                Layout.preferredHeight: width
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            }
            Kirigami.Heading {
                id: btnText
                level: 3
                color: Kirigami.Theme.linkColor
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            }
        }
    }
}
    
