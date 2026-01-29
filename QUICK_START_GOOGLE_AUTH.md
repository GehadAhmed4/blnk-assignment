# Quick Start Guide - Google Authentication & Drive Integration

## 🎯 What Was Implemented

A complete Google authentication and Google Drive integration system for your BLNK app registration flow.

**Flow**: Personal Info → Address Info → **Google Login (NEW)** → Front ID Capture → Back ID Capture → Confirmation

## 📦 New Files

1. **`lib/services/google_auth_service.dart`** - Manages Google Sign-In authentication
2. **`lib/screens/google_login_screen.dart`** - Beautiful login UI screen

## ✏️ Updated Files

1. `lib/services/google_drive_service.dart` - Rewritten to use authenticated Google Drive API
2. `lib/screens/address_screen.dart` - Navigate to Google login instead of ID screens
3. `lib/screens/front_id_screen.dart` - Auto-upload front ID after capture
4. `lib/screens/back_id_screen.dart` - Auto-upload both IDs and finalize submission
5. `lib/providers/user_data_provider.dart` - Track upload status
6. `lib/models/user_data.dart` - Added upload status field

## 🚀 How to Test

### Step 1: Run the App
```bash
flutter run
```

### Step 2: Go Through Registration Flow
1. Enter personal info (name, email, etc.)
2. Enter address details
3. **NEW**: Sign in with your Google account
4. Capture front ID - uploads automatically
5. Capture back ID - uploads automatically  
6. See confirmation with upload status

### Step 3: Verify Uploads
1. Check Google Drive folder: [/BLNKimages](https://drive.google.com/drive/u/0/folders/1TsThAsrxrlJSjWCULcxbfBmL5lqgLX01)
2. Files should be named: `firstName_lastName_front.jpg`, `firstName_lastName_back.jpg`
3. Check Google Sheets - `imagesUploadedToGoogleDrive` field should show `true`

## 🔑 Key Features

### ✅ Authentication
- User signs in with personal Google account
- Uses `google_sign_in` package
- Permissions limited to Google Drive file access only
- Secure OAuth 2.0 flow

### ✅ Image Upload
- Images uploaded to specific folder: `/BLNKimages`
- File naming: `{firstName}_{lastName}_{front|back}.jpg`
- Files are public read-only
- Non-blocking - doesn't freeze app during upload

### ✅ Error Handling  
- Upload failures don't stop app flow
- Records `true`/`false` status in Google Sheets
- Graceful degradation - app continues regardless

### ✅ Non-Blocking Uploads
- Front ID: Extracts → Saves → Uploads (background) → Next
- Back ID: Extracts → Saves → Uploads (background) → Submit Sheets

## 📊 Data Flow

```
Address Form Submitted
        ↓
   Save address
        ↓
Navigate to Google Login Screen
        ↓
User clicks "Sign in with Google"
        ↓
Google OAuth Dialog
        ↓
User grants permission
        ↓
Authenticated ✓
        ↓
Navigate to Front ID Screen
        ↓
User captures front ID
        ↓
Extract image
        ↓
Save to provider
        ↓
Upload to Drive (background)
        ↓
Navigate to Back ID Screen
        ↓
User captures back ID
        ↓
Extract image
        ↓
Save to provider
        ↓
Upload front + back to Drive (background)
        ↓
Set upload status
        ↓
Submit to Google Sheets (with upload status)
        ↓
Navigate to Confirmation Screen
```

## 🔧 Configuration

### Already Configured ✓
- `pubspec.yaml` has all required packages
- Google folder ID is set to `/BLNKimages`
- All services are properly initialized

### Need to Configure
**For iOS:**
Add to `ios/Runner/Info.plist`:
```xml
<dict>
  <key>CFBundleURLTypes</key>
  <array>
    <dict>
      <key>CFBundleTypeRole</key>
      <string>Editor</string>
      <key>CFBundleURLSchemes</key>
      <array>
        <string>com.googleusercontent.apps.YOUR_CLIENT_ID</string>
      </array>
    </dict>
  </array>
</dict>
```

**For Android:**
Already configured if you have Google Sign-In set up.

## 🧪 Testing Checklist

- [ ] Can sign in with Google account
- [ ] Front ID appears in `/BLNKimages` folder
- [ ] Back ID appears in `/BLNKimages` folder
- [ ] Files named correctly
- [ ] Google Sheets has upload status (`true`/`false`)
- [ ] Can go back and retry (no crashes)
- [ ] Works offline gracefully (records `false`)
- [ ] Can sign out and sign in again
- [ ] App continues even if upload fails

## 📱 Device Verification

### Android
```bash
flutter run -d RZCX6166SFE  # Your device ID
```

### iOS
```bash
flutter run -d iPhone
```

## 🐛 Debugging

### Enable Logs
All operations print to console:
```
✓ Signed in as: user@gmail.com
✓ File uploaded successfully: fileId123
✓ Back ID uploaded to Google Drive: https://...
Upload status - Front: ✓, Back: ✓
```

### Check Auth Status
```dart
final authService = GoogleAuthService();
print('Signed in: ${authService.isSignedIn}');
print('Email: ${authService.getUserEmail()}');
```

### Inspect Google Drive
Visit: https://drive.google.com/drive/u/0/folders/1TsThAsrxrlJSjWCULcxbfBmL5lqgLX01

### Check Google Sheets
Look for `imagesUploadedToGoogleDrive` column (true/false)

## ⚠️ Common Issues

### Issue: "Sign in failed"
**Solution**: Make sure you have internet connection and Google Sign-In is properly configured in Google Cloud Console.

### Issue: Files not uploading
**Solution**: Check auth status with `GoogleAuthService().isSignedIn`. If false, user needs to re-sign in.

### Issue: Upload timeout
**Solution**: Upload failures are graceful - app records `false` and continues. Check console for error message.

### Issue: "No images captured"
**Solution**: Make sure you captured images on both front and back ID screens before completion.

## 📞 Support

All code includes detailed comments and error handling. Check:
1. Console logs for detailed error messages
2. `GOOGLE_AUTH_IMPLEMENTATION.md` for architecture details
3. Individual file comments for specific implementation details

## 🎉 Next Steps

1. ✅ Test the flow end-to-end
2. ✅ Verify files in Google Drive `/BLNKimages`
3. ✅ Check Google Sheets for upload status
4. ✅ Test on actual device (Android)
5. ✅ Customize UI/messages if needed
6. ✅ Set up proper error handling for production

## 📝 Notes

- Session persists across app restarts (google_sign_in handles this)
- Failed uploads don't block flow - graceful degradation
- All data properly serialized to Google Sheets
- Ready for production use after testing
