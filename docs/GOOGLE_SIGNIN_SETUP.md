# Google Sign-In Setup (Firebase project)

**This app uses Firebase project `imagifyai-f8cad`** (configured via FlutterFire CLI). Google Sign-In uses this same project.

## Use Firebase for Google Sign-In

1. **Firebase Console** → project **imagifyai** (ID: `imagifyai-f8cad`) → **Authentication** → **Sign-in method** → enable **Google** (and add support email if prompted).
2. **Web Client ID:** In [Google Cloud Console](https://console.cloud.google.com/) select project **imagifyai-f8cad** → **APIs & Services** → **Credentials** → **"Web client (auto created by Google Service)"** → copy the **Client ID** (e.g. `687032857486-xxxx.apps.googleusercontent.com`).
3. **Update the app:** In `lib/Core/Constants/api_constants.dart` set `googleWebClientId` to that Web client ID.
4. **SHA-1 (Android):** In **Firebase Console** → **Project settings** → **Your apps** → Android app `com.imagifyai.app` → **Add fingerprint** and add your **debug** and **release** SHA-1.

After that, Google Sign-In uses the Firebase project; no separate Cloud Console OAuth setup is required.

---

## Fix DEVELOPER_ERROR / ApiException: 10

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

## 2. Add SHA-1 (Firebase or Cloud Console)

1. Open [Google Cloud Console](https://console.cloud.google.com/) → select your project.
2. Go to **APIs & Services** → **Credentials**.
3. Under **OAuth 2.0 Client IDs**, find your **Android** client (package `com.imagifyai.app`).
   - If it doesn’t exist, click **+ CREATE CREDENTIALS** → **OAuth client ID** → Application type **Android** → Package name `com.imagifyai.app` → add SHA-1.
4. Open that Android client → **Add fingerprint** → paste your SHA-1 (with or without colons) → Save.
5. Add **both** debug and release SHA-1 if you test locally and publish to Play.

**Preferred (Firebase):** Firebase Console → Project settings → Your apps → Android `com.imagifyai.app` → Add fingerprint (debug + release SHA-1). No separate Cloud Console step.

## 4. Checklist

- [ ] **Firebase:** Authentication → Google sign-in method enabled.
- [ ] **Web client ID** in `api_constants.dart` is the **Web client (auto created by Google Service)** from the **same project as Firebase** (Cloud Console → Credentials).
- [ ] **Debug** SHA-1 added in Firebase Project settings → Android app.
- [ ] **Release** SHA-1 added in Firebase Project settings → Android app (for Play Store).

After changing credentials, wait a few minutes and try sign-in again. No code change is required if IDs and SHA-1 are correct.

---

## Verification (with Firebase)

| What | Where to check |
|------|----------------|
| Firebase project | Same project as your app (e.g. `imagifyai-453d3`). |
| Google sign-in | Firebase Console → **Authentication** → **Sign-in method** → **Google** enabled. |
| Web client ID | Cloud Console (same project) → **Credentials** → "Web client (auto created by Google Service)" → copy to `api_constants.dart` → `googleWebClientId`. |
| SHA-1 | Firebase Console → **Project settings** → Android app → **Fingerprints** (debug + release). |

---

## Firebase warning: "SHA-1 and package name already in use"

If Firebase shows **"One or more of your Android apps have a SHA-1 fingerprint and package name combination that's already in use"**, the same app is registered in **two** projects (e.g. imagifyai-453d3 and genwalls-482410). Google allows that combo in only one project.

**Fix:** Remove the duplicate from the **other** project.

1. Open [Firebase Console](https://console.firebase.google.com) and switch to the **other** project (e.g. **genwalls** / genwalls-482410).
2. Go to **Project settings** → **Your apps** → find the Android app with package `com.imagifyai.app`.
3. Remove that Android app (or remove its SHA-1 fingerprints) so that only **imagifyai-453d3** has this app.
4. Wait 5–10 minutes, then try Google Sign-In again.

**Use the right Web Client ID:** Your app must use the **Web client ID from imagifyai-453d3**, not from genwalls. In [Google Cloud Console](https://console.cloud.google.com) select project **imagifyai-453d3** → **APIs & Services** → **Credentials** → copy the **Web client (auto created by Google Service)** Client ID and set it in `lib/Core/Constants/api_constants.dart` as `googleWebClientId`.

---

## Still getting Error 10? Try these

1. **OAuth consent screen (Testing mode)**  
   **APIs & Services** → **OAuth consent screen**. If the app is in **Testing**, add your Google account under **Test users** and Save.

2. **Add SHA-256 as well**  
   Get it: `keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android | grep SHA256`  
   In the same Android OAuth client, add this SHA-256 fingerprint if the Console allows it.

3. **Uninstall the app and reinstall**  
   On the device: **Settings → Apps → Imagify AI → Uninstall**. Then run `flutter run` again so the app is reinstalled with the current config.

4. **Correct Google Cloud project**  
   Top bar in Console must show project **imagifyai-482410** (or the project that owns client ID `247136119306-...`). Switch project if needed.

5. **Re-add SHA-1**  
   In the Android client, remove the existing SHA-1 fingerprint, Save, then **Add fingerprint** again and paste:  
   `B3:DB:69:75:8B:A3:66:BA:D0:5C:77:2D:67:67:B0:26:AA:BE:40:26`  
   (avoids invisible characters from copy-paste.)
