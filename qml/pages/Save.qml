import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0
import "../js/storage.js" as Storage

Dialog {
    id: savePage

    Component.onCompleted: {
            // Initialize the database
            Storage.initialize();
    }

    canAccept: nameInput.text.length > 0 && nameInput.text.length < 26

    DialogHeader {
        id: header
        acceptText: qsTr("Save profile")
        cancelText: qsTr("Cancel")
    }

    Column {
        width: savePage.width - 2*Theme.paddingMedium
        spacing: 2
        anchors.top: header.bottom
        anchors.topMargin: Theme.paddingLarge
        x: Theme.paddingMedium

        TextField {
            id: nameInput
            width: parent.width
            placeholderText: qsTr("Insert a name required")
            label: qsTr("Profile name")
        }
        Label {
            text: qsTr("Training time: ")+clock.trainingTime
            font.pixelSize: Theme.fontSizeSmall
        }
        Item {
            width: 5
            height: Theme.paddingLarge -2
        }

        Text {
            width: parent.width
            wrapMode: Text.Wrap
            color: Theme.highlightColor

            text: qsTr("The profile name should be unique and not be longer than 25 characters. It is not possible to change the profile name.")
        }
    }

    onAccepted: {
        profile.profileID = Storage.saveProfile(nameInput.text, clock.trainingTime, clock.holdTime, clock.cycles, clock.tStyle, clock.adjustmentTime, clock.adjustmentTimePause)
        Storage.saveExerciseList(profile.profileID)
        profile.profileChanged = false
    }
}
