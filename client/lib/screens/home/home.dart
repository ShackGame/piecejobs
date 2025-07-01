import 'dart:convert';

import 'package:client/screens/home/dashboard.dart';
import 'package:client/screens/home/dashboards/admin/admin_dashboard_page.dart';
import 'package:client/screens/home/dashboards/client/client_dashboard_page.dart';
import 'package:client/screens/home/dashboards/provider/provider_dashboard_page.dart';
import 'package:client/screens/home/messages.dart';
import 'package:client/screens/home/profile_page.dart';
import 'package:client/screens/home/profiles/provider/provider_add_business_page.dart';
import 'package:client/screens/home/profiles/provider/provider_profile_edit_page.dart';
import 'package:client/screens/home/profiles/provider/provider_profile_view_page.dart';
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
      _isChecking =true;
    });

    const String ROLE_CLIENT = 'Client';
    const String ROLE_PROVIDER = 'Provider';
    const String ROLE_ADMIN = 'Admin';

    if(!mounted) return;

    if (email != null && userId != null && userType != null) {
      late Widget dashboard, messages, profile, business;
      switch (userType) {
        case ROLE_PROVIDER:
          dashboard = ProviderDashboardPage();
          messages = const ProviderMessagesPage();
          business = ProviderAddBusinessPage();
          break;
        case ROLE_CLIENT:
          dashboard = const DashboardPage();
          messages = const ProviderMessagesPage();
          profile = const ProfilePage();
          break;
        case ROLE_ADMIN:
        // You can either assign AdminDashboard or redirect Admins
          dashboard = const AdminDashboard();
          messages = const ProviderMessagesPage();
          profile = const ProfilePage();
          break;
        default:
          dashboard = const DashboardPage();
      }
      if(!mounted) return;
      setState(() {
        _pages = [
          dashboard,
          messages,
          business,
        ];
        _isChecking = false;
      });
    } else {
      if(!mounted) return;
      // Not logged in
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }
  }

  Future<Widget> _loadProviderProfile(int userId) async {
    final response = await http.get(
      Uri.parse("http://10.0.2.2:8080/providers/user/$userId"),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['businessName'] != null) {
        return ProviderProfileViewPage(userId: userId);
      } else {
        return ProviderProfileEditPage(
          profile: data,
          onDone: () {
            Navigator.pop(context, true);
          },
        );
      }
    }

    return ProviderProfileEditPage(
      profile: {},
      onDone: () {
        Navigator.pop(context, true);
      },
    );
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
