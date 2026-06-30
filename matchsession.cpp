#include "matchsession.h"

#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QLineF>
#include <QtMath>

MatchSession::MatchSession(QObject *parent)
    : QObject(parent),
      m_profile(EventProfile::create(EventProfileId::RifleProneMatch))
{
    m_clock.setInterval(1000);
    connect(&m_clock, &QTimer::timeout, this, &MatchSession::onClockTick);
}

void MatchSession::selectProfile(EventProfileId id)
{
    m_profile = EventProfile::create(id);
    reset();
    reassertCatalogTiming();
    emit profileChanged();
}

const EventProfile &MatchSession::profile() const
{
    return m_profile;
}

MatchSession::Phase MatchSession::phase() const
{
    return m_phase;
}

QString MatchSession::eventName() const
{
    return m_profile.displayName;
}

QString MatchSession::eventCode() const
{
    return m_profile.code;
}

QString MatchSession::shotPlan() const
{
    if (m_profile.trainingMode && m_profile.threePosition)
        return QStringLiteral("%1 K + %2 P + %3 S")
                .arg(m_profile.kneelingShots)
                .arg(m_profile.proneShots)
                .arg(m_profile.standingShots);
    if (m_profile.trainingMode)
        return QStringLiteral("%1 shots").arg(m_profile.proneShots);
    if (m_profile.threePosition)
        return m_profile.finalEvent
                ? QStringLiteral("10 K + 10 P + 15 S")
                : QStringLiteral("20 K + 20 P + 20 S");
    return QStringLiteral("%1 shots").arg(m_profile.proneShots);
}

QString MatchSession::scoringName() const
{
    return m_profile.scoreFormat == ScoreFormat::Decimal
            ? QStringLiteral("Decimal") : QStringLiteral("Integer");
}

bool MatchSession::decimalScoring() const
{
    return m_profile.scoreFormat == ScoreFormat::Decimal;
}

double MatchSession::displayScoreValue(double decimalScore) const
{
    if (m_profile.scoreFormat == ScoreFormat::Integer)
        return qMax(0.0, static_cast<double>(qFloor(decimalScore)));

    const double rounded = qRound(decimalScore * 10.0) / 10.0;
    return qBound(0.0, rounded, 10.9);
}

QString MatchSession::formatScoreText(double decimalScore) const
{
    if (m_profile.scoreFormat == ScoreFormat::Integer)
        return QString::number(qMax(0, static_cast<int>(qFloor(decimalScore))));

    return QString::number(displayScoreValue(decimalScore), 'f', 1);
}

int MatchSession::preparationSeconds() const
{
    return effectivePreparationSeconds();
}

int MatchSession::matchSeconds() const
{
    return effectiveMatchSeconds();
}

int MatchSession::configuredMatchShots() const
{
    return m_profile.totalMatchShots();
}

int MatchSession::kneelingShotLimit() const
{
    return m_profile.kneelingShots;
}

int MatchSession::proneShotLimit() const
{
    return m_profile.proneShots;
}

int MatchSession::standingShotLimit() const
{
    return m_profile.standingShots;
}

QString MatchSession::phaseName() const
{
    switch (m_phase) {
    case Phase::Setup: return QStringLiteral("Setup");
    case Phase::PreparationAndSighting:
        return QStringLiteral("Preparation and Sighting");
    case Phase::Interlock: return QStringLiteral("Ready for Match");
    case Phase::KneelingMatch: return QStringLiteral("Kneeling Match");
    case Phase::ProneChangeoverSighting:
        return QStringLiteral("Prone Changeover / Sighting");
    case Phase::ProneMatch: return QStringLiteral("Prone Match");
    case Phase::StandingChangeoverSighting:
        return QStringLiteral("Standing Changeover / Sighting");
    case Phase::StandingMatch: return QStringLiteral("Standing Match");
    case Phase::Completed: return QStringLiteral("Completed");
    }
    return QString();
}

QString MatchSession::positionName() const
{
    switch (m_phase) {
    case Phase::KneelingMatch:
    case Phase::PreparationAndSighting:
        return m_profile.threePosition
                ? QStringLiteral("Kneeling") : QStringLiteral("Prone");
    case Phase::ProneChangeoverSighting:
    case Phase::ProneMatch:
        return QStringLiteral("Prone");
    case Phase::StandingChangeoverSighting:
    case Phase::StandingMatch:
        return QStringLiteral("Standing");
    default:
        return QString();
    }
}

