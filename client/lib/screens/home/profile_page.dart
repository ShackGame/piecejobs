import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  int _currentStep = 0;
  final TextEditingController _servicesController = TextEditingController();
  List<String> _services = [];

  final List<String> _businessCategories = [
    'Plumbing',
    'Beauty',
    'Painting',
    'Carpentry',
    'Electrical',
    'Tiling',
    'Roofing',
    'Cleaning',
    'Gardening',
    'Moving/Transport',
    'Other',
  ];

  String? _selectedCategories;

  // Controllers
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _businessHoursController = TextEditingController();
  final TextEditingController _businessDaysController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _alternateNumberController = TextEditingController();

  // Permissions
  Future<bool> _requestPermissions() async {
    if (Platform.isAndroid) {
      final status = await Permission.photos.request();
      if (!status.isGranted) {
        final legacyStatus = await Permission.storage.request();
        return legacyStatus.isGranted;
      }
      return true;
    } else if (Platform.isIOS) {
      final status = await Permission.photos.request();
      return status.isGranted;
    }
    return true;
  }

  // Image Picker
  Future<void> _pickImage() async {
    try {
      setState(() => _isLoading = true);

      final bool granted = await _requestPermissions();
      if (!granted) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permission denied')),
        );
        return;
      }

      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to select image')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Form Steps
  List<Step> _buildSteps() {
    return [
      Step(
        title: const Text('Business de1tails'),
        content: Column(
          children: [
            _buildTextField(_businessNameController, 'Business Name'),
            _buildTextField(_descriptionController, 'Description'),
            _buildTextField(_cityController, 'City'),
            _buildTextField(_addressController, 'General address'),
            _buildTextField(_phoneNumberController, 'Phone Number', keyboard: TextInputType.phone),
            _buildTextField(_alternateNumberController, 'Alternative Number', keyboard: TextInputType.phone),

          ],
        ),
        isActive: _currentStep >= 0,
      ),
      Step(
        title: const Text('Business'),
        content: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _selectedCategories,
              decoration: InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              items: _businessCategories.map((String province) {
                return DropdownMenuItem(value: province, child: Text(province));
              }).toList(),
              onChanged: (value) => setState(() => _selectedCategories = value),
              validator: (value) {
                final isValid = value != null && value.isNotEmpty;
                return isValid ? null : 'Please select a category';
              },
            ),
            _buildTextField(_businessDaysController, 'Working days'),
            _buildTextField(_businessHoursController, 'Working hours'),
          ],
        ),
        isActive: _currentStep >= 1,
      ),
      Step(
        title: const Text('Services'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Name your services"),
            TextField(
              controller: _servicesController,
              decoration: const InputDecoration(
                hintText: 'Enter a service and press enter',
              ),
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  setState(() {
                    _services.add(value.trim());
                    _servicesController.clear();
                  });
                }
              },
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: _services
                  .asMap()
                  .entries
                  .map(
                    (entry) => Chip(
                  label: Text(entry.value),
                  deleteIcon: const Icon(Icons.close),
                  onDeleted: () {
                    setState(() {
                      _services.removeAt(entry.key);
                    });
                  },
                ),
              )
                  .toList(),
            ),
            const SizedBox(height: 20),
          ],
        ),
        isActive: _currentStep >= 3,
      ),
    ];
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool isOptional = false, TextInputType keyboard = TextInputType.text, String? hint}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        validator: isOptional
            ? null
            : (value) {
          if (value == null || value.isEmpty) {
            return 'Required';
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  void _onStepContinue() {
    if (_currentStep < _buildSteps().length - 1) {
      setState(() => _currentStep += 1);
    } else if (_formKey.currentState!.validate()) {
      // All steps done
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile Saved')),
      );
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep -= 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold, // Use fontWeight for bold text
          ),
        ),
        centerTitle: false,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: _imageFile != null
                        ? FileImage(_imageFile!)
                        : const AssetImage('assets/images/default_profile.jpg') as ImageProvider,
                    child: _isLoading ? const CircularProgressIndicator() : null,
                  ),
                  if (!_isLoading)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.deepOrange,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.edit, size: 20, color: Colors.white),
                        onPressed: _pickImage,
                      ),
                    ),

                ],
              ),
            ),
            const SizedBox(height: 20),
            Stepper(
              physics: const ClampingScrollPhysics(),
              currentStep: _currentStep,
              onStepContinue: _onStepContinue,
              onStepCancel: _onStepCancel,
              steps: _buildSteps(),
              controlsBuilder: (context, details) {
                return Row(
                  children: [
                    ElevatedButton(
                      onPressed: details.onStepContinue,
                      child: Text(_currentStep == _buildSteps().length - 1 ? 'Finish' : 'Next'),
                    ),
                    const SizedBox(width: 8),
                    if (_currentStep > 0)
                      TextButton(
                        onPressed: details.onStepCancel,
                        child: const Text('Back'),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
