import 'package:flutter/material.dart';
import 'personal_info_screen.dart';

class AppSplashScreen extends StatefulWidget {
  const AppSplashScreen({Key? key}) : super(key: key);

  @override
  State<AppSplashScreen> createState() => _AppSplashScreenState();
}

class _AppSplashScreenState extends State<AppSplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const PersonalInfoScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/splash_background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo image - centered
              Image.asset(
                'assets/Screenshot_2026-01-27_at_10.28.59_PM-removebg-preview.png',
                width: 200,
                height: 200,
                fit: BoxFit.contain,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
