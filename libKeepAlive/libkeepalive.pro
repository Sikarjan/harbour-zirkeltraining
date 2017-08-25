# -*- mode: sh -*-

TEMPLATE   = lib
TARGET     = keepalive
TARGET     = $$qtLibraryTarget($$TARGET)
target.path = /usr/share/harbour-zirkeltraining/lib

QT        += dbus
QT        -= gui
CONFIG    += qt debug link_pkgconfig

system(qdbusxml2cpp -p mceiface.h:mceiface.cpp mceiface.xml)

SOURCES += \
    displayblanking.cpp \
    displayblanking_p.cpp \
    backgroundactivity.cpp \
    backgroundactivity_p.cpp \
    mceiface.cpp \
    heartbeat.cpp

PUBLIC_HEADERS += \
    displayblanking.h \
    backgroundactivity.h

PRIVATE_HEADERS += \
    displayblanking_p.h \
    mceiface.h \
    heartbeat.h \
    backgroundactivity_p.h \
    common.h \
    libiphb/libiphb.h \
    libiphb/iphb_internal.h \
    libiphb/messages.h

HEADERS += $$PUBLIC_HEADERS $$PRIVATE_HEADERS

QMAKE_PKGCONFIG_NAME        = lib$$TARGET
QMAKE_PKGCONFIG_DESCRIPTION = Nemomobile cpu/display keepalive development files
QMAKE_PKGCONFIG_LIBDIR      = $$target.path
QMAKE_PKGCONFIG_INCDIR      = $$develheaders.path
QMAKE_PKGCONFIG_DESTDIR     = pkgconfig
QMAKE_PKGCONFIG_REQUIRES    = Qt5Core Qt5DBus

INSTALLS += target
