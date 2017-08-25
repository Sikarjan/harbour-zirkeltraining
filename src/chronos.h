#ifndef CHRONOS_H
#define CHRONOS_H

#include <QObject>
#include <QTime>
#include <QDebug>
#include "../keepalive/backgroundactivity.h"

class Chronos : public QObject
{
    Q_OBJECT
    
public:
    explicit Chronos(QObject *parent = 0);
    ~Chronos();
    BackgroundActivity *activity;
    Q_PROPERTY(bool running READ running WRITE setRunning NOTIFY runningChanged)
    Q_PROPERTY(bool pause READ pause WRITE setPause NOTIFY pauseChanged)
    Q_PROPERTY(bool keepAlive READ keepAlive WRITE setKeepAlive NOTIFY keepAliveChanged)

    Q_INVOKABLE int getTime();
    Q_INVOKABLE void setNewTime(int newTime);

    bool running() { return mRunning;}
    void setRunning(bool status);
    bool pause() { return paused;}
    void setPause(bool status);
    bool keepAlive() {return activity->isRunning(); }
    void setKeepAlive(bool running);
    
    int setTime;

signals:
    void runningChanged(bool status);
    void pauseChanged(bool status);
    void keepAliveChanged(bool status);

public slots:

private:
    QTime startTime;
    QTime pauseTime;
    bool mRunning;
    bool paused;
};

#endif // CHRONOS_H
