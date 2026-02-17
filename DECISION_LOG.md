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

## Decision D-016: Splash Auto-Route + Persistent First-Time Login Gate
Date: 2026-02-16
Status: Accepted

What it is?
- Implemented a production splash experience for Brick Blast Shooter with a 2.5-second animated loading phase and automatic first-time routing.
- Added persistent `has_completed_login` gating so routing survives app relaunch.

Why?
- The prior splash and login flow was placeholder-only and required manual interaction.
- In-memory storage reset every launch, so first-time detection could not be trusted.

How it helps?
- Delivers the intended flow: `Splash -> Login (first-time) -> Home`, and `Splash -> Home` for returning users.
- Improves onboarding polish while keeping module routing and game systems unchanged.

Details
- Splash is now a responsive, cyber-themed screen with:
  - centered brand visual (`assets/images/splash_logo.png`)
  - stylized `BRICK / BLAST / SHOOTER` text stack
  - animated loading rail and loading text
- Splash duration is fixed to `2500ms` before route resolution.
- Login continue action now persists completion flag before navigation.
- Local storage service now supports persistent SharedPreferences-backed read/write while preserving existing API shape used across the module.

Implementation Details
- Files changed:
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/pubspec.yaml`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/pubspec.lock`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/lib/capabilities/storage/local_storage_service.dart`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/lib/main.dart`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/lib/screens/splash_screen.dart`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/lib/screens/login_screen.dart`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/test/widget_test.dart`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/test/app_flow_test.dart`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/test/capabilities/storage/local_storage_service_test.dart`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/macos/Flutter/GeneratedPluginRegistrant.swift`
- Storage key added:
  - `has_completed_login`
- Routing rule implemented:
  - after `2.5s`: `has_completed_login == true` -> `/brick-blast`; else -> `/login`
- Validation command outcomes:
  - `dart format lib test` passed
  - `flutter pub get` passed
  - `flutter analyze` passed (no issues)
  - `flutter test` passed (all tests)
  - `flutter run -d emulator-5554` built, installed, and synced successfully

## Decision D-017: Pixel-Close Responsive Login Screen Enablement
Date: 2026-02-16
Status: Accepted

What it is?
- Replaced the placeholder login page with a production-style, pixel-close cyber login screen aligned to the provided reference.
- Preserved guest-only auth flow while upgrading UI to responsive, device-adaptive layout behavior.

Why?
- The previous login screen was a scaffold (`AppBar` + single button) and did not match the target product quality.
- Login is a core part of the locked flow (`Splash -> Login -> Home -> Game -> Result`) and needed consistent visual language with splash/game screens.

How it helps?
- Delivers a branded and polished onboarding step with clear CTA hierarchy.
- Keeps UX and routing behavior intact while improving visual quality and responsiveness across compact and large screens.

Details
- Implemented full-screen dark cyber layout with ambient background elements (blurred glass shapes, arc lines, glow accents).
- Added centered brand stack: logo orb + `BRICK`, glowing `BLAST`, and pill-style `SHOOTER` label.
- Added primary CTA panel: `CONTINUE AS GUEST` with circular arrow affordance.
- Added footer metadata text: `v3.0.1 • No account required`.
- Added height-aware responsive scaling to avoid overflow/click misses on shorter viewports and tests.
- Kept behavior unchanged:
  - tapping CTA persists `has_completed_login = true`
  - navigates with `pushReplacementNamed` to `/brick-blast`

Implementation Details
- Files changed:
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/lib/screens/login_screen.dart`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/test/app_flow_test.dart`
- Compatibility updates:
  - flow test assertions updated from old `Login` app bar to new login branding/CTA.
  - test now ensures CTA is visible before tap to handle small-height test viewports.
- Validation command outcomes:
  - `dart format lib/screens/login_screen.dart test/app_flow_test.dart` passed
  - `flutter analyze` passed (no issues)
  - `flutter test` passed (full suite)
  - `flutter run -d emulator-5554` launched, installed, synced successfully and detached cleanly

## Decision D-018: Home Screen HUD Upgrade + Next-Level Play CTA
Date: 2026-02-16
Status: Accepted

What it is?
- Replaced the Brick Blast module home screen with a production-ready, pixel-close cyber UI aligned to the provided design.
- Added top stat pills for completed levels, total coins, and best score.
- Added `NEXT LEVEL <n>` label above the play CTA and kept play flow targeting the next unlocked level.

Why?
- The previous home screen was a placeholder card layout and did not match the visual quality bar established for splash/login/game.
- Core progression stats needed to be surfaced at the top exactly as requested.
- The primary action needed to explicitly communicate next-level progression.

How it helps?
- Creates a consistent branded flow across `Splash -> Login -> Home -> Game`.
- Improves at-a-glance understanding of progression and economy.
- Keeps session continuity by launching gameplay at the next unlocked level from persisted progress.

Details
- Top row now shows:
  - `LEVEL` = levels completed so far (`max(0, nextLevel - 1)`)
  - total coins (formatted with commas)
  - `BEST` score
- Main action area now shows:
  - `NEXT LEVEL <n>` in the same light grey used for `SHOOTER`
  - large gradient `PLAY` button
- Gameplay entry behavior remains compatible with existing logic:
  - home reads `brick_blast_highest_level` as the next unlocked level
  - tapping play opens game route where controller starts from persisted unlocked level
- Responsive behavior added:
  - width compact mode + height scaling
  - centered constrained content and scroll safety for shorter viewports

