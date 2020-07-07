import QtQuick.Layouts 1.4
import QtQuick 2.9
import QtGraphicalEffects 1.0
import QtQuick.Controls 2.12 as Controls
import org.kde.kirigami 2.10 as Kirigami
import Mycroft 1.0 as Mycroft

Item {
    id: rootImage
    anchors.fill: parent
    
    Timer {
        id: dTimeTimer
        running: idleLoaderView.showTime && rootImage.visible ? 1 : 0
        repeat: idleLoaderView.showTime && idleLoaderView.visible ? 1 : 0
        interval: 10000
        onTriggered: {
            console.log("dTimeTimer Triggered, should get updated Time")
            triggerGuiEvent("pixabay.idle.updateTime", {})
        }
    }
    
    Image {
        id: image
        anchors.fill: parent
        focus: true
        fillMode: Image.PreserveAspectCrop
        source: Qt.resolvedUrl(idleLoaderView.idleGenericURL)
        
        Rectangle {
            anchors.top: parent.top
            anchors.topMargin: Kirigami.Units.gridUnit * 3
            anchors.left: parent.left
            anchors.leftMargin: -Kirigami.Units.gridUnit
            radius: 30
            width: time.contentWidth + (Kirigami.Units.gridUnit * 2)
            enabled: idleLoaderView.showTime
            visible: idleLoaderView.showTime
            height: time.contentHeight
            color: Qt.rgba(0, 0, 0, 0.5)
            layer.enabled: true
            layer.effect: DropShadow {
                transparentBorder: true
                horizontalOffset: 2
                verticalOffset: 1
            }
            
            Controls.Label {
                id: time
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.horizontalCenterOffset: Kirigami.Units.gridUnit * 0.25
                font.capitalization: Font.AllUppercase
                font.family: "Noto Sans Display"
                font.weight: Font.Bold
                font.pixelSize: 75
                enabled: idleLoaderView.showTime
                visible: idleLoaderView.showTime
                color: "white"
                text: idleLoaderView.time_string.replace(":", "꞉")
            }
        }
    }
}
 
 
 
