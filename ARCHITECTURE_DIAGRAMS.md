# Architecture & Data Flow Diagrams

## System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         BLNK App                             │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐   │
│  │                   UI Layer                            │   │
│  │  ┌──────────────┐ ┌──────────────┐ ┌────────────┐   │   │
│  │  │  Address     │ │  Google      │ │  Front/    │   │   │
│  │  │  Screen      │→│  Login       │→│  Back ID   │   │   │
│  │  │              │ │  Screen      │ │  Screens   │   │   │
│  │  └──────────────┘ └──────────────┘ └────────────┘   │   │
│  └──────────────────────────────────────────────────────┘   │
│                              ↓                               │
│  ┌──────────────────────────────────────────────────────┐   │
│  │              Provider Layer (State)                   │   │
│  │  ┌───────────────────────────────────────────────┐   │   │
│  │  │      UserDataProvider                         │   │   │
│  │  │  - Personal data                              │   │   │
│  │  │  - Address data                               │   │   │
│  │  │  - Image paths & URLs                         │   │   │
│  │  │  - imagesUploadedToGoogleDrive (NEW)           │   │   │
│  │  └───────────────────────────────────────────────┘   │   │
│  └──────────────────────────────────────────────────────┘   │
│                              ↓                               │
│  ┌──────────────────────────────────────────────────────┐   │
│  │              Service Layer                            │   │
│  │  ┌──────────────┐ ┌──────────────┐ ┌────────────┐   │   │
│  │  │   Google     │ │  Google      │ │  Google    │   │   │
│  │  │   Auth       │ │  Drive       │ │  Sheets    │   │   │
│  │  │  Service     │ │  Service     │ │  Service   │   │   │
│  │  └──────────────┘ └──────────────┘ └────────────┘   │   │
│  └──────────────────────────────────────────────────────┘   │
│            ↓                        ↓             ↓          │
│       ┌────────┐             ┌──────────┐   ┌─────────┐    │
│       │ Google │             │ Google   │   │ Google  │    │
│       │ Sign-In│             │ Drive    │   │ Sheets  │    │
│       │  API   │             │   API    │   │   API   │    │
│       └────────┘             └──────────┘   └─────────┘    │
│          (OAuth)             (REST API)    (Append Row)     │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## Authentication Flow

```
┌─────────────────────────────────────────────────────┐
│ User navigates to GoogleLoginScreen                 │
└──────────────────┬──────────────────────────────────┘
                   ↓
        ┌──────────────────────┐
        │ Check if already     │
        │ signed in?           │
        └──────────┬───────────┘
                   ↓
        ┌──────────────────────┐
        │ Yes: Auto sign-in    │  Silent sign-in
        │ (cache exists)       │  No user interaction
        └──────────┬───────────┘
                   ↓
        ┌──────────────────────┐
        │ GoogleAuthService    │
        │ creates Drive API    │
        │ authenticated client │
        └──────────┬───────────┘
                   ↓
        ┌──────────────────────┐
        │ Navigate to          │
        │ FrontIdScreen        │
        └──────────────────────┘

Alternative Path (Not signed in):
        ┌──────────────────────┐
        │ No: Show login       │
        │ button               │
        └──────────┬───────────┘
                   ↓
        ┌──────────────────────┐
        │ User clicks          │
        │ "Sign in with Google"│
        └──────────┬───────────┘
                   ↓
        ┌──────────────────────┐
        │ Google OAuth Dialog  │
        │ appears              │
        └──────────┬───────────┘
                   ↓
        ┌──────────────────────┐
        │ User enters Google   │
        │ account credentials  │
        └──────────┬───────────┘
                   ↓
        ┌──────────────────────┐
        │ User grants drive    │
        │ permission           │
        └──────────┬───────────┘
                   ↓
        ┌──────────────────────┐
        │ GoogleAuthService    │
        │ gets access token    │
        │ (1 hour expiry)      │
        └──────────┬───────────┘
                   ↓
        ┌──────────────────────┐
        │ Creates Drive API    │
        │ client               │
        └──────────┬───────────┘
                   ↓
        ┌──────────────────────┐
        │ Navigate to          │
        │ FrontIdScreen        │
        └──────────────────────┘
```

---

## Image Upload Flow

