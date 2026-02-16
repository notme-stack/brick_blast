# Decision Log

This file is the single source of truth for project decisions.

## Rules
- Append-only: every new decision is added to the bottom.
- Do not delete or reorder past decisions.
- Every decision must start with:
  - `What it is?`
  - `Why?`
  - `How it helps?`
- Every decision must end with:
  - `Implementation Details`
- `Implementation Details` should include concrete file paths and key implementation behavior.

## Decision D-001: Flutter Modular Foundation
Date: 2026-02-16
Status: Accepted

What it is?
- Established a Flutter-first modular architecture with app shell, capabilities, modules, theme, screens, and utils.

Why?
- Needed Android-first implementation with future expansion to iOS and super-app integration.

How it helps?
- Keeps game modules isolated and pluggable.
- Reduces coupling and enables future super-app migration.

Details
- App shell and routing created.
- Capability interfaces added (analytics, ads, monetization, storage).

## Decision D-002: Replace Tic-Tac-Toe with Brick Blast Module
Date: 2026-02-16
Status: Accepted

What it is?
- Replaced the scaffold Tic-Tac-Toe module with Brick Blast as the first shipped module.

Why?
- Aligns the project with the intended core game direction.

How it helps?
- Focuses implementation and testing effort on the actual target gameplay.

Details
- Brick Blast module entry, home, and game screens introduced.
- Routing updated to point to Brick Blast module.

## Decision D-003: Ballz-Style Shooter Core Mechanics
Date: 2026-02-16
Status: Accepted

What it is?
- Migrated gameplay to Ballz-like turn-based shooter mechanics.

Why?
- Required by core game concept: stream firing, bounce physics, convergence, turn-based row shift.

How it helps?
- Delivers the defining gameplay loop and enables progression systems on top.

Details
- Added strict phase machine (`idle`, `aiming`, `firing`, `busy`, `endTurn`, `gameOver`).
- Added custom deterministic simulation and convergence behavior.

## Decision D-004: Deterministic Custom Physics Over External Engine
Date: 2026-02-16
Status: Accepted

What it is?
- Implemented custom 2D deterministic physics/collision logic instead of Flame/Forge2D.

Why?
- Needed strict control over turn phases and exact convergence behavior.

How it helps?
- Easier reproducibility, predictable tests, and better control of game-specific rules.

Details
- AABB/circle collision with reflection rules and bounded bounce corrections.

## Decision D-005: Level Progression System (Easy-to-Complete Profile)
Date: 2026-02-16
Status: Accepted

What it is?
- Added level container with wave progression, milestone variants, boss waves, and cleanup phase.

Why?
- Needed macro + micro progression instead of endless flat survival.

How it helps?
- Improves pacing and readability of difficulty.
- Gives strong level-end dopamine through cleanup mode.

Details
- Level types: Standard (10), Endurance (20 at 5/10/15...), Blitz (5 with 2x damage).
- Every 3rd wave is wall pattern.
- Final wave is boss wave with 2x HP and visual distinction.
- Strict cleanup: after final wave, no new spawns; level completes when bricks are cleared.

## Decision D-006: Project-Wide Decision Logging Rule
Date: 2026-02-16
Status: Accepted

What it is?
- Made decision logging mandatory through `AGENTS.md` and this file.

Why?
- Needed continuity, traceability, and stable collaboration context across sessions.

How it helps?
- Prevents lost context and inconsistent implementation choices.
- Enables future planning to build on explicit historical decisions.

Details
- All future decisions must append at bottom of this file.
- Required section order for each entry is enforced.

## Decision D-007: Clear-Only Coin Economy (Global Score Buckets)
Date: 2026-02-16
Status: Accepted

What it is?
- Implemented a coin economy where `1 coin = 100 score` using global run score buckets.
- Coins are awarded only when a level is cleared.
- No coins are paid on game over/loss.

Why?
- Needed a completion-based reward system that is simple, predictable, and aligned with progression goals.
- Avoids noisy payout events mid-level and reinforces finishing levels.

How it helps?
- Keeps player economy transparent and easy to reason about.
- Prevents edge-case payout bugs from direct modulo checks.
- Ensures loss states do not generate rewards.

Details
- Coin payout uses bucket delta: `score ~/ 100` minus buckets already paid in the current run.
- Added persistent total coins and highest-level display on home screen.
- Added level-complete coin summary and in-game coin HUD.

