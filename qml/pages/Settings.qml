import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0
import "../js/storage.js" as Storage

Dialog {
    id: preferencePage
    anchors.fill: parent

    Column {
        width: preferencePage.width
        spacing: Theme.paddingLarge

        DialogHeader {
            title: qsTr("Save")
            cancelText: qsTr("Cancel")
        }

        TextSwitch {
            id: randomizeSwitcher
            checked: player.random
            text: qsTr("Randomize Playlist")
            description: qsTr("When activated current playlist gets randomized on loading.")
        }

        TextSwitch {
            id: newTrackSwitcher
            checked: player.newTrack
            text: qsTr("New track")
            description: qsTr("When active a new track is played in every training phase.")
        }

        TextSwitch {
            id: screenSaverSwitcher
            checked: clock.displayOn
            text: checked ? qsTr("Enable screen saver"):qsTr("Disable screen saver")
            description: qsTr("When activated prevents screen from being turned off.")
//            onCheckedChanged: sleep.preventSleep = screenSaverSwitcher.checked
        }

        TextSwitch {
            id: tickSwitch
            checked: clock.playTick
            text: checked ? qsTr("Disable tick"):qsTr("Enable tick")
            description: qsTr("Play tick on every second if no playlist is selected.")
        }

        TextSwitch {
            id: applauseSwitch
            checked: clock.applause
            text: checked ? qsTr("Disable applause"):qsTr("Enable applause")
            description: qsTr("Plays an applause at the end of a session.")
        }
    }


    Component.onCompleted: {
        Storage.initialize();
    }

    onAccepted: {
        Storage.setSetting("sleepMode", screenSaverSwitcher.checked)
        Storage.setSetting("tickMode", tickSwitch.checked)
        Storage.setSetting("applauseMode", applauseSwitch.checked)
        Storage.setSetting("randomizer", randomizeSwitcher.checked)
        Storage.setSetting("newTracks", newTrackSwitcher.checked)
        clock.displayOn = screenSaverSwitcher.checked
        clock.playTick = tickSwitch.checked
        clock.applause = applauseSwitch.checked
        player.random = randomizeSwitcher.checked
        player.newTrack = newTrackSwitcher.checked
    }
}