Implementation Details
- Files changed:
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/lib/modules/brick_blast/ui/home_screen.dart`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/test/modules/brick_blast/ui/home_screen_test.dart`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/test/app_flow_test.dart`
- Test updates:
  - home widget test now validates top stat labels/values and `NEXT LEVEL` + `PLAY` CTA
  - app flow test updated to assert new home UI and taps `PLAY`
  - added `ensureVisible` guards for compact test viewport interactions
- Validation command outcomes:
  - `dart format lib/modules/brick_blast/ui/home_screen.dart test/modules/brick_blast/ui/home_screen_test.dart` passed
  - `flutter analyze` passed (no issues)
  - `flutter test` passed (full suite)
  - `flutter run -d emulator-5554` launched and synced successfully; session detached cleanly

## Decision D-019: Home Screen Rebuild (Non-Scrollable, Flutter-Drawn Icon, Pixel-Close Layout)
Date: 2026-02-16
Status: Accepted

What it is?
- Rebuilt the Brick Blast home screen to match the latest `home.png` reference with a fixed, non-scroll composition.
- Replaced asset-based center branding with a Flutter-drawn icon (`_HomeDiamondMark`) made from four rounded diamond tiles and glow layers.

Why?
- Previous home implementation was visually off-target, scroll-based, and reused the shared logo asset against the latest requirement.
- The home screen is a core flow step and needed production-level visual fidelity and deterministic layout behavior.

How it helps?
- Delivers a stable, pixel-close home UI that aligns with the target visual language.
- Ensures a consistent responsive layout across compact and regular devices without vertical scrolling.
- Keeps gameplay continuity intact while presenting progression data clearly.

Details
- Locked UI behavior implemented:
  - no `SingleChildScrollView` in home layout
  - top stat pills (`LEVEL`, coins, `BEST`)
  - centered `BRICK BLAST` + `SHOOTER`
  - `NEXT LEVEL <n>` above large `PLAY` CTA
- Center icon is now pure Flutter composition only (no `Image.asset` use in home screen).
- Responsive strategy:
  - deterministic size classes by height (`compact`, `regular`, `tall`)
  - additional width/height scale clamp to avoid overflow
  - tightened stat pill typography/min-height to fit compact constraints
- Play behavior unchanged: tap `PLAY` still navigates to game route and uses persisted progression.

Implementation Details
- Files changed:
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/lib/modules/brick_blast/ui/home_screen.dart`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/test/modules/brick_blast/ui/home_screen_test.dart`
- Test compatibility updates:
  - home test now asserts `Key('home-diamond-mark')` exists
  - home test now asserts `SingleChildScrollView` is absent
- Validation command outcomes:
  - `dart format lib/modules/brick_blast/ui/home_screen.dart test/modules/brick_blast/ui/home_screen_test.dart` passed
  - `flutter analyze` passed (no issues)
  - `flutter test` passed (full suite)
  - `flutter run -d emulator-5554` launched/synced successfully and detached cleanly
  - runtime re-check confirmed no home-screen RenderFlex overflow exceptions after responsive tightening

## Decision D-020: Home Top-Row Proportion Fix + 20% CTA Downsizing
Date: 2026-02-16
Status: Accepted

What it is?
- Fine-tuned the home screen to improve top section geometry and reduce the `NEXT LEVEL` + `PLAY` area by 20%.
- Locked top stats into fixed one-row proportions (compact side pills + wider center coin pill) for closer visual alignment with the reference.

Why?
- The top section in runtime did not match the target proportions and rhythm.
- The lower CTA block was visually oversized compared to the provided design.

How it helps?
- Brings home screen hierarchy closer to the intended pixel-close composition.
- Improves balance between top stats, center brand block, and bottom CTA.
- Preserves non-scroll behavior and existing game flow.

Details
- Applied explicit `0.8` scale factor to CTA block:
  - `NEXT LEVEL` font size
  - `NEXT LEVEL -> PLAY` gap
  - Play button height
  - Play icon and text scale indirectly via button height
- Top stats geometry updated:
  - fixed row proportions changed to `32 : 44 : 32` (left/center/right)
  - side pills compact, center pill wider
  - top inset tightened for better visual placement under safe area
- Top pill styling refined:
  - reduced pill height/padding
  - reduced number/label typography size
  - softened border/shadow and coin glow
- Added explicit top-row key for structure assertion:
  - `Key('home-top-stats-row')`

Implementation Details
- Files changed:
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/lib/modules/brick_blast/ui/home_screen.dart`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/test/modules/brick_blast/ui/home_screen_test.dart`
- 20% reduction targets implemented:
  - `const ctaScale = 0.8`
  - `nextLevelFontSize * ctaScale`
  - `nextLevelToPlayGap * ctaScale`
  - `playHeight * ctaScale`
- Top-row fixed proportion rule implemented:
  - `Expanded(flex: 32)` / `Expanded(flex: 44)` / `Expanded(flex: 32)`
- Validation command outcomes:
  - `dart format lib/modules/brick_blast/ui/home_screen.dart test/modules/brick_blast/ui/home_screen_test.dart` passed
  - `flutter analyze` passed (no issues)
  - `flutter test` passed (full suite)
  - `flutter run -d emulator-5554` launched and synced successfully; no RenderFlex exceptions observed; detached cleanly

## Decision D-021: Level-Clear Result Screen (Custom Cyber Modal + Level-Only Score)
Date: 2026-02-16
Status: Accepted

What it is?
- Implemented a dedicated production-style level-clear result modal with cyber visual treatment, replacing the plain level-clear `AlertDialog`.
- Added level-only score computation for the result screen while preserving existing coin/progression behavior.

Why?
- The previous level-clear dialog was generic and visually inconsistent with the game’s polished UI direction.
- The result requirement explicitly needed a dedicated clear screen and level-only score display.

How it helps?
- Delivers a player-facing completion moment that matches the target design language.
- Improves clarity with focused stats (`Score`, `Coins Earned`, `Total Coins`) and explicit progression actions (`NEXT LEVEL`, `HOME`).
- Keeps progression stable while giving accurate per-level scoring context.

Details
- New modal includes:
  - `LEVEL CLEARED!` heading (styled/glow)
  - always 3 stars (locked)
  - `MISSION COMPLETE` badge
  - `Level <n>` label
  - stat rows for level-only score, coins earned, total coins
  - CTA buttons: `NEXT LEVEL ->` and `HOME`
- Level-only score rule implemented in game screen:
  - `levelScore = max(0, state.score - _currentLevelStartScore)`
- Score baseline handling:
  - initialized to 0 on screen init
  - reset on restart actions
  - reset to current cumulative score after advancing to next level
- Home action from level-clear dialog returns to home and keeps unlocked progression as-is.

Implementation Details
- Files changed:
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/lib/modules/brick_blast/ui/result_dialog.dart`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/lib/modules/brick_blast/ui/game_screen.dart`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/test/modules/brick_blast/ui/result_dialog_test.dart`
- New/updated test coverage:
  - result dialog renders required content/stats and action buttons
  - result dialog action callbacks (`NEXT LEVEL`, `HOME`) are tappable
