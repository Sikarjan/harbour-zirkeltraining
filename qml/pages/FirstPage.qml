/*
  Copyright (C) 2013 Jolla Ltd.
  Contact: Thomas Perl <thomas.perl@jollamobile.com>
  All rights reserved.

  You may use this file under the terms of BSD license as follows:

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Jolla Ltd nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0
import "../js/storage.js" as Storage

Page {
    id: page

    function checkTime(){
        if(trainingStyle.currentIndex === 3){
            var testValue = trainingSlider.value

            if(cycleSlider.value > testValue/adjustmentSlider.value)
                cycleSlider.value = Math.round(testValue/adjustmentSlider.value-1)

            cycleSlider.maximumValue = Math.round(testValue/adjustmentSlider.value-1)
        }
    }

    // Restore Settings
    Component.onCompleted: {
        Storage.initialize()
        if(Storage.getSetting("sleepMode") === "1"){
            clock.displayOn = true
        }

        if(Storage.getSetting("randomizer") === "1")
            player.random = true
        if(Storage.getSetting("newTracks") === "1")
            player.newTrack = true

        if(Storage.getSetting("playlist") !== ""){
            player.playlist = Storage.getSetting("playlist")
            if(!player.setSource(player.playlist)){
                player.playlistError = true
                player.isActive = false
            }else{
                player.playlistError = false
                player.isActive = true
            }
        }else{
            player.isActive = false
            player.playlist = ""
        }
    }
    // Load Profile
    onStatusChanged: if (status === PageStatus.Active) {
                         if(profile.profileID !== -1 && !profile.profileChanged) {
                             console.log("Loading Profile: "+profile.profileID)
                             Storage.loadProfile(profile.profileID)
                             profile.profileChanged = false
                         }else if(!profile.profileChanged){
                             profile.profileTitel = qsTr("Make your settings:")
                         }
                     }

    SilicaFlickable {
        anchors.fill: parent

        // Menues
        PullDownMenu {
            MenuItem {
                text: qsTr("About")
                onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
            }
            MenuItem {
                text: qsTr("Settings")
                onClicked: pageStack.push(Qt.resolvedUrl("Settings.qml"))
            }
        }

        PushUpMenu {
            MenuItem {
                text:  qsTr("Save as new profile")
                onClicked: {
                    Storage.writeProfile('save');
                    pageStack.push(Qt.resolvedUrl("Save.qml"))
                }
            }
            MenuItem {
                text: qsTr("Save changed profile")
                visible: profile.profileID !== -1 && profile.profileChanged
                onClicked: {
                    Storage.writeProfile('save')
                    Storage.updateProfile(profile.profileID)
                    profile.profileChanged = false
                    profile.profileTitel = profile.profileTitel.substring(0,profile.profileTitel.length-1)
                }
            }
            MenuItem {
                text: qsTr("Load profile")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("Load.qml"))
                }
            }
        }

        // Tell SilicaFlickable the height of its content.
        contentHeight: column.height

        Column {
            id: column

            width: page.width
            spacing: trainingStyle.currentIndex === 0? Theme.paddingMedium:0

            PageHeader {
                title: qsTr("Zirkeltraining")
            }

            Text {
                id: introText
                x: Theme.paddingLarge
                y: 60
                text: profile.profileTitel
                color: Theme.secondaryHighlightColor
                font.pixelSize: Theme.fontSizeLarge
                wrapMode: Text.Wrap
                width: parent.width - Theme.paddingLarge
            }

            ComboBox {
                id: trainingStyle
                width: parent.width
                label: qsTr("Training mode:")

                menu: ContextMenu {
                    MenuItem { text: qsTr("Static")}
                    MenuItem { text: qsTr("Pyramid")}
                    MenuItem { text: qsTr("Raising")}
                    MenuItem { text: qsTr("Falling")}
                    MenuItem { text: qsTr("Zick zack")}
                }
                onMenuChanged: profile.profileChanged = true
            }

            Slider {
                id: trainingSlider
                width: parent.width
                label: qsTr("Training Cycle Time")
                value: 30
                minimumValue: 10
                maximumValue: 600
                stepSize: 5
                valueText: value + " s"
                onValueChanged: {
                    profile.profileChanged = true
                    checkTime()
                }
            }

            Slider {
                id: recoverSlider
                width: parent.width
                label: qsTr("Recover Cycle Time")
                value: 10
                minimumValue: 0
                maximumValue: 600
                stepSize: 5
                valueText: value + " s"
                onValueChanged: profile.profileChanged = true
            }
            Slider {
                id: cycleSlider
                width: parent.width
                label: qsTr("Cycles")
                value: 10
                minimumValue: 1
                maximumValue: trainingStyle.currentIndex ===3? checkTime():100
                stepSize: 1
                valueText: value
                onValueChanged: profile.profileChanged = true
            }

            Slider {
                id: adjustmentSlider
                visible: trainingStyle.currentIndex !== 0
                width: parent.width
                label: trainingStyle.currentIndex ===3? qsTr("Decrease Training Time"):qsTr("Increase Training Time")
                value: 10
                minimumValue: 5
                maximumValue: trainingStyle.currentIndex ===3? trainingSlider.value:600
                stepSize: 5
                valueText: value
                onValueChanged: {
                    profile.profileChanged = true
                    checkTime()
                }
            }

            Slider {
                id: adjustmentSliderPause
                visible: trainingStyle.currentIndex !== 0
                width: parent.width
                label: trainingStyle.currentIndex ===3? qsTr("Decrease Pause Time"):qsTr("Increase Pause Time")
                value: 10
                minimumValue: 5
                maximumValue: trainingStyle.currentIndex ===3? recoverSlider.value:600
                stepSize: 5
                valueText: value
                onValueChanged: {
                    profile.profileChanged = true
                    checkTime()
                }
            }

            Button {
                id: playlistButton
                anchors.horizontalCenter: parent.horizontalCenter
                text:{
                    if(player.playlistError){
                        qsTr("Could not be loaded")
                    }else{
                        (player.playlist === "" ? qsTr("No playlist selected"):qsTr("Playlist")+": "+player.playlist)
                    }
                }
                onClicked: pageStack.push(Qt.resolvedUrl("Playlist.qml"))
            }


            Button {
                id: start
                visible: cycleSlider.value > 0
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Start")
                onClicked: {
                    Storage.writeProfile('start')
                    pageStack.push(Qt.resolvedUrl("CountdownPage.qml"))
                }
            }
        }
    }
}


