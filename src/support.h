#ifndef SUPPORT_H
#define SUPPORT_H

#include <QObject>
#include <QDBusConnection>
#include <QDBusInterface>

class Support : public QObject
{
    Q_OBJECT
public:
    explicit Support(QObject *parent = 0);

    Q_INVOKABLE void setBlankingMode(bool state);

signals:

public slots:
};

#endif // SUPPORT_H