bool MatchSession::sighterMode() const
{
    return m_phase == Phase::PreparationAndSighting
            || m_phase == Phase::ProneChangeoverSighting
            || m_phase == Phase::StandingChangeoverSighting;
}

int MatchSession::totalMatchShots() const
{
    return m_totalMatchShots;
}

int MatchSession::positionMatchShots() const
{
    return m_positionMatchShots;
}

int MatchSession::storedShotCount() const
{
    return m_shots.size();
}

int MatchSession::preparationElapsed() const
{
    return m_preparationElapsed;
}

int MatchSession::matchElapsed() const
{
    return m_matchElapsed;
}

int MatchSession::catalogMatchSeconds() const
{
    return EventProfile::create(m_profile.id).matchSeconds;
}

int MatchSession::catalogPreparationSeconds() const
{
    return EventProfile::create(m_profile.id).preparationSightingSeconds;
}

int MatchSession::effectiveMatchSeconds() const
{
    if (m_profile.trainingMode)
        return m_profile.matchSeconds;
    return catalogMatchSeconds();
}

int MatchSession::effectivePreparationSeconds() const
{
    if (m_profile.trainingMode)
        return m_profile.preparationSightingSeconds;
    return catalogPreparationSeconds();
}

int MatchSession::matchRemainingSeconds() const
{
    return qMax(0, effectiveMatchSeconds() - m_matchElapsed);
}

int MatchSession::preparationRemainingSeconds() const
{
    return qMax(0, effectivePreparationSeconds() - m_preparationElapsed);
}

QString MatchSession::formatClock(int totalSeconds) const
{
    const int minutes = totalSeconds / 60;
    const int seconds = totalSeconds % 60;
    return QStringLiteral("%1:%2")
            .arg(minutes, 2, 10, QChar('0'))
            .arg(seconds, 2, 10, QChar('0'));
}

QString MatchSession::matchClockText() const
{
    return formatClock(matchRemainingSeconds());
}

QString MatchSession::preparationClockText() const
{
    return formatClock(preparationRemainingSeconds());
}

bool MatchSession::usesOfficialTiming() const
{
    return !m_profile.trainingMode && effectiveMatchSeconds() > 0;
}

void MatchSession::setSessionClockActive(bool active)
{
    if (m_sessionClockActive == active)
        return;
    m_sessionClockActive = active;
    updateClockTimer();
}

void MatchSession::updateClockTimer()
{
    const bool prepRunning = m_phase == Phase::PreparationAndSighting;
    const bool matchRunning = matchPhaseActive()
            || m_phase == Phase::ProneChangeoverSighting
            || m_phase == Phase::StandingChangeoverSighting;
    const bool shouldRun = m_sessionClockActive && (prepRunning || matchRunning);

    if (shouldRun && !m_clock.isActive())
        m_clock.start();
    else if (!shouldRun && m_clock.isActive())
        m_clock.stop();
}

void MatchSession::onClockTick()
{
    if (m_phase == Phase::PreparationAndSighting) {
        if (m_preparationElapsed >= effectivePreparationSeconds()) {
            onPreparationTimerExpired();
            emit clockStateChanged();
            updateClockTimer();
            return;
        }

        setPreparationElapsed(m_preparationElapsed + 1);
        if (m_preparationElapsed % 10 == 0)
            emit autosaveRequested();
        return;
    }

    const bool matchClockPhase = matchPhaseActive()
            || m_phase == Phase::ProneChangeoverSighting
            || m_phase == Phase::StandingChangeoverSighting;
    if (!matchClockPhase)
        return;

    if (m_matchElapsed >= effectiveMatchSeconds()) {
        onMatchTimerExpired();
        emit clockStateChanged();
        updateClockTimer();
        return;
    }

    setMatchElapsed(m_matchElapsed + 1);
    if (m_matchElapsed % 10 == 0)
        emit autosaveRequested();
}

bool MatchSession::completed() const
{
    return m_phase == Phase::Completed;
}

