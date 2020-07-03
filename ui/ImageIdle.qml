import QtQuick.Layouts 1.4
import QtQuick 2.9
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
        
        Controls.Label {
            id: time
            anchors.centerIn: parent
            font.capitalization: Font.AllUppercase
            font.family: "Noto Sans Display"
            font.weight: Font.Bold
            font.pixelSize: 140
            enabled: idleLoaderView.showTime
            visible: idleLoaderView.showTime
            color: "white"
            lineHeight: 0.6
            text: idleLoaderView.time_string.replace(":", "꞉")
        }
    }
}
 
 
 