- 3-star lock:
  - always renders exactly 3 styled stars in the level-clear header region
- Level-only score formula used:
  - `max(0, cumulativeScore - levelStartScoreBaseline)`
- Action mapping:
  - `NEXT LEVEL` => close dialog + `advanceToNextLevel()` + baseline reset
  - `HOME` => close dialog + `_goHome()`
- Validation outcomes:
  - `dart format lib test` passed
  - `flutter analyze` passed (no issues)
  - `flutter test` passed (full suite)
  - `flutter run -d emulator-5554` launched/synced successfully and detached cleanly

## Decision D-022: Game Over Result Screen (Custom Cyber Modal + Level-Only Score + Retry Failed Level)
Date: 2026-02-16
Status: Accepted

What it is?
- Replaced the generic game-over `AlertDialog` with a dedicated production-style cyber modal that matches the latest game-over reference.
- Locked game-over scoring to level-only score and mapped `PLAY AGAIN` to retry the same failed level.

Why?
- The previous game-over screen was visually inconsistent with the updated game UI/result system and lacked the target presentation quality.
- Restart behavior needed to match product intent: replay the failed stage directly instead of forcing a level-1 restart.

How it helps?
- Provides a clear, polished end-of-run experience with stronger visual continuity to the rest of the game.
- Removes ambiguity in score display by showing the failed level’s score delta only.
- Reduces friction by letting players retry the same level immediately.

Details
- Game-over modal now includes:
  - `GAME OVER` heading with glow/italic styling.
  - `RESULT` chip.
  - `FINAL SCORE` card with large formatted value.
  - Primary CTA: `PLAY AGAIN` with refresh icon.
  - Secondary CTA: `HOME` with home icon.
- Game-over score formula:
  - `finalLevelScore = max(0, cumulativeScore - _currentLevelStartScore)`.
- Play-again behavior lock:
  - `PLAY AGAIN` now triggers same-level retry via `retryCurrentLevel()`.
- Home behavior lock:
  - `HOME` closes modal and returns to module home route.
- No coin payout logic changed for game over (clear-only payout rule preserved).