```
FrontIdScreen:
┌─────────────────────────────────┐
│ User captures image             │
└────────────────┬────────────────┘
                 ↓
┌─────────────────────────────────┐
│ IdCardProcessor extracts ID card│
└────────────────┬────────────────┘
                 ↓
┌─────────────────────────────────┐
│ Save path to UserDataProvider    │
└────────────────┬────────────────┘
                 ↓
         ┌───────────────┐
         │ Call          │
         │ _uploadImage  │
         │ ToGoogleDrive │
         │ (async)       │
         └────────┬──────┘
                  ↓
   ┌──────────────────────────┐
   │ GoogleDriveService.      │
   │ uploadImage()            │
   │ (non-blocking)           │
   └────────────┬─────────────┘
                ↓
   ┌──────────────────────────┐
   │ If successful:           │
   │ Save URL to provider     │
   └────────────┬─────────────┘
                ↓
┌─────────────────────────────────┐
│ Navigate to BackIdScreen        │
│ (upload happens in background)  │
└─────────────────────────────────┘

BackIdScreen:
┌─────────────────────────────────┐
│ User captures image             │
└────────────────┬────────────────┘
                 ↓
┌─────────────────────────────────┐
│ IdCardProcessor extracts ID card│
└────────────────┬────────────────┘
                 ↓
┌─────────────────────────────────┐
│ Save path to UserDataProvider    │
└────────────────┬────────────────┘
                 ↓
         ┌──────────────────┐
         │ Call             │
         │ _uploadImages    │
         │ ToGoogleDrive()  │
         │ (await - wait)   │
         └────────┬─────────┘
                  ↓
   ┌──────────────────────────────┐
   │ Upload front ID (if not done)│
   └────────────┬─────────────────┘
                ↓
   ┌──────────────────────────────┐
   │ Upload back ID               │
   └────────────┬─────────────────┘
                ↓
   ┌──────────────────────────────┐
   │ Set provider:                │
   │ imagesUploadedSuccessfully   │
   │ = (frontUrl != null ||       │
   │    backUrl != null)          │
   └────────────┬─────────────────┘
                ↓
   ┌──────────────────────────────┐
   │ Submit to Google Sheets with │
   │ upload status field          │
   └────────────┬─────────────────┘
                ↓
┌─────────────────────────────────┐
│ Navigate to ConfirmationScreen  │
└─────────────────────────────────┘
```

---

## Google Drive Upload Details

```
User (Authenticated)
        ↓
  [Front ID Image]
  /path/to/front.jpg
        ↓
GoogleDriveService.uploadImage()
        ↓
  1. Read image bytes from file
  2. Create Drive File metadata:
     {
       name: "John_Doe_front.jpg",
       mimeType: "image/jpeg",
       parents: ["1TsThAsrxrlJSjWCULcxbfBmL5lqgLX01"]
     }
  3. Get authenticated Drive API
  4. Call: driveApi.files.create(
       metadata,
       uploadMedia: Media(imageBytes)
     )
        ↓
  5. If successful (fileId returned):
     - Create permission:
       {
         type: "anyone",
         role: "reader"
       }
     - Return URL:
       https://drive.google.com/file/d/{fileId}/view?usp=sharing
        ↓
  6. If error:
     - Return null
     - Log error
     - Continue (non-blocking)
        ↓
Result saved to provider:
  provider.setFrontIdUrl(url)
  
  ↓
Same process for back ID
  ↓
Final URLs stored in UserData:
  frontIdUrl: "https://..."
  backIdUrl: "https://..."
  imagesUploadedToGoogleDrive: true/false
```

---

## Google Sheets Submission

```
User completes all steps
        ↓
Collected data in UserDataProvider:
  {
    firstName: "John",
    lastName: "Doe",
    email: "john@gmail.com",
    mobileNumber: "+971501234567",
    apartment: "101",
    floor: "5",
    building: "Tower A",
    streetName: "Main Street",
    area: "Downtown",
    city: "Dubai",
    landmark: "Near Mall",
    frontIdImagePath: "/local/path",
    backIdImagePath: "/local/path",
    frontIdUrl: "https://drive.google.com/...",
    backIdUrl: "https://drive.google.com/...",
    imagesUploadedToGoogleDrive: true  ← NEW FIELD
  }
        ↓
GoogleSheetsService.submitUserData(userData)
        ↓
  1. Convert userData to JSON
  2. Get Google Sheets credentials
  3. Append row to sheet:
     [John, Doe, john@gmail.com, +971..., ...]
        ↓
  4. Sheet receives new row with all fields
  5. imagesUploadedToGoogleDrive column = true/false
        ↓
Success ✓
  Confirm to user
  Navigate to ConfirmationScreen
```

---

## Error Handling Tree

