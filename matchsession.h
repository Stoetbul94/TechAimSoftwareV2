#ifndef MATCHSESSION_H
#define MATCHSESSION_H

#include "eventprofile.h"

#include <QDateTime>
#include <QObject>
#include <QTimer>
#include <QVariantMap>
#include <QVariantList>
#include <QVector>

struct SessionShot
{
    int sequence = 0;
    QString phase;
    QString position;
    bool sighter = false;
    int positionShotNumber = 0;
    int matchShotNumber = 0;
    double x = 0.0;
    double y = 0.0;
    double decimalScore = 0.0;
    int integerScore = 0;
    int elapsedSeconds = 0;
    QString timestamp;
};

class MatchSession : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString eventName READ eventName NOTIFY profileChanged)
    Q_PROPERTY(QString eventCode READ eventCode NOTIFY profileChanged)
    Q_PROPERTY(QString shotPlan READ shotPlan NOTIFY profileChanged)
    Q_PROPERTY(QString scoringName READ scoringName NOTIFY profileChanged)
    Q_PROPERTY(bool decimalScoring READ decimalScoring NOTIFY profileChanged)
    Q_PROPERTY(int preparationSeconds READ preparationSeconds NOTIFY profileChanged)
    Q_PROPERTY(int matchSeconds READ matchSeconds NOTIFY profileChanged)
    Q_PROPERTY(int configuredMatchShots READ configuredMatchShots NOTIFY profileChanged)
    Q_PROPERTY(int kneelingShotLimit READ kneelingShotLimit NOTIFY profileChanged)
    Q_PROPERTY(int proneShotLimit READ proneShotLimit NOTIFY profileChanged)
    Q_PROPERTY(int standingShotLimit READ standingShotLimit NOTIFY profileChanged)
    Q_PROPERTY(QString phaseName READ phaseName NOTIFY phaseChanged)
    Q_PROPERTY(QString positionName READ positionName NOTIFY phaseChanged)
    Q_PROPERTY(bool sighterMode READ sighterMode NOTIFY phaseChanged)
    Q_PROPERTY(int totalMatchShots READ totalMatchShots NOTIFY shotCountChanged)
    Q_PROPERTY(int positionMatchShots READ positionMatchShots NOTIFY shotCountChanged)
    Q_PROPERTY(int storedShotCount READ storedShotCount NOTIFY shotStored)
    Q_PROPERTY(int preparationElapsed READ preparationElapsed NOTIFY clockStateChanged)
    Q_PROPERTY(int matchElapsed READ matchElapsed NOTIFY clockStateChanged)
    Q_PROPERTY(int matchRemainingSeconds READ matchRemainingSeconds NOTIFY clockStateChanged)
    Q_PROPERTY(int preparationRemainingSeconds READ preparationRemainingSeconds NOTIFY clockStateChanged)
    Q_PROPERTY(QString matchClockText READ matchClockText NOTIFY clockStateChanged)
    Q_PROPERTY(QString preparationClockText READ preparationClockText NOTIFY clockStateChanged)
    Q_PROPERTY(bool usesOfficialTiming READ usesOfficialTiming NOTIFY profileChanged)
    Q_PROPERTY(bool completed READ completed NOTIFY phaseChanged)
    Q_PROPERTY(bool matchPhaseActive READ matchPhaseActive NOTIFY phaseChanged)
    Q_PROPERTY(int remainingMatchShots READ remainingMatchShots NOTIFY shotCountChanged)
    Q_PROPERTY(int remainingPositionShots READ remainingPositionShots NOTIFY shotCountChanged)

