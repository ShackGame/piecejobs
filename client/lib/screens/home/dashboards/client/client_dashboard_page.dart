import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ClientDashboardPage extends StatefulWidget {
  const ClientDashboardPage({super.key});

  @override
  State<StatefulWidget> createState() => _ClientDashboardPageState();
}

class _ClientDashboardPageState extends State<ClientDashboardPage> {
  final List<Map<String, dynamic>> _allItems = const [
    {'title': 'Cleaning', 'icon': Icons.cleaning_services, 'color': Colors.teal},
    {'title': 'Delivery', 'icon': Icons.delivery_dining, 'color': Colors.orange},
    {'title': 'Gardening', 'icon': Icons.grass, 'color': Colors.green},
    {'title': 'Construction', 'icon': Icons.construction, 'color': Colors.brown},
    {'title': 'Tutoring', 'icon': Icons.school, 'color': Colors.deepPurple},
    {'title': 'More Jobs', 'icon': Icons.work_outline, 'color': Colors.grey},
  ];

  List<Map<String, dynamic>> _filteredItems = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredItems = _allItems;
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredItems = _allItems
          .where((item) => item['title'].toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'On Point',
          style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.deepPurpleAccent),
            tooltip: 'Logout',
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Confirm Logout"),
                  content: const Text("Are you sure you want to log out?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () async {
                        Navigator.of(context).pop();
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.clear();
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      child: const Text("Logout"),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search services...',
                prefixIcon: const Icon(Icons.search,
                    color: Colors.deepPurpleAccent),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),),
              ),
            ),
          ),

          // Grid Items
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: _filteredItems.isEmpty
                  ? const Center(child: Text('No matching services found'))
                  : GridView.builder(
                itemCount: _filteredItems.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemBuilder: (context, index) {
                  final item = _filteredItems[index];
                  return GestureDetector(
                    onTap: () {
                      if (item['title'] == 'Cleaning') {
                        Navigator.pushNamed(context, '/business_list_page');
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
          ),
        ],
      ),
    );
  }
}
