# TechAim Electronic Target — Architecture

## Overview

Windows desktop application (Qt 5/6, QML, C++) for TechAim electronic rifle targets at 50 m.
Hardware communication must remain stable during refactors.

## Startup (`main.cpp`)

1. Message handler → `%TEMP%/techaim_qt_runtime.log`
2. High-DPI + optional software QSG renderer (`OPEN_GL` in `defines.h`)
3. Single instance via `QLockFile`
4. `AppSettings` loads `config.ini` from application directory
5. `ModbusAdapter` + hidden `MainWindow` host Modbus I/O
6. `TachusWidget` (exposed as `MODREADER`) wraps hardware + shot buffers
7. `QQmlApplicationEngine` loads `qrc:/main.qml`

## QML context properties

| Property | C++ type | Role |
|----------|----------|------|
| `MODREADER` | `TachusWidget` | Modbus, shots, motor, demo mode |
| `APPSETTINGS` | `AppSettings` | Config, save/load, branding |
| `MATCHSESSION` | `MatchSession` | Event profile, phase FSM, shot ledger |
| `SCORINGENGINE` | `ScoringEngine` | mm-based ring scoring |
| `TARGETGEOMETRY` | `TargetGeometryService` | Face sizes, mm↔pixel mapping |
| `CUSTOMPRINT` | `CustomPrint` | PDF export |

## Session flow

```
ModernLoginPage → MATCHSESSION.selectProfile + startPreparation
               → ShootingPage.configureFromMatchSession
               → CenterPane timers + MODREADER shot events
               → MATCHSESSION.canAcceptIncomingShot() gate
               → MATCHSESSION.recordShot
               → AppSettings.saveMatch (.tch XML + session_json)
```

### Timer authority (Phase 2)

| Timer | Runs when | On expiry |
|-------|-----------|-----------|
| `sighterTimer` | `Preparation and Sighting` | `onPreparationTimerExpired()` → Interlock; athlete presses Start |
| `gameTimer` | All other active phases except Setup/Completed | `onMatchTimerExpired()` → Completed |

Shot acceptance is governed by `MatchSession.canAcceptIncomingShot(sighterUiMode)`, not legacy `globalModelOfData.count`.

## Layer boundaries

- **Do not refactor** Modbus register addresses (`targethardwaremap.h`) or `TachusWidget` public slots used from QML without lane testing.
- **Prefer** extending `MatchSession` and `EventProfile` over adding logic to QML globals.

## Key files

| Layer | Files |
|-------|-------|
| UI | `main.qml`, `ModernLoginPage.qml`, `ShootingPage.qml`, `CenterPane.qml` |
| Session | `eventprofile.*`, `matchsession.*` |
| Settings | `appsettings.*`, `config.ini` |
| Hardware | `ModReader/forms/tachuswidget.*`, `targethardwaremap.h` |
| Reports | `ModernMatchReport.qml`, `customprint.*` |

## Tests

```bash
cd tests && qmake matchsession_test.pro && make && ./matchsession_test
cd tests && qmake eventprofile_test.pro && make && ./eventprofile_test
cd tests && qmake scoringengine_test.pro && make && ./scoringengine_test
```
