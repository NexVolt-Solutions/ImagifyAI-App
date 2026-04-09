# Environment and secrets setup

All API keys, AdMob IDs, and the Google Web Client ID are loaded from environment files so they are not committed to git.

---

## 1. Flutter / Dart (`assets/env/default.env`)

The app bundles **`assets/env/default.env`** so **debug/release builds work on a fresh clone** without extra steps. Defaults match `EnvConstants` fallbacks.

1. **To customize** (API URL, Google client ID, ad unit IDs), edit **`assets/env/default.env`** before `flutter run` / `flutter build`. Do not commit production secrets in that file; use CI to inject the file for release builds if needed.

2. **Reference template:** `.env.example` lists the same variables for copy-paste.

   | Variable | Description |
   |----------|-------------|
   | `API_BASE_URL` | Backend API base URL (e.g. `https://api.imagifyai.io/api/v1`) |
   | `GOOGLE_WEB_CLIENT_ID` | Google Sign-In Web Client ID from Firebase/Cloud Console |
   | `ADMOB_APP_ID` | AdMob app ID (e.g. `ca-app-pub-xxx~yyy`) – used for reference; Android uses `secrets.properties` |
   | `ADMOB_REWARDED_AD_UNIT_ID` | AdMob Rewarded ad unit ID |
   | `ADMOB_INTERSTITIAL_AD_UNIT_ID` | AdMob Interstitial ad unit ID |
   | `ADS_ENABLE_INTERSTITIAL` | Set `true` to enable interstitials (client-side AdMob only) |
   | `ADS_INTERSTITIAL_FIRST_AFTER` | Successful generations in the **rolling 24-hour window** before first interstitial (default **5**) |
   | `ADS_INTERSTITIAL_EVERY_N_AFTER_FIRST` | After that **same window**, every N generations (default **3** → **5 → ad → 3 → ad → …**; window resets after 24h from its start) |
   | `ADS_INTERSTITIAL_COOLDOWN_SECONDS` | Minimum seconds between impressions (default 90) |

   The window uses **server time** estimated from API `Date` headers ([`ServerClock`]); device clock changes alone do not roll the window. Not enforced by the API (server still enforces real quotas).

3. A root **`.env`** file is optional and **not** used by the app (it is still in `.gitignore` if you use it for other tooling).

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
| API base URL | `assets/env/default.env` → `API_BASE_URL` |
| Google Web Client ID | `assets/env/default.env` → `GOOGLE_WEB_CLIENT_ID` |
| AdMob App ID | `android/secrets.properties` or `key.properties` → `ADMOB_APP_ID` |
| AdMob Rewarded ad unit ID | `assets/env/default.env` → `ADMOB_REWARDED_AD_UNIT_ID` |
| AdMob Interstitial ad unit ID | `assets/env/default.env` → `ADMOB_INTERSTITIAL_AD_UNIT_ID` |

Code that needs these values reads them via `EnvConstants` (Dart) or Gradle manifest placeholders (Android).
