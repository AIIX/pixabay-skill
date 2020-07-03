import QtQuick.Layouts 1.4
import QtQuick 2.9
import QtQuick.Controls 2.12 as Controls
import org.kde.kirigami 2.10 as Kirigami
import Mycroft 1.0 as Mycroft

Mycroft.Delegate {
    id: rootImage
    background: Rectangle {
        color: "black"
    }
    leftPadding: 0
    topPadding: 0
    rightPadding: 0
    bottomPadding: 0
    fillWidth: true
    
    Timer {
        id: hideTimer
        interval: 5000
        onTriggered: { 
            ctrlBar.visible = false;
        }
    }
    
    Image {
        id: image
        anchors.fill: parent
        focus: true
        fillMode: Image.Stretch
        source: Qt.resolvedUrl(sessionData.imageURL)
        
        MouseArea {
            anchors.fill: parent
            onClicked: {
                ctrlBar.visible = true
                hideTimer.restart();
            }
        }
        
        Item {
            id: ctrlBar
            visible: false
            enabled: visible
            anchors.centerIn: parent
            width: parent.width / 2
            height: parent.height / 2
            
            RoundButton {
                id: setashomebtn
                anchors.top: parent.top
                anchors.topMargin: Kirigami.Units.largeSpacing
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - Kirigami.Units.gridUnit
                height: Kirigami.Units.iconSizes.large * 2
                
                onClicked: {
                    triggerGuiEvent("pixabay.idle.set_idle", {"idleType": "Image", "idleImageURL": sessionData.imageURL})
                }
                
                imageSource: "images/sethome.png"
                textSource: "Set Homescreen"
            }
            
            RoundButton {
                id: showhomebtn
                anchors.top: setashomebtn.bottom
                anchors.topMargin: Kirigami.Units.largeSpacing
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - Kirigami.Units.gridUnit
                height: Kirigami.Units.iconSizes.large * 2
                
                onClicked: {
                    Mycroft.MycroftController.sendRequest("mycroft.mark2.reset_idle", {})
                }
                
                imageSource: "images/home.png"
                textSource: "Show Homescreen"
            }
        }
    }
}
 
 