bool MatchSession::matchPhaseActive() const
{
    switch (m_phase) {
    case Phase::KneelingMatch:
    case Phase::ProneMatch:
    case Phase::StandingMatch:
        return true;
    default:
        return false;
    }
}

int MatchSession::remainingMatchShots() const
{
    return qMax(0, configuredMatchShots() - m_totalMatchShots);
}

int MatchSession::remainingPositionShots() const
{
    const int limit = positionShotLimit();
    if (limit < 0)
        return 0;
    return qMax(0, limit - m_positionMatchShots);
}

bool MatchSession::canAcceptIncomingShot(bool sighterUiMode) const
{
    if (m_phase == Phase::Completed)
        return false;

    if (sighterUiMode)
        return sighterMode();

    if (positionShotLimit() < 0)
        return false;

    const bool enforcePlan = m_profile.strictMatch || m_profile.trainingMode;
    if (enforcePlan && m_positionMatchShots >= positionShotLimit())
        return false;

    return true;
}

bool MatchSession::onPreparationTimerExpired()
{
    if (m_phase != Phase::PreparationAndSighting)
        return false;

    if (!finishPreparation())
        return false;

    emit preparationExpired();
    return true;
}

bool MatchSession::onMatchTimerExpired()
{
    return expireMatch();
}

bool MatchSession::startPreparation()
{
    if (m_phase != Phase::Setup) {
        emit commandRejected(QStringLiteral("Preparation can only start from setup."));
        return false;
    }

    reassertCatalogTiming();
    setPhase(Phase::PreparationAndSighting);
    return true;
}

void MatchSession::selectProfileByIndex(int index)
{
    if (index == static_cast<int>(EventProfileId::Rifle3PQualificationIndoor))
        index = static_cast<int>(EventProfileId::Rifle3PQualificationOutdoor);

    if (index < static_cast<int>(EventProfileId::RifleProneMatch)
            || index > static_cast<int>(EventProfileId::Rifle3PTraining)) {
        emit commandRejected(QStringLiteral("Unknown event profile."));
        return;
    }

    selectProfile(static_cast<EventProfileId>(index));
}

bool MatchSession::configureTraining(int preparationMinutes,
                                     int matchMinutes,
                                     int proneShots,
                                     int kneelingShots,
                                     int standingShots)
{
    if (!m_profile.trainingMode) {
        emit commandRejected(QStringLiteral("The selected profile is not a training event."));
        return false;
    }
    if (preparationMinutes < 0 || preparationMinutes > 60
            || matchMinutes < 1 || matchMinutes > 480) {
        emit commandRejected(QStringLiteral("Training time is outside the allowed range."));
        return false;
    }

    if (m_profile.threePosition) {
        if (kneelingShots < 1 || proneShots < 1 || standingShots < 1
                || kneelingShots > 200 || proneShots > 200 || standingShots > 200) {
            emit commandRejected(QStringLiteral("Position shot counts must be between 1 and 200."));
            return false;
        }
        m_profile.kneelingShots = kneelingShots;
        m_profile.proneShots = proneShots;
        m_profile.standingShots = standingShots;
    } else {
        if (proneShots < 1 || proneShots > 300) {
            emit commandRejected(QStringLiteral("Training shots must be between 1 and 300."));
            return false;
        }
        m_profile.kneelingShots = 0;
        m_profile.proneShots = proneShots;
        m_profile.standingShots = 0;
    }

    m_profile.preparationSightingSeconds = preparationMinutes * 60;
    m_profile.matchSeconds = matchMinutes * 60;
    reset();
    emit profileChanged();
    return true;
}

bool MatchSession::finishPreparation()
{
    if (m_phase != Phase::PreparationAndSighting) {
        emit commandRejected(QStringLiteral("Preparation is not active."));
        return false;
    }

    setPhase(Phase::Interlock);
    return true;
}

bool MatchSession::startMatch()
{
    reassertCatalogTiming();

    switch (m_phase) {
    case Phase::Interlock:
        m_positionMatchShots = 0;
        setPhase(m_profile.threePosition
                 ? Phase::KneelingMatch : Phase::ProneMatch);
        return true;
    case Phase::ProneChangeoverSighting:
        m_positionMatchShots = 0;
        setPhase(Phase::ProneMatch);
        return true;
    case Phase::StandingChangeoverSighting:
        m_positionMatchShots = 0;
        setPhase(Phase::StandingMatch);
        return true;
    default:
        emit commandRejected(QStringLiteral("The current phase cannot start match firing."));
        return false;
    }
}

