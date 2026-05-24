import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtMultimedia
import MediaApp

ApplicationWindow {
    id: window
    visible: true
    width: 800
    height: 600
    title: qsTr("Media Player")

    // Глобальный доступ к плееру
    property alias mediaPlayer: player

    readonly property bool isMobile: Qt.platform.os === "android" || Qt.platform.os === "ios"
    readonly property bool isWindows: Qt.platform.os === "windows" || Qt.platform.os === "winrt"
    readonly property bool isWasm: Qt.platform.os === "wasm"

    MediaPlayer {
        id: player
        audioOutput: AudioOutput {}
        source: (backend.playlist && backend.playlist.length > 0 && backend.currentIndex >= 0)
                ? backend.playlist[backend.currentIndex].path
                : ""

        onErrorOccurred: (error, errorString) => {
            console.error("MediaPlayer Error: " + errorString)
        }
    }

    // Загрузчик платформозависимого интерфейса
    Loader {
        id: uiLoader
        anchors.fill: parent
        source: "PlatformUI.qml"
        onLoaded: {
            console.log("UI Loaded for platform: " + Qt.platform.os)
        }
    }

    // Обработка ошибок бэкенда
    Connections {
        target: backend
        function onErrorOccurred(message) {
            errorDialog.text = message
            errorDialog.open()
        }
    }

    Dialog {
        id: errorDialog
        property alias text: errorLabel.text
        title: qsTr("Error")
        standardButtons: Dialog.Ok
        anchors.centerIn: parent
        modal: true
        Label {
            id: errorLabel
            width: 300
            wrapMode: Text.Wrap
        }
    }
}
