QT += core
CONFIG += console c++17
CONFIG -= app_bundle

TARGET = eventprofile_test
TEMPLATE = app

SOURCES += \
    eventprofile_test.cpp \
    ../eventprofile.cpp

HEADERS += \
    ../eventprofile.h
