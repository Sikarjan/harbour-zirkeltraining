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
import QtQuick.Particles 2.0
import "../components"
import Nemo.KeepAlive 1.2
import "../js/storage.js" as Storage

Page {
    id: root
    allowedOrientations: Orientation.All

    property int totalTrainingTime: 0
    property int elapstTrainingTime: -8

    DisplayBlanking {
        id: blanking
    }

    onStatusChanged: {
        if (status === PageStatus.Deactivating) {
            if (_navigation === PageNavigation.Back) {
                player.stop()
                myTime.running = false
                clock.trainingPhase = false
                soundCountdown.stop()
                clock.iniStart = true
                confetti.running = false
                applause.stop()
                blanking.preventBlanking = false
                KeepAlive.enabled = false

                if(exerciseModel.count > 0){
                    Storage.initialize()
                    Storage.loadExerciseList(profile.profileID)
                }
            }
        }else if(status === PageStatus.Activating){
            blanking.preventBlanking = clock.displayOn
        }
    }

    Component.onCompleted: {
        myTime.running = true
        KeepAlive.enabled = true
        if(player.playlist !== ""){
            player.setSource(player.playlist)
            if(player.random)
                player.shuffle()
        }
        // Calc complete exercise time
        switch (clock.tStyle) {
        case 0: // Static
            root.totalTrainingTime = clock.cycles * (clock.trainingTime + clock.holdTime) - clock.holdTime
            break;
        case 1: // Pyramid
            var maxTraining = clock.trainingTime + (clock.tipCycle -1) * clock.adjustmentTime
            var maxPause = clock.holdTime + (clock.tipCycle -2) * clock.adjustmentTimePause
            root.totalTrainingTime = clock.tipCycle * maxTraining + (maxPause + clock.holdTime)*(clock.tipCycle -1)
            break;
        case 2: // Raising
            var avgPause = ((clock.holdTime+clock.adjustmentTimePause*(clock.cycles-1)) + clock.holdTime)/2
            var avgTraining = ((clock.trainingTime+clock.adjustmentTime*clock.cycles) + clock.trainingTime)/2

            root.totalTrainingTime = (avgPause + avgTraining) * clock.cycles - avgPause
            break;
        case 3: // Falling
            avgPause = ((clock.holdTime - clock.adjustmentTimePause*(clock.cycles-1)) + clock.holdTime)/2
            avgTraining = ((clock.trainingTime - clock.adjustmentTime*clock.cycles) + clock.trainingTime)/2

            root.totalTrainingTime = (avgPause + avgTraining) * clock.cycles - avgPause
            break;
        case 4: // Zig Zag
            avgTraining = (clock.trainingTime + clock.adjustmentTime)/2
            avgPause = (clock.holdTime + clock.adjustmentTimePause)/2

            root.totalTrainingTime = (avgPause + avgTraining) * clock.cycles - avgPause
            break;
        case 5: // Custom
            var custom = Storage.getTotalTime(profile.profileID)
            var factor = clock.cycles/custom[1];
            root.totalTrainingTime = custom[0]*factor;
            break;
        }

        root.totalTrainingTime = root.totalTrainingTime + 2* clock.cycles -1

        // show first ExercisePage
        textRunIn.start();
    }

    NumberAnimation {
        id: animateOpacity
        target: display
        property: "opacity"
        running: clock.time < 6 && Qt.application.state === Qt.ApplicationActive
        from: 0.1
        to: 1.0
        duration: 1000
        loops: Animation.Infinite
        easing.type: Easing.InOutCubic
    }

    NumberAnimation {
        id: textRunOut
        target: currentEx
        property: "x"
        duration: 750
        easing.type: Easing.InOutQuad
        from: 0
        to: parent.width

        running: !clock.trainingPhase
    }
    NumberAnimation {
        id: textRunIn
        target: currentEx
        property: "x"
        duration: 750
        easing.type: Easing.InOutQuad
        from: -parent.width
        to: 0

        running: clock.trainingPhase
    }

    Rectangle {
        id: scene
        anchors.fill: parent
        color: "black"

        Rectangle {
            id:progress
            height: headerText.height + 50
            width: parent.width * (root.elapstTrainingTime/root.totalTrainingTime)
            color: "blue"
            visible: clock.tStyle === 5
            opacity: 0.5
            Behavior on width {
                NumberAnimation { duration: 1000}
            }
        }

        Text {
            id:headerText
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            y: 30
            text: qsTr("Remaining Cycles:") + " " + clock.cycles
            color: "white"
            font.pixelSize: Theme.fontSizeLarge
        }

        Text {
            id: currentEx
            anchors {
                top: headerText.bottom
                topMargin: Theme.paddingMedium
            }
            width: parent.width
            height: parent.height * 0.15
            visible: exerciseModel.count > 0 && clock.cycles !== 0
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            wrapMode: Text.WordWrap
            clip: true
            color: "white"
            font.pixelSize: Theme.fontSizeExtraLarge

            text: clock.exercise
        }

        Text {
            id: display
            visible: clock.cycles !== 0
            anchors.centerIn: parent
            text: (clock.time < 1? 0:clock.time)
            color: (clock.time < 6? "red" : "white")
            opacity: (animateOpacity.running? 0: 1.0)
            font.bold: true
            font.pixelSize: scene.height*0.4

            onTextChanged: {
                root.elapstTrainingTime++

                if(!player.isActive && !soundCountdown.playing && clock.playTick){
                    tick.play()
                }

                if(clock.trainingPhase && !clock.playTick && clock.time < 6){
                    tick.play()
                }
            }
        }

        Text {
            id: finsh
            visible: clock.cycles === 0
            anchors.centerIn: parent
            text: qsTr("You have done it!")
            color: "white"
            font.bold: true
            font.pixelSize: Theme.fontSizeExtraLarge

            // triggers final animation
            onVisibleChanged:  {applauseTime.running = visible
//console.log("Total Time: " +root.elapstTrainingTime)
            }
        }

        Text {
            id: nextEx
            anchors {
                bottom: nav.top
                bottomMargin: Theme.paddingMedium
            }
            width: parent.width
            height: parent.height * 0.15
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            wrapMode: Text.WordWrap
            clip: true
            color: "white"
            font.pixelSize: clock.trainingPhase ? Theme.fontSizeMedium:Theme.fontSizeExtraLarge
            visible: exerciseModel.count > 0 && !clock.iniStart && clock.cycles !== 0

            text: qsTr("Next") + ": " + clock.nextExercise

            Behavior on font.pixelSize {
                NumberAnimation { duration: 500; easing: {type: Easing.InOutBounce; overshoot: 250} }
            }
        }

        Row {
            id: nav
            anchors {
                bottom: parent.bottom
                bottomMargin: 15
                horizontalCenter: parent.horizontalCenter
            }
            spacing: 15

            ActionButton {
                id:skip
                visible: player.isActive? true:false
                icon: ("qrc:/images/skip.png")

                onClicked: player.next()
            }
            ActionButton {
                id:lights
                visible: player.isActive? false:true
                clickable: false

                gradient: Gradient {
                    GradientStop { position: 0.0; color: (clock.trainingPhase? "#00CC00":"#0080FF") }
                    GradientStop { position: 1.0; color: (clock.trainingPhase? "#006600":"#004C99") }
                }
            }

            Text {
                id:statusLabel
                width: 200
                anchors.verticalCenter: parent.verticalCenter
                color: "white"
                font.bold: true
                font.pixelSize: 40
                horizontalAlignment: Text.AlignHCenter
                text: clock.statusText
            }

            ActionButton {
                id: pause
                icon: myTime.pause? ("qrc:/images/play.png"):("qrc:/images/pause.png")

                onClicked: {
                    if(myTime.pause){
                        myTime.pause = false
                        if(clock.time <= 5)
                            animateOpacity.start()
                    }else{
                        soundCountdown.stop()
                        myTime.pause = true
                        if(clock.time <= 5)
                            animateOpacity.stop()
                    }

                    if(clock.trainingPhase && myTime.pause && player.isActive){
                        player.pause()
                        clock
                    }else if(clock.trainingPhase && player.isActive){
                        player.play()
                    }
                }
            }
        }

        Timer {
            id: applauseTime
            interval: 15000
            repeat: false
            running: false
            onTriggered: {
                clock.iniStart = true
                clock.trainingPhase = false
                pageStack.pop()
            }
        }

        ParticleSystem {
            id: confetti
            anchors.fill: parent
            running: applauseTime.running && Qt.application.state === Qt.ApplicationActive

            ImageParticle {
                source: "qrc:/images/particle.png"
                colorVariation: 1.0
            }

            Emitter {
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                }

                size: 20
                velocity: AngleDirection {
                    angle: 90
                    // make the movement of the particles slighly different from one another
                    angleVariation: 10
                    // set speed
                    magnitude: 100
                }
                sizeVariation: 5
                lifeSpan: 8500
            }
        }
    }
}
