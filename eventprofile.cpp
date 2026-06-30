#include "eventprofile.h"

int EventProfile::totalMatchShots() const
{
    return kneelingShots + proneShots + standingShots;
}

EventProfile EventProfile::create(EventProfileId id)
{
    EventProfile profile;
    profile.id = id;

    switch (id) {
    case EventProfileId::RifleProneMatch:
        profile.code = QStringLiteral("ISSF50RPR");
        profile.displayName = QStringLiteral("50 m Rifle Prone — ISSF Match");
        profile.preparationSightingSeconds = 15 * 60;
        profile.matchSeconds = 50 * 60;
        profile.proneShots = 60;
        profile.scoreFormat = ScoreFormat::Decimal;
        break;

    case EventProfileId::RifleProneTraining:
        profile = create(EventProfileId::RifleProneMatch);
        profile.id = id;
        profile.code = QStringLiteral("TRAIN50RPR");
        profile.displayName = QStringLiteral("50 m Rifle Prone — Training");
        profile.strictMatch = false;
        profile.trainingMode = true;
        profile.proneShots = 60;
        profile.matchSeconds = 60 * 60;
        break;

    case EventProfileId::Rifle3PQualificationOutdoor:
        profile.code = QStringLiteral("ISSF50R3POUT");
        profile.displayName =
                QStringLiteral("50 m Rifle 3 Positions Qualification — Outdoor");
        profile.threePosition = true;
        profile.preparationSightingSeconds = 15 * 60;
        profile.matchSeconds = 105 * 60;
        profile.kneelingShots = 20;
        profile.proneShots = 20;
        profile.standingShots = 20;
        profile.scoreFormat = ScoreFormat::Integer;
        break;

    case EventProfileId::Rifle3PQualificationIndoor:
        // TechAim does not offer an Indoor 3P qualification profile. Keep this
        // legacy enum value as a compatibility alias so old saved sessions that
        // stored profile id 3 still open as the supported Outdoor 3P event.
        profile = create(EventProfileId::Rifle3PQualificationOutdoor);
        break;

    case EventProfileId::Rifle3PFinal:
        profile.code = QStringLiteral("ISSF50R3PFINAL");
        profile.displayName = QStringLiteral("50 m Rifle 3 Positions Final");
        profile.threePosition = true;
        profile.finalEvent = true;
        profile.preparationSightingSeconds = 5 * 60;
        profile.matchSeconds = 22 * 60;
        profile.kneelingShots = 10;
        profile.proneShots = 10;
        profile.standingShots = 15;
        profile.scoreFormat = ScoreFormat::Decimal;
        break;

    case EventProfileId::Rifle3PTraining:
        profile = create(EventProfileId::Rifle3PQualificationOutdoor);
        profile.id = id;
        profile.code = QStringLiteral("TRAIN50R3P");
        profile.displayName = QStringLiteral("50 m Rifle 3 Positions — Training");
        profile.strictMatch = false;
        profile.trainingMode = true;
        profile.matchSeconds = 120 * 60;
        break;
    }

    return profile;
}
