import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'confirm_registration.dart';
import '../providers/user_data_provider.dart';
import '../services/id_card_processor.dart';
import '../services/google_sheets_service.dart';
import '../services/google_drive_service.dart';

class BackIdScreen extends StatefulWidget {
  const BackIdScreen({Key? key}) : super(key: key);

  @override
  State<BackIdScreen> createState() => _BackIdScreenState();
}

class _BackIdScreenState extends State<BackIdScreen> {
  XFile? _capturedImage;
  final ImagePicker _imagePicker = ImagePicker();
  bool _isLoading = false;

  Future<void> _captureImage() async {
    try {
      XFile? image;

      // On iOS/macOS, use gallery as primary method
      if (Platform.isIOS || Platform.isMacOS) {
        image = await _imagePicker.pickImage(
          source: ImageSource.gallery,
        );
        if (image != null) {
          setState(() {
            _capturedImage = image;
          });
        }
        return;
      }

      // On Android, try camera first
      if (Platform.isAndroid) {
        final PermissionStatus cameraStatus = await Permission.camera.request();

        if (!cameraStatus.isGranted) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Camera permission is required')),
            );
          }
          return;
        }

        try {
          image = await _imagePicker.pickImage(
            source: ImageSource.camera,
            preferredCameraDevice: CameraDevice.rear,
          );
        } catch (e) {
          // Fallback to gallery if camera fails
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Using gallery instead.')),
            );
          }
          image = await _imagePicker.pickImage(
            source: ImageSource.gallery,
          );
        }
      }

      if (image != null) {
        setState(() {
          _capturedImage = image;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _handleNext() async {
    if (_capturedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please capture your national ID')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Extract ID card from image
      final extractedImagePath = await IdCardProcessor.extractIdCard(_capturedImage!.path);
      
      if (extractedImagePath == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not extract ID card. Please ensure the ID is fully visible in the frame.')),
          );
        }
        setState(() => _isLoading = false);
        return;
      }

      // Save back ID image to provider
      final userDataProvider = context.read<UserDataProvider>();
      userDataProvider.setBackIdImagePath(extractedImagePath);
      
      print('Back ID extracted and saved: $extractedImagePath');
      
      // Try to upload both images to Google Drive (non-blocking)
      await _uploadImagesToGoogleDrive(userDataProvider, extractedImagePath);
      
      print('Complete User Data:');
      print(userDataProvider.getUserDataAsJson());
      
      // Submit data to Google Sheets
      print('Submitting data to Google Sheets...');
      final submitted = await GoogleSheetsService.submitUserData(userDataProvider.userData);
      
      if (!mounted) return;
      
      if (submitted) {
        print('Data submitted successfully to Google Sheet');
        // Navigate to confirmation screen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ConfirmRegistrationScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to submit data. Please check your connection and try again.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Upload both front and back images to Google Drive without blocking UI
  Future<void> _uploadImagesToGoogleDrive(
    UserDataProvider userDataProvider,
    String backIdPath,
  ) async {
    try {
      final firstName = userDataProvider.userData.firstName ?? 'User';
      final lastName = userDataProvider.userData.lastName ?? 'ID';
      final frontIdPath = userDataProvider.frontIdImagePath;

      if (frontIdPath == null || frontIdPath.isEmpty) {
        print('⚠️ Front ID path not found, skipping upload');
        userDataProvider.setImagesUploadedSuccessfully(false);
        return;
      }

      // Upload back ID
      final backFileName = '${firstName}_${lastName}_back.jpg';
      final backUrl = await GoogleDriveService.uploadImage(
        imagePath: backIdPath,
        fileName: backFileName,
      );

      if (backUrl != null) {
        userDataProvider.setBackIdUrl(backUrl);
        print('✓ Back ID uploaded to Google Drive: $backUrl');
      } else {
        print('⚠️ Failed to upload back ID, will proceed without URL');
      }

      // Check if at least one image was uploaded successfully
      final frontUrl = userDataProvider.frontIdUrl;
      final atLeastOneUploaded = frontUrl != null || backUrl != null;

      userDataProvider.setImagesUploadedSuccessfully(atLeastOneUploaded);
      print('Upload status - Front: ${frontUrl != null ? "✓" : "✗"}, Back: ${backUrl != null ? "✓" : "✗"}');
    } catch (e) {
      print('⚠️ Error uploading images: $e');
      userDataProvider.setImagesUploadedSuccessfully(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              // Header with back button
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, size: 24),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                ],
              ),
              const SizedBox(height: 20),
              // Step Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStepIndicator(1, false),
                  _buildStepLine(),
                  _buildStepIndicator(2, false),
                  _buildStepLine(),
                  _buildStepIndicator(3, true),
                ],
              ),
              const SizedBox(height: 30),
              const Text(
                'step 3 (national id back)',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Please capture a clear photo of the back of your national ID",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),
              // Camera preview or placeholder
              Container(
                width: double.infinity,
                height: 350,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!, width: 2),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[50],
                ),
                child: _capturedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          File(_capturedImage!.path),
                          fit: BoxFit.cover,
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.camera_alt_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No image captured',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap the button below to capture',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: 40),
              // Capture button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: _captureImage,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.blue, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  icon: const Icon(Icons.camera_alt, color: Colors.blue),
                  label: const Text(
                    'Capture Photo',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Next button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    disabledBackgroundColor: Colors.grey[400],
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Complete',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator(int step, bool isActive) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? Colors.blue : Colors.grey[300],
      ),
      child: Center(
        child: Text(
          '$step',
          style: TextStyle(
            color: isActive ? Colors.white : Colors.grey[600],
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildStepLine() {
    return Container(
      width: 50,
      height: 2,
      color: Colors.grey[300],
      margin: const EdgeInsets.symmetric(horizontal: 10),
    );
  }
}
