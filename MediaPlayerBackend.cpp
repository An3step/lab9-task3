#include "MediaPlayerBackend.h"
#include <QDir>
#include <QStandardPaths>
#include <QSqlError>
#include <QSqlQuery>
#include <QDebug>
#include <QUrl>

MediaPlayerBackend::MediaPlayerBackend(QObject *parent) : QObject(parent)
{
    initDatabase();
}

MediaPlayerBackend::~MediaPlayerBackend()
{
    if (m_db.isOpen()) {
        m_db.close();
    }
}

QVariantList MediaPlayerBackend::playlist() const
{
    return m_playlist;
}

int MediaPlayerBackend::currentIndex() const
{
    return m_currentIndex;
}

void MediaPlayerBackend::setCurrentIndex(int index)
{
    if (m_currentIndex != index) {
        m_currentIndex = index;
        emit currentIndexChanged();
    }
}

void MediaPlayerBackend::scanDirectory(const QString &path)
{
    QString cleanPath = QUrl(path).toLocalFile();
    if (cleanPath.isEmpty()) cleanPath = path;

    QDir dir(cleanPath);
    if (!dir.exists()) {
        emit errorOccurred("Directory does not exist: " + cleanPath);
        return;
    }

    QStringList filters;
    filters << "*.mp3" << "*.wav" << "*.m4a" << "*.ogg";
    dir.setNameFilters(filters);

    m_playlist.clear();
    QFileInfoList list = dir.entryInfoList(QDir::Files);
    for (const QFileInfo &fileInfo : list) {
        QVariantMap track;
        track["title"] = fileInfo.baseName();
        track["artist"] = "Unknown Artist";
        track["path"] = QUrl::fromLocalFile(fileInfo.absoluteFilePath()).toString();
        track["cover"] = "qrc:/MediaApp/default_cover.png";
        m_playlist.append(track);
    }

    emit playlistChanged();
}

void MediaPlayerBackend::initDatabase()
{
    m_db = QSqlDatabase::addDatabase("QSQLITE");
    QString path = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir().mkpath(path);
    m_db.setDatabaseName(path + "/mediaplayer.db");

    if (!m_db.open()) {
        qCritical() << "Database error:" << m_db.lastError().text();
        return;
    }

    QSqlQuery query;
    if (!query.exec("CREATE TABLE IF NOT EXISTS favorites (id INTEGER PRIMARY KEY AUTOINCREMENT, path TEXT UNIQUE, title TEXT, artist TEXT)")) {
        qCritical() << "Table creation error:" << query.lastError().text();
    }
}

void MediaPlayerBackend::addToFavorites(int index)
{
    if (index < 0 || index >= m_playlist.size()) return;

    QVariantMap track = m_playlist[index].toMap();
    QSqlQuery query;
    query.prepare("INSERT OR IGNORE INTO favorites (path, title, artist) VALUES (?, ?, ?)");
    query.addBindValue(track["path"].toString());
    query.addBindValue(track["title"].toString());
    query.addBindValue(track["artist"].toString());

    if (!query.exec()) {
        qCritical() << "Insert error:" << query.lastError().text();
    }
}

void MediaPlayerBackend::loadFavorites()
{
    QSqlQuery query("SELECT path, title, artist FROM favorites");
    m_playlist.clear();
    while (query.next()) {
        QVariantMap track;
        track["path"] = query.value(0).toString();
        track["title"] = query.value(1).toString();
        track["artist"] = query.value(2).toString();
        track["cover"] = "qrc:/MediaApp/default_cover.png";
        m_playlist.append(track);
    }
    emit playlistChanged();
}
