# Google Sign-In Setup (Fix DEVELOPER_ERROR / ApiException: 10)

**This app does NOT use Firebase.** Sign-in uses **Google Cloud OAuth** only. You do **not** need `google-services.json` or Firebase Console for Google Sign-In to work—only **Google Cloud Console** credentials and SHA-1.

Error **10** means the app's **SHA-1 fingerprint** is not registered for your Android OAuth client. Do the following.

## 1. Get your SHA-1 fingerprint

### Debug (when running from Android Studio / `flutter run`)
```bash
cd android && ./gradlew signingReport
```
Or with keytool (default debug keystore):
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```
Copy the **SHA-1** line (e.g. `SHA1: AB:CD:EF:...`).

### Release (when building app bundle / APK for Play Store)
Use the keystore you use to sign the release build:
```bash
keytool -list -v -keystore /path/to/your/upload-keystore.jks -alias your-key-alias
```
Copy the **SHA-1** for that key.

## 2. Add SHA-1 in Google Cloud Console

1. Open [Google Cloud Console](https://console.cloud.google.com/) → select your project.
2. Go to **APIs & Services** → **Credentials**.
3. Under **OAuth 2.0 Client IDs**, find your **Android** client (package `com.imagifyai.app`).
   - If it doesn’t exist, click **+ CREATE CREDENTIALS** → **OAuth client ID** → Application type **Android** → Package name `com.imagifyai.app` → add SHA-1.
4. Open that Android client → **Add fingerprint** → paste your SHA-1 (with or without colons) → Save.
5. Add **both** debug and release SHA-1 if you test locally and publish to Play.

## 3. If you use Firebase

1. [Firebase Console](https://console.firebase.google.com/) → your project → **Project settings** (gear).
2. Under **Your apps**, select the Android app with package `com.imagifyai.app`.
3. Click **Add fingerprint** → paste SHA-1 → Save.
4. Download the updated `google-services.json` and replace the one in `android/app/` if you use Firebase.

## 4. Checklist

- [ ] Package name in Cloud Console Android client is exactly `com.imagifyai.app`.
- [ ] **Debug** SHA-1 added (for `flutter run` / debug builds).
- [ ] **Release** SHA-1 added (for Play Store / release builds).
- [ ] Android client ID in `AndroidManifest.xml` matches the Android OAuth client ID in Cloud Console.
- [ ] Web client ID in `api_constants.dart` (`googleWebClientId`) is the **Web** OAuth client ID from the same project (used for `serverClientId`).

After changing credentials, wait a few minutes and try sign-in again. No code change is required if IDs and SHA-1 are correct.

---

## Verification (no Firebase)

| What | Where to check |
|------|----------------|
| Firebase | **Not used** in this project. No need to configure Firebase or add `google-services.json`. |
| OAuth project | [Google Cloud Console](https://console.cloud.google.com/) → correct project selected. |
| Android OAuth client | **Credentials** → OAuth 2.0 Client IDs → one entry with type **Android**, package **`com.imagifyai.app`**. |
| SHA-1 on Android client | Same Android client → **Fingerprints** must include your debug SHA-1 (and release when publishing). |
| Android client ID in app | Must match `AndroidManifest.xml` → `com.google.android.gms.auth.api.signin.clientId`. |
| Web client ID in app | Must match **Web** OAuth client ID in Cloud Console → `api_constants.dart` → `googleWebClientId`. |
