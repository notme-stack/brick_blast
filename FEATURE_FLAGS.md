# Feature Flags

This document is the source of truth for feature flags used by the game app.

## Purpose

- Track all active and retired feature flags in one place.
- Document default behavior and safe OFF behavior.
- Keep rollout changes auditable.

## Usage

- Flags are defined in code with typed wrappers in:
  - `/Users/saurabhjawade/Desktop/Vibe Coding Projects/brick_blast/lib/app_shell/feature_flags.dart`
- Toggle at runtime/build using `dart-define`:
  - Default behavior: no flag needed
  - Example OFF:
    - `flutter run --dart-define=BRICK_BLAST_RECALL_ENABLED=false`

## Flag Registry

| Flag Key | Default | Scope/Module | Owner | Rollout Status | Behavior When OFF |
|---|---|---|---|---|---|
| `BRICK_BLAST_RECALL_ENABLED` | `true` | Brick Blast game screen + simulation | Game Team | Active | Recall button is hidden and recall logic path is no-op. Standard ball flow remains unchanged. |

## Change Log (Append-Only)

### 2026-02-17
- Added `BRICK_BLAST_RECALL_ENABLED` for Visual Magnet Recall feature rollout control.
