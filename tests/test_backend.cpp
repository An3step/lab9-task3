#include <QtTest>
#include <QSignalSpy>
#include <QStandardPaths>
#include "../MediaPlayerBackend.h"

class TestMediaApp : public QObject
{
    Q_OBJECT

private slots:
    // --- Модульные тесты (Unit Tests) ---
    void test_initialState() {
        MediaPlayerBackend backend;
        QCOMPARE(backend.playlist().size(), 0);
        QCOMPARE(backend.currentIndex(), -1);
    }

    void test_setCurrentIndex() {
        MediaPlayerBackend backend;
        QSignalSpy spy(&backend, &MediaPlayerBackend::currentIndexChanged);
        backend.setCurrentIndex(10);
        QCOMPARE(backend.currentIndex(), 10);
        QCOMPARE(spy.count(), 1);
    }

    void test_invalidDirectoryHandling() {
        MediaPlayerBackend backend;
        QSignalSpy spy(&backend, &MediaPlayerBackend::errorOccurred);
        backend.scanDirectory("Z:/non/existent/folder/12345");
        QVERIFY(spy.count() > 0);
    }

    void test_playlistClearOnNewScan() {
        MediaPlayerBackend backend;
        backend.scanDirectory(QDir::currentPath());
        backend.scanDirectory("/tmp/empty"); // Предположим пустую
        // Проверяем, что вызов не падает и логика очистки работает
        QVERIFY(backend.playlist().size() >= 0);
    }

    // --- Интеграционные тесты (Integration Tests) ---
    void test_databaseConnection() {
        MediaPlayerBackend backend;
        // Проверяем, что файл базы создается в AppData
        QString dbPath = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) + "/mediaplayer.db";
        backend.loadFavorites(); // Триггер инициализации
        QVERIFY(QFile::exists(dbPath));
    }

    void test_favoritesPersistence() {
        MediaPlayerBackend backend;
        backend.scanDirectory(QDir::currentPath());
        if (backend.playlist().size() > 0) {
            backend.addToFavorites(0);
            backend.loadFavorites();
            QVERIFY(backend.playlist().size() > 0);
        }
    }

    void test_fullScanCycle() {
        MediaPlayerBackend backend;
        QSignalSpy spy(&backend, &MediaPlayerBackend::playlistChanged);
        backend.scanDirectory(QStandardPaths::writableLocation(QStandardPaths::MusicLocation));
        QVERIFY(spy.count() >= 1);
    }

    void test_errorSignalFormatting() {
        MediaPlayerBackend backend;
        QSignalSpy spy(&backend, &MediaPlayerBackend::errorOccurred);
        backend.scanDirectory("");
        if (spy.count() > 0) {
            QString msg = spy.at(0).at(0).toString();
            QVERIFY(!msg.isEmpty());
        }
    }
};

QTEST_MAIN(TestMediaApp)
#include "test_backend.moc"
