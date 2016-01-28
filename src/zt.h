#ifndef ZT_H
#define ZT_H

#include <QObject>
#include <QProcess>

#include <QDebug>

class ZT : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString version READ version)

public:
    explicit ZT(QObject *parent = 0);

    QString version() const;

private:
    QString appVersion;
};

#endif // ZT_H