public:
    enum class Phase {
        Setup,
        PreparationAndSighting,
        Interlock,
        KneelingMatch,
        ProneChangeoverSighting,
        ProneMatch,
        StandingChangeoverSighting,
        StandingMatch,
        Completed
    };
    Q_ENUM(Phase)

    explicit MatchSession(QObject *parent = nullptr);

    void selectProfile(EventProfileId id);
    const EventProfile &profile() const;
    Phase phase() const;

    QString eventName() const;
    QString eventCode() const;
    QString shotPlan() const;
    QString scoringName() const;
    bool decimalScoring() const;
    Q_INVOKABLE double displayScoreValue(double decimalScore) const;
    Q_INVOKABLE QString formatScoreText(double decimalScore) const;
    int preparationSeconds() const;
    int matchSeconds() const;
    int configuredMatchShots() const;
    int kneelingShotLimit() const;
    int proneShotLimit() const;
    int standingShotLimit() const;
    QString phaseName() const;
    QString positionName() const;
    bool sighterMode() const;
    int totalMatchShots() const;
    int positionMatchShots() const;
    int storedShotCount() const;
    int preparationElapsed() const;
    int matchElapsed() const;
    int matchRemainingSeconds() const;
    int preparationRemainingSeconds() const;
    QString matchClockText() const;
    QString preparationClockText() const;
    bool usesOfficialTiming() const;
    Q_INVOKABLE QString formatClock(int totalSeconds) const;
    Q_INVOKABLE void setSessionClockActive(bool active);
    bool completed() const;
    bool matchPhaseActive() const;
    int remainingMatchShots() const;
    int remainingPositionShots() const;

    Q_INVOKABLE bool canAcceptIncomingShot(bool sighterUiMode) const;
    Q_INVOKABLE bool onPreparationTimerExpired();
    Q_INVOKABLE bool onMatchTimerExpired();

    Q_INVOKABLE bool startPreparation();
    Q_INVOKABLE void selectProfileByIndex(int index);
    Q_INVOKABLE bool configureTraining(int preparationMinutes,
                                       int matchMinutes,
                                       int proneShots,
                                       int kneelingShots = 0,
                                       int standingShots = 0);
    Q_INVOKABLE bool finishPreparation();
    Q_INVOKABLE bool startMatch();
    Q_INVOKABLE bool expireMatch();
    Q_INVOKABLE bool recordMatchShot();
    Q_INVOKABLE bool recordShot(double x,
                                double y,
                                double decimalScore,
                                int elapsedSeconds,
                                const QString &timestamp);
    Q_INVOKABLE QVariantList shotRecords() const;
    Q_INVOKABLE int shotCountFor(const QString &position, bool sighters) const;
    Q_INVOKABLE double scoreTotalFor(const QString &position) const;
    Q_INVOKABLE int integerTotalFor(const QString &position) const;
    Q_INVOKABLE QVariantList matchShotsFor(const QString &position) const;
    Q_INVOKABLE QVariantMap positionSummary(const QString &position) const;
    Q_INVOKABLE QVariantList positionSummaries() const;
    Q_INVOKABLE QVariantList seriesSummaries(const QString &position) const;
    Q_INVOKABLE QString sessionJson() const;
    Q_INVOKABLE bool restoreSessionJson(const QString &json);
    Q_INVOKABLE void setPreparationElapsed(int seconds);
    Q_INVOKABLE void setMatchElapsed(int seconds);
    Q_INVOKABLE void reset();
    Q_INVOKABLE void reassertCatalogTiming();

signals:
    void profileChanged();
    void phaseChanged();
    void shotCountChanged();
    void eventCompleted();
    void shotStored();
    void clockStateChanged();
    void commandRejected(const QString &reason);
    void preparationExpired();
    void autosaveRequested();

private:
    void setPhase(Phase phase);
    int positionShotLimit() const;
    int catalogMatchSeconds() const;
    int catalogPreparationSeconds() const;
    int effectiveMatchSeconds() const;
    int effectivePreparationSeconds() const;
    void updateClockTimer();
    void onClockTick();

    EventProfile m_profile;
    Phase m_phase = Phase::Setup;
    int m_totalMatchShots = 0;
    int m_positionMatchShots = 0;
    QVector<SessionShot> m_shots;
    int m_preparationElapsed = 0;
    int m_matchElapsed = 0;
    QTimer m_clock;
    bool m_sessionClockActive = false;
};

#endif // MATCHSESSION_H
