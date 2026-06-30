#include "targetgeometry.h"

#include <QtMath>

namespace TargetGeometry {

double targetFaceMillimeters(int rangeMeters, bool pistol)
{
    if (rangeMeters == 50)
        return pistol ? kFace50mPistolMm : kFace50mRifleMm;

    return pistol ? kFace10mPistolMm : kFace10mRifleMm;
}

TargetRingDimensions ringDimensions(int rangeMeters, bool pistol)
{
    if (rangeMeters == 50) {
        return pistol ? TargetRingDimensions{25.0, 25.0}
                      : TargetRingDimensions{8.0, 5.2};
    }

    return pistol ? TargetRingDimensions{8.0, 5.75}
                  : TargetRingDimensions{2.5, 0.25};
}

double pelletDisplayRatio(int rangeMeters, bool pistol, double projectileDiameterMm)
{
    const double diameter = qMax(0.001, projectileDiameterMm);
    return targetFaceMillimeters(rangeMeters, pistol) / diameter;
}

double pixelsPerMillimeter(double canvasSizePx, int rangeMeters, bool pistol)
{
    const double face = targetFaceMillimeters(rangeMeters, pistol);
    if (face <= 0.0 || canvasSizePx <= 0.0)
        return 0.0;
    return canvasSizePx / face;
}

double millimetersPerPixel(double canvasSizePx, int rangeMeters, bool pistol)
{
    const double ppm = pixelsPerMillimeter(canvasSizePx, rangeMeters, pistol);
    if (ppm <= 0.0)
        return 0.0;
    return 1.0 / ppm;
}

double pelletDiameterPixels(double canvasSizePx,
                            int rangeMeters,
                            bool pistol,
                            double projectileDiameterMm)
{
    const double ratio = pelletDisplayRatio(rangeMeters, pistol, projectileDiameterMm);
    if (ratio <= 0.0 || canvasSizePx <= 0.0)
        return 0.0;
    return canvasSizePx / ratio;
}

double mapCanvasRadiusToMillimeters(double canvasRadiusPx,
                                    double canvasSizePx,
                                    int rangeMeters,
                                    bool pistol)
{
    return canvasRadiusPx * millimetersPerPixel(canvasSizePx, rangeMeters, pistol);
}

QVariantMap mapHardwareToCanvas(double xMm,
                                double yMm,
                                double canvasWidthPx,
                                double canvasHeightPx,
                                int rangeMeters,
                                bool pistol,
                                double bulletOffsetMm)
{
    const double ppmX = pixelsPerMillimeter(canvasWidthPx, rangeMeters, pistol);
    const double ppmY = pixelsPerMillimeter(canvasHeightPx, rangeMeters, pistol);
    const double centerX = canvasWidthPx / 2.0;
    const double centerY = canvasHeightPx / 2.0;

    QVariantMap mapped;
    mapped.insert(QStringLiteral("x"), centerX + ((xMm + bulletOffsetMm) * ppmX));
    mapped.insert(QStringLiteral("y"), centerY - ((yMm + bulletOffsetMm) * ppmY));
    return mapped;
}

QVariantMap mapCanvasToHardware(double canvasX,
                                double canvasY,
                                double canvasWidthPx,
                                double canvasHeightPx,
                                int rangeMeters,
                                bool pistol,
                                double bulletOffsetMm)
{
    const double mppX = millimetersPerPixel(canvasWidthPx, rangeMeters, pistol);
    const double mppY = millimetersPerPixel(canvasHeightPx, rangeMeters, pistol);
    const double centerX = canvasWidthPx / 2.0;
    const double centerY = canvasHeightPx / 2.0;

    const double xMm = ((canvasX - centerX) * mppX) - bulletOffsetMm;
    const double yMm = ((centerY - canvasY) * mppY) - bulletOffsetMm;

    QVariantMap mapped;
    mapped.insert(QStringLiteral("x"), xMm);
    mapped.insert(QStringLiteral("y"), yMm);
    return mapped;
}

} // namespace TargetGeometry

TargetGeometryService::TargetGeometryService(QObject *parent)
    : QObject(parent)
{
}

double TargetGeometryService::targetFaceMillimeters(int rangeMeters, bool pistol) const
{
    return TargetGeometry::targetFaceMillimeters(rangeMeters, pistol);
}

double TargetGeometryService::ringSpacingMillimeters(int rangeMeters, bool pistol) const
{
    return TargetGeometry::ringDimensions(rangeMeters, pistol).ringSpacingMm;
}

double TargetGeometryService::tenRingRadiusMillimeters(int rangeMeters, bool pistol) const
{
    return TargetGeometry::ringDimensions(rangeMeters, pistol).tenRingRadiusMm;
}

double TargetGeometryService::pelletDisplayRatio(int rangeMeters,
                                                 bool pistol,
                                                 double projectileDiameterMm) const
{
    return TargetGeometry::pelletDisplayRatio(rangeMeters, pistol, projectileDiameterMm);
}

double TargetGeometryService::pixelsPerMillimeter(double canvasSizePx,
                                                  int rangeMeters,
                                                  bool pistol) const
{
    return TargetGeometry::pixelsPerMillimeter(canvasSizePx, rangeMeters, pistol);
}

double TargetGeometryService::millimetersPerPixel(double canvasSizePx,
                                                  int rangeMeters,
                                                  bool pistol) const
{
    return TargetGeometry::millimetersPerPixel(canvasSizePx, rangeMeters, pistol);
}

double TargetGeometryService::pelletDiameterPixels(double canvasSizePx,
                                                   int rangeMeters,
                                                   bool pistol,
                                                   double projectileDiameterMm) const
{
    return TargetGeometry::pelletDiameterPixels(canvasSizePx,
                                                rangeMeters,
                                                pistol,
                                                projectileDiameterMm);
}

double TargetGeometryService::mapCanvasRadiusToMillimeters(double canvasRadiusPx,
                                                           double canvasSizePx,
                                                           int rangeMeters,
                                                           bool pistol) const
{
    return TargetGeometry::mapCanvasRadiusToMillimeters(canvasRadiusPx,
                                                        canvasSizePx,
                                                        rangeMeters,
                                                        pistol);
}

QVariantMap TargetGeometryService::mapHardwareToCanvas(double xMm,
                                                       double yMm,
                                                       double canvasWidthPx,
                                                       double canvasHeightPx,
                                                       int rangeMeters,
                                                       bool pistol,
                                                       double bulletOffsetMm) const
{
    return TargetGeometry::mapHardwareToCanvas(xMm,
                                               yMm,
                                               canvasWidthPx,
                                               canvasHeightPx,
                                               rangeMeters,
                                               pistol,
                                               bulletOffsetMm);
}

QVariantMap TargetGeometryService::mapCanvasToHardware(double canvasX,
                                                       double canvasY,
                                                       double canvasWidthPx,
                                                       double canvasHeightPx,
                                                       int rangeMeters,
                                                       bool pistol,
                                                       double bulletOffsetMm) const
{
    return TargetGeometry::mapCanvasToHardware(canvasX,
                                               canvasY,
                                               canvasWidthPx,
                                               canvasHeightPx,
                                               rangeMeters,
                                               pistol,
                                               bulletOffsetMm);
}
