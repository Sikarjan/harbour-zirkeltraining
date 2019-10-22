#ifndef AUDIOPLAYER_H
#define AUDIOPLAYER_H

#include <QtMultimedia/QMediaPlaylist>
#include <QtMultimedia/QMediaPlayer>
#include <QFile>
#include <QTextStream>
#include <QTime>
#include <QDebug>
#include <QDir>

class AudioPlayer : public QObject
{
    Q_OBJECT

public:
    Q_PROPERTY(QString source READ source WRITE setSource)
    explicit AudioPlayer(QObject *parent = 0);

    QString source() { return mSource; }
    Q_INVOKABLE bool setSource(const QString &source);

public slots:
    int play();
    void pause();
    void stop();
    void next();
    void shuffle();

private:
    QMediaPlaylist *playlist;
    QMediaPlayer *player;
    QString mSource;

};

#endif // AUDIOPLAYER_H