Implementation Details
- Files changed:
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/lib/modules/brick_blast/ui/result_dialog.dart`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/lib/modules/brick_blast/ui/game_screen.dart`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/lib/modules/brick_blast/logic/game_controller.dart`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/test/modules/brick_blast/ui/result_dialog_test.dart`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/test/modules/brick_blast/logic/game_controller_progression_test.dart`
- Locked rules implemented:
  - Level-only final score on game over.
  - `PLAY AGAIN` retries same level index with fresh in-level state.
- Controller behavior added:
  - `retryCurrentLevel()` rebuilds current level prefill and resets run-scoped state (`score`, `coinsPaidBucketsInRun`, in-level transient simulation fields).
- Validation results:
  - `dart format lib test` passed.
  - `flutter analyze` passed (no issues).
  - `flutter test` passed (full suite).
  - `flutter run -d emulator-5554` failed because device `emulator-5554` was not available in this session.
  - `flutter devices` confirmed only `macOS` and `Chrome` were available.

## Decision D-023: Home Top Section Simplification (Icon+Value Header, Best Hidden)
Date: 2026-02-16
Status: Accepted

What it is?
- Reworked the home-screen top section from a 3-pill metrics bar to a 2-group icon+value header.
- Top row now shows only: completed levels (star + number) and total coins (coin + number).

Why?
- The latest design reference requires a cleaner top strip without card pills or metric labels.
- The prior top bar included `BEST` and label text, which did not match the target visual direction.

How it helps?
- Aligns the home top area with the reference style and reduces visual clutter.
- Improves immediate readability by emphasizing only the two required values.
- Keeps the screen responsive and non-scroll while preserving existing gameplay/navigation flow.

Details
- Locked metric set implemented: `Level completed + Coins` only.
- `BEST` metric is hidden in this pass (not deleted from persistence architecture globally).
- Label-removal rule implemented: no `LEVEL` or `BEST` text rendered in top row.
- Level value semantics kept as completed levels: `max(0, highestLevel - 1)`.
- Lower home-screen sections (`diamond mark`, branding, `NEXT LEVEL`, `PLAY`) were left unchanged.

Implementation Details
- Files changed:
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/lib/modules/brick_blast/ui/home_screen.dart`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/test/modules/brick_blast/ui/home_screen_test.dart`
- Top-section implementation specifics:
  - Removed 3-card `_StatPill` top layout.
  - Added two compact groups in `_HomeTopStats`:
    - left group: star icon in circular chip + completed level value
    - right group: gold coin badge + formatted coin value
  - Removed top-row label text rendering.
- Validation outcomes:
  - `dart format lib/modules/brick_blast/ui/home_screen.dart test/modules/brick_blast/ui/home_screen_test.dart` passed
  - `flutter analyze` passed (no issues)
  - `flutter test` passed (full suite)

## Decision D-024: Login Screen Rebuild (Non-Scrollable, Flutter-Drawn 2x2 Brand Mark)
Date: 2026-02-16
Status: Accepted

What it is?
- Rebuilt the login screen to a pixel-close cyber layout aligned with the latest `login.png` reference.
- Replaced reused app logo asset usage with a pure Flutter-drawn 2x2 brand mark and removed scroll-driven composition.

Why?
- The previous login implementation used a pasted logo asset and `SingleChildScrollView`, creating a non-native/pasted visual and weak layout rhythm.
- The latest UI direction requires production-quality, responsive, deterministic composition across devices.

How it helps?
- Produces a stable, non-scroll login experience that better matches the reference hierarchy and visual language.
- Ensures brand mark consistency using Flutter primitives only, avoiding dependency on pasted assets.
- Preserves onboarding behavior while improving presentation quality and responsiveness.

Details
- Locked design decisions implemented:
  - top icon uses Flutter-drawn 2x2 rounded tiles only
  - no target overlay on `BRICK`
  - non-scroll layout with deterministic spacing and size classes
- Hero composition rebuilt:
  - `BRICK` (cool white), `BLAST` (glow accent), centered `SHOOTER` capsule with side dividers
- CTA rebuilt:
  - `CONTINUE AS GUEST` full-width pill button with trailing circular arrow affordance
  - preserved existing guest-login storage and routing behavior
- Ambient background updated with subtle arcs, glass shapes, and spark dots for depth without clutter.

Implementation Details
- Files changed:
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/lib/screens/login_screen.dart`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/test/app_flow_test.dart`
- No app icon reuse:
  - removed `Image.asset('assets/images/splash_logo.png')` from login screen
  - introduced pure Flutter `_LoginBrandMark` + `_BrandTile` composition
- Non-scroll rule implementation:
  - removed `SingleChildScrollView`
  - implemented `SafeArea + LayoutBuilder + Stack + centered constrained Column` flow
- Validation command outcomes:
  - `dart format lib/screens/login_screen.dart test/app_flow_test.dart` passed
  - `flutter analyze` passed (no issues)
  - `flutter test` passed (full suite)

## Decision D-025: Turn-Based Ball Launch Speed Scaling (+7% Compound, Level-Scoped, x2 Cap)
Date: 2026-02-16
Status: Accepted

What it is?
- Added a turn-based ball launch speed scaler for gameplay: launch speed now grows by 7% after each completed turn.
- Speed scaling is level-scoped and capped at a maximum of `x2.0`.

Why?
- The launcher needed progressive momentum within a level while preserving balance and predictability.
- A cap prevents runaway speed escalation and keeps physics/controls stable.

How it helps?
- Creates clear per-turn power progression and faster pacing deeper into each level.
- Keeps difficulty manageable by resetting at level transitions and hard-capping growth.
- Preserves existing phase flow and game-loop compatibility.

Details
- Growth formula at end-turn:
  - `launchSpeedMultiplier = min(launchSpeedMultiplier * 1.07, 2.0)`
- Firing speed formula:
  - `launchSpeed = baseBallSpeed * launchSpeedMultiplier * cleanupFactor`
- Reset behavior:
  - `advanceToNextLevel()` resets multiplier to `1.0`
  - `restart()` resets multiplier to `1.0`
  - `retryCurrentLevel()` resets multiplier to `1.0`
- Scope lock:
  - no carry-over across levels
  - scaling applies within the current level only

Implementation Details
- Files changed:
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/lib/modules/brick_blast/models/game_state.dart`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/lib/modules/brick_blast/data/game_tuning.dart`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/lib/modules/brick_blast/logic/simulation_engine.dart`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/lib/modules/brick_blast/logic/turn_resolver.dart`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/lib/modules/brick_blast/logic/game_controller.dart`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/test/modules/brick_blast/logic/simulation_engine_test.dart`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/test/modules/brick_blast/logic/turn_resolver_test.dart`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/test/modules/brick_blast/logic/game_controller_progression_test.dart`
- Added tuning constants:
  - `turnSpeedGrowthMultiplier = 1.07`
  - `maxLaunchSpeedMultiplier = 2.0`
- Added state field:
  - `launchSpeedMultiplier` in `GameState` (default `1.0`, included in `copyWith`)
- Validation outcomes:
  - `dart format ...` passed
  - `flutter analyze` passed (no issues)
  - `flutter test` passed (full suite)

## Decision D-026: Unlock Next Level On Clear Before Result-Action Navigation
Date: 2026-02-16
Status: Accepted

What it is?
- Added explicit level-unlock confirmation logic so next level is persisted immediately when level-clear result is shown and user selects either `NEXT LEVEL` or `HOME`.
- Home now correctly displays `NEXT LEVEL N+1` after clearing level `N`, regardless of which result action is chosen.

Why?
- Previously, progression unlock persisted mainly through `advanceToNextLevel()` and level transition paths.
- If user chose `HOME` from level-clear modal, unlock persistence could lag and home could show stale next level value.

How it helps?
- Fixes progression UX inconsistency and prevents wrong home-state after a clear.
- Makes unlock behavior deterministic and action-driven at the result modal.
- Keeps existing gameplay and economy rules unchanged.

Details
- New controller method: `confirmLevelClearUnlock()`
  - Guard: runs only when `pendingLevelUpDialog == true`
  - Computes `unlockedNext = currentLevel + 1`
  - Updates and persists `highestLevelReached = max(currentHighest, unlockedNext)`
  - Idempotent for repeated calls in same clear state
- Game screen integration:
  - `onNextLevel` now calls `confirmLevelClearUnlock()` before `advanceToNextLevel()`
  - `onHome` now calls `confirmLevelClearUnlock()` before navigating home
- No route, storage-key, scoring, coin, or physics behavior changes.

Implementation Details
- Files changed:
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/lib/modules/brick_blast/logic/game_controller.dart`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/lib/modules/brick_blast/ui/game_screen.dart`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/test/modules/brick_blast/logic/game_controller_progression_test.dart`
- Method behavior added:
  - `confirmLevelClearUnlock()` performs explicit, persisted unlock without forcing level transition
