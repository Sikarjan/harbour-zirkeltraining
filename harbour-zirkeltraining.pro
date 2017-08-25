TARGET = harbour-zirkeltraining

CONFIG += sailfishapp

QT += multimedia \
    dbus

SOURCES += src/harbour-zirkeltraining.cpp \
    src/audioplayer.cpp \
    src/chronos.cpp \
    src/zt.cpp \
    src/support.cpp

OTHER_FILES += qml/harbour-zirkeltraining.qml \
    qml/cover/CoverPage.qml \
    qml/pages/FirstPage.qml \
    rpm/harbour-zirkeltraining.changes.in \
    rpm/harbour-zirkeltraining.spec \
    rpm/harbour-zirkeltraining.yaml \
    translations/*.ts \
    harbour-zirkeltraining.desktop \
    qml/pages/CountdownPage.qml \
    qml/pages/AboutPage.qml \
    qml/pages/Settings.qml \
    qml/js/storage.js \
    qml/pages/Playlist.qml \
    qml/pages/ActionButton.qml \
    qml/pages/Save.qml \
    qml/pages/Load.qml

SAILFISHAPP_ICONS = 86x86 108x108 128x128 256x256

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n
TRANSLATIONS += translations/harbour-zirkeltraining-de.ts

HEADERS += \
    src/audioplayer.h \
    src/chronos.h \
    src/zt.h \
    src/support.h \
    libKeepAlive/backgroundactivity.h

RESOURCES += \
    resource.qrc

DISTFILES += \
    qml/js/storage.js \
    libKeepAlive/libkeepalive.so.1.0.0

# Including the pro file did not work. During rpm build an error occurrs that an unknown file could not be found.
# Therefore the keepAlive was packaged in a shared lib which is included below.
#TEMPLATE = subdirs
#SUBDIRS = libKeepAlive

INCLUDEPATH += $$PWD/libKeepAlive
QMAKE_RPATHDIR += /usr/share/harbour-zirkeltraining/lib
LIBS += -L$$PWD/libKeepAlive/ -lkeepalive

lib.files += libKeepAlive/libkeepalive.so.1.0.0
lib.path = /usr/share/harbour-zirkeltraining/lib

INSTALLS += lib
