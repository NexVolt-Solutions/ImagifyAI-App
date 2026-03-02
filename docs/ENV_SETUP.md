# Environment and secrets setup

All API keys, AdMob IDs, and the Google Web Client ID are loaded from environment files so they are not committed to git.

---

## 1. Flutter / Dart (`.env`)

1. **Copy the example file:**
   ```bash
   cp .env.example .env
   ```
2. **Edit `.env`** and set your values:

   | Variable | Description |
   |----------|-------------|
   | `API_BASE_URL` | Backend API base URL (e.g. `https://api.imagifyai.io/api/v1`) |
   | `GOOGLE_WEB_CLIENT_ID` | Google Sign-In Web Client ID from Firebase/Cloud Console |
   | `ADMOB_APP_ID` | AdMob app ID (e.g. `ca-app-pub-xxx~yyy`) – used for reference; Android uses `secrets.properties` |
   | `ADMOB_REWARDED_AD_UNIT_ID` | AdMob Rewarded ad unit ID |
   | `ADMOB_INTERSTITIAL_AD_UNIT_ID` | AdMob Interstitial ad unit ID |

3. **Do not commit `.env`** — it is listed in `.gitignore`.

---

## 2. Android (AdMob App ID in manifest)

The AdMob **App ID** is injected into `AndroidManifest.xml` at build time from a properties file.

1. **Option A – use `android/secrets.properties`**  
   Copy the example and add your AdMob App ID:
   ```bash
   cp android/secrets.properties.example android/secrets.properties
   ```
   Then set:
   ```properties
   ADMOB_APP_ID=ca-app-pub-xxxxxxxxxxxxxxxx~yyyyyyyyyy
   ```

2. **Option B – use `key.properties`**  
   If you already have `android/key.properties` for signing, you can add the same line there:
   ```properties
   ADMOB_APP_ID=ca-app-pub-xxxxxxxxxxxxxxxx~yyyyyyyyyy
   ```

3. **Do not commit `android/secrets.properties`** — it is in `.gitignore`.

If neither file defines `ADMOB_APP_ID`, the build uses a default (see `android/app/build.gradle.kts`).

---

## 3. Summary

| Secret | Where to set |
|--------|----------------|
| API base URL | `.env` → `API_BASE_URL` |
| Google Web Client ID | `.env` → `GOOGLE_WEB_CLIENT_ID` |
| AdMob App ID | `android/secrets.properties` or `key.properties` → `ADMOB_APP_ID` |
| AdMob Rewarded ad unit ID | `.env` → `ADMOB_REWARDED_AD_UNIT_ID` |
| AdMob Interstitial ad unit ID | `.env` → `ADMOB_INTERSTITIAL_AD_UNIT_ID` |

Code that needs these values reads them via `EnvConstants` (Dart) or Gradle manifest placeholders (Android).