- Added regression coverage:
  - unlock + persistence check for level-clear state
  - idempotency check for repeated confirm calls
- Validation outcomes:
  - `dart format ...` passed
  - `flutter analyze` passed (no issues)
  - `flutter test` passed (full suite)

## Decision D-027: Post-Clear Transition Stability + Run Ball Carry + Compact UI Pass
Date: 2026-02-16
Status: Accepted

What it is?
- Implemented a combined stability + UI polish pass to fix post-clear progression reliability, preserve run balls when returning Home, and compact splash/login/game/result visuals.
- Added one-shot level-clear dialog handling to prevent repeated modal scheduling and transition stalls.

Why?
- During continuous level progression, level-clear dialog could be re-scheduled repeatedly while pending state remained true, causing double-action behavior and occasional freeze perception.
- Returning Home from an active run recreated controller state with default ball count, breaking progression continuity.
- Several screens needed compact visual adjustments and splash loading animation needed a deterministic sweep to avoid split/stuck appearance.

How it helps?
- Eliminates duplicate level-clear modal behavior and improves next-level action reliability.
- Preserves core run continuity (level + balls) across Home -> Play transitions.
- Produces cleaner, less distracting game visuals and a more compact/futuristic UI footprint.

Details
- Stability fixes:
  - Added UI guard for level-clear modal scheduling (`_isLevelClearDialogOpen`) in game screen.
  - Added `consumeLevelClearDialog()` in controller and used explicit result-action flow.
  - Removed strict pending guard in `advanceToNextLevel()` to allow consumed-dialog transition path.
- Run carry fixes:
  - Added run snapshot persistence keys for level + ball count:
    - `brick_blast_resume_level`
    - `brick_blast_resume_ball_count`
    - `brick_blast_resume_valid`
  - Added controller APIs:
    - `saveRunSnapshot({int? levelOverride})`
    - `clearRunSnapshot()`
  - Hydrate resumed level + ball count in `_loadPersistedProgress()` when resume snapshot is valid.
  - Clear snapshot on restart/retry/advance-next to avoid stale resume carry.
- Splash fix:
  - Replaced align-based moving fill with deterministic translated sweep segment in loading rail.
- Login compact pass:
  - Moved logo down by one tile height.
  - Reduced hero (`BRICK/BLAST/SHOOTER`) footprint by ~30%.
  - Reduced CTA/footer footprint by ~40%.
- Game board/HUD compact pass:
  - Removed thin blue horizontal grid lines from board background.
  - Reduced HUD footprint (padding/metric/icon sizing) for compact futuristic top bar.
- Result dialogs compact pass:
  - Reduced dialog max width/insets/padding and CTA heights for both win/loss dialogs while preserving readability.

Implementation Details
- Files changed:
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/lib/modules/brick_blast/logic/game_controller.dart`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/lib/modules/brick_blast/ui/game_screen.dart`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/lib/modules/brick_blast/widgets/shooter_board.dart`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/lib/modules/brick_blast/ui/result_dialog.dart`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/lib/screens/splash_screen.dart`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/lib/screens/login_screen.dart`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/test/modules/brick_blast/logic/game_controller_progression_test.dart`
- Added/updated controller methods:
  - `consumeLevelClearDialog()`
  - `saveRunSnapshot(...)`
  - `clearRunSnapshot()`
  - internal `_persistRunSnapshot(...)` and `_clearRunSnapshot()`
- Validation outcomes:
  - `dart format ...` passed
  - `flutter analyze` passed (no issues)
  - `flutter test` passed (full suite)

## Decision D-028: Resume Run Score Persistence (Keep HUD Cumulative + Result Level-Only)
Date: 2026-02-17
Status: Accepted

What it is?
- Persist and restore cumulative run score when the player exits to Home and re-enters via Play in the same run.
- Keep the split score model unchanged:
  - Game HUD shows cumulative run score.
  - Result modal shows level-only score delta.

Why?
- Home -> Play resume previously restored level and balls but could show incorrect level-score baseline behavior after async hydration.
- This created confusion where resumed runs could calculate level-clear delta from an outdated baseline.

How it helps?
- Keeps score continuity consistent across Home -> Play resume.
- Preserves expected UI model (cumulative in arena, level-only in result).
- Prevents accidental coin over-award by carrying paid bucket state with resumed score.

Details
- Resume snapshot includes:
  - `brick_blast_resume_level`
  - `brick_blast_resume_ball_count`
  - `brick_blast_resume_score`
  - `brick_blast_resume_paid_buckets`
  - `brick_blast_resume_valid`
- Resume hydration restores level, balls, score, and paid bucket count.
- Game-screen baseline now hydrates once from resumed score and is reset on level transitions/retry/restart to keep result delta accurate.
- Coin award logic remains unchanged:
  - `newBuckets = (score ~/ 100) - coinsPaidBucketsInRun`

Implementation Details
- Files changed:
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/lib/modules/brick_blast/ui/game_screen.dart`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/test/modules/brick_blast/logic/game_controller_progression_test.dart`
- Baseline behavior added in game screen:
  - one-time hydrate baseline from resumed score (`_didHydrateInitialBaseline`)
  - re-baseline on level-index change (`_trackedLevelForBaseline`)
  - explicit baseline resets after retry/restart/next-level transitions
- Test coverage update:
  - resume snapshot now verifies restore of level, balls, score, and `coinsPaidBucketsInRun`
- Validation outcomes:
  - `dart format lib test` passed
  - `flutter analyze` passed
  - `flutter test` passed

## Decision D-029: Infinite Progression Redesign (Log Waves + 60 Cap, HP=(Level*3)+Wave, Boss x2.5, Checkpoint Retry, Ball Cap Trim)
Date: 2026-02-17
Status: Accepted

What it is?
- Replaced linear progression with an infinite-ready logarithmic progression model.
- Added level-scoped ball-cap logic with gain-during-level and trim-on-clear behavior.
- Added level-entry checkpoint ball restore for retry on loss.

Why?
- Linear wave growth and uncapped balls become unbalanced and session-heavy at higher levels.
- High-level retries were too punishing because retry reset to default ball count instead of level-entry state.
- The new model keeps pacing bounded while preserving challenge escalation.

How it helps?
- Keeps each level duration bounded by a hard cap and avoids wave explosion.
- Maintains swarm fantasy while preventing unbounded ball inflation.
- Makes loss recovery fair by restoring level-entry ball count for same-level retry.

Details
- Locked formulas:
  - `wavesTotal(level) = min(60, 10 + floor(6 * ln(level)))`
  - `maxBalls(level) = 30 + floor(35 * ln(level))`
  - `normalHp(level, wave) = (level * 3) + wave`
  - `bossHp = ceil(normalHp * 2.5)`
- Turn behavior:
  - Keep `+1` ball per completed turn.
  - Enforce cap only on level clear via trim (overflow recorded).
- Loss behavior:
  - Retry same level with level-entry checkpoint balls.
- Coin behavior for this pass:
  - Unchanged score-bucket payout on clear only.
  - Overflow data recorded for future economy revisions.

Implementation Details
- Files changed:
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/lib/modules/brick_blast/data/game_tuning.dart`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/lib/modules/brick_blast/data/level_plan_builder.dart`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/lib/modules/brick_blast/data/brick_row_generator.dart`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/lib/modules/brick_blast/models/level_progress.dart`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/lib/modules/brick_blast/models/game_state.dart`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/lib/modules/brick_blast/logic/game_controller.dart`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/lib/modules/brick_blast/ui/game_screen.dart`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/test/modules/brick_blast/logic/level_progression_test.dart`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/test/modules/brick_blast/logic/game_controller_progression_test.dart`
- New helpers introduced:
  - `GameTuning.wavesForLevel(...)`
  - `GameTuning.maxBallsForLevel(...)`
  - `GameTuning.baseHpForWave(...)`
