# Brick Blast Shooter - Master Product Document
Version: 1.0
Date: 2026-02-17
Product: Brick Blast Shooter (Flutter)
Platform Scope: Android production path active, iOS planned
Owner: Product + Gameplay Engineering
Status: Living baseline document

## How To Use This Document
- Use this as the primary reference for product intent, gameplay rules, implementation boundaries, and roadmap priorities.
- Treat formulas and locked mechanics in this file as source-of-truth unless superseded by newer accepted decisions in `DECISION_LOG.md`.
- Use the Functionality Map section when scoping features or debugging cross-module behavior.

## 1) Product Overview (PRD)

### Vision
Deliver a high-retention, turn-based swarm shooter experience with short sessions, scalable progression, and strong super-app compatibility.

### Core Gameplay Promise
- Simple to understand: aim, release, clear waves.
- Deep to master: trajectory planning, wall banking, and resource pressure.
- Fair progression: checkpoint-style retry behavior and bounded wave lengths.

### Target Audience / Personas
- Casual arcade players who prefer short, repeatable sessions.
- Mid-core puzzle/physics players who enjoy optimization and angle mastery.
- Mobile-first users with limited session windows (2-8 minutes per run segment).

### Product Goals
- Maintain responsive 60 FPS gameplay on common Android devices.
- Keep late-game levels playable without runaway duration.
- Ensure state consistency across `home <-> game` transitions.
- Preserve modular architecture for future super-app expansion.

### Non-Goals (Current Phase)
- PvP and synchronous multiplayer.
- LiveOps backend and remote config.
- Cloud identity/sync.
- Full monetization rollout.

### Current Scope
- Android-first production flow.
- iOS compatibility considered in architecture, deferred in delivery.

### Success Metrics
- Gameplay Stability: crash-free sessions and no blocked progression transitions.
- UX Quality: no overlap/overflow in key portrait layouts.
- Retention Signals: repeat play and level advancement consistency.
- Performance: smooth simulation cadence and deterministic turn resolution.

## 2) Core Game Design (PRD)

### State Machine
Phases used by game loop:
- `idle`: waiting for input
- `aiming`: drag-to-aim trajectory preview
- `firing`: stream launch from queue
- `busy`: physics simulation while balls active/merging
- `endTurn`: turn resolution and spawn/shift actions
- `gameOver`: loss state and retry/home routing

### Ball Shooter Mechanics
- Stream launch (not shotgun): one ball released on fire interval.
- Bounce model: wall/top reflections + brick collision handling.
- Convergence model:
  - First grounded ball defines new launcher X.
  - Remaining balls slide/merge to that X.

### Turn and Wave Progression
- End turn triggers:
  - launcher reposition,
  - +1 ball gain,
  - board shift down,
  - optional new wave spawn.
- Final wave spawn transitions to cleanup mode (no new spawns).

### Win/Loss Conditions
- Win (level clear): all spawned waves complete and all bricks cleared.
- Loss (game over): brick reaches/passes danger line geometry threshold.

### Level Flow and Result Flow
- On clear: level-clear modal offers `NEXT LEVEL` or `HOME`.
- On loss: game-over modal offers `PLAY AGAIN` (retry) or `HOME`.

### Economy Rules Active
- Score is action-based (`+10` per effective hit unit).
- Coin payout currently uses score-bucket conversion on clear only.
- No coin payout on loss.

## 3) Progression and Balance Rules (Source of Truth)

### Formulas
- Waves per level:
  - `wavesTotal(level) = min(60, 10 + floor(6 * ln(level)))`
- Ball cap per level:
  - `maxBalls(level) = 30 + floor(35 * ln(level))`
- Brick HP:
  - `normalHp(level, waveNumber) = (level * 3) + waveNumber`
- Boss multiplier:
  - `bossHp = ceil(normalHp * 2.5)`

### Locked Progression Rules
- Ball growth: `+1` per completed turn.
- Cap policy: gain during level, trim overflow at level clear.
- Retry checkpoint: retry same level with level-entry checkpoint balls.

### Speed System
- Base launch speed: `1.425`
- Turn speed growth: `launchSpeedMultiplier *= 1.07`
- Launch speed cap: `x2.0`

## 4) User Flow (End-to-End)

### Navigation Flow
- `Splash -> Login -> Home -> Game -> Result`

### First-Time vs Returning
- First-time user: splash routes to login.
- Returning user: splash routes directly to home.

