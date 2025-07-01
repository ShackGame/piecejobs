import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../profiles/provider/provider_add_business_page.dart';

class ProviderDashboardPage extends StatefulWidget {
  @override
  _ProviderDashboardPage createState() => _ProviderDashboardPage();
}

class _ProviderDashboardPage extends State<ProviderDashboardPage> {
  List<dynamic>? businesses;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProviderProfile();
  }

  Future<void> _loadProviderProfile() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    if (userId == null) return;

    try {
      final response = await http.get(
          Uri.parse("http://10.0.2.2:8080/businesses/user/$userId"));


      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          setState(() {
            businesses = data;
            _isLoading = false;
          });
          return;
        }
      }

      setState(() {
        businesses = [];
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading businesses: $e");
      setState(() {
        businesses = [];
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Logged out successfully')),
    );
    // Replace with your actual login screen
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (businesses == null || businesses!.isEmpty) {
      return const Center(child: Text("Add businesses."));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Businesses"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: "Logout",
          ),
        ],
      ),
    body: RefreshIndicator(
    onRefresh: _loadProviderProfile,
    child: ListView.builder(
    padding: const EdgeInsets.all(16),
    itemCount: businesses!.length,
    itemBuilder: (context, index) {
    final business = businesses![index];
          final profileImageUrl = business['profileImageUrl'];

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.15),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Business name and category
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        "${business['businessName']}",
                        style: const TextStyle(color: Colors.deepPurple, fontSize: 20, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.deepPurpleAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        business['category'] ?? 'Uncategorized',
                        style: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Description
                Text(
                  "${business['description']}",
                  style: const TextStyle(fontSize: 14, color: Colors.deepPurpleAccent),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 12),

                // Image
                if (profileImageUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      "http://10.0.2.2:8080/uploads/$profileImageUrl",
                      width: double.infinity,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.broken_image, size: 80, color: Colors.grey);
                      },
                    ),
                  ),

                const SizedBox(height: 10),

                // Location and working days
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 18, color: Colors.deepPurple),
                    const SizedBox(width: 6),
                    Text(
                      "${business['city']}, ${business['suburb'] ?? '-'}",
                      style: const TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 18, color: Colors.deepPurple),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        ((business['workingDays'] ?? []) as List<dynamic>).cast<String>().join(', '),
                        style: const TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Working hours and rate
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 18, color: Colors.deepPurple),
                    const SizedBox(width: 6),
                    Text(
                      "${business['startTime']} - ${business['endTime']}",
                      style: const TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    const SizedBox(width: 20),
                    const Icon(Icons.monetization_on, size: 18, color: Colors.deepPurple),
                    const SizedBox(width: 6),
                    Text(
                      "R${business['minRate']} - R${business['maxRate']}",
                      style: const TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Services chips
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: ((business['services'] ?? []) as List<dynamic>)
                      .cast<String>()
                      .map((service) {
                    return Chip(
                      label: Text(service),
                      backgroundColor: Colors.deepPurpleAccent.withOpacity(0.15),
                      labelStyle: const TextStyle(color: Colors.deepPurple),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 12),

                // View Details Button
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Text(business['businessName'] ?? "Business Details"),
                          content: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (business['profileImageUrl'] != null)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      "http://10.0.2.2:8080/uploads/${business['profileImageUrl']}",
                                      width: double.infinity,
                                      height: 180,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Icon(Icons.broken_image, size: 100);
                                      },
                                    ),
                                  ),
                                const SizedBox(height: 12),
                                Text("Description: ${business['description'] ?? '-'}"),
                                const SizedBox(height: 6),
                                Text("Category: ${business['category'] ?? '-'}"),
                                const SizedBox(height: 6),
                                Text("City: ${business['city'] ?? '-'}"),
                                const SizedBox(height: 6),
                                Text("Suburb: ${business['suburb'] ?? '-'}"),
                                const SizedBox(height: 6),
                                Text("Working Days: ${(business['workingDays'] as List<dynamic>?)?.join(', ') ?? '-'}"),
                                const SizedBox(height: 6),
                                Text("Working Hours: ${business['startTime']} - ${business['endTime']}"),
                                const SizedBox(height: 6),
                                Text("Rate: R${business['minRate']} - R${business['maxRate']}"),
                                const SizedBox(height: 6),
                                Text("Phone: ${business['businessPhone'] ?? '-'}"),
                                const SizedBox(height: 6),
                                Text("Services: ${(business['services'] as List<dynamic>?)?.join(', ') ?? '-'}"),
                              ],
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () async {
                                Navigator.of(context).pop(); // Close dialog first

                                final updated = await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => ProviderAddBusinessPage(business: business),
                                  ),
                                );

                                if (updated == true) {
                                  _loadProviderProfile(); // Reload businesses
                                }
                              },
                              child: const Text("Edit", style: TextStyle(color: Colors.orange)),
                            ),
                            TextButton(
                              onPressed: () async {
                                Navigator.of(context).pop(); // Close the dialog first

                                final confirm = await showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text("Confirm Delete"),
                                    content: const Text("Are you sure you want to delete this business?"),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(false),
                                        child: const Text("Cancel"),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(true),
                                        child: const Text("Delete", style: TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                  try {
                                    final response = await http.delete(
                                      Uri.parse("http://10.0.2.2:8080/businesses/${business['id']}"),
                                    );

                                    if (response.statusCode == 200) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text("Business deleted successfully")),
                                      );
                                      _loadProviderProfile(); // Refresh the dashboard
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text("Failed to delete business")),
                                      );
                                    }
                                  } catch (e) {
                                    print("Delete error: $e");
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Error deleting business")),
                                    );
                                  }
                                }
                              },
                              child: const Text("Delete", style: TextStyle(color: Colors.red)),
                            ),

                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text("Close"),
                            ),
                          ],
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text("View Business"),

                  ),
                ),
              ],
            ),
          );
        },
      ),
    ),
    );
  }
}
