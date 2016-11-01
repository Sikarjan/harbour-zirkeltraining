# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
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

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n
TRANSLATIONS += translations/harbour-zirkeltraining-de.ts

HEADERS += \
    src/audioplayer.h \
    src/chronos.h \
    src/zt.h \
    src/support.h

RESOURCES += \
    resource.qrc

DISTFILES += \
    ../../BRKAubing/harbour-brkaubing/qml/js/storage.js

