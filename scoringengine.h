#ifndef SCORINGENGINE_H
#define SCORINGENGINE_H

#include <QObject>

class ScoringEngine : public QObject
{
    Q_OBJECT

public:
    explicit ScoringEngine(QObject *parent = nullptr);

    Q_INVOKABLE double calculateScore(double x,
                                      double y,
                                      int rangeMeters,
                                      bool pistol,
                                      double projectileDiameter) const;
};

#endif // SCORINGENGINE_H
