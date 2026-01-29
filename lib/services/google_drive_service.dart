import 'dart:io';
import 'package:googleapis/drive/v3.dart' as drive;
import 'google_auth_service.dart';

class GoogleDriveService {
  // Google Drive folder ID for /BLNKimages
  static const String _blnkImagesFolderId = '1TsThAsrxrlJSjWCULcxbfBmL5lqgLX01';

  /// Upload image to Google Drive /BLNKimages folder
  /// Returns the file URL if successful, null otherwise
  static Future<String?> uploadImage({
    required String imagePath,
    required String fileName,
  }) async {
    try {
      final authService = GoogleAuthService();
      
      // Ensure user is authenticated
      if (!authService.isSignedIn) {
        print('User not signed in');
        return null;
      }

      // TODO: Uncomment when ready to add Drive API access
      // final driveApi = await authService.getDriveApi();
      // if (driveApi == null) {
      //   print('Failed to get Drive API');
      //   return null;
      // }

      // Read image file
      final file = File(imagePath);
      if (!file.existsSync()) {
        print('Image file not found: $imagePath');
        return null;
      }

      // TODO: Uncomment when ready to add Drive API access
      // Create Drive file metadata
      // final driveFile = drive.File()
      //   ..name = fileName
      //   ..parents = [_blnkImagesFolderId];

      // Upload file
      // final response = await driveApi.files.create(
      //   driveFile,
      //   uploadMedia: drive.Media(file.openRead(), file.lengthSync()),
      // );

      // if (response.id != null) {
      //   // Make file publicly accessible and get shareable link
      //   await driveApi.permissions.create(
      //     drive.Permission()
      //       ..type = 'anyone'
      //       ..role = 'reader',
      //     response.id!,
      //   );

      //   // Return the file URL
      //   final fileUrl =
      //       'https://drive.google.com/file/d/${response.id}/view?usp=sharing';
      //   print('File uploaded successfully: $fileUrl');
      //   return fileUrl;
      // }

      return null;
    } catch (e) {
      print('Error uploading image to Google Drive: $e');
      return null;
    }
  }

  /// Upload both front and back ID images
  /// Returns a map with 'frontUrl' and 'backUrl' (or null if upload failed)
  static Future<Map<String, String?>> uploadIdImages({
    required String frontIdPath,
    required String backIdPath,
    required String firstName,
    required String lastName,
  }) async {
    try {
      final frontFileName = '${firstName}_${lastName}_front.jpg';
      final backFileName = '${firstName}_${lastName}_back.jpg';

      // Upload front ID
      final frontUrl = await uploadImage(
        imagePath: frontIdPath,
        fileName: frontFileName,
      );

      // Upload back ID
      final backUrl = await uploadImage(
        imagePath: backIdPath,
        fileName: backFileName,
      );

      return {
        'frontUrl': frontUrl,
        'backUrl': backUrl,
      };
    } catch (e) {
      print('Error uploading ID images: $e');
      return {'frontUrl': null, 'backUrl': null};
    }
  }
}
