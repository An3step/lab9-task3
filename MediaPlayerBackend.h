#ifndef MEDIAPLAYERBACKEND_H
#define MEDIAPLAYERBACKEND_H

#include <QObject>
#include <QStringList>
#include <QVariantList>
#include <QSqlDatabase>

struct Track {
    QString title;
    QString artist;
    QString path;
    QString cover;
};

class MediaPlayerBackend : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVariantList playlist READ playlist NOTIFY playlistChanged)
    Q_PROPERTY(int currentIndex READ currentIndex WRITE setCurrentIndex NOTIFY currentIndexChanged)

public:
    explicit MediaPlayerBackend(QObject *parent = nullptr);
    ~MediaPlayerBackend();

    QVariantList playlist() const;
    int currentIndex() const;
    void setCurrentIndex(int index);

    Q_INVOKABLE void scanDirectory(const QString &path);
    Q_INVOKABLE void addToFavorites(int index);
    Q_INVOKABLE void loadFavorites();

signals:
    void playlistChanged();
    void currentIndexChanged();
    void errorOccurred(const QString &message);

private:
    void initDatabase();
    QVariantList m_playlist;
    int m_currentIndex = -1;
    QSqlDatabase m_db;
};

#endif // MEDIAPLAYERBACKEND_H
