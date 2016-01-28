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

Page {
    id: countdownPage
    allowedOrientations: Orientation.All

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
            }
        }
    }

    Component.onCompleted: {
        myTime.running = true
        if(player.playlist !== ""){
            player.setSource(player.playlist)
            if(player.random)
                player.shuffle()
        }
    }

    NumberAnimation {
        id: animateOpacity
        target: display
        property: "opacity"
        running: clock.time < 6
        from: 0.1
        to: 1.0
        duration: 1000
        loops: Animation.Infinite
        easing.type: Easing.InOutCubic
    }

    Rectangle {
        id: scene
        anchors.fill: parent
        color: "black"

        Text {
            id:headerText
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            y: 30
            text: qsTr("Remaining Cycles:")
            color: "white"
        }

        Text {
            id: cycleText
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            anchors.top: headerText.bottom
            text: clock.cycles
            color: "white"
            font.pixelSize: Theme.fontSizeLarge
        }

        Text {
            id: display
            visible: clock.cycles !== 0? true:false
            anchors.centerIn: parent
            text: (clock.time < 1? 0:clock.time)
            color: (clock.time < 6? "red" : "white")
            opacity: (animateOpacity.running? 0: 1.0)
            font.bold: true
            font.pixelSize: 300
        }
        Text {
            id: finsh
            visible: clock.cycles === 0? true:false
            anchors.centerIn: parent
            text: qsTr("You have done it!")
            color: "white"
            font.bold: true
            font.pixelSize: 60

            // triggers final animation
            onVisibleChanged: visible === true? applauseTime.running = true:applauseTime.running = false
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
            running: applauseTime.running

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
