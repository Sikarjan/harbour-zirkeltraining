#include "support.h"

Support::Support(QObject *parent) : QObject(parent){

}

/* Prevents screen going dark during video playback.
   true = no blanking
   false = blanks normally

   Found at  https://github.com/skvark/SailKino
*/
void Support::setBlankingMode(bool state)
{

    QDBusConnection system = QDBusConnection::connectToBus(QDBusConnection::SystemBus,
                                                           "system");

    QDBusInterface interface("com.nokia.mce",
                             "/com/nokia/mce/request",
                             "com.nokia.mce.request",
                             system);

    if (state) {
        interface.call(QLatin1String("req_display_blanking_pause"));
    } else {
        interface.call(QLatin1String("req_display_cancel_blanking_pause"));
    }

}
