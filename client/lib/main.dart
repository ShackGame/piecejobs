import 'package:client/screens/Jobs/cleaners_page.dart';
import 'package:client/screens/auth/reset_password.dart';
import 'package:client/screens/auth/splash_screen.dart';
import 'package:client/screens/auth/verification.dart';
import 'package:client/screens/home/dashboards/admin/admin_dashboard_page.dart';
import 'package:client/screens/home/dashboards/client/client_dashboard_page.dart';
import 'package:client/screens/home/dashboards/provider/provider_dashboard_page.dart';
import 'package:client/screens/home/profile_page.dart';
import 'package:client/screens/home/profiles/provider/provider_add_business_page.dart';
import 'package:flutter/material.dart';
import 'package:client/screens/auth/forgot.dart';
import 'package:client/screens/auth/login.dart';
import 'package:client/screens/auth/register.dart';
import 'package:client/screens/home/home.dart';
import 'package:client/screens/home/dashboard.dart';
import 'package:client/screens/auth/verification.dart' show VerifyOtpScreen, VerificationType;




void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/register': (context) => RegisterScreen(),
        '/login': (context) => LoginScreen(),
        '/forgot': (context) =>  ForgotPasswordScreen(),
        '/home': (context) =>  HomeScreen(),
        '/dashboard': (context) => DashboardPage(),
        '/cleaners_page': (context) => CleanersPage(),
        '/provider_dashboard_page': (context) =>  ProviderDashboardPage(),
        '/client_dashboard': (context) =>  ClientDashboard(),
        '/admin_dashboard': (context) =>  AdminDashboard(),
        '/provider_add_business_page': (context) =>  ProviderAddBusinessPage(),
      },
        onGenerateRoute: (settings) {
          if (settings.name == '/verification') {
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => VerifyOtpScreen(
                email: args['email'],
                verificationType: args['verificationType'], // <-- include this
              ),
            );
          }
          if (settings.name == '/reset-password') {
            final String email = settings.arguments as String;
            return MaterialPageRoute(
              builder: (context) => ResetPasswordScreen(email: email),
            );
          }
          return null;
        }
    );
  }
}
