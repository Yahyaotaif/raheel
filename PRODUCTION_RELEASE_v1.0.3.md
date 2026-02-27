# Raheel v1.0.3 - Production Release Guide

## 📦 Build Complete ✅

**Production-signed AAB ready for Google Play:**
- **File:** `build/app/outputs/bundle/release/app-release.aab`
- **Size:** 43 MB
- **Version Code:** 10
- **Version Name:** 1.0.3
- **App ID:** `com.raheelcorp.raheel`
- **Date Built:** February 20, 2026

---

## 📝 Release Notes

### Version 1.0.3 - Authentication & Mobile Format Improvements

#### 🔐 Authentication Enhancements
- **Primary Login Change:** Users can now login with mobile number OR username
  - Mobile number is now the primary identifier (05XXXXXXXX format)
  - Username still supported as fallback for users who prefer it
  - More flexible authentication experience

#### 📱 Mobile Number Format Enforcement
- **Saudi Format Validation:** All mobile numbers now enforce Saudi local format (05XXXXXXXX)
  - Registration validation updated (both driver and traveler flows)
  - Live validation during input for immediate feedback
  - Profile edit enforces same format
  - Database constraint added for data integrity
  
- **User Experience Improvements:**
  - Clear error messages in Arabic and English
  - Consistent validation across all forms
  - Better input guidance

#### 🛡️ Data Quality & Security
- Added database-level constraint for mobile format
- Improved validation consistency across the application
- Enhanced authentication security with mobile-based login

#### 🌍 Multilingual Support
- All changes localized for Arabic and English
- Updated error messages and labels in both languages
- Consistent user experience across locales

---

## 📋 Pre-Release Checklist

Before uploading to Google Play, verify:

- [x] All features tested locally
- [x] No compilation errors
- [x] Version bumped in pubspec.yaml (1.0.3+10)
- [x] AAB built and signed with production keystore
- [x] File size reasonable (~43 MB)
- [x] Release notes prepared
- [x] Previous commits pushed to GitHub

---

## 🚀 Step-by-Step: Upload to Google Play Console

### Step 1: Access Google Play Console
1. Go to https://play.google.com/console
2. Sign in with the account associated with Raheel app
3. Select **Raheel** app from dashboard

### Step 2: Navigate to Release Section
1. In left sidebar, go to **Release** → **Production**
2. Click **Create new release**

### Step 3: Upload AAB
1. In the "App bundles" section, click **Upload**
2. Select file: `/Users/Lenovo/Flutter Projects/raheel/build/app/outputs/bundle/release/app-release.aab`
3. Wait for validation (usually 30 seconds - 2 minutes)
4. Verify no errors appear

### Step 4: Configure Release Details
1. Set **Release name:** "Version 1.0.3 - Mobile Login & Format"
2. Set **Release notes:** Use the release notes below

**Release Notes for Google Play:**
```
Version 1.0.3 - Authentication Improvements

✨ What's New:
• Login with mobile number or username - more flexible authentication
• Mobile numbers now enforce Saudi format (05XXXXXXXX)
• Improved validation across registration and profile edit
• Better error messages in Arabic and English

🔧 Technical Improvements:
• Enhanced data validation
• Database-level format constraints
• Improved security

📱 User Experience:
• Clearer mobile number input guidance
• Consistent validation messages
• Better multilingual support
```

### Step 5: Set Rollout Strategy

**Recommended:** Phased rollout (staged)
- Day 1: 10% of users
- Day 2: 25% of users
- Day 3: 50% of users
- Day 4: 100% of users

This allows you to monitor for issues before full release.

**Or:** Full rollout immediately (less safe, faster)

### Step 6: Review & Confirm
1. Review all details on the confirmation page
2. Verify version code (10) and name (1.0.3)
3. Check release notes for spelling/formatting
4. Click **Review release**

### Step 7: Start Rollout
1. Click **Start rollout to Production**
2. Confirm the action
3. Google Play will review and process the release (typically 2-4 hours)

---

## ⏱️ What Happens Next

### Immediate (0-2 hours)
- Google Play processes the AAB
- Automated security and policy checks run
- You'll receive email confirmation

### Short-term (2-4 hours)
- Release appears in Google Play Console dashboard
- Status shows as "Review in progress" initially
- May eventually show "Rolled out" if approved

### Common Outcomes
1. **Approved & Live:** Users can see the update in Play Store
2. **Partial Approval:** Sometimes Play Console needs policy review (may take 1-2 days)
3. **Rejected:** Check email for specific rejection reasons

### Monitor the Release
1. Go to **Releases** → **Production** in Google Play Console
2. Watch status updates
3. Once live, check **Ratings & reviews** section for user feedback
4. Monitor crash reports in **Android Vitals**

---

## 🔍 What If Issues Occur?

### Build Validation Failed
- Check error message in Google Play Console
- Common issues:
  - Version code already exists
  - Signing certificate mismatch
  - Incompatible API levels
- Solution: Create new version in pubspec.yaml and rebuild

### Release Rejected
- Check rejection email for specific reason
- Common reasons:
  - Apps with frequent crashes (check Android Vitals)
  - Policy violations (check Play Store policies)
  - Permissions not justified
- Fix issue → Increment version → Rebuild & resubmit

### Rollout Paused
- Google Play may pause automatic rollout if crash rate spikes
- Check Android Vitals dashboard
- Fix critical bugs → Increment version → Resubmit

---

## 📊 Post-Release Monitoring

### First Week Checklist
- [ ] Monitor crash rates in Android Vitals
- [ ] Check user reviews and ratings
- [ ] Monitor login issues specifically (since auth flow changed)
- [ ] Monitor mobile number validation feedback
- [ ] Track if users report format errors

### Key Metrics to Watch
1. **Crash Rate:** Should be < 1%
2. **ANR Rate:** Keep below 0.5%
3. **Star Rating:** Monitor changes
4. **Login Success Rate:** Critical - watch for auth failures
5. **Number of Reviews:** More reviews = more visibility

### If Critical Issues Found
1. Pause rollout in Google Play Console (if not 100%)
2. Fix the issue
3. Increment version (1.0.4+11)
4. Rebuild and resubmit new AAB
5. Document in release notes what was fixed

---

## 📝 Version History Reference

| Version | Date | Notes |
|---------|------|-------|
| 1.0.3+10 | Feb 20, 2026 | Mobile login & format enforcement |
| 1.0.2+9 | Feb 20, 2026 | Previous release |
| 1.0.1+8 | Earlier | Earlier features |
| 1.0.0+1 | Original | Initial release |

---

## 🔐 Security Reminders

⚠️ **Critical:**
- Never commit credentials to GitHub
- Keep `upload-keystore.jks` in secure backup
- Don't share release passwords
- Monitor app anomalies after release
- Review Android Vitals for security issues

---

## 📞 Support & Documentation

- **Google Play Console:** https://play.google.com/console
- **Play Store Documentation:** https://support.google.com/googleplay/android-developer
- **Flutter Deployment:** https://docs.flutter.dev/deployment/android
- **Raheel README:** See [README.md](README.md)

---

## ✅ Release Checklist - Final

- [x] Version bumped (1.0.3+10)
- [x] AAB built and signed
- [x] File exists and is correct size
- [x] Git changes committed and pushed
- [x] Release notes written
- [x] Ready for Google Play Console upload

**Next Action:** Upload AAB to Google Play Console following the steps above.
