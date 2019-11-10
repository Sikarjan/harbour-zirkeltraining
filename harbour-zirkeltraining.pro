TARGET = harbour-zirkeltraining

CONFIG += sailfishapp

QT += multimedia \
    dbus

PKGCONFIG += keepalive

SOURCES += src/harbour-zirkeltraining.cpp \
    src/audioplayer.cpp \
    src/chronos.cpp \
    src/zt.cpp

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
    qml/components/ActionButton.qml \
    qml/pages/Save.qml \
    qml/pages/Load.qml

SAILFISHAPP_ICONS = 86x86 108x108 128x128 172x172 256x256

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n
TRANSLATIONS += translations/harbour-zirkeltraining-de.ts

HEADERS += \
    src/audioplayer.h \
    src/chronos.h \
    src/zt.h

RESOURCES += \
    resource.qrc

DISTFILES += \
    qml/components/ButtonSlider.qml \
    qml/js/storage.js \
    qml/pages/ExercisePage.qml
