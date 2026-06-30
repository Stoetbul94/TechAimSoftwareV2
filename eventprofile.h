#ifndef EVENTPROFILE_H
#define EVENTPROFILE_H

#include <QString>

enum class EventProfileId {
    RifleProneMatch,
    RifleProneTraining,
    Rifle3PQualificationOutdoor,
    Rifle3PQualificationIndoor,
    Rifle3PFinal,
    Rifle3PTraining
};

enum class ScoreFormat {
    Integer,
    Decimal
};

struct EventProfile
{
    EventProfileId id = EventProfileId::RifleProneMatch;
    QString code;
    QString displayName;
    bool strictMatch = true;
    bool trainingMode = false;
    bool threePosition = false;
    bool finalEvent = false;
    int preparationSightingSeconds = 0;
    int matchSeconds = 0;
    int kneelingShots = 0;
    int proneShots = 0;
    int standingShots = 0;
    ScoreFormat scoreFormat = ScoreFormat::Decimal;

    int totalMatchShots() const;

    static EventProfile create(EventProfileId id);
};

#endif // EVENTPROFILE_H
