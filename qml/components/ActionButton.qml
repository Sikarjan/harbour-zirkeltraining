import QtQuick 2.0
import QtMultimedia 5.0

Rectangle {
    id: buttonRoot
    // export button properties
    property alias text: label.text
    property alias icon: image.source
    property alias clickable: clickArea.enabled
    property int animTime: 350
    signal clicked

    width: 90; height: 90
    gradient: Gradient {
        GradientStop { position: 0.0; color: (clickArea.pressed? "#F0F0F0":"white") }
        GradientStop { position: 1.0; color: (clickArea.pressed? "#B2B2B2":"#F0F0F0") }
    }
    border.color: "#DDDDDD"
    border.width: 4
    radius: 20

    Text {
        id: label
        anchors.centerIn: parent
        text: ""
    }

    Image {
        id: image
        anchors.centerIn: parent
        source: ""
    }

    MouseArea {
        id: clickArea
        enabled: true
        anchors.fill: parent
        onClicked: {
            click.play()
            clickAnimation.start()
            sendClick.start()
        }
    }

    Timer {
        id:sendClick
        interval: animTime
        onTriggered: {
            image.scale = 1
            buttonRoot.clicked()
        }
    }
    SoundEffect {
        id: click
        source: "qrc:/sounds/click.wav"
    }

    SequentialAnimation {
        id: clickAnimation
        ParallelAnimation {
            NumberAnimation {
                id: scaleUp
                target: image
                property: "scale"
                from: 1
                to: 1.4
                duration: animTime
                easing.type: Easing.OutQuad
            }
            NumberAnimation {
                id: fade
                target: image
                property: "opacity"
                from: 1
                to: 0.1
                duration: animTime
                easing.type: Easing.InQuad
            }
        }

        NumberAnimation {
            duration: animTime*0.75
            target: image
            property: "opacity"
            to: 1
            easing.type: Easing.InCubic
        }
    }
}
