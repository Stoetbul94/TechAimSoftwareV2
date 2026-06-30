#include "../eventprofile.h"
#include "../matchsession.h"

#include <QCoreApplication>

namespace {

bool fireShots(MatchSession &session, int count)
{
    for (int shot = 0; shot < count; ++shot) {
        if (!session.recordMatchShot())
            return false;
    }
    return true;
}

}

int main(int argc, char *argv[])
{
    QCoreApplication app(argc, argv);

    const EventProfile prone =
            EventProfile::create(EventProfileId::RifleProneMatch);
    if (prone.preparationSightingSeconds != 900
            || prone.matchSeconds != 3000
            || prone.proneShots != 60
            || prone.scoreFormat != ScoreFormat::Decimal)
        return 1;

    const EventProfile outdoor =
            EventProfile::create(EventProfileId::Rifle3PQualificationOutdoor);
    if (outdoor.matchSeconds != 6300
            || outdoor.totalMatchShots() != 60
            || outdoor.scoreFormat != ScoreFormat::Integer)
        return 2;

    const EventProfile legacyIndoor =
            EventProfile::create(EventProfileId::Rifle3PQualificationIndoor);
    if (legacyIndoor.matchSeconds != 6300
            || legacyIndoor.code != QStringLiteral("ISSF50R3POUT"))
        return 3;

    MatchSession session;
    session.selectProfile(EventProfileId::Rifle3PQualificationOutdoor);
    if (!session.startPreparation()
            || session.phase() != MatchSession::Phase::PreparationAndSighting
            || !session.sighterMode())
        return 4;
    if (!session.finishPreparation()
            || !session.startMatch()
            || session.phase() != MatchSession::Phase::KneelingMatch)
        return 5;
    if (!fireShots(session, 20)
            || session.phase() != MatchSession::Phase::ProneChangeoverSighting
            || session.totalMatchShots() != 20)
        return 6;
    if (session.recordMatchShot())
        return 7;
    if (!session.startMatch()
            || !fireShots(session, 20)
            || session.phase() != MatchSession::Phase::StandingChangeoverSighting)
        return 8;
    if (!session.startMatch()
            || !fireShots(session, 20)
            || session.phase() != MatchSession::Phase::Completed
            || session.totalMatchShots() != 60)
        return 9;
    if (session.recordMatchShot())
        return 10;

    MatchSession acceptance;
    acceptance.selectProfile(EventProfileId::RifleProneMatch);
    if (acceptance.canAcceptIncomingShot(true)
            || acceptance.canAcceptIncomingShot(false))
        return 50;
    if (!acceptance.startPreparation()
            || !acceptance.canAcceptIncomingShot(true)
            || acceptance.canAcceptIncomingShot(false))
        return 51;
    if (!acceptance.finishPreparation()
            || acceptance.canAcceptIncomingShot(true)
            || acceptance.canAcceptIncomingShot(false))
        return 52;
    if (!acceptance.startMatch()
            || acceptance.canAcceptIncomingShot(true)
            || !acceptance.canAcceptIncomingShot(false))
        return 53;
    if (acceptance.remainingMatchShots() != 60)
        return 54;

    MatchSession prepTimer;
    prepTimer.selectProfile(EventProfileId::RifleProneMatch);
    if (!prepTimer.startPreparation()
            || !prepTimer.onPreparationTimerExpired()
            || prepTimer.phase() != MatchSession::Phase::Interlock)
        return 55;
    if (prepTimer.canAcceptIncomingShot(true)
            || prepTimer.canAcceptIncomingShot(false))
        return 56;

    MatchSession timedSession;
    timedSession.selectProfile(EventProfileId::Rifle3PQualificationOutdoor);
    if (!timedSession.startPreparation()
            || !timedSession.finishPreparation()
            || !timedSession.startMatch()
            || !timedSession.expireMatch()
            || timedSession.phase() != MatchSession::Phase::Completed
            || timedSession.recordMatchShot())
        return 20;

    session.selectProfile(EventProfileId::RifleProneMatch);
    if (!session.startPreparation()
            || !session.finishPreparation()
            || !session.startMatch()
            || !fireShots(session, 60)
            || session.phase() != MatchSession::Phase::Completed)
        return 11;

    MatchSession finalSession;
    finalSession.selectProfile(EventProfileId::Rifle3PFinal);
    if (!finalSession.decimalScoring()
            || finalSession.formatScoreText(9.86) != QStringLiteral("9.9")
            || finalSession.formatScoreText(10.4) != QStringLiteral("10.4"))
        return 40;

    if (!finalSession.startPreparation()
            || !finalSession.finishPreparation()
            || !finalSession.startMatch()
            || finalSession.phase() != MatchSession::Phase::KneelingMatch)
        return 41;
    if (!fireShots(finalSession, 10)
            || finalSession.phase() != MatchSession::Phase::ProneChangeoverSighting)
        return 42;
    if (!finalSession.startMatch()
            || !fireShots(finalSession, 10)
            || finalSession.phase() != MatchSession::Phase::StandingChangeoverSighting)
        return 43;
    if (!finalSession.startMatch()
            || !fireShots(finalSession, 15)
            || finalSession.phase() != MatchSession::Phase::Completed
            || finalSession.totalMatchShots() != 35)
        return 44;

    MatchSession integerSession;
    integerSession.selectProfile(EventProfileId::Rifle3PQualificationOutdoor);
    if (integerSession.decimalScoring()
            || integerSession.formatScoreText(9.86) != QStringLiteral("9")
            || integerSession.displayScoreValue(10.4) != 10.0)
        return 45;

    session.selectProfile(EventProfileId::Rifle3PTraining);
    if (!session.configureTraining(7, 75, 12, 10, 14)
            || session.profile().preparationSightingSeconds != 420
            || session.profile().matchSeconds != 4500
            || session.profile().totalMatchShots() != 36)
        return 12;
    if (!session.startPreparation()
            || !session.finishPreparation()
            || !session.startMatch()
            || !fireShots(session, 10)
            || session.phase() != MatchSession::Phase::ProneChangeoverSighting)
        return 13;

    MatchSession ledger;
    ledger.selectProfile(EventProfileId::Rifle3PQualificationOutdoor);
    if (!ledger.startPreparation()
            || !ledger.recordShot(1.2, -0.7, 9.8, 4, "2026-06-21T10:00:00")
            || ledger.shotCountFor("Kneeling", true) != 1
            || !ledger.finishPreparation()
            || !ledger.startMatch())
        return 14;
    for (int shot = 0; shot < 20; ++shot) {
        if (!ledger.recordShot(shot, -shot, 9.5, shot + 1,
                               QStringLiteral("2026-06-21T10:01:%1")
                               .arg(shot, 2, 10, QLatin1Char('0'))))
            return 15;
    }
    if (ledger.phase() != MatchSession::Phase::ProneChangeoverSighting
            || ledger.shotCountFor("Kneeling", false) != 20
            || ledger.scoreTotalFor("Kneeling") < 189.9
            || ledger.storedShotCount() != 21)
        return 16;
    const QVariantMap kneelingSummary = ledger.positionSummary("Kneeling");
    const QVariantList kneelingSeries = ledger.seriesSummaries("Kneeling");
    if (ledger.matchShotsFor("Kneeling").size() != 20
            || kneelingSeries.size() != 2
            || qAbs(kneelingSummary.value("mpiX").toDouble() - 9.5) > 0.001
            || qAbs(kneelingSummary.value("mpiY").toDouble() + 9.5) > 0.001
            || kneelingSummary.value("group").toDouble() < 26.8
            || qAbs(kneelingSeries.at(0).toMap().value("decimalTotal").toDouble()
                    - 95.0) > 0.001)
        return 18;
    ledger.setMatchElapsed(456);
    if (!ledger.recordShot(2.5, -3.5, 9.7, 8,
                           QStringLiteral("2026-06-21T10:02:00"))
            || ledger.phase() != MatchSession::Phase::ProneChangeoverSighting
            || ledger.shotCountFor("Prone", true) != 1
            || ledger.totalMatchShots() != 20
            || ledger.matchElapsed() != 456)
        return 19;

    MatchSession restored;
    ledger.setPreparationElapsed(123);
    if (!restored.restoreSessionJson(ledger.sessionJson())
            || restored.phase() != MatchSession::Phase::ProneChangeoverSighting
            || restored.totalMatchShots() != 20
            || restored.shotCountFor("Kneeling", true) != 1
            || restored.shotCountFor("Kneeling", false) != 20
            || restored.storedShotCount() != 22
            || restored.preparationElapsed() != 123
            || restored.matchElapsed() != 456
            || restored.shotCountFor("Prone", true) != 1)
        return 17;

    for (int run = 0; run < 50; ++run) {
        MatchSession smoke;
        smoke.selectProfile(EventProfileId::Rifle3PQualificationOutdoor);
        if (!smoke.startPreparation())
            return 21;
        for (int shot = 0; shot < 4; ++shot) {
            if (!smoke.recordShot(shot + 0.1, shot + 0.2, 10.1,
                                  shot + 1, QString()))
                return 22;
        }
        if (!smoke.finishPreparation() || !smoke.startMatch())
            return 23;
        for (int shot = 0; shot < 20; ++shot) {
            if (!smoke.recordShot(shot * 0.2, -shot * 0.1, 9.5,
                                  shot + 1, QString()))
                return 24;
        }
        for (int shot = 0; shot < 5; ++shot) {
            if (!smoke.recordShot(shot + 1.5, -shot - 0.5, 9.9,
                                  shot + 1, QString()))
                return 25;
        }
        if (!smoke.startMatch())
            return 26;
        for (int shot = 0; shot < 20; ++shot) {
            if (!smoke.recordShot(-shot * 0.3, shot * 0.15, 9.6,
                                  shot + 1, QString()))
                return 27;
        }
        if (smoke.phase() != MatchSession::Phase::StandingChangeoverSighting)
            return 28;
        for (int shot = 0; shot < 8; ++shot) {
            if (!smoke.recordShot(shot + 2.25, shot - 3.75, 10.0,
                                  shot + 1, QString()))
                return 29;
        }
        if (smoke.shotCountFor("Standing", true) != 8
                || !smoke.startMatch()
                || smoke.phase() != MatchSession::Phase::StandingMatch)
            return 30;
        for (int shot = 0; shot < 20; ++shot) {
            if (!smoke.recordShot(shot - 6.0, 5.0 - shot, 9.4,
                                  shot + 1, QString()))
                return 31;
        }
        const QVariantMap standing = smoke.positionSummary("Standing");
        if (smoke.phase() != MatchSession::Phase::Completed
                || smoke.totalMatchShots() != 60
                || smoke.shotCountFor("Standing", false) != 20
                || standing.value("shots").toInt() != 20
                || qAbs(standing.value("mpiX").toDouble() - 3.5) > 0.001
                || qAbs(standing.value("mpiY").toDouble() + 4.5) > 0.001)
            return 32;
    }

    return 0;
}
