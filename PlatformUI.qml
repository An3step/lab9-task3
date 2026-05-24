import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import QtQuick.Dialogs

Item {
    id: root

    readonly property bool isMobile: Qt.platform.os === "android" || Qt.platform.os === "ios"
    readonly property bool isWindows: Qt.platform.os === "windows" || Qt.platform.os === "winrt"

    // --- Windows Desktop Layout ---
    ColumnLayout {
        visible: !root.isMobile
        anchors.fill: parent
        spacing: 0

        MenuBar {
            Layout.fillWidth: true
            Menu {
                title: qsTr("File")
                Action { text: qsTr("Open Folder..."); onTriggered: folderDialog.open() }
                Action { text: qsTr("Favorites"); onTriggered: backend.loadFavorites() }
                MenuSeparator { }
                Action { text: qsTr("Exit"); onTriggered: Qt.quit() }
            }
        }

        SplitView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            orientation: Qt.Horizontal

            TrackList {
                SplitView.preferredWidth: parent.width * 0.35
                Layout.fillHeight: true
            }

            Rectangle {
                color: palette.window
                SplitView.fillWidth: true
                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 20
                    Image {
                        source: (backend.playlist && backend.playlist.length > 0 && backend.currentIndex >= 0)
                                ? backend.playlist[backend.currentIndex].cover
                                : "qrc:/MediaApp/default_cover.png"
                        Layout.preferredWidth: 300; Layout.preferredHeight: 300
                        fillMode: Image.PreserveAspectFit
                    }
                    Label {
                        text: (backend.playlist && backend.playlist.length > 0 && backend.currentIndex >= 0)
                              ? backend.playlist[backend.currentIndex].title
                              : qsTr("No track selected")
                        font.pixelSize: 22
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }
        }

        PlayerControls {
            Layout.fillWidth: true
            player: window.mediaPlayer
            Layout.margins: 10
        }
    }

    // --- Mobile Layout (Android/iOS) ---
    Page {
        visible: root.isMobile
        anchors.fill: parent

        header: ToolBar {
            Label { text: qsTr("Media Player"); anchors.centerIn: parent; font.bold: true }
            ToolButton { text: "📁"; anchors.right: parent.right; onClicked: folderDialog.open() }
        }

        TrackList {
            anchors.fill: parent
            anchors.bottomMargin: miniPlayer.visible ? miniPlayer.height : 0
        }

        Rectangle {
            id: miniPlayer
            width: parent.width; height: 72
            anchors.bottom: parent.bottom
            color: palette.window
            visible: backend.playlist && backend.playlist.length > 0 && backend.currentIndex >= 0

            Rectangle { width: parent.width; height: 1; color: "#e0e0e0"; anchors.top: parent.top }

            RowLayout {
                anchors.fill: parent; anchors.margins: 10
                spacing: 15
                Image {
                    source: (backend.playlist && backend.playlist[backend.currentIndex]) ? backend.playlist[backend.currentIndex].cover : ""
                    Layout.preferredWidth: 52; Layout.preferredHeight: 52
                }
                Label {
                    text: (backend.playlist && backend.playlist[backend.currentIndex]) ? backend.playlist[backend.currentIndex].title : ""
                    Layout.fillWidth: true; elide: Text.ElideRight; font.bold: true
                }
                ToolButton {
                    text: window.mediaPlayer.playbackState === 1 ? "⏸" : "▶"
                    onClicked: window.mediaPlayer.playbackState === 1 ? window.mediaPlayer.pause() : window.mediaPlayer.play()
                }
            }
            MouseArea { anchors.fill: parent; onClicked: fullPlayer.open() }
        }
    }

    Popup {
        id: fullPlayer
        width: parent.width; height: parent.height
        y: parent.height; padding: 0
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        enter: Transition { NumberAnimation { property: "y"; to: 0; duration: 350; easing.type: Easing.OutExpo } }
        exit: Transition { NumberAnimation { property: "y"; to: parent.height; duration: 350; easing.type: Easing.InExpo } }

        ColumnLayout {
            anchors.fill: parent; anchors.margins: 30
            spacing: 20
            ToolButton { text: "⌄"; font.pixelSize: 30; Layout.alignment: Qt.AlignHCenter; onClicked: fullPlayer.close() }

            Rectangle {
                Layout.fillWidth: true; Layout.fillHeight: true
                color: "transparent"
                Image {
                    anchors.centerIn: parent
                    width: Math.min(parent.width, parent.height) * 0.9
                    height: width
                    source: (backend.playlist && backend.playlist[backend.currentIndex]) ? backend.playlist[backend.currentIndex].cover : ""
                    fillMode: Image.PreserveAspectFit
                }
            }

            ColumnLayout {
                Layout.fillWidth: true; spacing: 5
                Label {
                    text: (backend.playlist && backend.playlist[backend.currentIndex]) ? backend.playlist[backend.currentIndex].title : ""
                    font.pixelSize: 26; font.bold: true; Layout.alignment: Qt.AlignHCenter
                }
                Label {
                    text: (backend.playlist && backend.playlist[backend.currentIndex]) ? backend.playlist[backend.currentIndex].artist : ""
                    font.pixelSize: 18; opacity: 0.6; Layout.alignment: Qt.AlignHCenter
                }
            }

            PlayerControls { Layout.fillWidth: true; player: window.mediaPlayer }
            Item { Layout.preferredHeight: 20 }
        }
    }

    FolderDialog { id: folderDialog; onAccepted: backend.scanDirectory(selectedFolder) }
}
