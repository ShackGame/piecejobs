import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProviderDashboardPage extends StatefulWidget {
  const ProviderDashboardPage({super.key});

  @override
  State<StatefulWidget> createState() => _ProviderDashboardPageState();
}

class _ProviderDashboardPageState extends State<ProviderDashboardPage>{

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Provider Dashboard',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold, // Use fontWeight for bold text
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          IconButton(
              icon: const Icon(Icons.logout, color: Colors.deepPurpleAccent),
              tooltip: 'Logout',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text("Confirm Logout"),
                      content: const Text("Are you sure you want to log out?"),
                      actions: [
                        TextButton(
                          child: const Text("Cancel"),
                          onPressed: () {
                            Navigator.of(context).pop(); // Close the dialog
                          },
                        ),
                        TextButton(
                          child: const Text("Logout"),
                          onPressed: () async {
                            Navigator.of(context).pop(); // Close dialog first

                            // Clear SharedPreferences
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.clear();

                            // Navigate to login
                            Navigator.pushReplacementNamed(context, '/login');
                          },
                        ),
                      ],
                    );
                  },
                );
              }
          ),
        ],
      ),
    );
  }
}