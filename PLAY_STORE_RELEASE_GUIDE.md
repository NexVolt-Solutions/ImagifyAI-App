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
   storeFile=../upload-keystore.jks
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

## 📱 Version Management

To update the app version, edit `pubspec.yaml`:
```yaml
version: 1.0.1+2  # versionName+versionCode
```

Then rebuild:
```bash
flutter build appbundle --release
```

