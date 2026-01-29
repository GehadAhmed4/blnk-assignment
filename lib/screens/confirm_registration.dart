import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'personal_info_screen.dart';
import '../providers/user_data_provider.dart';

class ConfirmRegistrationScreen extends StatelessWidget {
  const ConfirmRegistrationScreen({Key? key}) : super(key: key);

  void _registerAnotherUser(BuildContext context) {
    // Reset user data for new registration
    context.read<UserDataProvider>().resetUserData();
    
    // Navigate to PersonalInfoScreen
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const PersonalInfoScreen()),
      (route) => false,
    );
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
              const SizedBox(height: 60),
              // Success checkmark circle
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF4CAF90),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 70,
                  ),
                ),
              ),
              const SizedBox(height: 50),
              // Title
              const Text(
                'Registration Complete',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 25),
              // Description
              const Text(
                "Congratulations! You have successfully completed the registration process. Your profile is now set up, and now you can start exploring all features and benefits we offer",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey,
                  height: 1.6,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 80),
              // Register Another User button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => _registerAnotherUser(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Register Another User',
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
}