- Checkpoint restore rule implemented:
  - `retryCurrentLevel()` now restores `levelEntryBallCount` instead of default initial count.
- Trim rule implemented:
  - `advanceToNextLevel()` and level-clear Home path apply clear-time cap trim and carry only capped balls forward.
- Validation outcomes:
  - `dart format lib test` passed
  - `flutter analyze` passed
  - `flutter test` passed

## Decision D-030: Start Balls 15 + Base Speed +50% + Home/Result Compact Rebalance
Date: 2026-02-17
Status: Accepted

What it is?
- Increased starting ball count from 10 to 15.
- Increased base launch speed by 50% while keeping turn-based speed progression unchanged.
- Applied a responsive compact rebalance to Home and Result screens.

Why?
- The game needed stronger early-run momentum and faster launch feel.
- Home and Result screens were visually oversized and vertically imbalanced on mobile.
- The UI needed compactness improvements without sacrificing text readability.

How it helps?
- Players enter levels with a larger initial swarm and higher perceived pace.
- Existing progression logic remains stable (`+7%` turn speed growth, cap `x2`).
- Home and Result layouts now better fit small screens with clearer hierarchy and less crowding at edges.

Details
- Gameplay constants:
  - `initialBallCount = 15`
  - `turnConfig.ballSpeed = 1.425` (from `0.95`)
  - Kept:
    - `turnSpeedGrowthMultiplier = 1.07`
    - `maxLaunchSpeedMultiplier = 2.0`
- Home screen compact pass:
  - Added explicit scale lanes:
    - `coreScale = 0.60`
    - `statsScale = 0.60`
    - `ctaScale = 0.60`
  - Added readability floors for title/shooter/next-level/play text.
  - Repositioned top stats downward and lifted CTA block upward.
  - Reduced bottom anchoring so `NEXT LEVEL` + `PLAY` are no longer stuck to the bottom.
- Result compact pass (win/loss):
  - Reduced dialog width envelope and internal spacing.
  - Reduced typography and icon sizes with readability floors.
  - Preserved CTA tap-target safety (>=44 px via 46/50 heights).