bool MatchSession::expireMatch()
{
    switch (m_phase) {
    case Phase::KneelingMatch:
    case Phase::ProneChangeoverSighting:
    case Phase::ProneMatch:
    case Phase::StandingChangeoverSighting:
    case Phase::StandingMatch:
        setPhase(Phase::Completed);
        return true;
    default:
        return false;
    }
}

bool MatchSession::recordMatchShot()
{
    const int limit = positionShotLimit();
    if (limit < 0) {
        emit commandRejected(QStringLiteral("The target is not in a match phase."));
        return false;
    }

    const bool enforcePlan = m_profile.strictMatch || m_profile.trainingMode;
    if (enforcePlan && m_positionMatchShots >= limit) {
        emit commandRejected(QStringLiteral("The position shot limit has been reached."));
        return false;
    }

    ++m_positionMatchShots;
    ++m_totalMatchShots;
    emit shotCountChanged();

    if (!enforcePlan || m_positionMatchShots < limit)
        return true;

    switch (m_phase) {
    case Phase::KneelingMatch:
        m_positionMatchShots = 0;
        setPhase(Phase::ProneChangeoverSighting);
        break;
    case Phase::ProneMatch:
        m_positionMatchShots = 0;
        if (m_profile.threePosition)
            setPhase(Phase::StandingChangeoverSighting);
        else
            setPhase(Phase::Completed);
        break;
    case Phase::StandingMatch:
        setPhase(Phase::Completed);
        break;
    default:
        break;
    }

    return true;
}

bool MatchSession::recordShot(double x,
                              double y,
                              double decimalScore,
                              int elapsedSeconds,
                              const QString &timestamp)
{
    const bool isSighter = sighterMode();
    if (!isSighter && positionShotLimit() < 0) {
        emit commandRejected(QStringLiteral("The current phase cannot accept a shot."));
        return false;
    }

    SessionShot shot;
    shot.sequence = m_shots.size() + 1;
    shot.phase = phaseName();
    shot.position = positionName();
    shot.sighter = isSighter;
    shot.positionShotNumber = isSighter
            ? shotCountFor(shot.position, true) + 1
            : m_positionMatchShots + 1;
    shot.matchShotNumber = isSighter ? 0 : m_totalMatchShots + 1;
    shot.x = x;
    shot.y = y;
    shot.decimalScore = decimalScore;
    shot.integerScore = qFloor(decimalScore);
    shot.elapsedSeconds = qMax(0, elapsedSeconds);
    shot.timestamp = timestamp.isEmpty()
            ? QDateTime::currentDateTime().toString(Qt::ISODate)
            : timestamp;
    m_shots.append(shot);
    emit shotStored();

    if (!isSighter && !recordMatchShot()) {
        m_shots.removeLast();
        emit shotStored();
        return false;
    }
    return true;
}

QVariantList MatchSession::shotRecords() const
{
    QVariantList result;
    for (const SessionShot &shot : m_shots) {
        QVariantMap value;
        value.insert(QStringLiteral("sequence"), shot.sequence);
        value.insert(QStringLiteral("phase"), shot.phase);
        value.insert(QStringLiteral("position"), shot.position);
        value.insert(QStringLiteral("sighter"), shot.sighter);
        value.insert(QStringLiteral("positionShotNumber"), shot.positionShotNumber);
        value.insert(QStringLiteral("matchShotNumber"), shot.matchShotNumber);
        value.insert(QStringLiteral("x"), shot.x);
        value.insert(QStringLiteral("y"), shot.y);
        value.insert(QStringLiteral("decimalScore"), shot.decimalScore);
        value.insert(QStringLiteral("integerScore"), shot.integerScore);
        value.insert(QStringLiteral("elapsedSeconds"), shot.elapsedSeconds);
        value.insert(QStringLiteral("timestamp"), shot.timestamp);
        result.append(value);
    }
    return result;
}

int MatchSession::shotCountFor(const QString &position, bool sighters) const
{
    int count = 0;
    for (const SessionShot &shot : m_shots) {
        if (shot.position.compare(position, Qt::CaseInsensitive) == 0
                && shot.sighter == sighters)
            ++count;
    }
    return count;
}

