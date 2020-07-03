import QtMultimedia 5.12
import QtQuick.Layouts 1.4
import QtQuick 2.9
import QtQuick.Controls 2.12 as Controls
import org.kde.kirigami 2.10 as Kirigami
import Mycroft 1.0 as Mycroft

Mycroft.Delegate {
    id: rootVideo
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
            video.forceActiveFocus();
        }
    }

    Video {
        id: video
        anchors.fill: parent
        focus: true
        autoLoad: true
        autoPlay: true
        loops: MediaPlayer.Infinite
        fillMode: VideoOutput.Stretch
        source: Qt.resolvedUrl(sessionData.videoURL)
        
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
                id: playpausebtn
                anchors.top: parent.top
                anchors.topMargin: Kirigami.Units.largeSpacing
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - Kirigami.Units.gridUnit
                height: Kirigami.Units.iconSizes.large * 2
                
                onClicked: {
                    video.playbackState === MediaPlayer.PlayingState ? video.pause() : video.play();
                }
                
                imageSource: video.playbackState === MediaPlayer.PlayingState ? "images/media-playback-pause.svg" : "images/media-playback-start.svg"
                textSource: "Play / Pause"
            }
            
            RoundButton {
                id: setashomebtn
                anchors.top: playpausebtn.bottom
                anchors.topMargin: Kirigami.Units.largeSpacing
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - Kirigami.Units.gridUnit
                height: Kirigami.Units.iconSizes.large * 2
                
                onClicked: {
                     triggerGuiEvent("pixabay.idle.set_idle", {"idleType": "Video", "idleVideoURL": sessionData.videoURL})
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
 
