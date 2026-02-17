# Project Rules

## Decision Logging (Global Rule)

1. All important project decisions MUST be recorded in `DECISION_LOG.md`.
2. This rule applies to all future work in this repository.
3. Every new decision MUST be appended to the bottom of `DECISION_LOG.md`.
4. No existing decision log entries should be deleted or reordered.
5. Every decision entry MUST begin with these fields (in this order):
   - `What it is?`
   - `Why?`
   - `How it helps?`
6. Every decision entry MUST end with implementation specifics under:
   - `Implementation Details`
7. `Implementation Details` must include concrete file paths and key behavioral/logic changes where applicable.

## Feature Flag Registry (Global Rule)

1. Every new feature flag MUST be documented in `FEATURE_FLAGS.md`.
2. `FEATURE_FLAGS.md` is the source of truth for active/retired flags.
3. Flag updates MUST be append-only in the `Change Log` section.
4. Any decision log entry that introduces or changes a feature flag MUST reference the matching `FEATURE_FLAGS.md` entry.

## Entry Format Rule

Use this structure for each appended decision:

```md
## Decision <ID>: <Title>
Date: YYYY-MM-DD
Status: Accepted

What it is?
- ...

Why?
- ...

How it helps?
- ...

Details
- ...

Implementation Details
- Files touched:
  - /absolute/path/to/file
- Key code/logic changes:
  - ...
- Validation:
  - ...
```