```
                           Start Registration
                                  ↓
                    ┌──────────────────────────┐
                    │ Any step fails?          │
                    └────┬────────────────┬────┘
                         No              Yes
                         ↓                ↓
                    Continue      Show error dialog
                         ↓                ↓
        ┌──────────────────────┐  ┌──────────────┐
        │ Reached Back ID      │  │ User can:    │
        │ Screen?              │  │ • Retry      │
        └────┬────────────┬────┘  │ • Go back    │
             Yes          No      └──────────────┘
             ↓            ↓
        Upload Both   Continue
             ↓            ↓
        ┌────────────┐ ┌────────┐
        │ Upload     │ │Submit  │
        │ Fails?     │ │to      │
        └──┬──────┬──┘ │Sheets  │
           Yes   No    └────────┘
           ↓     ↓          ↓
        ┌──────────┐   Success
        │Set       │       ↓
        │uploaded  │  Confirmation
        │= false   │
        └────┬─────┘
             ↓
        ┌──────────┐
        │Still     │
        │Submit to │
        │Sheets    │
        │with      │
        │false     │
        └────┬─────┘
             ↓
        Success (with status)
             ↓
        ┌─────────────────┐
        │Confirmation     │
        │Shows upload:    │
        │false            │
        └─────────────────┘
```

---

## Data Model Changes

```
OLD UserData:
┌─────────────────────────────────┐
│ firstName: String?              │
│ lastName: String?               │
│ mobileNumber: String?           │
│ email: String?                  │
│ apartment: String?              │
│ floor: String?                  │
│ building: String?               │
│ streetName: String?             │
│ area: String?                   │
│ city: String?                   │
│ landmark: String?               │
│ frontIdImagePath: String?       │
│ backIdImagePath: String?        │
│ frontIdUrl: String?             │
│ backIdUrl: String?              │
└─────────────────────────────────┘

NEW UserData:
┌─────────────────────────────────┐
│ [All above fields]              │
│ + imagesUploadedToGoogleDrive   │ ← NEW
│   : bool = false                │
└─────────────────────────────────┘

In Google Sheets:
┌────────────┬───────────┬───────────┬─────┬──────────────────────┐
│ FirstName  │ LastName  │ Email     │ ... │ imagesUploaded       │
│            │           │           │     │ ToGoogleDrive        │
├────────────┼───────────┼───────────┼─────┼──────────────────────┤
│ John       │ Doe       │ john@... │ ... │ true                 │
│ Jane       │ Smith     │ jane@... │ ... │ false                │
│ Ahmed      │ Ali       │ ahmed@...│ ... │ true                 │
└────────────┴───────────┴───────────┴─────┴──────────────────────┘
```

---

## Service Communication

```
      UI Layer
      ┌─────────────┐
      │  Screens    │
      └──────┬──────┘
             │ calls
             ↓
   ┌─────────────────────────┐
   │ UserDataProvider        │
   │ (manages state)         │
   └──────┬──────┬──────┬────┘
          │      │      │
    reads │      │      │ notifies
    from  │      │      │ listeners
          ↓      ↓      ↓
   ┌────────────────────────────┐
   │ GoogleAuthService          │ ← Singleton
   │ - isSignedIn               │
   │ - signIn()                 │
   │ - getDriveApi()            │
   └────────┬────────────────────┘
            │ creates
            ↓
   ┌────────────────────────────┐
   │ AuthClient (authenticated) │
   └────────┬────────────────────┘
            │ uses
            ↓
   ┌────────────────────────────┐
   │ GoogleDriveService         │
   │ - uploadImage()            │
   │ - uploadIdImages()         │
   └────────┬────────────────────┘
            │ uses
            ↓
   ┌────────────────────────────┐
   │ Drive API                  │
   │ files.create()             │
   │ permissions.create()       │
   └────────────────────────────┘
```

---

## Deployment Checklist

```
┌─────────────────────────────────────────┐
│ Pre-Deployment Testing                  │
├─────────────────────────────────────────┤
│ ✓ iOS configuration complete            │
│ ✓ Android configuration complete        │
│ ✓ Google OAuth credentials valid        │
│ ✓ Tested on actual Android device       │
│ ✓ Tested sign-in flow                   │
│ ✓ Tested image upload                   │
│ ✓ Verified files in Drive                │
│ ✓ Verified Sheets submission            │
│ ✓ Tested error scenarios                │
│ ✓ Tested offline behavior               │
└─────────────────────────────────────────┘
             ↓
┌─────────────────────────────────────────┐
│ Deploy to Production                    │
├─────────────────────────────────────────┤
│ 1. flutter clean                        │
│ 2. flutter pub get                      │
│ 3. flutter run -d android-device        │
│ 4. Run full registration flow           │
│ 5. Monitor console for errors           │
│ 6. Verify data in Sheets                │
│ 7. Deploy APK to Google Play             │
└─────────────────────────────────────────┘
```

---

This architecture ensures:
- ✅ Clean separation of concerns
- ✅ Testability and maintainability
- ✅ Non-blocking operations
- ✅ Graceful error handling
- ✅ Secure authentication
- ✅ User data protection
