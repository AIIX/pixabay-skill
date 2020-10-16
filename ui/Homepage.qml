import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.4
import org.kde.kirigami 2.12 as Kirigami
import QtGraphicalEffects 1.0
import Mycroft 1.0 as Mycroft

Mycroft.Delegate {
    id: delegatePixabay
    skillBackgroundSource: Qt.resolvedUrl("images/pixa.jpg")
    leftPadding: 0
    rightPadding: 0
    bottomPadding: 0
    topPadding: 0
    focus: true

    Component.onCompleted: {
	delegatePixabay.forceActiveFocus()
    }
    
    ListModel {
        id: sampleModel
        ListElement {example: "Search Pixabay for nature"}
        ListElement {example: "Search Pixabay for space images"}
        ListElement {example: "Search Pixabay for abstract art"}
        ListElement {example: "Set as homescreen wallpaper"}
    }
    
    Rectangle {
        id: headerBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: Kirigami.Units.gridUnit * 2
        color: "#303030"
        layer.enabled: true
        layer.effect: DropShadow {
            transparentBorder: true
            horizontalOffset: 0
            verticalOffset: 2
        }
        
        RowLayout {
            width: parent.width
            height: parent.height
            anchors.verticalCenter: parent.verticalCenter
            
            ToolButton {
                Kirigami.Theme.colorSet: Kirigami.Theme.Button
                Layout.preferredWidth: Kirigami.Units.iconSizes.smallMedium
                Layout.preferredHeight: Kirigami.Units.iconSizes.smallMedium
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
		flat: true
                
                contentItem: Image {
                    anchors.centerIn: parent
		    width: Kirigami.Units.iconSizes.smallMedium
		    height: Kirigami.Units.iconSizes.smallMedium
                    source: "images/back.png"
                }
                
                onClicked: {
                    delegatePixabay.parent.backRequested()
                }
            }
            
            Kirigami.Heading {
            id: headingLabel
                level: 2
                text: "Pixabay"
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }
    
    Rectangle {
        anchors.top: headerBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        color: Qt.rgba(0, 0, 0, 0.7)
        
        ColumnLayout {
            id: root
            anchors.fill: parent
            anchors.margins: Kirigami.Units.largeSpacing
            
            Kirigami.Heading {
                level: 2
                font.bold: true
                text: "What can it do" 
            }
            
            Label {
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
		font.pointSize: Kirigami.Theme.defaultFont.pointSize * 0.9
                text: "Browse Pixabay Gallery Images and Videos, Set Images as Your Homescreen / Wallpaper"
            }
            
            Item {
                Layout.preferredHeight: Kirigami.Units.largeSpacing
            }
            
            Kirigami.Heading {
                level: 2
                font.bold: true
                text: "Examples"
            }
                                    
            ListView {
                id: skillExampleListView
                Layout.fillWidth: true
                Layout.fillHeight: true
                focus: false
                clip: true
                model: sampleModel
                spacing: Kirigami.Units.smallSpacing
                delegate: Kirigami.AbstractListItem {
                    id: rootCard
                    
                    background: Kirigami.ShadowedRectangle {
                        color: rootCard.pressed ? Kirigami.Theme.highlightColor : Kirigami.Theme.backgroundColor
                        radius: Kirigami.Units.smallSpacing
                    }
                    
                    contentItem: Label {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.rightMargin: Kirigami.Units.largeSpacing
                            anchors.leftMargin: Kirigami.Units.largeSpacing
                            wrapMode: Text.WordWrap
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                            color: Kirigami.Theme.textColor
			    font.pointSize: Kirigami.Theme.defaultFont.pointSize * 0.9
                            text: "Hey Mycroft, " + model.example
                    }

                    onClicked: {
                        Mycroft.MycroftController.sendText(model.example)
                    }
                }
            }
        }
    }
}