### Home -> Play Behavior
- Home launches next available level.
- Resume semantics preserve run continuity via controller snapshot rules.

### Result Actions
- Level clear:
  - `NEXT LEVEL`: advance immediately.
  - `HOME`: unlock state retained; home shows correct next level.
- Game over:
  - `PLAY AGAIN`: retry same failed level using checkpoint rule.
  - `HOME`: exit to home while preserving persistent progression/economy state.

## 5) User Guide

### Start Playing
1. Open app and complete guest entry on login if first launch.
2. On home screen, tap `PLAY` to start next available level.

### Controls
- Touch/drag from launcher area to aim.
- Release to fire ball stream.
- Tap settings icon in game HUD for pause actions.

### HUD Meaning (Game Screen)
- `SCORE`: cumulative run score.
- `WAVE x/y`: current spawned wave progress in level.
- `LEVEL n`: current level index.

### Progression Basics
- Each completed turn grants +1 ball.
- Bricks move downward each turn.
- New rows spawn until wave quota is reached.
- Final wave triggers cleanup mode; clear remaining bricks to finish level.

### Score and Result Display
- In-game HUD score: cumulative run score.
- Level-clear result score: level-only score delta.

### Coin Behavior (Current)
- `1 coin = 100 score` bucket conversion.
- Coins are paid on level clear only.
- No payout on game over.

### Win/Loss Outcomes
- Win: proceed to next level or return home.
- Loss: retry same level or return home.

### Troubleshooting (Common)
- If score appears different between game HUD and result modal:
  - this is expected by design (cumulative vs level-only split).
- If progression display looks stale after clear:
  - revisit home from result action; unlock is confirmed during clear action path.

## 6) Functionality Map (What Exists Today)

### App Shell and Routing
- Entry/app composition:
  - `lib/main.dart`
  - `lib/app.dart`
- App shell context/router:
  - `lib/app_shell/`
- Module entry and routes:
  - `lib/modules/brick_blast/module_entry.dart`

Implemented:
- Named-route flow for splash/login/module home/game.
Known constraints:
- Portrait-first UX tuning.
Dependencies:
- Local storage for first-time and progression gates.

### Screens
- `lib/screens/splash_screen.dart`
- `lib/screens/login_screen.dart`
- `lib/modules/brick_blast/ui/home_screen.dart`
- `lib/modules/brick_blast/ui/game_screen.dart`
- `lib/modules/brick_blast/ui/result_dialog.dart`

Implemented:
- Production-themed splash/login/home/game/result stack.
- Responsive compact sizing logic for home and result dialogs.
Known constraints:
- Tablet landscape is not primary optimization target.
Dependencies:
- Game controller state + storage keys.

### Game Module Internals

#### Models
- `lib/modules/brick_blast/models/`
Implemented:
- Game phase/state, level progress, launcher, ball, brick, patterns, style enums.
Known constraints:
- Some future-facing fields may be placeholders for economy variants.

#### Logic Engine
- `lib/modules/brick_blast/logic/simulation_engine.dart`
- `lib/modules/brick_blast/logic/turn_resolver.dart`
- `lib/modules/brick_blast/logic/game_controller.dart`

Implemented:
- Deterministic fixed-step simulation.
- Turn resolution, convergence, spawn/shift, clear/loss handling.
- Level clear and game over action handling.
Known constraints:
- Physics is custom and intentionally lightweight.
Dependencies:
- Tuning constants and row generator.

#### Progression/Planner
- `lib/modules/brick_blast/data/level_plan_builder.dart`
- `lib/modules/brick_blast/logic/level_progression_service.dart`
- `lib/modules/brick_blast/data/game_tuning.dart`

Implemented:
- Log waves with cap.
- Pattern scheduling and cleanup phase transitions.
- Ball cap and speed progression constants.
Known constraints:
- Additional progression variants deferred.

#### Row Generation
- `lib/modules/brick_blast/data/brick_row_generator.dart`

Implemented:
- Pattern-based row generation with boss rule and density controls.
- HP derived from locked formulas.
Known constraints:
- Pattern pool intentionally limited for this phase.

#### UI / Widgets
- `lib/modules/brick_blast/widgets/shooter_board.dart`
- `lib/modules/brick_blast/ui/game_screen.dart`
- `lib/modules/brick_blast/ui/result_dialog.dart`

