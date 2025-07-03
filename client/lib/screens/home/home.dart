import 'dart:convert';

import 'package:client/screens/home/dashboard.dart';
import 'package:client/screens/home/dashboards/admin/admin_dashboard_page.dart';
import 'package:client/screens/home/dashboards/client/client_dashboard_page.dart';
import 'package:client/screens/home/dashboards/provider/provider_dashboard_page.dart';
import 'package:client/screens/home/messages.dart';
import 'package:client/screens/home/profile_page.dart';
import 'package:client/screens/home/profiles/client/client_profile_page.dart';
import 'package:client/screens/home/profiles/provider/provider_add_business_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/login.dart';
import 'messages/provider/provider_messages_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _userType;
  int _selectedIndex = 0;

  bool _isChecking = false;

  List<Widget> _pages = [];

  void _onItemTapped(int index) async {
    setState(() {
      _selectedIndex = index;
    });
  }

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

    _userType = userType;
    setState(() {
      _isChecking = true;
    });

    const String ROLE_CLIENT = 'Client';
    const String ROLE_PROVIDER = 'Provider';
    const String ROLE_ADMIN = 'Admin';

    if (!mounted) return;

    if (email != null && userId != null && userType != null) {
      late Widget dashboard, messages, thirdPage;

      switch (userType) {
        case ROLE_PROVIDER:
          dashboard = ProviderDashboardPage();
          messages = const ProviderMessagesPage();
          thirdPage = ProviderAddBusinessPage();
          break;
        case ROLE_CLIENT:
          dashboard = ClientDashboardPage();
          messages = const ProviderMessagesPage(); // TODO: Replace with ClientMessagesPage later
          thirdPage = ClientProfilePage();
          break;
        case ROLE_ADMIN:
          dashboard = const AdminDashboard();
          messages = const ProviderMessagesPage();
          thirdPage = const ProfilePage();
          break;
        default:
          dashboard = const DashboardPage();
          messages = const ProviderMessagesPage();
          thirdPage = const ProfilePage();
      }

      if (!mounted) return;
      setState(() {
        _pages = [
          dashboard,
          messages,
          thirdPage,
        ];
        _isChecking = false;
      });
    } else {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if(_isChecking || _pages.isEmpty){
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(),),
      );
    }
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.deepPurpleAccent,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(_userType == 'Provider' ? Icons.add_business : Icons.person),
            label: _userType == 'Provider' ? 'Add Business' : 'Profile',
          ),
        ],
      ),
    );
  }
}