Implementation Details
- Files changed:
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/lib/modules/brick_blast/data/game_tuning.dart`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/lib/modules/brick_blast/ui/home_screen.dart`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/lib/modules/brick_blast/ui/result_dialog.dart`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/test/modules/brick_blast/logic/game_controller_progression_test.dart`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/test/modules/brick_blast/logic/simulation_engine_test.dart`
- Home strategy:
  - Introduced scale controls + vertical offsets (`topInsetShift`, `ctaLift`, `centerStartOffset`) with clamp-based readability.
- Result strategy:
  - Width cap moved from 430 to 330, inset/padding/radii and content blocks reduced ~25% with preserved legibility.
- Validation outcomes:
  - `dart format lib test` passed
  - `flutter analyze` passed
  - `flutter test` passed

## Decision D-031: Home Vertical Rebalance (Centered Brand + Lifted CTA Cluster)
Date: 2026-02-17
Status: Accepted

What it is?
- Rebalanced the Home screen into explicit vertical regions to center the brand cluster and lift the CTA cluster.
- Replaced implicit bottom-heavy spacing with deterministic top/center/bottom zone layout.

Why?
- The brand block appeared slightly high and the CTA block felt stuck to the bottom.
- The screen had a large disconnected empty middle-lower area, hurting visual rhythm.

How it helps?
- Centers logo + `BRICK BLAST` + `SHOOTER` in the visual middle.
- Moves `NEXT LEVEL` + `PLAY` upward for better balance and modern compact feel.
- Reduces overlap risk by using explicit flex zones and responsive margins.

Details
- Zone layout:
  - Top zone: stats row with fixed top inset.
  - Middle zone: centered brand cluster.
  - Bottom zone: top-aligned CTA cluster with controlled margin.
- Flex strategy by size class:
  - compact: center 46 / bottom 22
  - regular: center 48 / bottom 24
  - tall: center 50 / bottom 26
- CTA lift strategy:
  - replaced transform lift with bottom-zone top alignment + `ctaTopMargin`.
- Bottom padding reduced to keep CTA off the edge while maintaining touch-safe layout.

Implementation Details
- Files changed:
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/lib/modules/brick_blast/ui/home_screen.dart`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/test/modules/brick_blast/ui/home_screen_test.dart`
- Non-overlap safeguards:
  - kept width clamping and readability floors from D-030
  - explicit zone flex + top-aligned CTA in bottom zone
  - non-scroll layout preserved
- Added widget coverage:
  - compact viewport visibility/overflow test
  - regular viewport visibility stability test
- Validation outcomes:
  - `dart format lib test` passed
  - `flutter analyze` passed
  - `flutter test` passed

## Decision D-032: Master Product Documentation Baseline (PRD + User Guide + Functionality Map + Future Roadmap)
Date: 2026-02-17
Status: Accepted

What it is?
- Added a single root-level master documentation file covering PRD, user guide, functionality map, quality gates, and future enhancement roadmap.
- Established one consolidated baseline artifact for PM, design, and engineering alignment.

Why?
- Product context, gameplay rules, and implementation behavior were spread across decisions and code context.
- A unified reference is needed to reduce ambiguity and speed planning/implementation handoff.

How it helps?
- Provides one source for current behavior, formulas, UX flow, and future backlog direction.
- Improves onboarding and cross-functional collaboration.
- Reduces rework from misunderstood scope and stale assumptions.

Details
- Created:
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/BRICK_BLAST_MASTER_DOC.md`
- Section taxonomy included:
  - Title/meta
  - Product overview (PRD)
  - Core game design
  - Progression/balance source-of-truth formulas
  - End-to-end user flow
  - User guide
  - Functionality map (module/file responsibilities)
  - Quality/testing/release readiness
  - Future enhancements by horizon
  - Open decisions/deferred items
  - Changelog/decision references

Implementation Details
- Files changed:
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/BRICK_BLAST_MASTER_DOC.md`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/DECISION_LOG.md`
- Readability checklist applied:
  - clear headers and concise subsections
  - formulas in monospace form
  - explicit distinction between implemented-now vs future roadmap
  - file/module grounding in functionality map
- Validation outcomes:
  - manual review for structure completeness against requested taxonomy
  - root placement verified for discoverability

## Decision D-033: Pause Restart Uses Level Checkpoint Retry (Full Run Reset Deferred)
Date: 2026-02-17
Status: Accepted

What it is?
- Changed pause-menu `Restart Level` action to restart the current level via checkpoint retry semantics.
- Kept full-run reset behavior available in controller, but deferred as a separate future UX action.

Why?
- Pause restart was incorrectly bound to full-run reset, sending players to Level 1.
- This contradicted the checkpoint concept where restart should preserve current level context.

How it helps?
- Aligns user expectation: restarting from pause now retries the same level.
- Prevents accidental run wipe when player intends only a level retry.
- Preserves future flexibility by keeping explicit run reset logic separate.

Details
- Remap:
  - from: pause restart -> `restart()`
  - to: pause restart -> `restartLevelFromCheckpoint()` -> `retryCurrentLevel()`
- Added explicit TODO marker to keep full run reset as a deferred enhancement path.
- Game-over `Play Again` behavior remains unchanged and already aligned to retry semantics.

Implementation Details
- Files changed:
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/lib/modules/brick_blast/ui/game_screen.dart`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/lib/modules/brick_blast/logic/game_controller.dart`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/test/modules/brick_blast/ui/game_screen_test.dart`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/test/modules/brick_blast/logic/game_controller_progression_test.dart`
- Controller addition:
  - `restartLevelFromCheckpoint()` wrapper delegates to `retryCurrentLevel()`
- Deferred TODO:
  - `restart()` annotated for future explicit `Reset Run` UX exposure
- Validation outcomes:
  - `dart format lib test` passed
  - `flutter analyze` passed
  - `flutter test` passed

## Decision D-034: Game-Screen Back Gesture Opens Pause Modal (No Direct Route Pop)
Date: 2026-02-17
Status: Accepted

What it is?
- Intercepted Android back gesture/button on game screen so it opens the in-game `Paused` modal instead of popping to Home.
- Route pop now occurs only via explicit `Home` action in the pause modal.

Why?
- Direct route pop from gameplay caused accidental exits and broke the intended in-game control flow.
- The pause/settings modal already exists and is the correct first back action for game UX.

How it helps?
- Prevents unintentional navigation away from an active run.
- Makes back behavior predictable and consistent with mobile game norms.
- Keeps all exit/restart actions centralized in one modal.

Details
- Added root-level back interception with `PopScope(canPop: false)` in game screen.
- On back:
  - if pause modal is closed: open pause modal
  - if pause modal is open: do nothing at screen layer (dialog handles its own close)
- Re-entry is guarded by existing `_isPausedOverlayOpen` check in `_openPauseModal()`.

Implementation Details
- Files changed:
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/lib/modules/brick_blast/ui/game_screen.dart`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/test/modules/brick_blast/ui/game_screen_test.dart`
- Tests added/updated:
  - `system back opens paused modal instead of popping route`
  - `system back while paused keeps game route active`
- Validation outcomes:
  - pending run in this change set (`dart format lib test`, `flutter analyze`, `flutter test`)

## Decision D-035: Visual Magnet Recall Behind Feature Flag + Feature Flag Registry Rule
Date: 2026-02-17
Status: Accepted

What it is?
- Added the Visual Magnet Recall mechanic to Brick Blast with a fixed bottom-left recall icon and anchor-based homing return behavior.
- Gated the feature behind a typed app-level flag so it can be disabled without removing code.
- Added a permanent feature-flag registry document and policy rule for future flag governance.

