#include "zt.h"

ZT::ZT(QObject *parent) :
    QObject(parent){

    QProcess app;
    app.start("/bin/rpm", QStringList() << "-qa" << "--queryformat" << "%{version}" << "harbour-zirkeltraining");
    app.waitForFinished(-1);
    if (app.bytesAvailable() > 0) {
        appVersion = app.readAll();
    }
}

QString ZT::version() const {
    return appVersion;
}
