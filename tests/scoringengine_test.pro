QT += core
CONFIG += console c++17
CONFIG -= app_bundle

TARGET = scoringengine_test
TEMPLATE = app

SOURCES += \
    scoringengine_test.cpp \
    ../scoringengine.cpp \
    ../targetgeometry.cpp

HEADERS += \
    ../scoringengine.h \
    ../targetgeometry.h
