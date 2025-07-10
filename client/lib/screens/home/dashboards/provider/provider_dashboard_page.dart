import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../utils/Business.dart';
import '../../profiles/provider/provider_add_business_page.dart';

class ProviderDashboardPage extends StatefulWidget {
  final Business? business;

  const ProviderDashboardPage({Key? key, this.business}) : super(key: key);

  @override
  _ProviderDashboardPage createState() => _ProviderDashboardPage();
}

class _ProviderDashboardPage extends State<ProviderDashboardPage> {
  List<dynamic>? businesses;
  bool _isLoading = true;
  List<String> businessServices = [];

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
      if (!mounted) return;
      setState(() {
        businesses = [];
        _isLoading = false;
      });
    } catch (e) {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "On-Point",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      actions: [
          IconButton(
            icon: const Icon(
              Icons.logout,
              color: Colors.deepPurpleAccent,
            ),
            tooltip: "Logout",
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
              },// Optional: better touch target
          ),
        ],
      ),
      body: (businesses == null || businesses!.isEmpty)
          ? const Center(
        child: Text(
          "Add businesses.",
          style: TextStyle(fontSize: 18, color: Colors.black54),
        ),
      )
          : RefreshIndicator(
        onRefresh: _loadProviderProfile,
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: businesses!.length,
          itemBuilder: (context, index) {
            final business = businesses![index];
            final profileImageUrl = business['profileImageUrl'];

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFFE8DDF9),
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
                  if (business['profilePicData'] != null)
                    GestureDetector(
                      onTap: () async {
                        final picker = ImagePicker();
                        final pickedFile = await picker.pickImage(source: ImageSource.gallery);

                        if (pickedFile != null) {
                          final request = http.MultipartRequest(
                            'POST',
                            Uri.parse("http://10.0.2.2:8080/businesses/${business['id']}/profile/upload"),
                          );
                          request.files.add(
                            await http.MultipartFile.fromPath('image', pickedFile.path),
                          );

                          final response = await request.send();

                          if (response.statusCode == 200) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Profile image updated')),
                            );
                            _loadProviderProfile(); // Refresh business data
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Failed to upload image')),
                            );
                          }
                        }
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.memory(
                              base64Decode(business['profilePicData']),
                              fit: BoxFit.cover,
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.width * 0.4,
                              errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.broken_image, size: 100),
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.width * 0.4,
                            color: Colors.black.withOpacity(0.4), // Dark overlay
                          ),
                          const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 48,
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 5),
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

                    const SizedBox(height: 10),
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
                    // Location and working days
                  Row(
                    children: [
                      const Icon(Icons.phone, size: 20, color: Colors.deepPurple),
                      const SizedBox(width: 6),
                      Text(
                        "${business['businessPhone']}",
                        style: const TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
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
                    const SizedBox(height: 5),
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
                    const SizedBox(height: 5),
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
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () async {
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
                                  _loadProviderProfile(); // Refresh after deletion
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Failed to delete business")),
                                  );
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Error deleting business")),
                                );
                              }
                            }
                          },
                          icon: const Icon(Icons.delete),
                          label: const Text("Delete"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                        const SizedBox(width: 8), // spacing between buttons
                        ElevatedButton.icon(
                          onPressed: () async {
                            final updated = await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ProviderAddBusinessPage(business: business),
                              ),
                            );

                            if (updated == true) {
                              _loadProviderProfile(); // Reload businesses
                            }
                          },
                          icon: const Icon(Icons.edit),
                          label: const Text("Edit"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Stylists",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),

                            SizedBox(
                              height: 150, // Just the list scrolls
                              child: FutureBuilder<List<dynamic>>(
                                future: fetchStylists(business['id']),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return const Center(child: CircularProgressIndicator());
                                  } else if (snapshot.hasError) {
                                    return const Center(child: Text("Failed to load stylists"));
                                  }

                                  final stylists = snapshot.data ?? [];
                                  if (stylists.isEmpty) {
                                    return const Center(child: Text("No stylists found"));
                                  }
                                  return ListView.separated(
                                    itemCount: stylists.length,
                                    separatorBuilder: (_, __) => const Divider(),
                                    itemBuilder: (context, index) {
                                      final stylist = stylists[index];
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          ListTile(
                                            leading: const Icon(Icons.person, color: Colors.deepPurple),
                                            title: Text(
                                              '${stylist['firstName'] ?? ''} ${stylist['lastName'] ?? ''}'.trim(),
                                              style: const TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                            subtitle: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text('Working Hours: ${stylist['startTime']} - ${stylist['endTime']}'),
                                                if (stylist['stylistExpertise'] != null)
                                                  Wrap(
                                                    spacing: 6,
                                                    children: (stylist['stylistExpertise'] as List<dynamic>)
                                                        .map<Widget>((expertise) {
                                                      return Chip(
                                                        label: Text(expertise.toString()),
                                                        backgroundColor: Colors.deepPurple.withOpacity(0.1),
                                                        labelStyle: const TextStyle(color: Colors.deepPurple),
                                                      );
                                                    }).toList(),
                                                  ),
                                              ],
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              TextButton.icon(
                                      onPressed: () async {
                                      final result = await _showAddStylistDialog(
                                      context,
                                      (business['services'] ?? []).cast<String>(),
                                      existingStylist: stylist,
                                      );

                                      if (result != null) {


                                        final startTime = DateTime.now();
                                      showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (_) => const Center(child: CircularProgressIndicator()),
                                      );

                                      try {
                                        print("📡 Sending request at: $startTime");
                                      final response = await http.put(
                                      Uri.parse("http://10.0.2.2:8080/stylists/${stylist['id']}"),
                                      headers: {'Content-Type': 'application/json'},
                                      body: jsonEncode({
                                      "firstName": result['firstName'],
                                      "lastName": result['lastName'],
                                      "expertise": result['expertise'],
                                      "startTime": result['startTime'],
                                      "endTime": result['endTime'],
                                      }),
                                      );
                                      if (!context.mounted) return;

                                      // 👇 Close loading dialog
                                      Navigator.of(context).pop();

                                      if (response.statusCode == 200) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Stylist updated successfully")),
                                      );

                                      // ✅ Update local list
                                      setState(() {
                                      stylist['firstName'] = result['firstName'];
                                      stylist['lastName'] = result['lastName'];
                                      stylist['stylistExpertise'] = result['expertise'];
                                      stylist['startTime'] = result['startTime'];
                                      stylist['endTime'] = result['endTime'];
                                      });
                                      } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Failed to update stylist")),
                                      );
                                      }
                                      } catch (e) {
                                      if (context.mounted) Navigator.of(context).pop(); // Ensure dialog closes on error
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text("Error updating stylist")),
                                      );
                                      }
                                      }
                                      },
                                      icon: const Icon(Icons.edit, color: Colors.orange),
                                                label: const Text("Edit", style: TextStyle(color: Colors.orange)),
                                              ),
                                              TextButton.icon(
                                                onPressed: () async {
                                                  final confirm = await showDialog(
                                                    context: context,
                                                    builder: (_) => AlertDialog(
                                                      title: const Text("Delete Stylist"),
                                                      content: const Text("Are you sure you want to delete this stylist?"),
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
                                                        Uri.parse("http://10.0.2.2:8080/stylists/${stylist['id']}"),
                                                      );

                                                      if (response.statusCode == 200) {
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          const SnackBar(content: Text("Stylist deleted successfully")),
                                                        );
                                                        _loadProviderProfile();
                                                      } else {
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          const SnackBar(content: Text("Failed to delete stylist")),
                                                        );
                                                      }
                                                    } catch (e) {
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        const SnackBar(content: Text("Error deleting stylist")),
                                                      );
                                                    }
                                                  }
                                                },
                                                icon: const Icon(Icons.delete, color: Colors.red),
                                                label: const Text("Delete", style: TextStyle(color: Colors.red)),
                                              ),
                                            ],
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            ),

                            const SizedBox(height: 16),

                            Center(
                              child: ElevatedButton.icon(
                                onPressed: () async{
                                  final result = await _showAddStylistDialog(context, (business['services'] ?? []).cast<String>());

                                  if (result != null) {
                                    // Send POST request to your API
                                    try {
                                      final response = await http.post(
                                        Uri.parse('http://10.0.2.2:8080/stylists/business/${business['id']}'),
                                        headers: {'Content-Type': 'application/json'},
                                        body: jsonEncode({
                                          "firstName": result['firstName'],
                                          "lastName": result['lastName'],
                                          "expertise": result['expertise'],
                                          "startTime": result['startTime'],
                                          "endTime": result['endTime'],
                                        }),
                                      );

                                      if (response.statusCode == 201 || response.statusCode == 200) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text("Stylist added successfully")),
                                        );
                                        setState(() {
                                          _isLoading = true;
                                        });
                                        await _loadProviderProfile();
                                        setState(() {
                                          _isLoading = false;
                                        });
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text("Failed to add stylist")),
                                        );
                                      }
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text("Error adding stylist")),
                                      );
                                    }
                                  }
                                },
                                icon: const Icon(Icons.add),
                                label: const Text("Add Stylist"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepPurple,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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

  Future<List<dynamic>> fetchStylists(int businessId) async {
    final url = Uri.parse("http://10.0.2.2:8080/stylists/business/$businessId");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is List) {
        return decoded;
      } else {
        throw Exception("Unexpected response format");
      }
    } else {
      throw Exception("Failed to fetch stylists: ${response.statusCode}");
    }
  }

  Future<Map<String, dynamic>?> _showAddStylistDialog(
      BuildContext context,
      List<String> businessServices, {
        Map<String, dynamic>? existingStylist, // optional for edit
      }) async {
    final _formKey = GlobalKey<FormState>();

    // Controllers initialized with existing data or empty
    final TextEditingController _firstNameController = TextEditingController(text: existingStylist?['firstName'] ?? '');
    final TextEditingController _lastNameController = TextEditingController(text: existingStylist?['lastName'] ?? '');
    final TextEditingController _hoursController = TextEditingController();

    TimeOfDay? _startTime;
    TimeOfDay? _endTime;
    List<String> _selectedExpertise = [];

    // Prefill expertise if editing
    if (existingStylist != null && existingStylist['stylistExpertise'] != null) {
      _selectedExpertise = List<String>.from(existingStylist['stylistExpertise']);
    }

    // Prefill working hours if editing
    if (existingStylist != null && existingStylist['startTime'] != null && existingStylist['endTime'] != null) {
      // Parse existing times (assuming format like '08:00 AM')
      _startTime = parseTimeOfDay(existingStylist['startTime']);
      _endTime = parseTimeOfDay(existingStylist['endTime']);
      if (_startTime != null && _endTime != null) {
        _hoursController.text = '${existingStylist['startTime']} - ${existingStylist['endTime']}';
      }
    }

    return await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(existingStylist == null ? 'Add Stylist' : 'Edit Stylist'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // First Name
                  TextFormField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(labelText: 'First Name'),
                    validator: (value) => value == null || value.isEmpty ? 'Enter first name' : null,
                  ),
                  const SizedBox(height: 8),

                  // Last Name
                  TextFormField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(labelText: 'Last Name'),
                    validator: (value) => value == null || value.isEmpty ? 'Enter last name' : null,
                  ),
                  const SizedBox(height: 12),

                  // Expertise Chips
                  FormField<List<String>>(
                    initialValue: _selectedExpertise,
                    validator: (value) => value == null || value.isEmpty ? 'Select at least one expertise' : null,
                    builder: (state) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Select Expertise'),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: businessServices.map((service) {
                              final isSelected = _selectedExpertise.contains(service);
                              return FilterChip(
                                label: Text(service),
                                selected: isSelected,
                                onSelected: (selected) {
                                  if (selected) {
                                    _selectedExpertise.add(service);
                                  } else {
                                    _selectedExpertise.remove(service);
                                  }
                                  state.didChange(_selectedExpertise);
                                },
                                selectedColor: Colors.deepPurpleAccent,
                                labelStyle: TextStyle(
                                  color: isSelected ? Colors.deepPurple : Colors.black,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              );
                            }).toList(),
                          ),
                          if (state.hasError)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(state.errorText!, style: const TextStyle(color: Colors.red)),
                            ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  // Working Hours
                  FormField<String>(
                    validator: (_) => _startTime == null || _endTime == null ? 'Select working hours' : null,
                    builder: (state) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: _hoursController,
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: 'Working Hours',
                            suffixIcon: Icon(Icons.access_time),
                          ),
                          onTap: () async {
                            _startTime = await showTimePicker(
                              context: context,
                              initialTime: _startTime ?? const TimeOfDay(hour: 8, minute: 0),
                            );
                            if (_startTime == null) return;

                            _endTime = await showTimePicker(
                              context: context,
                              initialTime: _endTime ?? const TimeOfDay(hour: 17, minute: 0),
                            );
                            if (_endTime == null) return;

                            _hoursController.text =
                            '${_startTime!.format(context)} - ${_endTime!.format(context)}';
                            state.didChange("set");
                          },
                        ),
                        if (state.hasError)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(state.errorText!, style: const TextStyle(color: Colors.red)),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  Navigator.of(context).pop({
                    "firstName": _firstNameController.text.trim(),
                    "lastName": _lastNameController.text.trim(),
                    "expertise": _selectedExpertise,
                    "startTime": _startTime!.format(context),
                    "endTime": _endTime!.format(context),
                  });
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  TimeOfDay? parseTimeOfDay(String timeStr) {
    try {
      final parts = timeStr.split(' ');
      if (parts.length != 2) return null;

      final timeParts = parts[0].split(':');
      if (timeParts.length != 2) return null;

      int hour = int.parse(timeParts[0]);
      final int minute = int.parse(timeParts[1]);
      final String period = parts[1].toUpperCase();

      if (period == 'PM' && hour != 12) {
        hour += 12;
      } else if (period == 'AM' && hour == 12) {
        hour = 0;
      }

      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      return null;
    }
  }
}