Implementation Details
- Files touched:
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/lib/modules/brick_blast/models/game_state.dart`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/lib/modules/brick_blast/logic/game_controller.dart`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/lib/modules/brick_blast/ui/game_screen.dart`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/lib/modules/brick_blast/ui/home_screen.dart`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/lib/capabilities/storage/local_storage_service.dart`
- Key code/logic changes:
  - Global score-bucket conversion (`score ~/ 100`) with payout only when a level clear transition occurs.
  - Run-scoped paid-bucket tracking reset on restart; no payout on game-over.
  - Home/game UI updated to show coins and level completion coin summary.
- Validation:
  - `flutter analyze` passed.
  - `flutter test` passed, including coin and flow coverage.

## Decision D-008: Primary User Flow Sequencing
Date: 2026-02-16
Status: Accepted

What it is?
- Set the default user journey to `splash -> login -> home -> game screen`.

Why?
- The project workflow requirement explicitly prioritizes this sequence for onboarding and session entry.

How it helps?
- Creates a predictable navigation path for users.
- Keeps authentication/entry separate from gameplay entry.
- Simplifies testing and future expansion of login/home experiences.

Details
- Splash now routes to Login.
- Login now routes directly to Brick Blast Home.
- Home launches Game screen where win/loss result dialogs are shown.

Implementation Details
- Files touched:
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/lib/screens/splash_screen.dart`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/lib/screens/login_screen.dart`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/test/app_flow_test.dart`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/test/widget_test.dart`
- Key code/logic changes:
  - Splash CTA now routes to `/login`.
  - Login guest CTA routes to Brick Blast home module route.
  - Added dedicated flow test: splash -> login -> home -> game.
- Validation:
  - `flutter analyze` passed.
  - `flutter test` passed for the full suite including the new flow test.

## Decision D-009: Decision Log Format Expansion (Implementation Tail Section)
Date: 2026-02-16
Status: Accepted

What it is?
- Expanded the project decision-log standard to require richer implementation detail at the end of each decision entry.

Why?
- Needed stronger execution traceability beyond high-level rationale.
- Helps future contributors understand exactly what changed and where.

How it helps?
- Improves maintainability and handoff clarity.
- Reduces ambiguity when revisiting historical decisions.
- Makes decisions auditable against concrete file-level implementation.

Details
- `AGENTS.md` now enforces a mandatory `Implementation Details` section.
- `DECISION_LOG.md` rules were updated to mirror this requirement.

Implementation Details
- Files touched:
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/AGENTS.md`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/DECISION_LOG.md`
- Key code/logic changes:
  - Entry template expanded with required tail section:
    - files touched
    - key logic changes
    - validation notes
- Validation:
  - Structural documentation update only; no runtime behavior changed.

## Decision D-010: Launch/Floor Collision Fix and Level 1 Ball Count
Date: 2026-02-16
Status: Accepted

What it is?
- Fixed the launch/floor collision logic so balls no longer get marked as landed immediately after firing.
- Set Level 1 starting ball count to 10.

Why?
- Balls were appearing to never shoot because floor-landing condition triggered right after launch.
- Gameplay requirement is to start Level 1 with 10 balls.

How it helps?
- Restores visible and correct shooting behavior.
- Aligns early-game pacing and difficulty with product expectations.

Details
- Floor landing now requires downward motion and crossing the floor line.
- Initial ball count reduced from 30 to 10.

Implementation Details
- Files touched:
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/lib/modules/brick_blast/logic/simulation_engine.dart`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/lib/modules/brick_blast/data/game_tuning.dart`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/test/modules/brick_blast/logic/simulation_engine_test.dart`
- Key code/logic changes:
  - Landing condition changed from `position.dy >= floorY - radius` to `velocity.dy > 0 && position.dy >= floorY`.
  - `initialBallCount` set to `10`.
  - Added regression test verifying launched ball moves upward and remains active initially.
- Validation:
  - `flutter analyze` passed.
  - `flutter test` passed.

## Decision D-011: Formula Progression + Physics Return Guarantee + Cyber HUD Pass
Date: 2026-02-16
Status: Accepted

What it is?
- Migrated level progression to formula-based wave counts (`wavesTotal = 8 + level * 2`) while keeping the board at 7 columns and prefill at 4 rows.
- Stabilized shooter physics so fired balls reliably return to the floor platform.
- Upgraded the game screen and board visuals to the matte-cyber direction with a two-segment reflected aim guide.

