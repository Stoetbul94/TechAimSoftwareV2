# Target Geometry Service

Single source of truth for ISSF target face sizes, display scaling, and coordinate mapping.

## C++ modules

| File | Role |
|------|------|
| `targetgeometry.h/cpp` | Face dimensions, mm↔pixel mapping, pellet sizing |
| `scoringengine.cpp` | Ring scoring uses `TargetGeometry::ringDimensions()` |

## QML access

Context property: **`TARGETGEOMETRY`** (`TargetGeometryService`)

Common calls:

```javascript
TARGETGEOMETRY.targetFaceMillimeters(rangeMeters, isPistol)
TARGETGEOMETRY.pelletDisplayRatio(rangeMeters, isPistol, bulletDiameterMm)
TARGETGEOMETRY.pixelsPerMillimeter(canvasSizePx, rangeMeters, isPistol)
TARGETGEOMETRY.mapHardwareToCanvas(xMm, yMm, w, h, range, pistol, offset)
TARGETGEOMETRY.mapCanvasToHardware(x, y, w, h, range, pistol, offset)
```

`CenterPane.qml` wraps these in `faceMillimeters()`, `mapHardwarePoint()`, etc.

## Face sizes (mm)

| Range | Pistol | Rifle |
|-------|--------|-------|
| 10 m | 155.5 | 45.5 |
| 50 m | 500.0 | 154.4 |

## Ring dimensions (scoring)

Used by `ScoringEngine::calculateScore()` — do not duplicate in QML.

## Tests

```powershell
cd tests\build_tg
qmake ..\targetgeometry_test.pro
mingw32-make
.\release\targetgeometry_test.exe
```
