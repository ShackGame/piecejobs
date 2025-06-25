import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<StatefulWidget> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>{

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email');
    final userId = prefs.getInt('userId');
    final userType = prefs.getString('userType');

    // Simulate a short delay (optional, like showing a splash)
    await Future.delayed(const Duration(seconds: 2));

    if (email != null && userId != null && userType != null) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
      return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