double MatchSession::scoreTotalFor(const QString &position) const
{
    double total = 0.0;
    for (const SessionShot &shot : m_shots) {
        if (!shot.sighter
                && (position.isEmpty()
                    || shot.position.compare(position, Qt::CaseInsensitive) == 0))
            total += shot.decimalScore;
    }
    return total;
}

int MatchSession::integerTotalFor(const QString &position) const
{
    int total = 0;
    for (const SessionShot &shot : m_shots) {
        if (!shot.sighter
                && (position.isEmpty()
                    || shot.position.compare(position, Qt::CaseInsensitive) == 0))
            total += shot.integerScore;
    }
    return total;
}

QVariantList MatchSession::matchShotsFor(const QString &position) const
{
    QVariantList result;
    for (const SessionShot &shot : m_shots) {
        if (shot.sighter
                || (!position.isEmpty()
                    && shot.position.compare(position, Qt::CaseInsensitive) != 0))
            continue;

        QVariantMap value;
        value.insert(QStringLiteral("sequence"), shot.sequence);
        value.insert(QStringLiteral("phase"), shot.phase);
        value.insert(QStringLiteral("position"), shot.position);
        value.insert(QStringLiteral("positionShotNumber"), shot.positionShotNumber);
        value.insert(QStringLiteral("matchShotNumber"), shot.matchShotNumber);
        value.insert(QStringLiteral("series"), (shot.positionShotNumber - 1) / 10 + 1);
        value.insert(QStringLiteral("shotInSeries"), (shot.positionShotNumber - 1) % 10 + 1);
        value.insert(QStringLiteral("x"), shot.x);
        value.insert(QStringLiteral("y"), shot.y);
        value.insert(QStringLiteral("decimalScore"), shot.decimalScore);
        value.insert(QStringLiteral("integerScore"), shot.integerScore);
        value.insert(QStringLiteral("elapsedSeconds"), shot.elapsedSeconds);
        value.insert(QStringLiteral("timestamp"), shot.timestamp);
        result.append(value);
    }
    return result;
}

QVariantMap MatchSession::positionSummary(const QString &position) const
{
    const QVariantList shots = matchShotsFor(position);
    QVariantMap summary;
    summary.insert(QStringLiteral("position"),
                   position.isEmpty() ? QStringLiteral("Match") : position);
    summary.insert(QStringLiteral("shots"), shots.size());
    summary.insert(QStringLiteral("decimalTotal"), scoreTotalFor(position));
    summary.insert(QStringLiteral("integerTotal"), integerTotalFor(position));

    double xTotal = 0.0;
    double yTotal = 0.0;
    int innerTens = 0;
    double group = 0.0;
    for (int i = 0; i < shots.size(); ++i) {
        const QVariantMap first = shots.at(i).toMap();
        xTotal += first.value(QStringLiteral("x")).toDouble();
        yTotal += first.value(QStringLiteral("y")).toDouble();
        if (first.value(QStringLiteral("decimalScore")).toDouble() >= 10.2)
            ++innerTens;
        for (int j = i + 1; j < shots.size(); ++j) {
            const QVariantMap second = shots.at(j).toMap();
            group = qMax(group,
                         QLineF(first.value(QStringLiteral("x")).toDouble(),
                                first.value(QStringLiteral("y")).toDouble(),
                                second.value(QStringLiteral("x")).toDouble(),
                                second.value(QStringLiteral("y")).toDouble()).length());
        }
    }

    summary.insert(QStringLiteral("mpiX"), shots.isEmpty() ? 0.0 : xTotal / shots.size());
    summary.insert(QStringLiteral("mpiY"), shots.isEmpty() ? 0.0 : yTotal / shots.size());
    summary.insert(QStringLiteral("group"), group);
    summary.insert(QStringLiteral("innerTens"), innerTens);
    return summary;
}

QVariantList MatchSession::positionSummaries() const
{
    QVariantList result;
    const QStringList positions = {
        QStringLiteral("Kneeling"),
        QStringLiteral("Prone"),
        QStringLiteral("Standing")
    };
    for (const QString &position : positions) {
        const QVariantMap summary = positionSummary(position);
        if (summary.value(QStringLiteral("shots")).toInt() > 0)
            result.append(summary);
    }
    return result;
}