Why?
- Gameplay behavior needed to match the latest locked spec and remove mismatches from milestone-level logic.
- Players were experiencing unreliable ball movement and unclear aiming feedback.
- The module needed a clearer, livelier visual identity aligned with the defined game design.

How it helps?
- Makes progression predictable and spec-aligned across all levels.
- Prevents stuck-flight scenarios and preserves turn completion reliability.
- Improves shot planning clarity, readability, and perceived quality during active play.

Details
- Progression now uses formula totals (L1=10, L2=12, L5=18).
- Wall waves are level-gated (`level >= 6`) and occur every 5th wave; boss is always final wave.
- Boss HP multiplier is `2.5x`.
- Prefill enforces visible pressure: minimum 3 bricks per prefill row.
- Two-segment trajectory preview computes first collision boundary and reflected second segment.
- Final-wave banner (`FINAL WAVE!`) appears on boss-wave cleanup start.
- Game-over back action now returns to home via a single navigator action.

Implementation Details
- Files touched:
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/lib/modules/brick_blast/data/game_tuning.dart`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/lib/modules/brick_blast/data/level_plan_builder.dart`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/lib/modules/brick_blast/data/brick_row_generator.dart`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/lib/modules/brick_blast/logic/game_controller.dart`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/lib/modules/brick_blast/logic/level_progression_service.dart`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/lib/modules/brick_blast/logic/simulation_engine.dart`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/lib/modules/brick_blast/widgets/shooter_board.dart`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/lib/modules/brick_blast/ui/game_screen.dart`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/lib/theme/colors.dart`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/lib/theme/app_theme.dart`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/test/modules/brick_blast/logic/simulation_engine_test.dart`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/test/modules/brick_blast/logic/level_progression_test.dart`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/test/modules/brick_blast/logic/game_controller_progression_test.dart`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/test/modules/brick_blast/ui/shooter_board_test.dart`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/test/modules/brick_blast/ui/game_screen_test.dart`
- Locked gameplay rules implemented:
  - Columns: `7`
  - Level prefill rows: `4`
  - Wave total formula: `8 + level * 2`
  - Wall gating: `level >= 6` and every `5th` wave
  - Boss HP multiplier: `2.5`
  - Coin economy unchanged: `1 coin = 100 score`, payout only on level clear
- Validation results:
  - `dart format lib test` completed successfully.
  - `flutter analyze` completed successfully with no issues.
  - `flutter test` completed successfully (all tests passed).
  - Emulator launch verified with `flutter run -d emulator-5554` (debug + hot reload session started).

## Decision D-012: Danger-Line Geometry Unification + Bottom-Edge Fail Rule
Date: 2026-02-16
Status: Accepted

What it is?
- Unified danger-line geometry across game logic and board rendering.
- Locked game-over trigger to bottom-edge contact: game over when any brick bottom reaches or crosses the danger line.
- Added a targeted bounce stability pass to reduce wall/corner stall behavior without changing the phase architecture.

Why?
- The red danger line shown in UI was previously computed from a hardcoded pixel offset while game-over logic used row index thresholds.
- This mismatch caused premature game-over popups where bricks appeared visually above the danger mark.
- Bounce reliability needed additional safeguards for near-corner/near-wall low-velocity edge cases.

How it helps?
- Makes what players see and what game logic evaluates exactly consistent.
- Removes false-positive game-over events caused by UI/logic drift.
- Improves ball-movement stability while preserving deterministic turn behavior.

Details
- Implementation plan captured and executed in one pass:
  - Introduce shared normalized danger-line geometry in tuning.
  - Drive both `TurnResolver` fail check and `ShooterBoard` danger line from the same source.
  - Add minimal anti-stall velocity floor after reflections.
  - Add focused tests for danger threshold semantics and bounce non-stall behavior.
- Locked rule: `dangerLineYNormalized = launcherY - rowHeight` (one brick height above floor).
- Locked fail trigger: `brickBottomY(row) >= dangerLineYNormalized`.

Implementation Details
- Files touched:
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/lib/modules/brick_blast/data/game_tuning.dart`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/lib/modules/brick_blast/logic/turn_resolver.dart`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/lib/modules/brick_blast/widgets/shooter_board.dart`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/lib/modules/brick_blast/logic/simulation_engine.dart`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/test/modules/brick_blast/logic/turn_resolver_test.dart`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/test/modules/brick_blast/ui/shooter_board_test.dart`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/test/modules/brick_blast/logic/simulation_engine_test.dart`
- Key implementation specifics:
  - Added shared geometry helpers in tuning:
    - `dangerLineYNormalized`
    - `brickTopY(int row)`
    - `brickBottomY(int row)`
    - `isAtOrPastDangerLine(double brickBottom)`
  - Replaced resolver fail check from row-index boundary to bottom-edge geometry boundary.
  - Replaced board danger line draw from `size.height - 50` to `GameTuning.dangerLineYNormalized * size.height`.
  - Added anti-stall reflection safeguard via `minBallVelocityMagnitude` and `_enforceMinVelocity(...)` in simulation.
