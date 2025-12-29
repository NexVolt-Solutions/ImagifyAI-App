# Google Cloud Console - Step-by-Step Setup for Google Sign-In

## Current Status
✅ You're logged into Google Cloud Console
✅ Project: `genwalls-482410` (Project ID)
✅ Project Number: `247136119306`

## Step-by-Step Instructions

### Step 1: Enable Google Sign-In API

1. In the Google Cloud Console, click on **"Enable recommended APIs"** button (you should see this on your dashboard)
   - OR go to: **APIs & Services** → **Library** (from left sidebar)
2. Search for: **"Google Sign-In API"**
3. Click on **"Google Sign-In API"**
4. Click **"Enable"** button
5. Wait for it to enable (usually takes a few seconds)

### Step 2: Get Your SHA-1 Fingerprint

**For Debug Build (Development):**

Open PowerShell or Command Prompt and run:

```powershell
keytool -list -v -keystore "$env:USERPROFILE\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
```

**What to look for:**
- Find the line that says: **SHA1: XX:XX:XX:XX:...**
- Copy the entire SHA1 value (it will look like: `A1:B2:C3:D4:E5:F6:...`)

**Example output:**
```
Certificate fingerprints:
     SHA1: A1:B2:C3:D4:E5:F6:11:22:33:44:55:66:77:88:99:AA:BB:CC:DD:EE
     SHA256: ...
```

### Step 3: Create OAuth 2.0 Client ID

1. In Google Cloud Console, go to: **APIs & Services** → **Credentials** (from left sidebar)
2. Click **"+ CREATE CREDENTIALS"** button (top of the page)
3. Select **"OAuth client ID"**
4. If prompted, configure OAuth consent screen first:
   - User Type: **External** (unless you have Google Workspace)
   - App name: **Genwalls**
   - User support email: Your email
   - Developer contact: Your email
   - Click **"Save and Continue"**
   - Scopes: Click **"Save and Continue"** (default scopes are fine)
   - Test users: Click **"Save and Continue"** (skip for now)
   - Summary: Click **"Back to Dashboard"**

5. Now create OAuth Client ID:
   - Application type: Select **"Android"**
   - Name: `Genwalls Android App` (or any name you prefer)
   - Package name: `com.example.genwalls`
   - SHA-1 certificate fingerprint: Paste the SHA1 you copied in Step 2
   - Click **"Create"**

6. **IMPORTANT:** Copy the **Client ID** that appears (it will look like: `123456789-abcdefghijklmnop.apps.googleusercontent.com`)
   - You might not need to add this to your code if using `google-services.json`, but keep it for reference

### Step 4: Verify Package Name

Your package name should be: `com.example.genwalls`

To verify:
- Check file: `android/app/build.gradle.kts`
- Look for: `applicationId = "com.example.genwalls"`

Make sure this **exactly matches** what you entered in Step 3.

### Step 5: Test the Setup

1. **Wait 5-10 minutes** after creating the OAuth Client ID (Google needs time to propagate changes)
2. Build and run your Flutter app
3. Try Google Sign-In
4. If you get error code 10, double-check:
   - SHA-1 fingerprint is correct
   - Package name matches exactly
   - Google Sign-In API is enabled
   - Wait a bit longer if you just created it

## Quick Checklist

- [ ] Google Sign-In API is enabled
- [ ] OAuth consent screen is configured
- [ ] OAuth 2.0 Client ID created for Android
- [ ] SHA-1 fingerprint added correctly
- [ ] Package name matches: `com.example.genwalls`
- [ ] Waited 5-10 minutes after setup
- [ ] Tested Google Sign-In in app

## Troubleshooting

### Error Code 10 (DEVELOPER_ERROR)
- ✅ Check SHA-1 fingerprint is correct
- ✅ Verify package name matches exactly
- ✅ Ensure Google Sign-In API is enabled
- ✅ Wait 5-10 minutes after changes

### Still Getting Errors?
1. Double-check SHA-1 fingerprint (make sure you copied the entire value)
2. Verify package name in `build.gradle.kts` matches OAuth Client ID
3. Try creating a new OAuth Client ID if the first one doesn't work
4. Check that you're using the debug keystore SHA-1 for debug builds

## Your Project Details
- **Project ID:** `genwalls-482410`
- **Project Number:** `247136119306`
- **Package Name:** `com.example.genwalls`

## Next Steps After Setup

Once OAuth is configured:
1. Your app will be able to get Google ID tokens
2. These tokens will be sent to your backend API (`/auth/google`)
3. Your backend will validate and create/login the user
4. No Firebase needed - your backend handles everything!

---

**Note:** You don't need Firebase for this setup. Google Cloud Console OAuth is sufficient since your backend handles authentication.

