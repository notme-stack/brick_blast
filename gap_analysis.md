# Gap Analysis: Brick Blast (v1.0 to v2.0 Roadmap)

This document outlines the gap between the current implementation of **Brick Blast** and a fully polished, commercially viable mobile game. It identifies key areas for enhancement, missing features, and technical debt.

## 1. Core Gameplay & "Juice"
**Current State:**
- Functional turn-based shooter loop.
- Basic physics and collision detection.
- Simple level progression.

**Gaps & Enhancements:**
- **Audit System**: No sound effects (SFX) or background music (BGM).
    - *Need:* Impact sounds, launch sounds, level win/loss stings, ambient background track.
    - *Tech:* Implement an `AudioService` (using `audioplayers` or `flame_audio`).
- **Haptic Feedback**: No vibration on interaction.
    - *Need:* Subtle haptics for ball collisions, UI taps, and heavy impacts (boss waves).
- **Visual Polish**:
    - *Need:* Particle effects for brick destruction, screen shake on heavy hits, trail renderers for balls.
    - *Need:* Animated transitions for UI (score counting up, level start animations).

## 2. Meta-Game & Retention
**Current State:**
- Basic "Home Screen" with high score and total coins.
- "Guest" login only.

**Gaps & Enhancements:**
- **Economy Sinks**: Coins are earned but have no use.
    - *Need:* A **Shop** to spend coins on:
        - Ball Skins / Trails.
        - Launcher Skins.
        - Power-ups (Start with extra balls, aim assist extension).
- **Progression Systems**:
    - *Need:* **Leaderboards** (Global and Friend rankings) via Firebase or Play Games Services.
    - *Need:* **Achievements** (e.g., "Break 1000 Bricks", "Reach Level 50").
- **Onboarding**:
    - *Need:* A strictly guided **Tutorial** for the first run (how to aim, what power-ups do).

## 3. Monetization
**Current State:**
- None.

**Gaps & Enhancements:**
- **Ads Integration**:
    - *Need:* **Rewarded Video Ads** (Revive after Game Over, Double Coins at end of level).
    - *Need:* **Interstitial Ads** (Between levels, frequency capped).
- **In-App Purchases (IAP)**:
    - *Need:* "Remove Ads" purchase.
    - *Need:* Coin packs.

## 4. Technical Infrastructure
**Current State:**
- Local Storage (`SharedPreferences`) for data persistence.
- Basic "Guest" auth.

**Gaps & Enhancements:**
- **Cloud Save**:
    - *Need:* Sync progress across devices using **Firebase Auth** + **Firestore** or **Cloud Storage**.
- **Settings**:
    - *Need:* A Settings screen to toggle Music/SFX/Vibration and manage account (Sign Out/Delete).
- **Analytics & Crash Reporting**:
    - *Need:* Integrate **Firebase Crashlytics** and **Analytics** to track retention, rigid levels, and crashes.
- **Performance**:
    - *Need:* Object pooling for Balls and Particles (if not already strictly implemented) to scale to 100+ balls without frame drops.

## 5. Summary Roadmap
| Priority | Feature | Effort | Impact |
| :--- | :--- | :--- | :--- |
| **High** | Audio System (SFX + Music) | Medium | ⭐⭐⭐⭐⭐ (Feel) |
| **High** | Settings Screen | Low | ⭐⭐⭐ (UX) |
| **High** | Cloud Save / Persistent Auth | High | ⭐⭐⭐⭐⭐ (Retention) |
| **Medium** | Shop & Inventory (Skins) | High | ⭐⭐⭐⭐ (Economy) |
| **Medium** | AdMob Integration | Medium | ⭐⭐⭐⭐⭐ (Revenue) |
| **Low** | Leaderboards | Medium | ⭐⭐⭐ (Social) |