QVariantList MatchSession::seriesSummaries(const QString &position) const
{
    const QVariantList shots = matchShotsFor(position);
    QVariantList result;
    for (int start = 0; start < shots.size(); start += 10) {
        const int end = qMin(start + 10, shots.size());
        double decimalTotal = 0.0;
        int integerTotal = 0;
        int elapsedTotal = 0;
        for (int i = start; i < end; ++i) {
            const QVariantMap shot = shots.at(i).toMap();
            decimalTotal += shot.value(QStringLiteral("decimalScore")).toDouble();
            integerTotal += shot.value(QStringLiteral("integerScore")).toInt();
            elapsedTotal += shot.value(QStringLiteral("elapsedSeconds")).toInt();
        }
        QVariantMap series;
        series.insert(QStringLiteral("series"), start / 10 + 1);
        series.insert(QStringLiteral("shots"), end - start);
        series.insert(QStringLiteral("decimalTotal"), decimalTotal);
        series.insert(QStringLiteral("integerTotal"), integerTotal);
        series.insert(QStringLiteral("elapsedSeconds"), elapsedTotal);
        result.append(series);
    }
    return result;
}

QString MatchSession::sessionJson() const
{
    QJsonObject root;
    root.insert(QStringLiteral("version"), 1);
    root.insert(QStringLiteral("profileId"), static_cast<int>(m_profile.id));
    root.insert(QStringLiteral("eventCode"), m_profile.code);
    root.insert(QStringLiteral("scoreFormat"),
                m_profile.scoreFormat == ScoreFormat::Decimal
                    ? QStringLiteral("decimal") : QStringLiteral("integer"));
    root.insert(QStringLiteral("preparationSeconds"), m_profile.preparationSightingSeconds);
    root.insert(QStringLiteral("matchSeconds"), m_profile.matchSeconds);
    root.insert(QStringLiteral("kneelingShots"), m_profile.kneelingShots);
    root.insert(QStringLiteral("proneShots"), m_profile.proneShots);
    root.insert(QStringLiteral("standingShots"), m_profile.standingShots);
    root.insert(QStringLiteral("phase"), static_cast<int>(m_phase));
    root.insert(QStringLiteral("totalMatchShots"), m_totalMatchShots);
    root.insert(QStringLiteral("positionMatchShots"), m_positionMatchShots);
    root.insert(QStringLiteral("preparationElapsed"), m_preparationElapsed);
    root.insert(QStringLiteral("matchElapsed"), m_matchElapsed);

    QJsonArray shots;
    for (const QVariant &value : shotRecords())
        shots.append(QJsonObject::fromVariantMap(value.toMap()));
    root.insert(QStringLiteral("shots"), shots);
    return QString::fromUtf8(QJsonDocument(root).toJson(QJsonDocument::Compact));
}

