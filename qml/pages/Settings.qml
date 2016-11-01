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
            text: qsTr("Turn off screen saver")
            description: qsTr("When activated prevents screen from being turned off.")
//            onCheckedChanged: sleep.preventSleep = screenSaverSwitcher.checked
        }
    }


    Component.onCompleted: {
        Storage.initialize();
    }

    onAccepted: {
        Storage.setSetting("sleepMode", screenSaverSwitcher.checked)
        Storage.setSetting("randomizer", randomizeSwitcher.checked)
        Storage.setSetting("newTracks", newTrackSwitcher.checked)
        clock.displayOn = screenSaverSwitcher.checked
        player.random = randomizeSwitcher.checked
        player.newTrack = newTrackSwitcher.checked
    }
}
