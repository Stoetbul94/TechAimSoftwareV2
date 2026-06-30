QT += core
CONFIG += console c++17
CONFIG -= app_bundle

TARGET = matchsession_test
TEMPLATE = app

SOURCES += \
    matchsession_test.cpp \
    ../eventprofile.cpp \
    ../matchsession.cpp

HEADERS += \
    ../eventprofile.h \
    ../matchsession.h
