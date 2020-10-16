/*
 * Copyright 2020 by Aditya Mehra <aix.m@outlook.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

import QtQuick.Layouts 1.4
import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Window 2.2
import org.kde.kirigami 2.8 as Kirigami
import Mycroft 1.0 as Mycroft

Mycroft.Delegate {
    id: idleLoaderView
    background: Rectangle {
        color: "black"
    }
    leftPadding: 0
    topPadding: 0
    rightPadding: 0
    bottomPadding: 0
    fillWidth: true
    
    property var idleType: sessionData.idleType
    property var idleGenericURL: sessionData.idleGenericURL
    property bool showTime: sessionData.showTime
    property string time_string: sessionData.time_string
    
    function setSource(source) {
        rootLoader.setSource(source)
    }
    
    onVisibleChanged: {
        if(!visible){
            console.log("Idle Loader Hidden")
        }
    }
    
    Loader {
        anchors.fill: parent
        id: rootLoader
    }

    onIdleTypeChanged: {
        rootLoader.setSource(sessionData.idleType + ".qml")
    }
} 
