# Google Play Store Release Guide for Imagify AI

## ✅ Configuration Complete

The following has been configured:
- ✅ Application ID updated to `com.imagifyai.app`
- ✅ App name set to "Imagify AI"
- ✅ Release signing configuration added
- ✅ Build optimization enabled (minify & shrink resources)

## 📋 Steps to Upload to Play Store

### Quick Setup (Recommended)

**Option 1: Use the automated setup script**

1. **Generate keystore** (one-time, interactive):
   ```powershell
   keytool -genkey -v -keystore android/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```
   Enter your passwords and details when prompted.

2. **Run the setup script**:
   ```powershell
   .\setup-release-signing.ps1
   ```
   This will create the `key.properties` file with your passwords.

3. **Build the release bundle**:
   ```powershell
   .\build-release.ps1
   ```
   Or manually:
   ```powershell
   flutter build appbundle --release
   ```

### Manual Setup (Alternative)

**Step 1: Generate a Keystore (One-time setup)**

**IMPORTANT:** Keep your keystore file and passwords safe! You'll need them for all future updates.

Run this command in PowerShell (from the project root):

```powershell
keytool -genkey -v -keystore android/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

You'll be prompted for:
- **Keystore password**: Choose a strong password (save it!)
- **Key password**: Can be same as keystore password (save it!)
- **Name, Organization, etc.**: Enter your details

**Step 2: Create key.properties File**

1. Copy the template:
   ```powershell
   Copy-Item android\key.properties.template android\key.properties
   ```

2. Edit `android/key.properties` and replace with your actual values:
   ```
   storePassword=YOUR_ACTUAL_STORE_PASSWORD
   keyPassword=YOUR_ACTUAL_KEY_PASSWORD
   keyAlias=upload
   storeFile=upload-keystore.jks
   ```

3. **IMPORTANT:** The `key.properties` file is already in `.gitignore` to keep your passwords safe!

**Step 3: Build the Release App Bundle (AAB)**

Run this command from the project root:

```powershell
flutter build appbundle --release
```

The AAB file will be generated at:
```
build/app/outputs/bundle/release/app-release.aab
```

### Step 4: Upload to Google Play Console

1. Go to your Google Play Console: https://play.google.com/console
2. Select your app "Imagify AI"
3. Go to **Testing** → **Internal testing** (or your chosen track)
4. Click **Create new release**
5. Upload the `app-release.aab` file
6. Fill in:
   - **Release name**: e.g., "1.0.0 (1)" or "Initial Release"
   - **Release notes**: Describe what's new in this version
7. Click **Save** then **Review release**
8. Complete the review and submit

## 🔒 Security Notes

- **Never commit** `key.properties` or `upload-keystore.jks` to version control
- Store your keystore file and passwords in a secure location
- You'll need the same keystore for all future app updates

## 📝 Additional Play Store Requirements

Before publishing, make sure you have:
- ✅ App icon (512x512px)
- ✅ Feature graphic (1024x500px)
- ✅ Screenshots (at least 2, up to 8)
- ✅ App description
- ✅ Privacy policy URL (if required)
- ✅ Content rating questionnaire completed

## 🐛 Troubleshooting

**If build fails:**
- Make sure `key.properties` exists and has correct paths
- Verify keystore file exists at `android/upload-keystore.jks`
- Check that passwords in `key.properties` match your keystore

**If upload fails:**
- Ensure version code is incremented (currently: 1)
- Check that AAB file is not corrupted
- Verify app signing is correct

**"Your Android App Bundle is signed with the wrong key."** (SHA1 mismatch)
- Play Console already has an **upload key** on file (from a previous upload or app setup). Your current AAB is signed with a *different* keystore. You must use the **same** keystore Play expects.
- **Check which key Play expects:** In [Play Console](https://play.google.com/console) → your app → **Setup** → **App signing**. Under "Upload key certificate", you’ll see the expected SHA-1 (e.g. `79:A6:43:2C:...`).
- **Check your keystore’s SHA-1:** Run:
  ```bash
  keytool -list -v -keystore android/upload-keystore.jks -alias upload
  ```
  The SHA1 in the output must match the one in Play Console.
- **If you have the original keystore:** Use that keystore (and its `key.properties`) to build and upload. Replace `android/upload-keystore.jks` with the correct `.jks`/`.keystore` file and point `storeFile` in `key.properties` to it.
- **If you lost the original keystore:** In Play Console → **Setup** → **App signing**, use **Request upload key reset** (see **Request upload key reset** below). The account owner must start the reset; after Google registers your new key, you can upload AABs signed with it. Do not create a new app to “start over” if you already have users or existing releases.

**Request upload key reset** (lost upload key):
1. Only the **developer account owner** can start this. Go to [Play Console](https://play.google.com/console) → your app → **Setup** (or **Test and release** → **Setup**) → **App signing**. Find **Lost or compromised upload key?** / **Request upload key reset**.
2. You will need to upload the **certificate** of your new key (PEM). Generate it from your current keystore:
   ```bash
   keytool -export -rfc -keystore /Users/mac/my-release-key.jks -alias upload -file upload_certificate.pem
   ```
3. In the reset flow, upload `upload_certificate.pem` when prompted. Google support registers the new key; the account owner gets an email when done.
4. After the reset, keep using that keystore in `key.properties`, run `flutter build appbundle --release`, and upload the new AAB. See [Play Help: Lost or compromised upload key?](https://support.google.com/googleplay/android-developer/answer/9842756).

**"All uploaded bundles must be signed."**
- The AAB you uploaded was not signed with a release keystore (e.g. it was a debug build or signing wasn’t configured). Fix:
  1. **Use release signing:** Create `android/key.properties` (see **Step 2** above or run `.\setup-release-signing.ps1`). It must contain `storePassword`, `keyPassword`, `keyAlias`, and `storeFile` pointing to your keystore (e.g. `storeFile=upload-keystore.jks` for a keystore in the `android/` folder).
  2. **Put the keystore where Gradle expects it:** If `storeFile=upload-keystore.jks`, the file must be at `android/upload-keystore.jks`. Generate it there with:  
     `keytool -genkey -v -keystore android/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload`
  3. **Build the release bundle (not debug):** Run `flutter build appbundle --release` from the project root. Do not upload a build from `flutter run` or `flutter build apk` (debug).
  4. **Confirm the build is signed:** After the build, you can check with  
     `jarsigner -verify -verbose -certs build/app/outputs/bundle/release/app-release.aab`  
     (should report “jar verified” when signed).

### Play Console rollout errors

**"This release does not add or remove any app bundles."**
- The release has no app bundle attached. Fix:
  1. Open the release in Play Console (e.g. **Testing** → **Internal testing** → your draft release).
  2. In **App bundles**, click **Upload** and select your `app-release.aab` (from `build/app/outputs/bundle/release/`).
  3. Save the release. Do not remove the only bundle; each release must have at least one AAB.

**"You can't rollout this release because it doesn't allow any existing users to upgrade to the newly added app bundles."**
- Play thinks existing users cannot upgrade to this release. Common causes and fixes:
  1. **No bundle in the release** – Same as above: add your AAB to the release.
  2. **Same or lower version code** – Existing users already have this version. In `pubspec.yaml`, bump the version so the **version code** (the number after `+`) is higher than the one already in production (e.g. `1.0.0+2` if the last release was `+1`). Then run `flutter build appbundle --release` and upload the new AAB.
  3. **Wrong track** – If this is the first release on this track, ensure you’re creating a **new release** and uploading an AAB (not reusing an empty or old release).
  4. **Draft from a previous attempt** – If you previously created a release without an AAB, remove that draft or add the AAB to it. Prefer **Create new release** and upload the AAB in one go.

**Quick fix checklist:**
1. Bump version in `pubspec.yaml` (e.g. `1.0.0+2`).
2. Run `flutter build appbundle --release`.
3. In Play Console, create a **new** release (or open the draft), **upload** `app-release.aab`, add release notes, then **Save** and **Review release**.

## 📱 Version Management

To update the app version, edit `pubspec.yaml`:
```yaml
version: 1.0.1+2  # versionName+versionCode
```

Then rebuild:
```bash
flutter build appbundle --release
```