- Tests added/updated:
  - `turn_resolver_test.dart`:
    - below-threshold brick => no game over
    - at/past threshold => game over
    - equality helper check at exact danger line
  - `shooter_board_test.dart`:
    - danger-line pixel Y equals normalized tuning value
  - `simulation_engine_test.dart`:
    - corner/wall bounce does not stall near boundary
- Validation command results:
  - `dart format lib test` completed successfully.
  - `flutter analyze` completed successfully (no issues).
  - `flutter test` completed successfully (all tests passed).
  - Focused reruns passed:
    - `flutter test test/modules/brick_blast/logic/simulation_engine_test.dart`
    - `flutter test test/modules/brick_blast/logic/turn_resolver_test.dart`
    - `flutter test test/modules/brick_blast/ui/shooter_board_test.dart`
- Emulator verification notes:
  - Launched and synced successfully on Android emulator (`emulator-5554`) via `flutter run -d emulator-5554`.
  - Hot-reload session established; app detached with app left running.

## Decision D-013: HUD-First Game Screen UI (No AppBar, Settings-Driven Actions)
Date: 2026-02-16
Status: Accepted

What it is?
- Reworked the game screen into a HUD-first layout that removes the app bar and surfaces only player-facing progress data (Score, Wave, Level, Settings).
- Moved restart action into a settings menu and removed debug/internal stats from the gameplay surface.

Why?
- The target UI direction is cleaner and production-facing, with reduced cognitive load during play.
- On-screen debug details (`coins`, `phase`, `balls`, `mode`) were useful for development but not appropriate for player-facing UX.
- Restart placement needed to move under settings to match the desired interaction model.

How it helps?
- Aligns the game screen with the intended visual style and hierarchy.
- Improves readability and focus during gameplay by showing only core progression metrics.
- Makes actions discoverable via a consistent settings affordance.

Details
- Implementation plan executed:
  - remove app bar and use SafeArea HUD
  - hide debug/internal info
  - add settings popup with `Restart` and `Back to Home`
  - keep gameplay overlays (final wave banner, result dialogs)
  - ensure responsive spacing/typography for compact and regular widths
- Back navigation from settings is routed to module home (`/brick-blast`).

