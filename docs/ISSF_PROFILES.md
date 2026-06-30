# ISSF Event Profiles

Profiles are defined in `eventprofile.cpp` and selected via `MatchSession::selectProfileByIndex()`.

## Supported disciplines (50 m rifle)

| Index | ID | Code | Shots | Prep | Match | Scoring |
|-------|-----|------|-------|------|-------|---------|
| 0 | RifleProneMatch | ISSF50RPR | 60 P | 15 min | 50 min | Decimal |
| 1 | RifleProneTraining | TRAIN50RPR | 60 P | 15 min | 60 min | Decimal (flex) |
| 2 | Rifle3PQualificationOutdoor | ISSF50R3POUT | 20K+20P+20S | 15 min | 105 min | **Integer** |
| 3 | Rifle3PQualificationIndoor | *(alias → Outdoor)* | — | — | — | — |
| 4 | Rifle3PFinal | ISSF50R3PFINAL | 10K+10P+15S | 5 min | 22 min | Decimal |
| 5 | Rifle3PTraining | TRAIN50R3P | 20K+20P+20S | 15 min | 120 min | Integer (flex) |

## Phase machine (`MatchSession::Phase`)

```
Setup
  → PreparationAndSighting (unlimited sighters)
  → Interlock (Ready for Match)
  → KneelingMatch (3P only)
  → ProneChangeoverSighting
  → ProneMatch
  → StandingChangeoverSighting (3P only)
  → StandingMatch
  → Completed
```

Prone-only events skip kneeling/standing phases and go Interlock → ProneMatch → Completed.

## Scoring format enforcement

- **Decimal** (match / final / prone): one decimal place via `MatchSession::formatScoreText()`
- **Integer** (3P qualification): `floor(decimalScore)` per shot; totals use `integerScore`

QML should use `MATCHSESSION.decimalScoring` — not global `APPSETTINGS.getScoringSystem()` — for event-aware display.

## Compliance notes

| Rule | Status |
|------|--------|
| 60 prone competition shots | Implemented |
| 3P 20+20+20 qualification | Implemented |
| Single 105 min match clock (3P qual) | Timer in QML; verify on lane |
| Integer qualification scoring | Enforced in MatchSession + reports |
| 3P Final elimination format | **Not implemented** — current profile is simplified 35-shot K/P/S |
| Prep timer auto-advance to match | Moves to **Interlock** on expiry; athlete presses Start |
| Match end authority | `MatchSession.completed` + `canAcceptIncomingShot()` |

## 3P Final (profile 4)

The application runs a **simplified** 10+10+15 decimal final suitable for training and range use.
Full ISSF CRO elimination workflow (ranking, series elimination) is planned for a later phase.

## Validation tests

- `tests/eventprofile_test.cpp` — static profile fields
- `tests/matchsession_test.cpp` — phase transitions, final flow, integer formatting
