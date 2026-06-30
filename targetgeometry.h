#ifndef TARGETGEOMETRY_H
#define TARGETGEOMETRY_H

#include <QObject>
#include <QVariantMap>

struct TargetRingDimensions
{
    double ringSpacingMm = 0.0;
    double tenRingRadiusMm = 0.0;
};

namespace TargetGeometry {

constexpr double kFace10mPistolMm = 155.5;
constexpr double kFace10mRifleMm = 45.5;
constexpr double kFace50mPistolMm = 500.0;
constexpr double kFace50mRifleMm = 154.4;

double targetFaceMillimeters(int rangeMeters, bool pistol);
TargetRingDimensions ringDimensions(int rangeMeters, bool pistol);
double pelletDisplayRatio(int rangeMeters, bool pistol, double projectileDiameterMm);
double pixelsPerMillimeter(double canvasSizePx, int rangeMeters, bool pistol);
double millimetersPerPixel(double canvasSizePx, int rangeMeters, bool pistol);
double pelletDiameterPixels(double canvasSizePx,
                            int rangeMeters,
                            bool pistol,
                            double projectileDiameterMm);
double mapCanvasRadiusToMillimeters(double canvasRadiusPx,
                                    double canvasSizePx,
                                    int rangeMeters,
                                    bool pistol);

QVariantMap mapHardwareToCanvas(double xMm,
                                double yMm,
                                double canvasWidthPx,
                                double canvasHeightPx,
                                int rangeMeters,
                                bool pistol,
                                double bulletOffsetMm = 0.0);

QVariantMap mapCanvasToHardware(double canvasX,
                                double canvasY,
                                double canvasWidthPx,
                                double canvasHeightPx,
                                int rangeMeters,
                                bool pistol,
                                double bulletOffsetMm = 0.0);

} // namespace TargetGeometry

class TargetGeometryService : public QObject
{
    Q_OBJECT

public:
    explicit TargetGeometryService(QObject *parent = nullptr);

    Q_INVOKABLE double targetFaceMillimeters(int rangeMeters, bool pistol) const;
    Q_INVOKABLE double ringSpacingMillimeters(int rangeMeters, bool pistol) const;
    Q_INVOKABLE double tenRingRadiusMillimeters(int rangeMeters, bool pistol) const;
    Q_INVOKABLE double pelletDisplayRatio(int rangeMeters,
                                          bool pistol,
                                          double projectileDiameterMm) const;
    Q_INVOKABLE double pixelsPerMillimeter(double canvasSizePx,
                                           int rangeMeters,
                                           bool pistol) const;
    Q_INVOKABLE double millimetersPerPixel(double canvasSizePx,
                                           int rangeMeters,
                                           bool pistol) const;
    Q_INVOKABLE double pelletDiameterPixels(double canvasSizePx,
                                            int rangeMeters,
                                            bool pistol,
                                            double projectileDiameterMm) const;
    Q_INVOKABLE double mapCanvasRadiusToMillimeters(double canvasRadiusPx,
                                                    double canvasSizePx,
                                                    int rangeMeters,
                                                    bool pistol) const;
    Q_INVOKABLE QVariantMap mapHardwareToCanvas(double xMm,
                                                double yMm,
                                                double canvasWidthPx,
                                                double canvasHeightPx,
                                                int rangeMeters,
                                                bool pistol,
                                                double bulletOffsetMm = 0.0) const;
    Q_INVOKABLE QVariantMap mapCanvasToHardware(double canvasX,
                                                double canvasY,
                                                double canvasWidthPx,
                                                double canvasHeightPx,
                                                int rangeMeters,
                                                bool pistol,
                                                double bulletOffsetMm = 0.0) const;
};

#endif // TARGETGEOMETRY_H
