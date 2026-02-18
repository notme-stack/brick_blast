# Brick Blast Shooter - Master Product Document
Version: 1.1
Date: 2026-02-18
Product: Brick Blast Shooter (Flutter)
Platform Scope: Android production path active, iOS planned
Owner: Product + Gameplay Engineering
Status: Living baseline document

## How To Use This Document
- Use this as the primary source for product intent, gameplay rules, implementation boundaries, and roadmap priorities.
- Treat formulas and locked mechanics in this file as source-of-truth unless superseded by newer accepted entries in `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/DECISION_LOG.md`.
- Treat feature-toggle behavior as source-of-truth in `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/FEATURE_FLAGS.md`.

## 1) Product Overview (PRD)

### Vision
Deliver a high-retention, turn-based swarm shooter with short mobile sessions, predictable progression, and super-app-compatible modular architecture.

### Core Gameplay Promise
- Easy to start: drag, release, clear rows.
- Skill depth: pathing, wall banking, and turn-level tactical choices.
- Fair progression: level-scoped checkpoint retry and bounded level length.

### Target Audience
- Casual arcade players (short sessions, fast loop).
- Mid-core puzzle/physics players (trajectory optimization).
- Mobile-first users on portrait devices.

### Product Goals
- Stable long-run gameplay (no deadlocks/hangs in extended sessions).
- Deterministic turn resolution.
- Production-ready responsive UI across core screens.
- Feature-gated rollout for risky gameplay enhancements.

### Non-Goals (Current Phase)
- Multiplayer/PvP.
- LiveOps backend and remote-config rollout.
- Cloud profile and cross-device sync.
- Full monetization integration.

## 2) Core Game Design

### State Machine
- `idle`: waiting for user shot input
- `aiming`: drag to set angle
- `firing`: queued stream launch
- `busy`: physics simulation + return/merge
- `endTurn`: launcher move, row shift/spawn, checks
- `gameOver`: fail state with retry/home actions

### Shooter Loop
- Stream launch cadence, not shotgun.
- Ball-wall-top/brick interactions in normal physics path.
- First floor contact sets anchor (`nextLauncherX`), later grounded balls merge to anchor.

### Recall Mechanic (Visual Magnet)
- Enabled behind feature flag (`BRICK_BLAST_RECALL_ENABLED`, default ON).
- Recall CTA appears only after anchor exists (first floor landing).
- Fixed button position at bottom-left of arena.
- Recall allowed only in `firing`/`busy`.
- On recall:
  - stop queue (`ballsToFire = 0`)
  - queued unlaunched balls instant-merge at anchor
  - active balls enter ghost homing return to anchor
  - no scoring while recalling
- Completion: immediate end-turn when no active/queued work remains.
- Includes deadlock guard to force end-turn recovery for rare inconsistent states.

### Win/Loss
- Win: all waves spawned for level and board cleared (cleanup complete).
- Loss: any brick reaches/passes danger line geometry threshold.

## 3) Progression and Balance Rules (Source of Truth)

### Formulas
- Waves per level:
  - `wavesTotal(level) = min(60, 10 + floor(6 * ln(level)))`
- Ball cap per level:
  - `maxBalls(level) = 30 + floor(35 * ln(level))`
- Brick HP:
  - `normalHp(level, waveNumber) = (level * 3) + waveNumber`
- Boss HP:
  - `bossHp = ceil(normalHp * 2.5)`

### Locked Rules
- +1 ball per completed turn.
- Gain during level, cap trim only on level clear.
- Retry uses level-entry checkpoint balls on same level.

### Speed Rules
- Base launch speed: `1.425`
- Per-turn launch multiplier: `* 1.07`
- Per-level cap: `x2.0`
- Long-run stability guard:
  - fixed-step loop clamps incoming delta and caps catch-up steps to avoid freeze-like stalls.

## 4) End-to-End User Flow

- `Splash -> Login -> Home -> Game -> Result`

### First-Time vs Returning
- First-time: splash routes to login.
- Returning: splash routes directly to home.

### Home -> Play
- Starts next available level.
- Resume snapshot preserves run continuity (level/balls/score/bucket state) when valid.

### Game Screen Actions
- Back gesture opens pause modal (no direct route pop).
- Pause actions:
  - `Restart Level` -> checkpoint retry (same level)
  - `Home` -> home route
  - projectile style switching

### Result Actions
- Level clear:
  - `NEXT LEVEL` advances immediately
  - `HOME` unlocks next level state before navigation
- Game over:
  - `PLAY AGAIN` retries failed level
  - `HOME` returns home

## 5) Economy and Scoring

