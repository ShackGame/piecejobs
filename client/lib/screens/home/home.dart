import 'dart:convert';

import 'package:client/screens/home/bookings/provider_bookings_page.dart';
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
import 'package:client/utils/business.dart';

import '../auth/login.dart';
import 'messages/provider/provider_messages_page.dart';

class HomeScreen extends StatefulWidget {
  final int initialIndex;
  final Business? business;

  const HomeScreen({
    super.key,
    this.initialIndex = 0,
    this.business,
  });


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
    _selectedIndex = widget.initialIndex;
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
      late Widget dashboard, bookings, thirdPage;

      switch (userType) {
        case ROLE_PROVIDER:
        // ✅ Fetch business for provider
          final response = await http.get(
            Uri.parse("http://10.0.2.2:8080/businesses/user/$userId/single"),
          );

          if (response.statusCode == 200) {
            final jsonData = jsonDecode(response.body);
            Business business = Business.fromJson(jsonData);

            dashboard = ProviderDashboardPage();
            bookings = ProviderBookingsPage(business: business);
            thirdPage = ProviderAddBusinessPage();
          } else {
            // Handle error or show fallback UI
            dashboard = ProviderDashboardPage();
            bookings = const Center(child: Text("Failed to load business"));
            thirdPage = ProviderAddBusinessPage();
          }
          break;

        case ROLE_CLIENT:
          dashboard = ClientDashboardPage();
          bookings = const ProviderMessagesPage(); // Replace later if needed
          thirdPage = ClientProfilePage();
          break;

        case ROLE_ADMIN:
          dashboard = const AdminDashboard();
          bookings = const ProviderMessagesPage();
          thirdPage = const ProfilePage();
          break;

        default:
          dashboard = const DashboardPage();
          bookings = const ProviderMessagesPage();
          thirdPage = const ProfilePage();
      }

      if (!mounted) return;
      setState(() {
        _pages = [
          dashboard,
          bookings,
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
      backgroundColor: Color(0xFFE8DDF9),
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
          BottomNavigationBarItem(
            icon: Icon(_userType == 'Provider' ? Icons.calendar_month : Icons.person),
            label: _userType == 'Provider' ? 'Bookings' : 'Booking',
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
