import QtQuick 2.0
import Sailfish.Silica 1.0

import harbour.zirkeltraining 1.0

Page {
    id: aboutPage

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        VerticalScrollDecorator {}

        Column {
            id: column
            width: parent.width - 2*Theme.paddingMedium
            x: Theme.paddingMedium

            spacing: Theme.paddingLarge

            PageHeader {
                title: qsTr("About ZirkelTraining")
            }

            Text {
                font.pixelSize: Theme.fontSizeSmall
                width: column.width
                color: Theme.primaryColor
                text: qsTr("Version")+": "+zt.version
            }

            Text {
                textFormat: Text.RichText
                font.pixelSize: Theme.fontSizeSmall
                width: column.width
                color: Theme.secondaryColor
                wrapMode: Text.Wrap
                text: "<style>a:link { color: " + Theme.highlightColor + "; }</style>" +
                      qsTr("Please use <a href=\"https://github.com/Sikarjan/harbour-zirkeltraining\">GitHub</a> for comments and bug reports.")
                onLinkActivated: Qt.openUrlExternally(link)
            }

            Text {
                font.pixelSize: Theme.fontSizeSmall
                width: column.width
                color: Theme.secondaryColor
                wrapMode: Text.Wrap
                text: qsTr("To enable music during your training phase you need to have a playlist created with the Jolla Media app first. "+
                           "The app expects to find the .pls files within Media App's standard path. If you have created a playlist you can "+
                           "click on 'No playlist selected' and a page will be shown with all your playlist. If your playlist is not shown "+
                           "restart the app.")
            }

            Label {
                anchors.topMargin: Theme.paddingMedium
                font.pixelSize: Theme.fontSizeMedium
                width: column.width
                color: Theme.primaryColor
                text: qsTr("Training modes")
            }

            Text {
                textFormat: Text.RichText
                font.pixelSize: Theme.fontSizeSmall
                width: column.width
                color: Theme.secondaryColor
                wrapMode: Text.Wrap
                text: qsTr("<p><b>Pyramid</b><br>For the pyramid mode, looking linke this /\\, you only have to add the details for the raising part. The decreasing part will be a copy of the raising part. This is also true for the exercises. The exercise list will be worked backwards on the decreasing part.</p>"+
                           "<p><b>Custom</b><br>To use the custom mode you are required to add exercise list. Here you can define training and recovery time for each exercise.</p>")
            }
        }
    }
}
