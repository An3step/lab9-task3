import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    ListView {
        id: listView
        anchors.fill: parent
        model: backend.playlist
        clip: true
        spacing: 0

        Label {
            anchors.centerIn: parent
            text: qsTr("Playlist is empty.\nOpen a folder to scan for music.")
            horizontalAlignment: Text.AlignHCenter
            opacity: 0.5
            visible: listView.count === 0
        }

        delegate: ItemDelegate {
            width: listView.width
            height: 64
            highlighted: index === backend.currentIndex

            contentItem: RowLayout {
                spacing: 12
                Image {
                    source: (modelData && modelData.cover) ? modelData.cover : "qrc:/MediaApp/default_cover.png"
                    Layout.preferredWidth: 40
                    Layout.preferredHeight: 40
                    fillMode: Image.PreserveAspectFit
                }
                ColumnLayout {
                    spacing: 0
                    Layout.fillWidth: true
                    Label {
                        text: (modelData && modelData.title) ? modelData.title : "Unknown Track"
                        font.bold: index === backend.currentIndex
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                    Label {
                        text: (modelData && modelData.artist) ? modelData.artist : "Unknown Artist"
                        font.pixelSize: 11
                        opacity: 0.7
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                }

                ToolButton {
                    text: "★"
                    onClicked: backend.addToFavorites(index)
                }
            }

            onClicked: {
                backend.currentIndex = index
                if (window.mediaPlayer) {
                    window.mediaPlayer.play()
                }
            }
        }
    }
}
