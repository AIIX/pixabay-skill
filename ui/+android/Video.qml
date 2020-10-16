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
    
    property string message: sessionData.setMessage
    
    onMessageChanged: {
        messageBox.visible = true
        messageBox.enabled = true
        messageLabel.text = message
        delay(2000, function() {
            messageBox.visible = false
            messageBox.enabled = false
        }); 
    }
    
    Timer {
        id: hideTimer
        interval: 5000
        onTriggered: { 
            ctrlBar.visible = false;
            video.forceActiveFocus();
        }
    }
    
    Timer {
        id: timer
    }

    function delay(delayTime, cb) {
        timer.interval = delayTime;
        timer.repeat = false;
        timer.triggered.connect(cb);
        timer.start();
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
            
            //RoundButton {
                //id: setashomebtn
                //anchors.top: playpausebtn.bottom
                //anchors.topMargin: Kirigami.Units.largeSpacing
                //anchors.horizontalCenter: parent.horizontalCenter
                //width: parent.width - Kirigami.Units.gridUnit
                //height: Kirigami.Units.iconSizes.large * 2
                
                //onClicked: {
                     //triggerGuiEvent("pixabay.idle.set_idle", {"idleType": "Video", "idleVideoURL": sessionData.videoURL})
                //}
                
                //imageSource: "images/sethome.png"
                //textSource: "Set Homescreen"
            //}
            
            RoundButton {
                id: showhomebtn
                anchors.top: playpausebtn.bottom
                anchors.topMargin: Kirigami.Units.largeSpacing
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - Kirigami.Units.gridUnit
                height: Kirigami.Units.iconSizes.large * 2
                
                onClicked: {
                    Mycroft.MycroftController.sendText("show homescreen", {})
                }
                
                imageSource: "images/home.png"
                textSource: "Show Homescreen"
            }
        }
        
        Rectangle {
            id: messageBox
            visible: false
            enabled: false
            color: Qt.rgba(0,0,0,0.8)
            radius: 10
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.leftMargin: Kirigami.Units.gridUnit
            anchors.rightMargin: Kirigami.Units.gridUnit
            anchors.bottomMargin: Kirigami.Units.gridUnit * 2
            height: messageLabel.height
            
            Controls.Label {
                id: messageLabel
                color: "white"
                anchors.centerIn: parent
            }
        }
    }
}
 
