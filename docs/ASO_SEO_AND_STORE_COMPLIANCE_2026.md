# ImagifyAI — ASO, SEO & Store Compliance (2026)

**Role:** Lead ASO/SEO & Store Policy  
**Scope:** App Store (iOS), Google Play (Android), in-app metadata, privacy/terms, and 2026 policy alignment.

---

## 1. Executive Summary

| Area | Status | Priority |
|------|--------|----------|
| App metadata (name, description) | Needs improvement | High |
| Privacy Policy & Terms (placeholders, URLs) | Must fix | High |
| iOS 2026 (SDK, age rating, Xcode 26) | Plan ahead | High |
| Google Play 2026 (Data safety, developer verification) | Declare & verify | High |
| iOS usage descriptions (photo/camera) | Missing — add | High |
| ASO (keywords, screenshots, listing copy) | Document & optimize | Medium |
| Contact / support consistency | Inconsistent emails | Medium |

---

## 2. App Store (iOS) — 2026 Requirements

### 2.1 SDK & tooling (Apple)

- **By April 2026:** New apps and updates must be built with **iOS 26 SDK** (or later) and **Xcode 26 or later**.
- **Action:** When Xcode 26 is released, upgrade the project, set minimum iOS version to 26 (or as required), and build with Xcode 26 for submission.
- **Current:** Project uses Flutter; ensure Flutter supports iOS 26 when Apple enforces it and that `ios/Podfile` / deployment target are updated.

### 2.2 Age rating (App Store Connect)

- **By January 31, 2026:** Complete the **updated age rating questionnaire** in App Store Connect (new tiers: 4+, 9+, 13+, 16+, 18+).
- **ImagifyAI:** AI image generation, optional account, optional ads. Likely **4+** or **9+** if no UGC/messaging; if you allow sharing/user content, declare it. No gambling/restricted content.
- **Action:** In App Store Connect, answer the new questionnaire (in-app controls, capabilities, advertising, user-generated content, etc.) so your app gets a rating and submissions are not blocked.

### 2.3 App name and display (iOS)

- **Current:** `CFBundleDisplayName` / `CFBundleName` = **"imagifyai"** (all lowercase) in `ios/Runner/Info.plist`.
- **ASO:** Consider **"Imagify AI"** (or your brand) for display name so the listing looks consistent with Android and is more readable. Align with Android `android:label="Imagify AI"` if that’s your chosen brand.
- **Action:** If you want consistency and better ASO, set `CFBundleDisplayName` to `Imagify AI` in Info.plist (or your final brand name).

### 2.4 Privacy and usage descriptions (iOS) — required

- **Current:** No `NSPhotoLibraryUsageDescription`, `NSCameraUsageDescription`, or `NSPhotoLibraryAddUsageDescription` in `Info.plist`.
- **Risk:** Using photo library or camera without these can cause rejection or runtime issues. Your app uses `image_picker` (sign up profile photo, edit profile photo).
- **Action:** Add the following to `ios/Runner/Info.plist` (see Section 8 below for exact keys). Recommended text:
  - **NSPhotoLibraryUsageDescription:** “Imagify AI needs access to your photos to let you choose a profile picture.”
  - **NSCameraUsageDescription:** “Imagify AI needs camera access to take a profile picture.”
  - **NSPhotoLibraryAddUsageDescription:** “Imagify AI needs permission to save generated wallpapers to your photo library.” (Use if you save images to gallery.)
- **App Tracking Transparency (ATT):** If you use IDFA or similar for ads/analytics, add `NSUserTrackingUsageDescription` and request ATT before tracking. With Google Mobile Ads and Firebase Analytics, declare in App Privacy and, if you track, implement ATT where required.

---

## 3. Google Play (Android) — 2026 Requirements

### 3.1 Data safety and privacy policy

- **Required:** Complete the **Data safety** form in Play Console and provide a **public Privacy Policy URL** (even if you collect no data).
- **Current:** Privacy Policy and Terms exist **in-app only** (no live web URL). Play and Apple often require a **stable URL** to the same policy.
- **Action:**
  1. Host your Privacy Policy and Terms on a webpage. Your privacy policy is live at: **https://imagifyai.io/privacy-policy** (add a Terms URL similarly if needed, e.g. `https://imagifyai.io/terms`).
  2. Enter that URL in Play Console (Data safety / Store settings) and in App Store Connect (App Privacy / App Information).
  3. Optionally, in-app screens can “Open in browser” to the same URL for consistency.

### 3.2 Data safety form content (Play Console)

Declare accurately:

- **Account:** Email, name (for sign up / profile).
- **App activity:** Prompts, generated images (if stored or processed on your/third-party servers).
- **Analytics:** Firebase Analytics, session/usage data — declare as “Analytics” and whether data is shared.
- **Advertising:** Google Mobile Ads (and AD_ID permission) — declare ads, and whether you use advertising ID / share with ad partners.
- **Device/identifiers:** As required by your SDKs (e.g. Firebase, AdMob).

Ensure **no sale of personal data** and that disclosures match your in-app Privacy Policy.

### 3.3 Developer verification (2026)

- **Google:** Mandatory developer verification for distribution (including outside Play) is rolling out (e.g. 2026). Ensure your Play Console account is verified (identity, payment profile if needed).
- **Action:** Complete any verification prompts in Play Console and keep account details current.

### 3.4 Target SDK and permissions