bool MatchSession::restoreSessionJson(const QString &json)
{
    const QJsonDocument document = QJsonDocument::fromJson(json.toUtf8());
    if (!document.isObject())
        return false;
    const QJsonObject root = document.object();
    int profileId = root.value(QStringLiteral("profileId")).toInt(-1);
    if (profileId == static_cast<int>(EventProfileId::Rifle3PQualificationIndoor))
        profileId = static_cast<int>(EventProfileId::Rifle3PQualificationOutdoor);
    if (profileId < static_cast<int>(EventProfileId::RifleProneMatch)
            || profileId > static_cast<int>(EventProfileId::Rifle3PTraining))
        return false;

    m_profile = EventProfile::create(static_cast<EventProfileId>(profileId));
    if (m_profile.trainingMode) {
        m_profile.preparationSightingSeconds =
                root.value(QStringLiteral("preparationSeconds"))
                .toInt(m_profile.preparationSightingSeconds);
        m_profile.matchSeconds =
                root.value(QStringLiteral("matchSeconds")).toInt(m_profile.matchSeconds);
        m_profile.kneelingShots =
                root.value(QStringLiteral("kneelingShots")).toInt(m_profile.kneelingShots);
        m_profile.proneShots =
                root.value(QStringLiteral("proneShots")).toInt(m_profile.proneShots);
        m_profile.standingShots =
                root.value(QStringLiteral("standingShots")).toInt(m_profile.standingShots);
    }
    m_phase = static_cast<Phase>(root.value(QStringLiteral("phase")).toInt(0));
    m_totalMatchShots = root.value(QStringLiteral("totalMatchShots")).toInt(0);
    m_positionMatchShots = root.value(QStringLiteral("positionMatchShots")).toInt(0);
    m_preparationElapsed = root.value(QStringLiteral("preparationElapsed")).toInt(0);
    m_matchElapsed = root.value(QStringLiteral("matchElapsed")).toInt(0);
    m_shots.clear();

    const QJsonArray shots = root.value(QStringLiteral("shots")).toArray();
    for (const QJsonValue &entry : shots) {
        const QJsonObject value = entry.toObject();
        SessionShot shot;
        shot.sequence = value.value(QStringLiteral("sequence")).toInt();
        shot.phase = value.value(QStringLiteral("phase")).toString();
        shot.position = value.value(QStringLiteral("position")).toString();
        shot.sighter = value.value(QStringLiteral("sighter")).toBool();
        shot.positionShotNumber =
                value.value(QStringLiteral("positionShotNumber")).toInt();
        shot.matchShotNumber = value.value(QStringLiteral("matchShotNumber")).toInt();
        shot.x = value.value(QStringLiteral("x")).toDouble();
        shot.y = value.value(QStringLiteral("y")).toDouble();
        shot.decimalScore = value.value(QStringLiteral("decimalScore")).toDouble();
        shot.integerScore = value.value(QStringLiteral("integerScore")).toInt();
        shot.elapsedSeconds = value.value(QStringLiteral("elapsedSeconds")).toInt();
        shot.timestamp = value.value(QStringLiteral("timestamp")).toString();
        m_shots.append(shot);
    }

    if (!m_profile.trainingMode)
        reassertCatalogTiming();

    emit profileChanged();
    emit phaseChanged();
    emit shotCountChanged();
    emit shotStored();
    emit clockStateChanged();
    return true;
}

void MatchSession::setPreparationElapsed(int seconds)
{
    const int bounded = qBound(0, seconds, effectivePreparationSeconds());
    if (m_preparationElapsed == bounded)
        return;
    m_preparationElapsed = bounded;
    emit clockStateChanged();
}

void MatchSession::setMatchElapsed(int seconds)
{
    const int bounded = qBound(0, seconds, effectiveMatchSeconds());
    if (m_matchElapsed == bounded)
        return;
    m_matchElapsed = bounded;
    emit clockStateChanged();
}

void MatchSession::reset()
{
    m_totalMatchShots = 0;
    m_positionMatchShots = 0;
    m_shots.clear();
    m_preparationElapsed = 0;
    m_matchElapsed = 0;
    setPhase(Phase::Setup);
    updateClockTimer();
    emit shotCountChanged();
    emit shotStored();
    emit clockStateChanged();
}

void MatchSession::reassertCatalogTiming()
{
    const EventProfile catalog = EventProfile::create(m_profile.id);
    if (m_profile.trainingMode)
        return;

    m_profile.preparationSightingSeconds = catalog.preparationSightingSeconds;
    m_profile.matchSeconds = catalog.matchSeconds;
    m_profile.kneelingShots = catalog.kneelingShots;
    m_profile.proneShots = catalog.proneShots;
    m_profile.standingShots = catalog.standingShots;
    m_profile.scoreFormat = catalog.scoreFormat;
    m_profile.strictMatch = catalog.strictMatch;
    m_profile.threePosition = catalog.threePosition;
    m_profile.finalEvent = catalog.finalEvent;
    emit profileChanged();
    emit clockStateChanged();
}

void MatchSession::setPhase(Phase phase)
{
    if (m_phase == phase)
        return;

    m_phase = phase;
    emit phaseChanged();
    updateClockTimer();
    if (m_phase == Phase::Completed)
        emit eventCompleted();
}

int MatchSession::positionShotLimit() const
{
    switch (m_phase) {
    case Phase::KneelingMatch: return m_profile.kneelingShots;
    case Phase::ProneMatch: return m_profile.proneShots;
    case Phase::StandingMatch: return m_profile.standingShots;
    default: return -1;
    }
}
