#include "preventsleep.h"

PreventSleep::PreventSleep(QObject *parent) :
    QObject(parent){
    dbm_blankpause_start = QDBusMessage::createMethodCall("com.nokia.mce",
                                                          "/com/nokia/mce/request",
                                                          "com.nokia.mce.request",
                                                          "req_display_blanking_pause");

    dbm_blankpause_cancel = QDBusMessage::createMethodCall("com.nokia.mce",
                                                           "/com/nokia/mce/request",
                                                           "com.nokia.mce.request",
                                                           "req_display_cancel_blanking_pause");
}

PreventSleep::~PreventSleep(){
    QDBusConnection::systemBus().send(dbm_blankpause_cancel);
}

void PreventSleep::stayUp(const bool &sleepState){
    if(sleepState)
        QDBusConnection::systemBus().send(dbm_blankpause_start);
    else
        QDBusConnection::systemBus().send(dbm_blankpause_cancel);
}
