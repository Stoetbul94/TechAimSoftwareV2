QT += core
CONFIG += console c++17
CONFIG -= app_bundle

TARGET = targetgeometry_test
TEMPLATE = app

SOURCES += \
    targetgeometry_test.cpp \
    ../targetgeometry.cpp \
    ../scoringengine.cpp

HEADERS += \
    ../targetgeometry.h \
    ../scoringengine.h
