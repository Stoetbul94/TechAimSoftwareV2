# Session Persistence Schema

## Current format (v1) — `.tch` XML

```xml
<root>
  <Game_information>
    <user_name>...</user_name>
    <game_mode>1</game_mode>
    <game_event>2</game_event>
    <game_type>1</game_type>
    <session_json>{...compact JSON...}</session_json>
  </Game_information>
  <GameData>
    <data_0>
      <x_data>...</x_data>
      <y_data>...</y_data>
      <score>...</score>
      <time>...</time>
      <time_stamp>...</time_stamp>
    </data_0>
  </GameData>
</root>
```

### session_json v1 fields

- `version`, `profileId`, `preparationSeconds`, `matchSeconds`
- `kneelingShots`, `proneShots`, `standingShots`
- `phase`, `totalMatchShots`, `positionMatchShots`
- `preparationElapsed`, `matchElapsed`
- `shots[]` — full ledger from `MatchSession::shotRecords()`

## Planned v2 (additive, backward compatible)

Embed as `session_json_v2` or migrate when `schemaVersion >= 2`:

```json
{
  "schemaVersion": 2,
  "application": "TechAim Electronic Target",
  "athlete": "",
  "eventProfile": "ISSF50R3POUT",
  "ruleSet": "ISSF 2026",
  "distance": 50,
  "scoreFormat": "integer",
  "sessionState": "ProneChangeoverSighting",
  "preparationSighting": { "limitSeconds": 900, "elapsedSeconds": 540 },
  "match": { "limitSeconds": 6300, "elapsedSeconds": 1200, "totalShots": 20 },
  "positions": [
    { "name": "Kneeling", "limit": 20, "decimalTotal": 0, "integerTotal": 187 }
  ],
  "shots": [],
  "hardware": { "lane": 1, "demoMode": false, "bulletDiameter": 5.6 },
  "audit": []
}
```

## Load compatibility

- Old sessions without `session_json` load shot coordinates from `GameData` only.
- Profile id `3` (Indoor) maps to Outdoor (index 2).
- v2 import should fall back to v1 when `session_json_v2` is absent.

## Save locations

- Manual save: `Match_<timestamp>.tch` or `Match_<username>.tch` (config `match_file=Clear`)
- Auto-save: every 10 s during timers + on each shot
