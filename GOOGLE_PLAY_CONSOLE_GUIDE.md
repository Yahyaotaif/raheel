# Google Play Console Closed Testing Release Guide

## Build Complete ✅
Your production-signed AAB has been built:
- **File:** `build/app/outputs/bundle/release/app-release.aab`
- **Size:** 45.5 MB
- **Version:** 1.0.0 (v3)
- **App ID:** `com.raheelcorp.raheel`

---

## Step-by-Step: Uploading to Closed Testing

### 1. Go to Google Play Console
- Visit: https://play.google.com/console
- Sign in with your Google account associated with Raheel

### 2. Select Your App
- Click on **"Raheel"** app from the dashboard

### 3. Navigate to Closed Testing
- Left sidebar → **Testing** → **Closed testing**
- Click **Create new release**

### 4. Upload the AAB
- Click **Upload** in the "App bundles" section
- Select: `build/app/outputs/bundle/release/app-release.aab`
- Wait for upload and validation (may take a few seconds)

### 5. Configure Release Notes
- **Name:** "Walkthrough v1.0" (or your chosen name)
- **Release notes:**
  ```
  ### ✨ New Features
  - Added Arabic in-app walkthrough with 4 guided slides
  - Improved onboarding experience with modern gradient UI
  - Added walkthrough accessibility from profile menu
  
  ### 🎨 UI Improvements
  - Modernized splash screen animations
  - Centered walkthrough content for better visual hierarchy
  - Refined navigation buttons for better readability
  
  ### 🐛 Bug Fixes
  - Fixed car animation timing on splash screen
  ```

### 6. Manage Testers
- Scroll to **Testers** section
- Click **Manage Testers**
- Add email addresses of your closed testers
- Example: `your-email@gmail.com`

### 7. Review & Publish
- Click **Review**
- Check all details
- Click **Start rollout**

### 8. Share Testing Link
- Once approved, testers will receive an email with **opt-in link**
- They can click the link to join closed testing
- They'll be able to install from Play Store

---

## Important Notes

### Version Management
- Current version: **1.0.0+3** (from `pubspec.yaml`)
- For next release, increase: `pubspec.yaml` → `version: 1.0.1+4`
- Run: `flutter build appbundle --release` again

### Review Time
- **Closed testing:** Usually 30 minutes - 2 hours
- **If rejected:** Check Google Play Console for rejection reasons

### Tester Access
- Add testers' Gmail addresses (not just email domains)
- They'll see "Open" button instead of "Install" once approved
- No purchase required for closed testing

### How to Get Feedback
1. Testers can rate/review in Play Store
2. Check **Ratings & reviews** section in Google Play Console
3. Respond to reviews within console

---

## Key Files for Reference

| File | Purpose |
|------|---------|
| `build/app/outputs/bundle/release/app-release.aab` | Production signed bundle |
| `android/key.properties` | Signing credentials (keep secret!) |
| `pubspec.yaml` | Version number for next release |

---

## Troubleshooting

### Build Failed?
```bash
flutter clean
flutter pub get
flutter build appbundle --release
```

### Upload Rejected?
- Check Google Play Console support docs: https://support.google.com/googleplay/android-developer
- Common issues: app signing, content policy, permissions

### Testers Can't See App?
- Ensure email is added as tester
- Wait for approval email
- Clear Play Store cache on test device

---

## Next Steps After Testing

1. **Collect feedback** from closed testers (1-2 weeks recommended)
2. **Fix issues** based on feedback
3. **Increment version** in `pubspec.yaml`
4. **Build new AAB** and upload
5. **Release to Beta** (optional wider testing)
6. **Release to Production** when ready

---

## Security Reminders
- ⚠️ Never commit `key.properties` to public repos
- ⚠️ Keep `upload-keystore.jks` safe (backup multiple locations)
- ⚠️ Use strong passwords for keystore
- ⚠️ Limit tester access during beta phase
