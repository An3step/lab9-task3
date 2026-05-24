import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtMultimedia

ColumnLayout {
    id: root
    spacing: 10

    property MediaPlayer player

    RowLayout {
        Layout.fillWidth: true
        Label {
            text: formatTime(player.position)
        }
        Slider {
            id: seekSlider
            Layout.fillWidth: true
            from: 0
            to: player.duration
            value: player.position
            onMoved: player.position = value
        }
        Label {
            text: formatTime(player.duration)
        }
    }

    RowLayout {
        Layout.alignment: Qt.AlignHCenter
        spacing: 20

        Button {
            text: "⏮"
            onClicked: {
                if (backend.currentIndex > 0)
                    backend.currentIndex--
            }
        }

        Button {
            text: player.playbackState === MediaPlayer.PlayingState ? "⏸" : "▶"
            highlighted: true
            onClicked: {
                if (player.playbackState === MediaPlayer.PlayingState)
                    player.pause()
                else
                    player.play()
            }
        }

        Button {
            text: "⏭"
            onClicked: {
                if (backend.currentIndex < backend.playlist.length - 1)
                    backend.currentIndex++
            }
        }
    }

    function formatTime(ms) {
        let totalSeconds = Math.floor(ms / 1000)
        let minutes = Math.floor(totalSeconds / 60)
        let seconds = totalSeconds % 60
        return minutes + ":" + (seconds < 10 ? "0" : "") + seconds
    }
}
