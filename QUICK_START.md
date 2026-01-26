# 🚀 Quick Start - Upload to Play Store

## ✅ What's Already Done

- ✅ Application ID changed to `com.imagifyai.app`
- ✅ App name set to "Imagify AI"
- ✅ Release signing configuration ready
- ✅ Build optimization enabled
- ✅ Package structure updated

## 📝 3 Simple Steps

### Step 1: Generate Keystore (One-time)

Run in PowerShell:
```powershell
keytool -genkey -v -keystore android/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

**Save your passwords!** You'll need them forever.

### Step 2: Setup Signing

Run the setup script:
```powershell
.\setup-release-signing.ps1
```

This creates `android/key.properties` with your passwords.

### Step 3: Build & Upload

Build the release:
```powershell
.\build-release.ps1
```

Or manually:
```powershell
flutter build appbundle --release
```

Then upload `build/app/outputs/bundle/release/app-release.aab` to Google Play Console!

---

**Need help?** See `PLAY_STORE_RELEASE_GUIDE.md` for detailed instructions.

