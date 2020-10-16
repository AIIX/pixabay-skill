import QtQuick.Layouts 1.4
import QtQuick 2.9
import QtQuick.Controls 2.12 as Controls
import org.kde.kirigami 2.10 as Kirigami
import QtGraphicalEffects 1.0
import Mycroft 1.0 as Mycroft

Controls.ItemDelegate {
    id: delegate
    
    readonly property GridView gridView: GridView.view
    implicitWidth: gridView.width > 600 ? gridView.cellWidth - Kirigami.Units.gridUnit : gridView.cellWidth
    implicitHeight: gridView.cellHeight - Kirigami.Units.gridUnit

    function secondsToHms(d) {
        d = Number(d);
        var h = Math.floor(d / 3600);
        var m = Math.floor(d % 3600 / 60);
        var s = Math.floor(d % 3600 % 60);

        var hDisplay = h > 0 ? h + (h == 1 ? " hour, " : " hours, ") : "";
        var mDisplay = m > 0 ? m + (m == 1 ? " minute, " : " minutes, ") : "";
        var sDisplay = s > 0 ? s + (s == 1 ? " second" : " seconds") : "";
        return hDisplay + mDisplay + sDisplay; 
    }
    
    background: Rectangle {
        id: background
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.9)
        radius: 10
        layer.enabled: true
        layer.effect: DropShadow {
            transparentBorder: true
            horizontalOffset: 2
            verticalOffset: 1
        }
    }
    
    contentItem: Rectangle {
        id: frame
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.9)
        radius: 10
        layer.enabled: true
        layer.effect: OpacityMask {
            cached: true
            maskSource: Rectangle {
                x: frame.x;
                y: frame.y
                width: frame.width
                height: frame.height
                radius: frame.radius
            }
        }
        
        Image {
            id: img
            source: Qt.resolvedUrl("https://i.vimeocdn.com/video/" + model.picture_id + "_640x360.jpg")
            opacity: 1
            fillMode: Image.PreserveAspectCrop
            anchors {
                fill: parent
            }
            
            RowLayout{
                anchors.bottom: parent.bottom
                anchors.bottomMargin: Kirigami.Units.largeSpacing
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: Kirigami.Units.largeSpacing
                anchors.rightMargin: Kirigami.Units.largeSpacing
                height: parent.height * 0.15
                
                Rectangle {
                    radius: 200
                    color: Qt.rgba(0, 0, 0, 0.5)
                    Layout.alignment: Qt.AlignLeft
                    Layout.preferredHeight: parent.height
                    Layout.preferredWidth: userImage.width + userName.contentWidth + Kirigami.Units.largeSpacing * 5
                    layer.enabled: true
                    layer.effect: DropShadow {
                        transparentBorder: true
                        horizontalOffset: 2
                        verticalOffset: 1
                    }
                    
                    Image {
                        id: userImage
                        anchors.left: parent.left
                        anchors.leftMargin: Kirigami.Units.largeSpacing * 2
                        anchors.top: parent.top
                        anchors.topMargin: Kirigami.Units.smallSpacing
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: Kirigami.Units.smallSpacing
                        width: height
                        source: model.userImageURL
                    }
                    
                    Controls.Label {
                        id: userName
                        anchors.left: userImage.right
                        anchors.leftMargin: Kirigami.Units.largeSpacing
                        color: "White"
                        text: model.user
                        anchors.verticalCenter: parent.verticalCenter
                    }                    
                }
                
                Rectangle {
                    radius: 200
                    color: Qt.rgba(0, 0, 0, 0.5)
                    Layout.alignment: Qt.AlignRight
                    Layout.preferredHeight: parent.height
                    Layout.preferredWidth: duration.contentWidth + Kirigami.Units.gridUnit
                    layer.enabled: true
                    layer.effect: DropShadow {
                        transparentBorder: true
                        horizontalOffset: 2
                        verticalOffset: 1
                    }
                                        
                    Controls.Label {
                        id: duration
                        anchors.centerIn: parent
                        color: "White"
                        text: secondsToHms(model.duration)
                    }                    
                }
            }
        }
    }
    
    onClicked: {
        triggerGuiEvent("pixabay.show.video", {'videourl': model.videos.medium.url})
    }
}
 
