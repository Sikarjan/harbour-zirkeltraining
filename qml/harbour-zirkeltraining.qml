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
import QtMultimedia 5.0
import "pages"

import harbour.zirkeltraining 1.0

ApplicationWindow
{
    id: zirkel

    ZT {
        id: zt
    }

    KeepAlive {
        id: keepAlive
    }

    AudioPlayer {
        id: player

        property string playlist: ""
        property bool playlistError: false
        property bool isActive: false
        property bool random
        property bool newTrack
    }

    Item {
        id: profile
        property int profileID: -1
        property bool profileChanged: false
        property string profileTitel: ''

        // Titel anpassen wenn Programm verändert wurde
        onProfileChangedChanged: {
            console.log('Current profile changed? '+profileChanged)
            if (profileChanged === true && profile.profileID !== -1) {
                 profileTitel = profileTitel+"*"
             }
        }
    }

    Item {
        id:clock
        state: "start"

        property int time
        property int trainingTime: 30
        property int holdTime: 10
        property int adjustmentTime: 15
        property int adjustmentTimePause: 10
        property int cycles: 10
        property int tipCycle
        property int tStyle: 0
        property bool trainingPhase: false
        property bool iniStart: true
        property int last: 0
        property string statusText: qsTr("Get ready!")
        property bool displayOn: false
        property bool playTick: false

        states: [
            State {
                name: "start"
                when: clock.iniStart
                PropertyChanges {
                    target: clock
                    statusText: qsTr("Get ready!")
                }
            },
            State {
                name: "finished"
                when: clock.cycles === 0
                PropertyChanges {
                    target: clock
                    statusText: qsTr("Finished")
                }
            },
            State {
                name: "active"
                when: !myTime.pause && !clock.iniStart
                PropertyChanges {
                    target: clock
                    statusText: clock.trainingPhase? qsTr("Go!"): qsTr("Recover")
                }
            },
            State {
                name: "pause"
                when: myTime.pause
                PropertyChanges {
                    target: clock
                    statusText: qsTr("Paused")
                }
            }
        ]

        SoundEffect {
            id: soundGong
            source: "qrc:/sounds/gong.wav"
            volume: 1.0
        }
        SoundEffect {
            id: soundCountdown
            source: "qrc:/sounds/countdown_male.wav"
        }
        SoundEffect {
            id: applause
            source: "qrc:/sounds/applause.wav"
        }
        SoundEffect {
            id: tick
            source: "qrc:/sounds/tick.wav"
        }

        Chronos {
            id: myTime
            running: false
            pause: false
        }

        Timer {
            id: ticker
            interval: 200
            running: (myTime.running && !myTime.pause? true:false)
            repeat: true

            onTriggered: {
                clock.time = myTime.getTime()

                if(clock.time != clock.last){
                    console.log(clock.time+" clock State: "+clock.state+" Running: "+myTime.running)
                    clock.last = clock.time
                }

                if(clock.time === 0 && !soundGong.playing && clock.trainingPhase){
                    if(player.isActive)
                        player.pause()
                    if(player.newTrack)
                        player.next()

                    soundGong.play()

                    clock.cycles--
                    if(clock.cycles === 0){
                        myTime.running = false
                        // Button still displays pause symbol. Could be improved
                        applauseTimer.start()
                    }
                }else if(clock.time <= -1){
                    if(clock.trainingPhase){
                        clock.trainingPhase = false
                        myTime.setNewTime(clock.holdTime)
                    }else{
                        if(clock.iniStart){
                            clock.iniStart = false
                        }else{
                            // recover phase is over new times need to be set
                            switch (clock.tStyle) {
                            case 1: // Pyramid
                                if(clock.cycles < clock.tipCycle && clock.adjustmentTime > 0){
                                    clock.adjustmentTime = clock.adjustmentTime*-1
                                    clock.adjustmentTime = clock.adjustmentTimePause*-1
                                }
                                clock.holdTime = clock.holdTime+clock.adjustmentTimePause
                                clock.trainingTime = clock.trainingTime+clock.adjustmentTime
                                break;
                            case 2: // Raising
                                clock.holdTime = clock.holdTime+clock.adjustmentTimePause
                                clock.trainingTime = clock.trainingTime+clock.adjustmentTime
                                break;
                            case 3: // Falling
                                clock.holdTime = clock.holdTime-clock.adjustmentTimePause
                                clock.trainingTime = clock.trainingTime-clock.adjustmentTime
                                break;
                            case 4: // Zig Zag
                                clock.holdTime = clock.holdTime+clock.adjustmentTimePause*clock.tipCycle
                                clock.trainingTime = clock.trainingTime+clock.adjustmentTime*clock.tipCycle
                                clock.tipCycle = -1*clock.tipCycle
                                break;
                            }
                        }

                        clock.trainingPhase = true
                        myTime.setNewTime(clock.trainingTime)

                        if(player.isActive)
                            player.play()
                    }
                }

                if(clock.time <= 5 && clock.time >4 && !clock.trainingPhase && !soundCountdown.playing)
                    soundCountdown.play()
                else if(clock.time > 5 && soundCountdown.playing)
                    soundCountdown.stop()
            }
        }

        // Final applause
        Timer {
            id: applauseTimer
            interval: 1000
            running: false
            repeat:false

            onTriggered: applause.play()
        }

        Timer {
            id: keepDisplayOn
            interval: 15000
            running: false
            repeat: true

            onTriggered: Support.setBlankingMode(clock.displayOn)
        }
    }

    initialPage: Component { FirstPage { } }
    cover: Qt.resolvedUrl("cover/CoverPage.qml")
}
