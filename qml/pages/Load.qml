import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0
import "../js/storage.js" as Storage

Page {
    id: loadPage

    Component.onCompleted: {
        // Load all available profiles from the DB
        Storage.getProfiles();
    }

    function addProfile (name,uid, mode, training) {
        profileModel.append({"name":name, "uid": uid, "mode":mode, "training":training})
    }

    ListModel {
        id: profileModel
    }

    SilicaFlickable {
        anchors.fill: parent

        PullDownMenu {
            visible: false //profileList.count !== 0
            MenuItem {
                text: qsTr("Delete all profiles")
                onClicked: remorseAction(qsTr("Deleting all profiles"), function () {
                    profileList.remove()
                    Storage.deleteAll()
                    clock.profileID = -1
                })
            }
        }

        PageHeader {
            id: header
            title: qsTr("Load profile")
        }

        SilicaListView {
            id: profileList
            width: parent.width
            height: parent.height - header.height
            anchors {
                top: header.bottom
            }
            model: profileModel
            VerticalScrollDecorator {}

            ViewPlaceholder {
                enabled: profileList.count === 0
                text: qsTr("No profiles saved.")
            }

            delegate: ListItem {
                id: profileItem
                width: ListView.view.width
                contentHeight: Theme.itemSizeMedium // two line delegate
                ListView.onRemove: animateRemoval(profileItem)

                function remove() {
                    remorseAction(qsTr("Deleting profile"), function() {
                        Storage.deleteProfileItem(uid)
                        if(uid === clock.profileID)
                            profile.profileID = -1
                        profileList.model.remove(index)
                    });
                }

                Label {
                    id: nameLabel
                    anchors {
                        left: parent.left
                        right: parent.right
                        leftMargin: Theme.paddingLarge
                    }
                    text: name
                    color: profileItem.highlighted ? Theme.highlightColor : Theme.primaryColor
                }

                Label {
                    id: descLabel
                    anchors {
                        left: parent.left
                        right: parent.right
                        leftMargin: Theme.paddingLarge
                    }
                    anchors.top: nameLabel.bottom
                    property variant styles: [qsTr("Static"), qsTr("Pyramid"),  qsTr("Raising"), qsTr("Falling"), qsTr("Zick zack")]
                    text: qsTr("Training Style: ")+styles[mode]+qsTr(" - Training time: ")+training
                    font.pixelSize: Theme.fontSizeSmall
                    color: profileItem.highlighted ? Theme.highlightColor : Theme.primaryColor
                }

                onClicked: {
                    profile.profileID = uid
                    pageStack.pop(null)
                }
                menu: ContextMenu {
                    MenuItem {
                        text: qsTr("Delete profile")
                        onClicked: remove()
                    }
                }
            }
        }
    }
}
