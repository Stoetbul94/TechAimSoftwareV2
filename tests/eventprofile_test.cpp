#include "../eventprofile.h"

#include <QCoreApplication>

namespace {

bool expectProfile(const EventProfile &profile,
                   EventProfileId id,
                   const char *code,
                   int prepMinutes,
                   int matchMinutes,
                   int kneeling,
                   int prone,
                   int standing,
                   ScoreFormat format,
                   bool strictMatch,
                   bool trainingMode,
                   bool threePosition,
                   bool finalEvent)
{
    if (profile.id != id)
        return false;
    if (profile.code != QLatin1String(code))
        return false;
    if (profile.preparationSightingSeconds != prepMinutes * 60)
        return false;
    if (profile.matchSeconds != matchMinutes * 60)
        return false;
    if (profile.kneelingShots != kneeling)
        return false;
    if (profile.proneShots != prone)
        return false;
    if (profile.standingShots != standing)
        return false;
    if (profile.scoreFormat != format)
        return false;
    if (profile.strictMatch != strictMatch)
        return false;
    if (profile.trainingMode != trainingMode)
        return false;
    if (profile.threePosition != threePosition)
        return false;
    if (profile.finalEvent != finalEvent)
        return false;
    return profile.totalMatchShots() == kneeling + prone + standing;
}

}

int main(int argc, char *argv[])
{
    QCoreApplication app(argc, argv);

    const EventProfile proneMatch =
            EventProfile::create(EventProfileId::RifleProneMatch);
    if (!expectProfile(proneMatch,
                       EventProfileId::RifleProneMatch,
                       "ISSF50RPR",
                       15, 50,
                       0, 60, 0,
                       ScoreFormat::Decimal,
                       true, false, false, false))
        return 1;

    const EventProfile proneTraining =
            EventProfile::create(EventProfileId::RifleProneTraining);
    if (!expectProfile(proneTraining,
                       EventProfileId::RifleProneTraining,
                       "TRAIN50RPR",
                       15, 60,
                       0, 60, 0,
                       ScoreFormat::Decimal,
                       false, true, false, false))
        return 2;

    const EventProfile outdoor =
            EventProfile::create(EventProfileId::Rifle3PQualificationOutdoor);
    if (!expectProfile(outdoor,
                       EventProfileId::Rifle3PQualificationOutdoor,
                       "ISSF50R3POUT",
                       15, 105,
                       20, 20, 20,
                       ScoreFormat::Integer,
                       true, false, true, false))
        return 3;

    const EventProfile indoorAlias =
            EventProfile::create(EventProfileId::Rifle3PQualificationIndoor);
    if (indoorAlias.code != outdoor.code
            || indoorAlias.totalMatchShots() != outdoor.totalMatchShots())
        return 4;

    const EventProfile finalEvent =
            EventProfile::create(EventProfileId::Rifle3PFinal);
    if (!expectProfile(finalEvent,
                       EventProfileId::Rifle3PFinal,
                       "ISSF50R3PFINAL",
                       5, 22,
                       10, 10, 15,
                       ScoreFormat::Decimal,
                       true, false, true, true))
        return 5;

    const EventProfile training3p =
            EventProfile::create(EventProfileId::Rifle3PTraining);
    if (!expectProfile(training3p,
                       EventProfileId::Rifle3PTraining,
                       "TRAIN50R3P",
                       15, 120,
                       20, 20, 20,
                       ScoreFormat::Integer,
                       false, true, true, false))
        return 6;

    return 0;
}