Implementation Details
- Files touched:
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/lib/modules/brick_blast/ui/game_screen.dart`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/test/modules/brick_blast/ui/game_screen_test.dart`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/test/app_flow_test.dart`
- Key code/logic changes:
  - Removed `AppBar` and replaced top area with custom HUD card (`SCORE`, `wave/total`, `LEVEL n`, gear icon).
  - Added responsive layout tuning inside `LayoutBuilder` for compact vs regular widths.
  - Added `PopupMenuButton` with actions:
    - `Restart` -> `_controller.restart()`
    - `Back to Home` -> pop-until home route with safe replacement fallback.
  - Removed in-game display of `coins`, `phase`, `balls`, and `mode`.
  - Removed bottom restart button.
  - Added score number formatting helper with grouped thousands.
- Test updates:
  - `game_screen_test.dart` now validates HUD-only layout and settings menu actions.
  - `app_flow_test.dart` now validates entry into game by checking HUD/settings presence instead of old app bar/phase labels.
- Validation results:
  - `dart format lib test` passed.
  - `flutter analyze` passed with no issues.
  - `flutter test` passed (full suite).
  - Emulator run verified via `flutter run -d emulator-5554` and app launched/synced in debug mode.

## Decision D-014: Paused Modal + Persistent Projectile Style + Floor-Line Removal
Date: 2026-02-16
Status: Accepted

What it is?
- Replaced settings popup menu with a custom full-screen-style paused modal dialog aligned to the provided reference.
- Added selectable projectile styles (`Dotted Line`, `Light Sabre`) inside the paused modal.
- Persisted projectile style globally across app restarts.
- Removed the bottom blue floor line from the game board render path.

Why?
- The previous settings interaction (popup menu) did not match the desired gameplay UX and visual hierarchy.
- Projectile style customization is now a player-facing feature and needed an in-game control surface.
- The blue floor line should be hidden to match the updated game screen visual design.

How it helps?
- Delivers a production-style pause/settings experience with clearer actions (`Restart`, `Home`, `Resume`).
- Adds a customizable trajectory aesthetic while preserving gameplay mechanics.
- Keeps UI cleaner and closer to the intended visual direction.

Details
- Implemented a custom paused modal with:
  - title + close icon
  - restart button
  - home button
  - projectile style cards (dotted/light sabre)
  - resume action
- Modal opens from the settings gear and pauses game ticking/input while visible.
- Projectile selection updates trajectory rendering live and persists to local storage.
- Dotted style keeps dashed aim lines; light sabre style uses glow + bright core lines.

Implementation Details
- Files touched:
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/lib/modules/brick_blast/models/projectile_style.dart`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/lib/modules/brick_blast/models/game_state.dart`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/lib/modules/brick_blast/logic/game_controller.dart`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/lib/modules/brick_blast/ui/game_screen.dart`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/lib/modules/brick_blast/widgets/shooter_board.dart`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/test/modules/brick_blast/ui/game_screen_test.dart`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/test/modules/brick_blast/logic/game_controller_projectile_style_test.dart`
- Persistence key introduced:
  - `brick_blast_projectile_style`
- Key logic changes:
  - `GameState` now carries `projectileStyle` (default `dotted`).
  - `GameController` loads/saves style from storage and exposes `setProjectileStyle(...)`.
  - `GameScreen` uses custom paused dialog and ticker/input pause gate (`_isPausedOverlayOpen`).
  - `ShooterBoard` now renders either dashed trajectory or light-sabre trajectory and no longer draws the bottom floor line.
- Validation results:
  - `dart format lib test` passed.
  - `flutter analyze` passed.
  - `flutter test` passed (full suite).
  - Focused tests passed:
    - `flutter test test/modules/brick_blast/ui/game_screen_test.dart`
    - `flutter test test/modules/brick_blast/ui/shooter_board_test.dart`
    - `flutter test test/modules/brick_blast/logic/game_controller_projectile_style_test.dart`
  - Emulator verification:
    - `flutter run -d emulator-5554` launched successfully; debug sync and detach succeeded.

## Decision D-015: Pause Modal Compact Sizing and Centered Title
Date: 2026-02-16
Status: Accepted

What it is?
- Reduced pause modal footprint and tightened internal spacing for a more compact responsive layout.
- Center-aligned the `Paused` title independently from the close icon.
- Scaled typography and action/control card sizes down to reduce visual bulk.

Why?
- The modal was too large relative to the game area and looked heavy on phone screens.
- The title alignment needed to be visually centered despite the right-side close icon.

How it helps?
- Preserves gameplay context visibility behind the modal.
- Improves readability and visual balance on compact and regular devices.
- Keeps interaction targets intact while reducing density and clutter.

Details
- Modal width now targets ~70% of screen width with clamps for phone/tablet ranges.
- `Paused` headline reduced by roughly 40% from prior size.
- Buttons/cards/labels are compact-scaled via breakpoint-driven sizing.

Implementation Details
- Files touched:
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/lib/modules/brick_blast/ui/game_screen.dart`
- Key implementation behavior:
  - Dialog width uses clamped dynamic sizing (`screenWidth * 0.7`, min/max bounds).
  - Header switched to `Stack` for true centered title plus right-aligned close control.
  - Reduced heights and font sizes in `_PauseActionButton` and `_ProjectileStyleCard` with compact mode support.
- Validation:
  - `dart format lib/modules/brick_blast/ui/game_screen.dart` passed.
  - `flutter analyze` passed.
  - `flutter test test/modules/brick_blast/ui/game_screen_test.dart` passed.
