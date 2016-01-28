import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0
import "../js/storage.js" as Storage

Dialog {
    id: playlistPage

    DialogHeader {
        id: header
        defaultAcceptText: qsTr("Select Playlist")
        cancelText: qsTr("Cancel")
    }

    property string m_playlistName: ""

    canAccept: fileCounter > 0

    onAccepted: {
        player.playlist = m_playlistName
        player.playlistError = false
        player.isActive = m_playlistName === ""? false:true
        Storage.setSetting("playlist", m_playlistName)
    }

    SilicaListView {
        id: myListView
        width: parent.width
        height: parent.height - header.height
        anchors.top: header.bottom
        spacing: Theme.paddingLarge
        VerticalScrollDecorator {}

        model: m_playlists

        property int selected: -1

        delegate: TextSwitch {
            id: playlistSwitch
            height: 50
            width:  parent.width
            property bool isChecked: (index === myListView.selected? playlistSwitch.checked = true:playlistSwitch.checked = false)

            text: m_playlists[index].slice(0,-4)

            onClicked: {
                if(playlistSwitch.checked){
                    m_playlistName = text
                    myListView.selected = index
                }else{
                    m_playlistName = ""
                }
            }
        }
    }

    Text {
        id: errorText
        visible: fileCounter === 0? true:false
        anchors.centerIn: parent
        x: Theme.paddingLarge
        text: qsTr("No playlists found in the standard folder. Please create a new playlist using the Media app.")
        color: Theme.secondaryHighlightColor
        font.pixelSize: Theme.fontSizeLarge
        wrapMode: Text.Wrap
        width: parent.width - Theme.paddingLarge
    }
}
