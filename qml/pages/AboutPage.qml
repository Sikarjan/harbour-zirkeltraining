import QtQuick 2.0
import Sailfish.Silica 1.0

import harbour.zirkeltraining 1.0

Page {
    id: aboutPage

    SilicaFlickable {
        anchors.fill: parent

        Column {
            id: column
            anchors {
                fill: parent
                margins: Theme.paddingLarge
            }
            spacing: Theme.paddingLarge

            PageHeader {
                title: qsTr("About ZirkelTraining")
            }

            Text {
                font.pixelSize: Theme.fontSizeSmall
                width: column.width
                color: Theme.highlightColor
                text: qsTr("Version")+": "+zt.version+"\n"+
                      qsTr("Autor")+": FloR707"
            }

            Text {
                textFormat: Text.RichText
                font.pixelSize: Theme.fontSizeSmall
                width: column.width
                color: Theme.highlightColor
                wrapMode: Text.Wrap
                text: qsTr("Please use <a href=\"https://github.com/Sikarjan/harbour-zirkeltraining\">GitHub</a> for comments and bug reports.")
                onLinkActivated: Qt.openUrlExternally(link)
            }

            Text {
                font.pixelSize: Theme.fontSizeSmall
                width: column.width
                color: Theme.highlightColor
                wrapMode: Text.Wrap
                text: qsTr("To enable music during your training phase you need to have a playlist created with the Jolla Media app first. The app expects to find the .pls files within Media App's standard path. If you have created a playlist you can click on 'No playlist selected' and a page will be shown with all your playlist.")
            }
        }
    }
}
