# Google Sign-In Setup Guide

## Overview
Your app uses **Google Sign-In** (not Firebase Auth directly). The authentication flow is:
1. User signs in with Google → App gets Google ID token
2. App sends ID token to your backend API (`/auth/google`)
3. Backend validates token and returns access/refresh tokens

## Setup Options

### Option 1: Google Cloud Console (Recommended - No Firebase needed)
This is what you need since your backend handles authentication.

### Option 2: Firebase Console (Easier, but optional)
Firebase can make OAuth setup easier, but it's not required.

---

## Setup Steps (Google Cloud Console)

### Step 1: Get Your SHA-1 Fingerprint

**For Debug Build:**
```bash
# Windows (PowerShell)
keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android

# Mac/Linux
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

**For Release Build:**
```bash
keytool -list -v -keystore <path-to-your-release-keystore> -alias <your-key-alias>
```

Look for the line that says **SHA1:** and copy that value.

### Step 2: Create OAuth 2.0 Client ID

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing one
3. Enable **Google Sign-In API**:
   - Go to "APIs & Services" → "Library"
   - Search for "Google Sign-In API"
   - Click "Enable"

4. Create OAuth 2.0 Credentials:
   - Go to "APIs & Services" → "Credentials"
   - Click "Create Credentials" → "OAuth client ID"
   - Application type: **Android**
   - Name: `Genwalls Android App` (or any name)
   - Package name: `com.example.genwalls` (check your `AndroidManifest.xml`)
   - SHA-1 certificate fingerprint: Paste your SHA-1 from Step 1
   - Click "Create"

5. Copy the **Client ID** (you'll see it after creation)

### Step 3: Configure Android App (Optional - if needed)

If you need to specify the client ID in your app, you can add it to `AndroidManifest.xml`:

```xml
<meta-data
    android:name="com.google.android.gms.auth.api.signin.clientId"
    android:value="YOUR_CLIENT_ID_HERE" />
```

However, with `google_sign_in` package, it usually auto-detects the client ID from `google-services.json` OR you can configure it in code.

### Step 4: Verify Package Name

Check your package name matches:
- File: `android/app/src/main/AndroidManifest.xml`
- Look for: `package="com.example.genwalls"`

Make sure this matches what you entered in Google Cloud Console.

---

## Setup Steps (Firebase Console - Optional but Easier)

If you want to use Firebase Console (which makes setup easier):

### Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project" or select existing
3. Follow the setup wizard

### Step 2: Add Android App to Firebase

1. In Firebase Console, click "Add app" → Android
2. Package name: `com.example.genwalls`
3. App nickname: `Genwalls` (optional)
4. Register app

### Step 3: Download `google-services.json`

1. Download the `google-services.json` file
2. Place it in: `android/app/google-services.json`

### Step 4: Configure build.gradle

Add to `android/build.gradle` (project level):
```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

Add to `android/app/build.gradle` (app level):
```gradle
apply plugin: 'com.google.gms.google-services'
```

### Step 5: Add SHA-1 Fingerprint

1. In Firebase Console → Project Settings → Your Android app
2. Click "Add fingerprint"
3. Paste your SHA-1 fingerprint
4. Click "Save"

---

## Which Option Should You Use?

### Use Google Cloud Console if:
- ✅ Your backend handles all authentication
- ✅ You don't need Firebase features (Analytics, Crashlytics, etc.)
- ✅ You want minimal setup

### Use Firebase Console if:
- ✅ You want easier OAuth management
- ✅ You plan to use other Firebase features
- ✅ You want automatic configuration

**Note:** Both options create OAuth 2.0 credentials. Firebase just makes it easier to manage.

---

## Troubleshooting Error Code 10 (DEVELOPER_ERROR)

If you get error code 10, check:

1. ✅ SHA-1 fingerprint is added correctly
2. ✅ Package name matches exactly
3. ✅ OAuth client ID is created for Android (not Web)
4. ✅ Google Sign-In API is enabled
5. ✅ Wait 5-10 minutes after adding SHA-1 (Google needs time to propagate)

---

## Testing

After setup:
1. Build and run your app
2. Try Google Sign-In
3. Check logs for any errors
4. If error code 10 persists, verify all steps above

---

## Your Current Setup

Based on your code:
- ✅ Using `google_sign_in` package
- ✅ Backend API endpoint: `/auth/google`
- ✅ Backend handles token validation
- ❌ Need to configure OAuth in Google Cloud Console
- ❌ Need to add SHA-1 fingerprint

You **don't need Firebase** for authentication, but you **do need** Google Cloud Console OAuth setup.