### Scoring
- Action-based scoring (`+10` per effective hit unit).
- HUD shows cumulative run score.
- Level-clear result shows level-only score delta.

### Coin System (Current)
- `1 coin = 100 score` bucket conversion.
- Payout occurs only on level clear.
- No payout on game over.
- Overflow-ball conversion is recorded for future economy phase (not active payout in current release behavior).

## 6) Feature Flag Governance

### Source of Truth
- `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/lib/app_shell/feature_flags.dart`
- `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/FEATURE_FLAGS.md`

### Active Flag Snapshot
- `BRICK_BLAST_RECALL_ENABLED`
  - default: `true`
  - OFF behavior: recall UI/logic path disabled safely

### Governance Rule
- Every new flag must be documented in `FEATURE_FLAGS.md` and referenced in decision logs.

## 7) Functionality Map (Implemented)

### App shell and routes
- `lib/main.dart`
- `lib/app.dart`
- `lib/app_shell/app_router.dart`
- `lib/modules/brick_blast/module_entry.dart`

### Screens
- `lib/screens/splash_screen.dart`
- `lib/screens/login_screen.dart`
- `lib/modules/brick_blast/ui/home_screen.dart`
- `lib/modules/brick_blast/ui/game_screen.dart`
- `lib/modules/brick_blast/ui/result_dialog.dart`

### Game internals
- Models: `lib/modules/brick_blast/models/`
- Engine and turn flow:
  - `lib/modules/brick_blast/logic/simulation_engine.dart`
  - `lib/modules/brick_blast/logic/turn_resolver.dart`
  - `lib/modules/brick_blast/logic/game_controller.dart`
- Progression/tuning:
  - `lib/modules/brick_blast/data/level_plan_builder.dart`
  - `lib/modules/brick_blast/logic/level_progression_service.dart`
  - `lib/modules/brick_blast/data/game_tuning.dart`
- Row generation:
  - `lib/modules/brick_blast/data/brick_row_generator.dart`
- Rendering:
  - `lib/modules/brick_blast/widgets/shooter_board.dart`

### Capabilities
- Storage: `lib/capabilities/storage/local_storage_service.dart`
- Analytics interface/no-op: `lib/capabilities/analytics/`

### Testing map
- Logic: controller/progression/simulation/turn resolver
- UI: home/game/result dialogs
- App flow: splash/login/home/game routing

## 8) Quality, Stability, and Release Readiness

### Standard validation workflow
1. `dart format lib test`
2. `flutter analyze`
3. `flutter test`

### High-risk regressions covered
- result-dialog sequencing and action idempotency
- home/play resume state consistency
- checkpoint retry behavior vs full reset
- recall interactions (queue merge + deadlock recovery)
- long-frame catch-up stability under extended sessions

### Device expectations
- Portrait-first optimized.
- No key overlap/overflow on compact/regular/tall phone classes.
- Touch targets preserved for primary controls.

## 9) User Guide (Operational)

1. Launch app; login once as guest on first install.
2. Tap `PLAY` on home to continue progression.
3. Aim by dragging; release to fire stream.
4. Use settings for pause actions and projectile style.
5. Use recall (when visible) to force fast return and accelerate turn resolution.
6. Clear all waves + cleanup bricks to complete level.
7. On loss, use `PLAY AGAIN` to retry same level with checkpoint behavior.

## 10) Future Enhancements

### Near-term
1. Finalize coin economy presentation (overflow data surfacing in result UX).
2. Add optional recall telemetry and balancing counters.
3. Add a user-facing explicit `Reset Run` entrypoint (separate from restart-level).

### Mid-term
1. Powerups/special bricks.
2. Difficulty presets and challenge modifiers.
3. Missions/objectives.
4. Audio/haptics polish.

### Long-term
1. LiveOps/event layers.
2. Cloud profile/sync.
3. Competitive systems.
4. Super-app embedding contracts.

## 11) Open Decisions / Deferred Items
- Final coin model policy (score-only vs overflow/hybrid presentation).
- Overflow reward tuning if conversion economics are changed.
- Remote-config strategy for feature flags (post local `dart-define` phase).
- Landscape optimization priority.

## 12) Decision References
Recent source-of-truth decisions:
- D-033: pause restart uses checkpoint retry
- D-034: game back gesture opens pause modal
- D-035: recall feature + flag governance baseline
- D-036: recall CTA downsize + fixed-step long-run guard
- D-037: icon-only recall tap visual (no square ink highlight)
- D-038: recall freeze fix (queue instant-merge + deadlock fallback)

---
This is a living document. Any accepted behavior change must be appended to `DECISION_LOG.md` and reflected here when it changes source-of-truth product behavior.
