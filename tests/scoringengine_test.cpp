#include "../scoringengine.h"

#include <QCoreApplication>
#include <QtMath>

namespace {

bool approximatelyEqual(double actual, double expected)
{
    return qAbs(actual - expected) < 0.0001;
}

}

int main(int argc, char *argv[])
{
    QCoreApplication app(argc, argv);
    ScoringEngine scoring;

    if (!approximatelyEqual(
                scoring.calculateScore(0, 0, 10, true, 4.5), 10.9))
        return 1;

    if (!approximatelyEqual(
                scoring.calculateScore(16, 0, 10, true, 4.5), 9.0))
        return 2;

    if (!approximatelyEqual(
                scoring.calculateScore(5, 0, 10, false, 4.5), 9.0))
        return 3;

    if (!approximatelyEqual(
                scoring.calculateScore(16, 0, 50, false, 5.6), 9.0))
        return 4;

    if (!approximatelyEqual(
                scoring.calculateScore(200, 0, 10, true, 4.5), 0.0))
        return 5;

    return 0;
}
