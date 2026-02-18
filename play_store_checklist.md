# Play Store Publication Checklist: Brick Blast

This document outlines the mandatory steps to prepare **Brick Blast** for the Google Play Store.

## 🚨 Critical Blockers (Must Fix First)
These issues **will** prevent you from even uploading the APK/AAB to the console.

- [ ] **Rename Package ID**:
    - Current: `com.example.brick_blast`
    - Action: Change to a unique domain you own (e.g., `com.vibecoding.brickblast`). `com.example` is **rejected** by Play Store.
- [ ] **Sign with Release Keystore**:
    - Current: Using `debug` keys for release build.
    - Action: Generate a secure `.jks` keystore and configure `build.gradle.kts` to use it.
- [ ] **Generate App Bundle (.aab)**:
    - Current: Generating `.apk`.
    - Action: Run `flutter build appbundle`. Play Store requires AAB format now (smaller size, optimized delivery).

## 1. Store Listing Assets
Prepare these files to upload to the "Main Store Listing" page.

- [ ] **App Icon**:
    - Size: 512 x 512 px (PNG/JPEG).
    - *Status*: Created (`assets/images/app_icon.png` - check high-res version).
- [ ] **Feature Graphic**:
    - Size: 1024 x 500 px.
    - *Status*: Created (`assets/marketing/feature_graphic.png`).
- [ ] **Screenshots**:
    - Requirements: Min 2 per device type. Max 8.
    - [ ] **Phone**: 6.5-inch aspect ratio (e.g., 1080x2400).
    - [ ] **7-inch Tablet**: e.g., 1280x800.
    - [ ] **10-inch Tablet**: e.g., 1920x1200.
- [ ] **Descriptions**:
    - [ ] **Short Description**: Max 80 characters (e.g., "Blast bricks in this neon arcade shooter!").
    - [ ] **Full Description**: Max 4000 characters (Detail features, levels, power-ups).
- [ ] **Video** (Optional): YouTube video URL (landscape orientation).

## 2. Technical Configuration
- [ ] **Version Code**: Ensure it's an integer that increments with every upload (currently `1`).
- [ ] **Target Audience**: Complete the content rating questionnaire (IARC) in the console.
- [ ] **Privacy Policy**:
    - Action: Host a simple privacy policy page (GitHub Pages or Google Doc) and link it.
- [ ] **Data Safety Form**:
    - Declare data usage. (Brick Blast is mostly local, but if you add Firebase/AdMob, you must declare "Location", "Device ID", etc.).

## 3. Testing Strategy
- [ ] **Internal Testing**:
    - Upload the AAB to the "Internal Verification" track first.
    - Add your email as a tester.
    - Download and test specifically for "Release" bugs (obfuscation issues).
- [ ] **Pre-Launch Report**:
    - Google will automatically run your app on ~10 devices. Check this report for crashes on specific models.

## 4. Final Verification
- [ ] **Permissions**: Check `AndroidManifest.xml` to ensure no unnecessary permissions are requested (e.g., Camera, Location) that might scare users.
- [ ] **Obfuscation**: Check `proguard-rules.pro` if using R8 (default in release) to ensure it doesn't strip necessary code.

---

### Recommended Next Step
**"I can help you Rename the Package and Generate the Keystore now if you want to proceed."**
