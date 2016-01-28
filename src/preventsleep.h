#ifndef PREVENTSLEEP_H
#define PREVENTSLEEP_H

#include <QObject>
#include <QtDBus/QDBusConnection>
#include <QtDBus/QDBusMessage>
#include <QDebug>

class PreventSleep: public QObject
{
    Q_OBJECT

public:
    PreventSleep(QObject *parent = 0);
    ~PreventSleep();
    Q_INVOKABLE void stayUp(const bool &sleepState);
    QDBusMessage dbm_blankpause_start;
    QDBusMessage dbm_blankpause_cancel;
};

#endif // PREVENTSLEEP_H
