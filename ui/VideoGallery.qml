import QtQuick.Layouts 1.4
import QtQuick 2.9
import QtQuick.Controls 2.12 as Controls
import org.kde.kirigami 2.10 as Kirigami
import Mycroft 1.0 as Mycroft

Item {
    id: rootVideoGallery
    
    Image {
       anchors.fill: parent
       source: "https://source.unsplash.com/random"
       
       Item {
           id: headerArea
           width: parent.width
           height: Kirigami.Units.iconSizes.large
           
           Image {
                id: pixBlogo
                source: "images/pxlogo.png"
                width: Kirigami.Units.iconSizes.medium
                height: width
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.topMargin: Kirigami.Units.smallSpacing
                anchors.leftMargin: Kirigami.Units.smallSpacing
           }
           
           Item {
               anchors.horizontalCenter: parent.horizontalCenter
               width: Kirigami.Units.iconSizes.large * 2 + Kirigami.Units.largeSpacing
               height: Kirigami.Units.iconSizes.large
               
               RoundButton {
                    id: prevPageButton
                    anchors.left: parent.left
                    height: Kirigami.Units.iconSizes.large
                    width: Kirigami.Units.iconSizes.large
                    imageWidth: Kirigami.Units.iconSizes.small
                    buttonEnabled: pixaLoaderView.currentPageNumber == 1 ? 0 : 1
                    onClicked: {
                        triggerGuiEvent("pixabay.gallery.previous", {"galleryType": "Video", "currentPageNumber": pixaLoaderView.currentPageNumber})
                    }
                    imageSource: "images/previous.png"
                    textSource: ""
               }
               
               RoundButton {
                    id: nextPageButton
                    anchors.right: parent.right
                    height: Kirigami.Units.iconSizes.large
                    width: Kirigami.Units.iconSizes.large
                    imageWidth: Kirigami.Units.iconSizes.small
                    buttonEnabled: pixaLoaderView.showMoreAvailable
                    onClicked: {
                        triggerGuiEvent("pixabay.gallery.next", {"galleryType": "Video", "currentPageNumber": pixaLoaderView.currentPageNumber})
                    }                    
                    imageSource: "images/next.png"
                    textSource: ""
               }
           }
           
           RoundButton {
                id: backBtn
                anchors.right: parent.right
                height: Kirigami.Units.iconSizes.large
                width: Kirigami.Units.iconSizes.large
                imageWidth: Kirigami.Units.iconSizes.small
                onClicked: {
                    Mycroft.MycroftController.sendRequest("mycroft.mark2.reset_idle", {})
                }
                imageSource: "images/back.png"
                textSource: ""
           }
       }
       
        GridView {
            id: videoGalleryView
            anchors.top: headerArea.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.leftMargin: Kirigami.Units.gridUnit
            anchors.rightMargin: Kirigami.Units.gridUnit
            anchors.bottomMargin: Kirigami.Units.gridUnit
            focus: true
            clip: true
            model: pixaLoaderView.videoGalleryModel
            cellWidth: width > 600 ? width / 2 : width
            cellHeight: height / 3
            delegate: VideoGalleryDelegate{}
        }
    }
} 