- **Current:** `compileSdk` / `targetSdk` from Flutter; `minSdk` from Flutter. Play may require a minimum target SDK (e.g. 34+ in recent years).
- **Action:** Check [Play Console Policy table](https://support.google.com/googleplay/android-developer/table/12921780) for 2026 target SDK and update `android/app/build.gradle.kts` if needed.
- **AD_ID:** You declare `com.google.android.gms.permission.AD_ID` — ensure Data safety declares use of advertising ID if you use it.

---

## 4. In-App Legal & Support Consistency

### 4.1 Placeholders to fix

- **Privacy Policy screen:** “Last updated: **[Insert Date]**” and “contact us at **[Your Support Email]**”.
- **Terms of Use screen:** “Last updated: **[Insert Date]**” and “**[Insert office address, if any]**”.
- **Action:** Replace with real date (e.g. last revised date) and real support email. Use a single support email across app and stores (e.g. support@imagifyai.com or your chosen address).

### 4.2 Contact consistency

- **Terms of Use:** “support@imagifyai.com”.
- **Contact Us screen:** “info@nexvoltsolutions.com” and a phone number.
- **Action:** Decide one canonical support contact (e.g. support@imagifyai.com). Use it in Terms, Privacy Policy, Contact Us, and store listings. If you keep a separate “developer” email (e.g. info@nexvoltsolutions.com), label it clearly (e.g. “Developer”) so users and reviewers see one primary support channel.

---

## 5. ASO (App Store Optimization)

### 5.1 App name and subtitle (iOS)

- **Name:** “Imagify AI” (or final brand) — short, memorable, keyword-friendly.
- **Subtitle (30 chars):** e.g. “AI Wallpaper & Image Creator”.

### 5.2 Keywords (iOS)

- **100 characters, comma-separated, no spaces after commas.** Include: AI wallpaper, image generator, AI art, wallpaper maker, AI creator, custom wallpaper, etc. Avoid repeating words from app name/subtitle.
- **Action:** Maintain a keywords list and A/B test in App Store Connect.

### 5.3 Short and long description (both stores)

- **Short (80 chars Android / subtitle iOS):** Value proposition + primary keyword.
- **Long:** Bullets: AI-generated wallpapers, multiple styles, save & share, account optional, etc. Include a clear “What’s new” for updates.
- **Action:** Draft store listing copy in a doc (e.g. `docs/store_listing_copy.md`) and keep “Last updated” in sync with app version.

### 5.4 Screenshots and preview video

- **iOS:** 6.7", 6.5", 5.5" (optional); iPad if supported. Show: onboarding, creation flow, result, library, profile.
- **Android:** Phone and optionally tablet. Same flow.
- **Video (optional):** 15–30 s showing “prompt → style → result → save”.
- **Action:** Use real UI; add short captions (e.g. “Create in seconds”) for clarity.

### 5.5 Pubspec and project description

- **Current:** `description: "A new Flutter project."`
- **Action:** Set a proper one-line description (used by tools and some store metadata): e.g. “AI-powered wallpaper and image generator — create, save, and share.”

---

## 6. SEO and Discoverability (Web)

- If you have a **website** (e.g. imagifyai.com): publish Privacy Policy and Terms there; use same titles and key phrases as in-app; add structured data if applicable.
- **Action:** Use the same support email and policy URLs in app, App Store Connect, Play Console, and website.

---

## 7. Checklist Summary

**High priority**

- [ ] Add iOS usage descriptions (photo library, camera, save to library if used) in `Info.plist`.
- [ ] Host Privacy Policy and Terms at public URLs; add URLs to Play Console and App Store Connect.
- [ ] Complete Google Play Data safety form (account, analytics, ads, identifiers).
- [ ] Replace “[Insert Date]” and “[Your Support Email]” (and address placeholder) in Privacy and Terms in-app.
- [ ] Unify support contact (one primary email) across Terms, Privacy, Contact Us, and stores.
- [ ] Plan for Xcode 26 / iOS 26 SDK and complete App Store age rating questionnaire by Jan 31, 2026.

**Medium priority**

- [ ] Set `CFBundleDisplayName` to “Imagify AI” (or brand) for ASO consistency with Android.
- [ ] Update `pubspec.yaml` description.
- [ ] Draft and maintain store listing copy (short/long description, keywords) in `docs/store_listing_copy.md`.
- [ ] Prepare screenshots and optional preview video for both stores.

**Ongoing**

- [ ] Bump version/build for each store submission; keep “What’s new” aligned.
- [ ] Review Apple and Google policy pages annually (2026 and beyond).

---

## 8. Code / Config Changes to Apply

### 8.1 iOS — add usage descriptions to `ios/Runner/Info.plist`

Add inside the top-level `<dict>` (e.g. after `UISupportedInterfaceOrientations~ipad`):

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>Imagify AI needs access to your photos to choose a profile picture.</string>
<key>NSCameraUsageDescription</key>
<string>Imagify AI needs camera access to take a profile picture.</string>
<key>NSPhotoLibraryAddUsageDescription</key>
<string>Imagify AI needs permission to save generated wallpapers to your photo library.</string>
```

(If you do not save wallpapers to the photo library, you can omit `NSPhotoLibraryAddUsageDescription` or add it when you implement save-to-gallery.)

### 8.2 Optional: display name (ASO)

In `ios/Runner/Info.plist`, set:

- `CFBundleDisplayName` = `Imagify AI` (or your final brand name)
- `CFBundleName` can stay `imagifyai` for the bundle name.

---

## 9. References (2026)

- [Apple — Upcoming requirements (SDK, Xcode 26)](https://developers.apple.com/news/upcoming-requirements)
- [Apple — Age rating updates](https://developer.apple.com/news/upcoming-requirements/?id=07242025a)
- [Google Play — Data safety](https://support.google.com/googleplay/android-developer/answer/10787469)
- [Google Play — Policy deadlines](https://support.google.com/googleplay/android-developer/table/12921780)
