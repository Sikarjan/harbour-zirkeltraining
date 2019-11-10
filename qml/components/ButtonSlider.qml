import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    id: root
    height: mSlider.height

    property string label
    property int value
    property int minimumValue
    property int maximumValue
    property int stepSize
    property string unit


    IconButton {
        id: buttonLeft
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        icon.source: "image://theme/icon-m-left?" + (pressed
                                                     ? Theme.highlightColor
                                                     : Theme.primaryColor)

        onClicked: {
            console.log("höhe: "+ mSlider.height + " breite: " + mSlider.width)
            if(mSlider.value > mSlider.minimumValue){
                mSlider.value = mSlider.value-mSlider.stepSize
            }
        }
    }

    Slider {
        id: mSlider
        anchors.horizontalCenter: parent.horizontalCenter
        width: root.width - buttonLeft.width/2

        label: root.label
        value: root.value
        minimumValue: root.minimumValue
        maximumValue: root.maximumValue
        stepSize: root.stepSize
        valueText: value + " " + root.unit

        onValueChanged: root.value = value
    }

    IconButton {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        icon.source: "image://theme/icon-m-right?" + (pressed
                                                     ? Theme.highlightColor
                                                     : Theme.primaryColor)

        onClicked: {
            if(mSlider.value < mSlider.maximumValue){
                mSlider.value = mSlider.value+mSlider.stepSize
            }
        }
    }
}
