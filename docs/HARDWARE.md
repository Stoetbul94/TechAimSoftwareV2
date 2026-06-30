# Hardware Integration

## Modbus stack

- `ModbusAdapter` — libmodbus communication
- `MainWindow` — read/write registers (not shown in QML UI)
- `TachusWidget` (`MODREADER`) — QML-facing facade

## Register map (`targethardwaremap.h`)

| Register | Address | Purpose |
|----------|---------|---------|
| HardwareStatusRegister | 0x1000 | Target status |
| ShotCountRegister | 0x2000 | Shot counter |
| ResetShotCountRegister | 0x2001 | Reset hardware buffer |
| PaperFeedControlRegister | 0x2004 | Motor / auto-feed mode |
| PaperFeedDurationRegister | 0x2005 | Feed duration (×10 ms) |
| PaperFeedRadiusRegister | 0x2006 | Feed radius (×0.1 mm) |
| FirstShotDataRegister | 16376 | Base of per-shot data block |
| RegistersPerShot | 8 | Stride per shot |

Shot data register: `FirstShotDataRegister + 8 * (shotNumber - 1)`

## Motor control

- `MotorThread` — writes PaperFeedControlRegister, polls until complete
- `intiateAutoMovementSetup()` / `intiateAutoMovementSighterSetup()` — auto paper feed after sighter period

## QML integration points (do not break)

- `MODREADER.getShootCount()` / `onShootCountChanged`
- `MODREADER.getXCord(n)` / `getYCord(n)` — coordinates in mm from target centre
- `MODREADER.uxShoot(x, y)` — demo mode injection
- `MODREADER.connectedModbus(port)` / `isModBusConnected()` / `isHardwareConnected()`
- `MODREADER.changeSighterMode(bool)` / `resetActiveShootBuffer()`
- `MODREADER.setCurrentMatchTotalShotsCount(n)`

## Demo vs live

- `config.ini` → `app_mode=Demo|Live`
- Demo: canvas clicks call `uxShoot`; start screen skips hardware checks
- Live: Modbus COM port required; reconnection via `onHardwareDisconnected` / `attemptReconnection()`

## Legacy SETA / network

- `ReceiverTachus` — UDP port 7756 (TCMA broadcast)
- CSV status files under SETA server path (`AppSettings` file watcher)
- Lane feedback: `{lane}_feedbackFile.csv`

## Refactor rules

1. Never change register addresses without hardware team sign-off.
2. Keep shot coordinate units in **millimetres** end-to-end.
3. Test every hardware-touching change on a live lane before release.
