# Google Sheets Integration - Setup Guide

## Issue Found & Fixed

The app was trying to save local file paths (from the device) to Google Sheets, but Google Sheets cannot access local file paths. This has been fixed.

### What Changed in `google_sheets_service.dart`:

1. **Images are now converted to Base64**: Instead of saving file paths, the app now reads the image files and encodes them as base64 strings
2. **Enhanced error handling**: Better logging to diagnose submission issues
3. **Longer timeout**: Increased from 30 to 60 seconds (base64 encoding + network can take time)
4. **Better response parsing**: Supports multiple success response formats

## What You Need to Do in Google Apps Script

Your Google Apps Script deployment needs to be updated to handle the new data format. Here's what to expect:

### New Data Format

The app now sends:
```json
{
  "firstName": "John",
  "lastName": "Doe",
  "mobileNumber": "+971501234567",
  "landline": "043334567",
  "email": "john@example.com",
  "apartment": "101",
  "floor": "1",
  "building": "Building A",
  "streetName": "Sheikh Zayed Road",
  "area": "Downtown Dubai",
  "city": "Dubai",
  "landmark": "Near Mall",
  "frontIdImage": "base64_encoded_image_string_here...",
  "backIdImage": "base64_encoded_image_string_here...",
  "timestamp": "2026-01-28T15:30:00.000Z"
}
```

### Google Apps Script Setup Steps

1. **Open your Google Apps Script project** in Google Drive
2. **Replace or update your `doPost` function** with the template below
3. **Deploy as "Web app"** (you can use either "Web app" or "API executable"):
   - Click "Deploy" → "New deployment"
   - Type can be **"Web app"** or **"API executable"**
   - If you get an error about GCP project for API executable, just use "Web app" - it works fine for receiving POST requests
   - Click "Deploy" and authorize if prompted
   - Copy the deployment URL and use it in your Flutter app
4. **Update the URL in your Flutter app** to the deployment URL

### Google Apps Script Template

Update your Apps Script to handle this data:

```javascript
function doPost(e) {
  try {
    const data = JSON.parse(e.postData.contents);
    
    // Get the sheet
    const spreadsheet = SpreadsheetApp.getActiveSpreadsheet();
    const sheet = spreadsheet.getSheetByName("Registrations") || spreadsheet.getActiveSheet();
    
    // Check if headers exist, if not create them
    if (sheet.getLastRow() === 0) {
      const headers = [
        "Timestamp",
        "First Name",
        "Last Name",
        "Mobile Number",
        "Landline",
        "Email",
        "Apartment",
        "Floor",
        "Building",
        "Street Name",
        "Area",
        "City",
        "Landmark",
        "Front ID (Base64)",
        "Back ID (Base64)",
        "Submission Status"
      ];
      sheet.appendRow(headers);
    }
    
    // Add the data row
    const row = [
      data.timestamp || new Date().toISOString(),
      data.firstName || "",
      data.lastName || "",
      data.mobileNumber || "",
      data.landline || "",
      data.email || "",
      data.apartment || "",
      data.floor || "",
      data.building || "",
      data.streetName || "",
      data.area || "",
      data.city || "",
      data.landmark || "",
      data.frontIdImage ? data.frontIdImage.substring(0, 50) + "..." : "Not provided",
      data.backIdImage ? data.backIdImage.substring(0, 50) + "..." : "Not provided",
      "Submitted"
    ];
    
    sheet.appendRow(row);
    
    // OPTIONAL: Save full base64 images to separate sheet or cloud storage
    // For now, we're just saving a preview in the main sheet
    
    return ContentService.createTextOutput(JSON.stringify({
      status: "success",
      message: "Data saved successfully"
    })).setMimeType(ContentService.MimeType.JSON);
    
  } catch (error) {
    Logger.log("Error: " + error.toString());
    return ContentService.createTextOutput(JSON.stringify({
      status: "error",
      message: error.toString()
    })).setMimeType(ContentService.MimeType.JSON);
  }
}
```

### Handling Large Images (Optional)

If you want to save the full base64 images (they can be quite large), consider:

1. **Separate Images Sheet**: Store base64 in a different sheet to keep main data clean
2. **Google Drive**: Upload to Google Drive programmatically
3. **Database**: Use a database service like Firebase instead

## Testing

1. **Check Logs**: In Google Apps Script, go to Executions to see if the script ran without errors
2. **Check Sheets**: Look for the new data row in your sheet
3. **Monitor Console**: Check the Flutter app's console/Logcat for detailed debug logs

## Debugging Checklist

- ✓ Images are being converted to base64 (check app logs for "Image converted to base64")
- ✓ Request is being sent (check for "Submitting data to Google Sheet...")
- ✓ Response received (check for "Response status: 200")
- ✓ Data appears in Google Sheet

## Common Issues

### Images Not Converting
- **Cause**: Image file path doesn't exist
- **Solution**: Ensure image extraction in `IdCardProcessor` is working correctly

### Timeout Error
- **Cause**: Base64 encoding of large images takes time, or network is slow
- **Solution**: Already increased to 60 seconds; if still failing, check network

### "Got HTML Response"
- **Cause**: Google Apps Script might be redirecting or erroring
- **Solution**: Check Google Apps Script execution logs and ensure the doPost function is properly deployed

### Data Not Appearing in Sheet
- **Cause**: Script might be returning error status
- **Solution**: Check that your Apps Script matches the template above and has proper permissions
