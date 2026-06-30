#include "../targetgeometry.h"
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

    if (!approximatelyEqual(
                TargetGeometry::targetFaceMillimeters(50, false),
                TargetGeometry::kFace50mRifleMm))
        return 1;

    if (!approximatelyEqual(
                TargetGeometry::targetFaceMillimeters(10, true),
                TargetGeometry::kFace10mPistolMm))
        return 2;

    if (!approximatelyEqual(
                TargetGeometry::pixelsPerMillimeter(154.4, 50, false), 1.0))
        return 3;

    if (!approximatelyEqual(
                TargetGeometry::pelletDisplayRatio(50, false, 5.6),
                154.4 / 5.6))
        return 4;

    const QVariantMap mapped = TargetGeometry::mapHardwareToCanvas(
                10.0, -5.0, 154.4, 154.4, 50, false, 0.0);
    if (!approximatelyEqual(mapped.value(QStringLiteral("x")).toDouble(), 87.2)
            || !approximatelyEqual(mapped.value(QStringLiteral("y")).toDouble(), 82.2))
        return 5;

    const QVariantMap hardware = TargetGeometry::mapCanvasToHardware(
                mapped.value(QStringLiteral("x")).toDouble(),
                mapped.value(QStringLiteral("y")).toDouble(),
                154.4, 154.4, 50, false, 0.0);
    if (!approximatelyEqual(hardware.value(QStringLiteral("x")).toDouble(), 10.0)
            || !approximatelyEqual(hardware.value(QStringLiteral("y")).toDouble(), -5.0))
        return 6;

    if (!approximatelyEqual(
                TargetGeometry::mapCanvasRadiusToMillimeters(77.2, 154.4, 50, false),
                77.2))
        return 7;

    ScoringEngine scoring;
    if (!approximatelyEqual(
                scoring.calculateScore(0, 0, 50, false, 5.6), 10.9))
        return 8;

    TargetGeometryService service;
    if (!approximatelyEqual(
                service.targetFaceMillimeters(50, false),
                TargetGeometry::kFace50mRifleMm))
        return 9;

    return 0;
}
