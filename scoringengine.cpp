#include "scoringengine.h"
#include "targetgeometry.h"

#include <QtMath>

ScoringEngine::ScoringEngine(QObject *parent)
    : QObject(parent)
{
}

double ScoringEngine::calculateScore(double x,
                                     double y,
                                     int rangeMeters,
                                     bool pistol,
                                     double projectileDiameter) const
{
    const TargetRingDimensions target =
            TargetGeometry::ringDimensions(rangeMeters, pistol);
    const double projectileRadius = qMax(0.0, projectileDiameter) / 2.0;
    const double impactRadius = qSqrt((x * x) + (y * y));
    const double outerTenBoundary =
            target.ringSpacingMm + target.tenRingRadiusMm + projectileRadius;

    double score = 9.0
            + ((outerTenBoundary - impactRadius) / target.ringSpacingMm);

    if (score < 1.0)
        return 0.0;
    if (score >= 11.0)
        return 10.9;

    return score;
}
