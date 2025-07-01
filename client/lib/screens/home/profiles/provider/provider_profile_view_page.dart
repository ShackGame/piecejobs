import 'dart:convert';

import 'package:client/screens/home/profiles/provider/provider_profile_edit_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProviderProfileViewPage extends StatefulWidget {
  final int userId;
  const ProviderProfileViewPage({required this.userId, super.key});

  @override
  State<ProviderProfileViewPage> createState() => _ProviderProfileViewPage();
}

class _ProviderProfileViewPage extends State<ProviderProfileViewPage> {
  Map<String, dynamic>? _profile;
  bool _isLoading = true;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadProviderProfile();
  }

  Future<void> _loadProviderProfile() async {
    setState(() => _isLoading = true); // set loading before request

    try {
      final response = await http.get(
          Uri.parse("http://10.0.2.2:8080/providers/user/${widget.userId}"));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['businessName'] != null) {
          setState(() {
            _profile = data;
            _isLoading = false;
          });
          return;
        }
      }

      setState(() {
        _profile = null;
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading profile: $e");
      setState(() {
        _profile = null;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_profile == null) {
      return const Center(child: Text("No profile data found."));
    }

    final String? profileImageUrl = _profile!['profileImageUrl'];

    return _isEditing
        ? ProviderProfileEditPage(
      profile: _profile!,
      onDone: () async {
        setState(() {
          _isEditing = false;
          _isLoading = true;
        });
        await _loadProviderProfile();
      },
    )
        : Scaffold(
      appBar: AppBar(
        title: const Text(
          'View business profile',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold, // Use fontWeight for bold text
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => setState(() => _isEditing = true),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            if (profileImageUrl != null)
              Image.network(
                "http://10.0.2.2:8080/uploads/$profileImageUrl",
                width: double.infinity, // fill width
                height: 200, // fixed height or adjust as you want
                fit: BoxFit.cover, // crop to fill
                errorBuilder: (context, error, stackTrace) {
                  debugPrint('Image load error: $error');
                  return const Icon(Icons.broken_image, size: 100);
                },
              )
            else
              const Icon(Icons.account_circle, size: 100),

            const SizedBox(height: 10),
            Text("Business Name: ${_profile!['businessName']}",
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text("Description: ${_profile!['description']}"),
            const SizedBox(height: 10),
            Text("City: ${_profile!['city']}"),
            const SizedBox(height: 10),
            Text("Suburb: ${_profile!['suburb'] ?? '-'}"),
            const SizedBox(height: 10),
            Text("Category: ${_profile!['category']}"),
            const SizedBox(height: 10),
            Text(
                "Working Days: ${((_profile!['workingDays'] ?? []) as List)
                    .join(', ')}"),
            const SizedBox(height: 10),
            Text(
                "Working Hours: ${_profile!['startTime']} - ${_profile!['endTime']}"),
            const SizedBox(height: 10),
            Text(
                "Services: ${((_profile!['services'] ?? []) as List).join(
                    ', ')}"),
            const SizedBox(height: 10),
            Text("Rate: R${_profile!['minRate']} - R${_profile!['maxRate']}"),
          ],
        ),
      ),
    );
  }
}