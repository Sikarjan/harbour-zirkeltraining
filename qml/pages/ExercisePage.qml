import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"
import QtQuick.LocalStorage 2.0
import "../js/storage.js" as Storage

Dialog {
    id: exPage
    property int profileID
    property int tStyle
    property int cycles
    property int training
    property int recover
    property int tAdjust
    property int rAdjust
    property bool listChanged: false

    property int exerciseId: -1

    Component.onCompleted: {
        if(profileID !== -1){
            // Load exercise list from db
            Storage.initialize()
            Storage.loadExerciseList(profileID)
            trainingSlider.value = training
            recoverSlider.value = recover
        }
    }

    onRejected: {
        Storage.loadExerciseList(profileID)
    }
    onAccepted: {
        profile.profileChanged = listChanged
        profile.cycles = exerciseModel.count
    }

    function addExercise(){
        // Adjust time per training style
        var training = trainingSlider.value
        var recover = recoverSlider.value
        var recalc = false

        if(tStyle > 0 && tStyle < 5){
            if(editPos.text !== ""){
                training = -1
                recover = -1
                recalc = true
            }else if(tStyle === 2){ // Pyramid && Raising
                training = training + exerciseModel.count*tAdjust
                recover = recover + exerciseModel.count+rAdjust
            }else if(tStyle === 3){// Falling
                if(exerciseModel.count === cycles && exerciseId === -1){
                    return
                }

                training = training - exerciseModel.count*tAdjust
                recover = recover - exerciseModel.count+rAdjust
            }else if(tStyle === 4 && exerciseModel.count % 2 === 0){ // ZigZag
                training = training + tAdjust
                recover = recover + rAdjust
            }
        }

        if(exerciseId > -1){
            exerciseModel.set(exerciseId, {
                                 "training": training,
                                 "recover": recover,
                                 "exercise": exerciseName.text
                             })
            exerciseId = -1
        }else if(editPos.text !== ""){
            exerciseModel.insert(editPos.text-1, {
                                 "training": training,
                                 "recover": recover,
                                 "exercise": exerciseName.text
                             })
        }else{
            exerciseModel.append({
                                 "training": training,
                                 "recover": recover,
                                 "exercise": exerciseName.text
                             })
        }
        exerciseName.text = ""
        listChanged = true

        if(recalc){
            recalc = false
            updateExerciseList()
        }
    }

    function updateExerciseList(){
        if(tStyle === 0 || tStyle > 4){
            return
        }

        var training = 0
        var recover = 0

        for(var i = 0; i < exerciseModel.count; i++){
            if(tStyle === 1 || tStyle === 2){ // Pyramid or Raising
                training = exPage.training + i*exPage.tAdjust
                recover = exPage.recover + i*exPage.rAdjust
            }else if(tStyle === 3){ // Falling
                training = exPage.training - i*exPage.tAdjust
                recover = exPage.recover - i*exPage.rAdjust
            }else if(tStyle === 4){ // ZigZag
                if(i % 2 === 0){
                    training = exPage.training
                    recover = exPage.recover
                }else {
                    training = exPage.training + tAdjust
                    recover = exPage.recover + rAdjust
                }
            }

            exerciseModel.set(i, {"training": training,
                                  "recover": recover})
        }
    }

    SilicaFlickable {
        anchors.fill: parent

        Column {
            id: setCol
            width: exPage.width

            DialogHeader {
                acceptText: qsTr("Accept")
                cancelText: qsTr("Cancel")
            }

            Column {
                width: parent.width-2*Theme.paddingMedium
                x: Theme.paddingMedium

                ButtonSlider {
                    id: trainingSlider
                    visible: tStyle === 5
                    width: parent.width
                    label: qsTr("Training Cycle Time")
                    value: training
                    minimumValue: 10
                    maximumValue: 600
                    stepSize: 5
                    unit: "s"
                }

                ButtonSlider {
                    id: recoverSlider
                    visible: tStyle === 5
                    width: parent.width
                    label: qsTr("Recover Cycle Time")
                    value: recover
                    minimumValue: 0
                    maximumValue: 600
                    stepSize: 5
                    unit: "s"
                }

                TextField {
                    id: exerciseName
                    width: parent.width
                    readOnly: !(tStyle !== 1 || tStyle !== 3 || cycles >= exerciseModel.count || exerciseId !== -1)
                    placeholderText: qsTr("Insert a exercise name or task")
                    label: qsTr("Exercise name")

                    EnterKey.iconSource: "image://theme/icon-m-add"
                    EnterKey.enabled: text.length > 0
                    EnterKey.onClicked: addExercise()
                }


                TextField {
                    id: editPos
                    width: parent.width
                    visible: exerciseModel.count > 1
                    validator: IntValidator{bottom: 1; top: exerciseModel.count}
                    inputMethodHints: Qt.ImhDigitsOnly
                    label: text === "" ? qsTr("Appending exercise"):qsTr("Inserting befor position")
                    placeholderText: qsTr("Insert bevor or empty for append")
                }

                Text {
                    id: errorLine
                    width: parent.width
                    visible: tStyle === 3 && exerciseModel.count === cycles
                    color: Theme.primaryColor
                    wrapMode: Text.Wrap

                    text: qsTr("Exercise list is full. To add additional exercises accept and edit your training settings first.")
                }

                Item {
                    anchors.right: parent.right
                    width: parent.width
                    height: addExerciseButton.height

                    Label {
                        id: addExerciseLabel
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: addExerciseButton.left
                        anchors.rightMargin: Theme.paddingSmall
                        text: exerciseId !== -1 ? qsTr("Update exercise ")+(exerciseId+1):(editPos.text === "" ? qsTr("Append exercise"):qsTr("Insert exercise"))
                    }

                    IconButton {
                        id: addExerciseButton
                        anchors.right: parent.right
                        icon.source: "image://theme/icon-m-add?" + (pressed
                                                                     ? Theme.highlightColor
                                                                     : Theme.primaryColor)
                    }
                    MouseArea {
                        anchors.fill: parent

                        onClicked: addExercise()

                        onPressed: {
                            addExerciseButton.icon.source = "image://theme/icon-m-add?"+Theme.highlightColor
                            addExerciseLabel.color = Theme.highlightColor
                        }
                        onReleased: {
                            addExerciseButton.icon.source = "image://theme/icon-m-add?"+Theme.primaryColor
                            addExerciseLabel.color = Theme.primaryColor
                        }
                    }
                }

                Text {
                    width: parent.width
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.secondaryColor
                    wrapMode: Text.Wrap

                    text: exerciseModel.count === 0 ? qsTr("Add exercises to your list"):
                            exerciseModel.count > cycles ? qsTr("More exercises than cycles. Cycles will be increased."):
                            exerciseModel.count === cycles ? qsTr("Exercise list will be repeated once. ") + exerciseModel.count + qsTr(" exercises."):
                            qsTr("Exercise list will be reapeated ") + Math.round(cycles/exerciseModel.count*10)/10 + qsTr(" times.")
                }
            }
        }

        SilicaListView {
            id: exerciseList
            width: exPage.width - 2* Theme.paddingSmall
            height: exPage.height - setCol.height
            anchors.top: setCol.bottom
            x: Theme.paddingSmall
            clip: true

            VerticalScrollDecorator {}

            model: exerciseModel

            header: Label {
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: Theme.fontSizeLarge
                text: qsTr("Exercise List")
            }

            delegate: ListItem {
                id: listItem
                contentHeight:  exerciseItem.height
                menu: contextMenu
                ListView.onRemove: animateRemoval(listItem)
                function remove() {
                    remorseAction(qsTr("Deleting"), function() {
                        exerciseList.model.remove(index);
                        exPage.listChanged = true;
                    })
                }

                Row {
                    id: exerciseItem
                    width: exerciseList.width
                    spacing: Theme.paddingSmall

                    Rectangle {
                        id: numberBlock
                        anchors.verticalCenter: parent.verticalCenter
                        height: Theme.itemSizeSmall - Theme.paddingMedium
                        width: numberLabel.width + 2*Theme.paddingMedium
                        radius: 5

                        color: Theme.secondaryColor
                        Label {
                            anchors.centerIn: parent
                            id: numberLabel
                            text: (exerciseModel.count > 9 && index <  9 ? "0":"") + (index+1)
                        }
                    }

                    Column {
                        width: parent.width - numberBlock.width - Theme.paddingMedium
                        Row {
                            spacing: Theme.paddingSmall
                            Label {
                                text: qsTr("Exercise") + ": " + training === -1 ? "-":training +" s"
                            }

                            Label {
                                text: qsTr("Pause") + ": " + recover === -1 ? "-":recover+" s"
                            }
                        }

                        Label {
                            width: parent.width
                            wrapMode: Text.Wrap

                            text: exercise
                        }
                    }
                }

                Component {
                   id: contextMenu
                   ContextMenu {
                      MenuItem {
                          text: qsTr("Move up")
                          onClicked: {
                              exerciseList.model.move(index, index-1, 1)
                              updateExerciseList()
                          }
                      }
                      MenuItem {
                          text: qsTr("Move down")
                          onClicked: {
                              exerciseList.model.move(index, index+1, 1)
                              updateExerciseList()
                          }
                      }
                      MenuItem {
                          text: qsTr("Edit")
                          onClicked: {
                              exerciseName.text = exercise
                              trainingSlider.value = training
                              recoverSlider.value = recover
                              exerciseId = index
                          }
                      }
                      MenuItem {
                          text: qsTr("Remove")
                          onClicked: remove()
                      }
                   }
                }
            }
        }
    }
}