Implemented:
- Board render, aim styles, pause modal, result modals.
Known constraints:
- Additional accessibility polish remains a backlog item.

### Storage and Analytics Capabilities
- `lib/capabilities/storage/local_storage_service.dart`
- `lib/capabilities/analytics/`

Implemented:
- Persistent keys for progression, score, coins, and resume snapshot.
- Analytics interface with no-op implementation available.
Known constraints:
- No remote analytics backend integration in this phase.

### Test Coverage Map
- Logic tests:
  - progression, controller, resolver, simulation
- UI tests:
  - home, game screen, result dialogs
- App flow tests:
  - splash/login/home/game routing

Known constraints:
- Visual pixel parity is validated manually on emulator in addition to widget tests.

## 7) Quality, Testing, and Release Readiness

### Standard Validation Workflow
1. `dart format lib test`
2. `flutter analyze`
3. `flutter test`

### High-Risk Regression Scenarios
- level-clear action sequencing (`next/home`) consistency
- resume snapshot state coherence (`home -> play`)
- game-over retry behavior at checkpoint
- cap-trim application on clear
- no dialog overlap/re-entrancy issues

### Device/Responsiveness Expectations
- Portrait-first layout quality on compact/regular/tall phones.
- No key element overlap in home/game/result primary screens.
- Touch targets remain practical on compact screens.

### UI Production-Readiness Checklist
- no overflow warnings
- no scroll-on-home for core layout
- readable text floors enforced
- coherent spacing hierarchy
- action buttons clearly reachable and visible

## 8) Future Enhancements Backlog

### Near-Term (next 1-2 passes)

1. Coin model finalization (score vs overflow vs hybrid)
- User Value: clearer economy and reward transparency.
- Complexity: M
- Risk/Dependency: touches controller/state/result UX.
- Priority: P0

2. Overflow visualization on clear result
- User Value: explains trim outcomes and reduces confusion.
- Complexity: S
- Risk/Dependency: depends on finalized coin policy.
- Priority: P1

3. Balancing telemetry hooks
- User Value: faster tuning and issue diagnosis.
- Complexity: M
- Risk/Dependency: analytics provider integration.
- Priority: P1

4. Additional home/game polish
- User Value: higher visual quality and retention.
- Complexity: M
- Risk/Dependency: layout iteration bandwidth.
- Priority: P1

### Mid-Term

1. Powerups and special bricks
- User Value: deeper strategic variety.
- Complexity: L
- Risk/Dependency: state/physics extensions.
- Priority: P2

2. Difficulty presets
- User Value: broader audience fit.
- Complexity: M
- Risk/Dependency: tuning matrix complexity.
- Priority: P2

3. Missions/objectives
- User Value: stronger session goals and progression meaning.
- Complexity: M
- Risk/Dependency: economy/progression interactions.
- Priority: P2

4. Audio + haptics polish
- User Value: stronger game feel and feedback.
- Complexity: M
- Risk/Dependency: platform-specific tuning.
- Priority: P2

### Long-Term

1. LiveOps/events
- User Value: long-term engagement loops.
- Complexity: XL
- Risk/Dependency: backend tooling.
- Priority: P3

2. Cloud profile and sync
- User Value: cross-device continuity.
- Complexity: L
- Risk/Dependency: auth/backend data contracts.
- Priority: P3

3. Competitive systems (leaderboards/challenges)
- User Value: social/competitive retention.
- Complexity: L
- Risk/Dependency: anti-cheat/data integrity.
- Priority: P3

4. Super-app integration hooks
- User Value: modular expansion strategy fulfillment.
- Complexity: L
- Risk/Dependency: host app contracts.
- Priority: P3

## 9) Open Decisions / Deferred Items
- Final coin economy model:
  - score-only, overflow-only, or hybrid.
- Overflow reward tuning values if conversion is enabled.
- Advanced progression variants beyond current standard path.
- Optional UX reveal of internal cap/trim behavior.

## 10) Changelog and Decision References
- Historical decisions are maintained in:
  - `DECISION_LOG.md`
- Key recent baseline decisions:
  - D-029: infinite progression model + formulas + checkpoint/cap trim
  - D-030: start balls 15 + base speed boost + compact home/result pass
  - D-031: home vertical rebalance (center brand + lifted CTA)

---

Document Note:
This file is intentionally living documentation. Any new product or gameplay decisions must be appended to `DECISION_LOG.md` and reflected here when they change source-of-truth behavior.
