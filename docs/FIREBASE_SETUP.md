# Firebase Integration Checklist

Your app currently **does not** have Firebase connected. Analytics and other Firebase features will only work after you complete the steps below.

---

## 1. Firebase Console (Account & Project)

1. Go to [Firebase Console](https://console.firebase.google.com/).
2. **Create a project** (or select an existing one).
3. In **Project settings** (gear icon), note your **Project ID**.

---

## 2. Add Your Apps to the Firebase Project

### Android

1. In Firebase Console: **Project Overview** → **Add app** → choose **Android**.
2. **Android package name:** use exactly:
   ```text
   com.imagifyai.app
   ```
3. (Optional) App nickname: e.g. `imagifyai Android`.
4. (Optional) Debug signing certificate SHA-1: add if you use Google Sign-In or other APIs that need it.
5. Click **Register app**.
6. **Download `google-services.json`** and place it in your project at:
   ```text
   android/app/google-services.json
   ```
7. Finish the wizard. The console will tell you to add the Google Services plugin—see **Step 4** below.

### iOS

1. In Firebase Console: **Add app** → **iOS**.
2. **iOS bundle ID:** must match your Xcode project (e.g. `com.imagifyai.app` or the value in `ios/Runner.xcodeproj`).
3. Click **Register app**.
4. **Download `GoogleService-Info.plist`** and add it to the **Runner** target in Xcode (e.g. drag into `ios/Runner/` and ensure “Copy items if needed” and Runner target are checked).
5. Finish the wizard.

---

## 3. Enable Analytics (Optional but Recommended)

1. In Firebase Console: **Build** → **Analytics** → **Get started** (if not already enabled).
2. No extra code needed; events will be sent once the app is configured and `Firebase.initializeApp()` runs.

---

## 4. Code / Project Configuration

### 4.1 Android: Config file and Google Services plugin

1. **Download `google-services.json`** from Firebase Console (see step 2) and put it in:
   ```text
   android/app/google-services.json
   ```
2. **Then** add the Google Services plugin so the file is applied:

   **`android/settings.gradle.kts`** – inside `plugins { }` add:
   ```kotlin
   id("com.google.gms.google-services") version "4.4.2" apply false
   ```

   **`android/app/build.gradle.kts`** – inside `plugins { }` add:
   ```kotlin
   id("com.google.gms.google-services")
   ```

   Do not add the plugin until `google-services.json` is in place, or the Android build will fail.

### 4.2 iOS

- Add **`GoogleService-Info.plist`** to the Runner target (see step 2 above).
- If the Firebase docs tell you to add initialization code in `AppDelegate`, add it as described there (FlutterFire may handle this via the plugins).

### 4.3 Flutter: Initialize Firebase and Analytics

In **`lib/main.dart`**, after `WidgetsFlutterBinding.ensureInitialized();` and before `runApp()`:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:imagifyai/Core/services/analytics_service.dart';
import 'package:imagifyai/Core/services/firebase_analytics_delegate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (requires google-services.json and GoogleService-Info.plist)
  await Firebase.initializeApp();
  AnalyticsService.delegate = FirebaseAnalyticsDelegate();

  await LocalNotificationService.initialize();
  _setupTokenRefresh();
  runApp(const MyApp());
}
```

If you **don’t** add the config files or don’t call `Firebase.initializeApp()`, the app will run as it does now (no Firebase). Only add the code above when the config files are in place.

---

## 5. Verify Integration & Why the Overview Shows "No data"

The **Firebase Analytics overview** (user activity, event count, retention, etc.) will show **0 / "No data available"** until:

1. **Events are sent** – Users (or you) must run the app and trigger actions: open app, generate images, select styles, share. The app sends `session_start`, `session_end`, `image_generated`, `style_selected`, `image_shared` via `AnalyticsService` → `FirebaseAnalyticsDelegate`.
2. **Aggregation delay** – Overview and standard reports can take **24–48 hours** to populate. For immediate checks, use **DebugView** (see below).
3. **Correct build** – The running app must have `Firebase.initializeApp()` and `AnalyticsService.delegate = FirebaseAnalyticsDelegate()` in `main.dart` (already added).

### See events immediately: DebugView

1. **Enable debug mode on the device:**
   - **Android:** `adb shell setprop debug.firebase.analytics.app com.imagifyai.app` (or your package name). To turn off: `adb shell setprop debug.firebase.analytics.app .none.`
   - **iOS:** In Xcode scheme, add launch argument `-FIRAnalyticsDebugEnabled`.
2. Open **Firebase Console** → **Analytics** → **DebugView**.
3. Run the app and use it (open, generate image, pick a style, share). Events should appear in DebugView within seconds.

Once real usage (or test usage) is happening and 24–48 hours have passed, the main **Analytics** overview (user activity, engagement, event count, retention) will start showing data.

---

## Quick Checklist

| Step | Done |
|------|------|
| Firebase project created / selected | ☐ |
| Android app added with package `com.imagifyai.app` | ☐ |
| `google-services.json` in `android/app/` | ☐ |
| Android Gradle: Google Services plugin applied | ☐ |
| iOS app added with correct bundle ID | ☐ |
| `GoogleService-Info.plist` in `ios/Runner/` | ☐ |
| `main.dart`: `Firebase.initializeApp()` + `AnalyticsService.delegate = FirebaseAnalyticsDelegate()` | ☐ |

Until these are done, **Firebase is not integrated**; the app will work without it, and no analytics will be sent.
