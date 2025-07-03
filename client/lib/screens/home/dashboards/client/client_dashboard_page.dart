import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ClientDashboardPage extends StatefulWidget {
  const ClientDashboardPage({super.key});

  @override
  State<StatefulWidget> createState() => _ClientDashboardPageState();
}

class _ClientDashboardPageState extends State<ClientDashboardPage>{

  final List<Map<String, dynamic>> gridItems = const [
    {'title': 'Cleaning', 'icon': Icons.cleaning_services, 'color': Colors.teal},
    {'title': 'Delivery', 'icon': Icons.delivery_dining, 'color': Colors.orange},
    {'title': 'Gardening', 'icon': Icons.grass, 'color': Colors.green},
    {'title': 'Construction', 'icon': Icons.construction, 'color': Colors.brown},
    {'title': 'Tutoring', 'icon': Icons.school, 'color': Colors.deepPurple},
    {'title': 'More Jobs', 'icon': Icons.work_outline, 'color': Colors.grey},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Dashboard',
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

      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.builder(
          itemCount: gridItems.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemBuilder: (context, index) {
            final item = gridItems[index];
            return GestureDetector(
              onTap: () {
                if (item['title'] == 'Cleaning') {
                  Navigator.pushNamed(context, '/cleaners_page');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${item['title']} tapped')),
                  );
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: item['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: item['color']),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(item['icon'], size: 40, color: item['color']),
                    const SizedBox(height: 10),
                    Text(
                      item['title'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: item['color'],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}