# Google Login & Drive Integration - Implementation Summary

## Overview
This implementation adds Google authentication and Google Drive image upload to your BLNK app registration flow.

## Architecture

### New Files Created
1. **`lib/services/google_auth_service.dart`** - Google Sign-In authentication service
2. **`lib/screens/google_login_screen.dart`** - Google login UI screen

### Modified Files
1. **`lib/services/google_drive_service.dart`** - Updated to use authenticated Google Drive API
2. **`lib/screens/address_screen.dart`** - Navigate to Google login instead of Front ID
3. **`lib/screens/front_id_screen.dart`** - Upload front ID after extraction (non-blocking)
4. **`lib/screens/back_id_screen.dart`** - Upload back ID and handle completion
5. **`lib/providers/user_data_provider.dart`** - Track upload status
6. **`lib/models/user_data.dart`** - Added `imagesUploadedToGoogleDrive` field

## User Flow
```
Personal Info Screen
        ↓
Address Info Screen
        ↓
Google Login Screen (NEW - MANDATORY)
        ↓
Front ID Capture Screen (uploads in background)
        ↓
Back ID Capture Screen (uploads both images)
        ↓
Confirmation Screen
```

## Key Features

### 1. Google Authentication (`GoogleAuthService`)
- **Singleton Pattern**: Single instance manages authentication state
- **Scope**: `drive.file` - Limited to app-created files
- **Session**: Persists using `google_sign_in` package (can re-sign in if needed)
- **Methods**:
  - `initialize()` - Check if already signed in
  - `signIn()` - Show Google login dialog
  - `signOut()` - Sign out user
  - `getDriveApi()` - Get authenticated Drive API client
  - `isSignedIn` - Check current auth state

### 2. Google Drive Upload (`GoogleDriveService`)
- **Target Folder**: `/BLNKimages` (ID: `1TsThAsrxrlJSjWCULcxbfBmL5lqgLX01`)
- **File Naming**: `{firstName}_{lastName}_{front|back}.jpg`
- **Permissions**: Files set to public read-only after upload
- **Non-Blocking**: Uploads happen in background without freezing UI
- **Error Handling**: Failure doesn't block app flow - continues to next step
- **Methods**:
  - `uploadImage()` - Upload single image, returns shareable URL
  - `uploadIdImages()` - Upload both front and back images

### 3. Google Login Screen
- **Mandatory**: User must sign in after address info
- **Features**:
  - Beautiful Google Sign-In button
  - Auto-sign-in if already authenticated
  - Error messages for failed sign-in
  - Info box explaining data security
- **Navigation**: After successful login → Front ID Screen

### 4. Non-Blocking Uploads
**Front ID Screen:**
- Extracts image
- Saves locally
- Uploads to Drive (background)
- Navigates to Back ID immediately

**Back ID Screen:**
- Extracts image  
- Saves locally
- Uploads both front & back (background)
- Sets upload status in provider
- Submits to Google Sheets with status
- Navigates to confirmation

### 5. Upload Status Field
- **In UserData**: `imagesUploadedToGoogleDrive: bool`
- **In Google Sheets**: Submitted as `true` or `false`
- **Purpose**: Track whether images were successfully uploaded
- **Failure Handling**: If upload fails, `false` is recorded but app continues

## Code Examples

### Check Authentication Status
```dart
final authService = GoogleAuthService();
if (authService.isSignedIn) {
  // User is signed in
}
```

### Upload Image
```dart
final url = await GoogleDriveService.uploadImage(
  imagePath: '/path/to/image.jpg',
  fileName: 'firstName_lastName_front.jpg',
);
// Returns: 'https://drive.google.com/file/d/{fileId}/view?usp=sharing'
// or null if failed
```

### Check Upload Status
```dart
final provider = context.read<UserDataProvider>();
final uploaded = provider.imagesUploadedSuccessfully;
print('Images uploaded: $uploaded');
```

## Error Handling

### Upload Failures Don't Block Flow
- If Google Drive upload fails, app continues to next step
- Upload status (`true`/`false`) is recorded in Sheets
- User sees warnings in console but app flow is not interrupted

### Sign-In Failures
- Shows error dialog with message
- User can retry sign-in
- Can go back to previous screen

### Network Issues
- Uploads use try-catch with fallback
- Graceful degradation: records `false` in Sheets if upload fails
- No impact on main app flow

## Google Sheets Integration

### Submitted Fields
```json
{
  "firstName": "John",
  "lastName": "Doe",
  "email": "john@example.com",
  "mobileNumber": "+971...",
  "landline": "",
  "apartment": "101",
  "floor": "1",
  "building": "ABC",
  "streetName": "Main Street",
  "area": "Area 1",
  "city": "Dubai",
  "landmark": "Near Mall",
  "frontIdImagePath": "/path/to/local/file",
  "backIdImagePath": "/path/to/local/file",
  "frontIdUrl": null,
  "backIdUrl": null,
  "imagesUploadedToGoogleDrive": true  // NEW FIELD
}
```

## Prerequisites

### Required Packages (Already in pubspec.yaml)
- `google_sign_in: ^6.1.0`
- `googleapis: ^13.2.0`
- `googleapis_auth: ^1.6.0`
- `provider: ^6.1.2`

### Required Setup

#### 1. iOS Setup
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

#### 2. Android Setup
Add to `android/app/build.gradle`:
```gradle
android {
  compileSdkVersion 34
  // ... rest of config
}
```

#### 3. Google Cloud Setup
- Create OAuth 2.0 Client IDs for iOS and Android in Google Cloud Console
- Add `com.google.android.gms` as an authorized app for Android
- Configure Firebase (optional but recommended)

## Testing Checklist

- [ ] Can sign in with personal Google account
- [ ] Front ID uploads to `/BLNKimages` folder
- [ ] Back ID uploads to `/BLNKimages` folder
- [ ] Both files named correctly (`firstName_lastName_front.jpg`, etc.)
- [ ] Upload status appears in Google Sheets (`true`/`false`)
- [ ] App continues even if upload fails
- [ ] Files are publicly readable in Google Drive
- [ ] Session persists if app restarts
- [ ] Sign-out works properly
- [ ] Re-login works after sign-out

## Debugging Tips

### Enable Verbose Logging
All upload and auth operations print to console:
```
✓ Signed in as: user@gmail.com
✓ File uploaded successfully: {fileId}
✓ Back ID uploaded to Google Drive: https://...
Upload status - Front: ✓, Back: ✓
```

### Check Authentication State
```dart
final authService = GoogleAuthService();
print('Signed in: ${authService.isSignedIn}');
print('User: ${authService.getUserEmail()}');
print('Name: ${authService.getUserName()}');
```

### Inspect Uploaded Files
Visit: `https://drive.google.com/drive/u/0/folders/1TsThAsrxrlJSjWCULcxbfBmL5lqgLX01`

## Security Considerations

1. **Scoped Permissions**: Only `drive.file` scope - can't access other files
2. **Public Read-Only**: Uploaded files are readable but not editable by others
3. **No Credentials Storage**: OAuth tokens managed by `google_sign_in` package
4. **User Consent**: User must explicitly sign in and authorize
5. **Data Privacy**: Images stored in user's Google Drive folder

## Future Enhancements

- Add Dropbox/OneDrive as alternatives
- Store URLs in encrypted local storage for recovery
- Add image preview before upload
- Batch upload optimization
- Retry logic with exponential backoff
- Custom folder organization
- Share images with customer support