Why?
- Recall is a gameplay enhancement that needs controlled rollout and quick disable support.
- The project previously lacked a dedicated source-of-truth for feature flags and maintenance rules.
- We need predictable behavior across gameplay, testing, and release management when toggling features.

How it helps?
- Enables safe rollout/rollback via `--dart-define`.
- Keeps gameplay deterministic when the flag is OFF (no UI or logic side-effects).
- Standardizes how all future flags are tracked and documented.

Details
- Feature flag key: `BRICK_BLAST_RECALL_ENABLED`.
- Default behavior: ON (`true`) when no define is provided.
- OFF behavior: recall button hidden and recall trigger path is no-op.
- Recall gameplay behavior when ON:
  - recall button appears only after first landing anchor exists (`nextLauncherX`)
  - fixed button location at bottom-left of arena
  - recall allowed in `firing`/`busy`
  - queued launches are canceled on trigger (`ballsToFire = 0`)
  - ghost return mode disables scoring and collision processing during recall
  - completion follows existing all-merged condition and immediate end-turn transition

Implementation Details
- Files touched:
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/lib/app_shell/feature_flags.dart`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/lib/modules/brick_blast/models/game_state.dart`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/lib/modules/brick_blast/data/game_tuning.dart`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/lib/modules/brick_blast/logic/game_controller.dart`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/lib/modules/brick_blast/logic/simulation_engine.dart`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/lib/modules/brick_blast/logic/turn_resolver.dart`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/lib/modules/brick_blast/ui/game_screen.dart`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/test/modules/brick_blast/logic/simulation_engine_test.dart`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/test/modules/brick_blast/logic/game_controller_progression_test.dart`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/test/modules/brick_blast/ui/game_screen_test.dart`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/FEATURE_FLAGS.md`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/AGENTS.md`
- Key code/logic changes:
  - Added `FeatureFlags.brickBlastRecallEnabled` with `bool.fromEnvironment` source and testing override.
  - Added `GameState.isRecalling` and `GameState.recallButtonVisible`.
  - Added `GameController.triggerRecall()` with strict phase/anchor/flag gates.
  - Added recall homing branch in simulation engine (`_recallBalls`) and anchor-driven CTA visibility updates.
  - Added fixed bottom-left recall CTA widget on game screen.
  - Cleared recall state in turn resolution and major controller transitions.
  - Added global feature-flag documentation policy and registry file.
- Validation:
  - `dart format lib test` passed
  - `flutter analyze` passed
  - `flutter test` passed

## Decision D-036: Recall CTA Size Reduction + Fixed-Step Catch-Up Guard for Long-Run Stability
Date: 2026-02-17
Status: Accepted

What it is?
- Reduced recall control visual size by 40% and increased cyan glow intensity for clearer futuristic styling.
- Added simulation catch-up guardrails in `GameController.tick()` to prevent long-frame backlog stalls that can appear as hangs during very long play sessions.

Why?
- The recall button occupied too much visual space relative to the compact game HUD.
- Unbounded fixed-step catch-up loops can cause frame stalls when `deltaSeconds` spikes, especially after long sessions or lifecycle interruptions.

How it helps?
- Keeps recall CTA compact while remaining discoverable through stronger glow.
- Prevents freeze-like behavior by bounding per-frame simulation work and dropping stale backlog safely.
- Improves run stability for extended sessions (e.g., 100-level play streaks).

Details
- Recall CTA visual changes:
  - Outer interactive hit area kept touch-safe (`44x44`).
  - Visible orb reduced from `52x52` to `31.2x31.2` (40% reduction).
  - Icon reduced from `24` to `14.4` with dual glow shadows for stronger neon cue.
- Fixed-step stability changes:
  - Bounded incoming delta to `0.25s`.
  - Limited per-tick simulation iterations to `30` fixed steps.
  - Dropped remaining stale accumulator backlog when cap is reached.

Implementation Details
- Files touched:
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/lib/modules/brick_blast/ui/game_screen.dart`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/lib/modules/brick_blast/logic/game_controller.dart`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/test/modules/brick_blast/logic/game_controller_progression_test.dart`
- Key code/logic changes:
  - `_RecallButton` compacted visually with stronger glow while retaining 44px touch target.
  - Added `_maxFixedStepsPerTick = 30` and `_maxDeltaSecondsPerTick = 0.25` in `GameController`.
  - `tick()` now clamps delta, caps catch-up iterations, and clears stale accumulator backlog.
  - Added regression test verifying large-delta tick does not exceed catch-up cap.
- Validation:
  - `dart format lib test` passed
  - `flutter analyze` passed
  - `flutter test` passed

## Decision D-037: Recall Control Uses Icon-Only Tap Handling (No Square Ink Highlight)
Date: 2026-02-17
Status: Accepted

What it is?
- Removed the rectangular ink/highlight effect from the recall control so only the circular recall icon and glow are visible.

Why?
- The `InkWell` interaction layer rendered a square highlight artifact around the control, which conflicted with the intended icon-only futuristic visual.

How it helps?
- Aligns gameplay UI with the intended visual language: clean circular recall icon with glow only.
- Eliminates distracting square flash/background near the danger line area.

Details
- Replaced `Material + InkWell + Ink` interaction stack for `_RecallButton` with icon-only tap handling using `GestureDetector`.
- Preserved touch usability by keeping a `44x44` hit target.
- Kept the existing circular icon/glow styling unchanged.
- Scope intentionally limited to recall control only.

Implementation Details
- Files touched:
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/lib/modules/brick_blast/ui/game_screen.dart`
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/DECISION_LOG.md`
- Key code/logic changes:
  - `_RecallButton` now uses `GestureDetector(behavior: HitTestBehavior.opaque)`.
  - Removed `InkWell`-driven highlight fill layer causing square artifact.
- Validation:
  - `dart format lib test` passed
  - `flutter analyze` passed
  - `flutter test` passed
