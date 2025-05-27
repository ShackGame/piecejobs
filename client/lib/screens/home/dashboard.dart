import 'package:flutter/material.dart';

import '../Jobs/cleaners_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
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
        title: const Text(
          'Dashboard',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold, // Use fontWeight for bold text
          ),
        ),
        centerTitle: false,
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
