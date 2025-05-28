import 'dart:io';

import 'package:flutter/material.dart';
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
  final TextEditingController _toolController = TextEditingController();
  List<String> _tools = [];

  final List<String> _jobCategories = [
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

  final Set<String> _selectedCategories = {};

  String _selectedGender = 'Male'; // default
  final TextEditingController _genderController = TextEditingController(text: 'Male');

  // Controllers
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _cellController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _provinceController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();
  final TextEditingController _areaCommonNameController = TextEditingController();

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
        title: const Text('Personal'),
        content: Column(
          children: [
            _buildTextField(_nameController, 'Name'),
            _buildTextField(_surnameController, 'Surname'),
            _buildTextField(_dobController, 'Date of Birth', hint: 'YYYY-MM-DD'),
            _buildTextField(_cellController, 'Cell Number', keyboard: TextInputType.phone),
            DropdownButtonFormField<String>(
              value: _selectedGender,
              items: ['Male', 'Female'].map((String gender) {
                return DropdownMenuItem<String>(
                  value: gender,
                  child: Text(gender),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedGender = newValue!;
                  _genderController.text = _selectedGender; // Optional: if you still use the controller
                });
              },
              decoration: const InputDecoration(
                labelText: 'Gender',
                border: OutlineInputBorder(),
              ),
            )
          ],
        ),
        isActive: _currentStep >= 0,
      ),
      Step(
        title: const Text('Location'),
        content: Column(
          children: [
            _buildTextField(_provinceController, 'Province'),
            _buildTextField(_cityController, 'City/Town'),
            _buildTextField(_areaCommonNameController, 'Area common name'),
          ],
        ),
        isActive: _currentStep >= 1,
      ),
      Step(
        title: const Text('Skills'),
        content: Column(
          children: [
            const Text("Select applicable job categories:"),
            _buildCheckboxList(),
            const SizedBox(height: 10),
          ],
        ),
        isActive: _currentStep >= 2,
      ),
      Step(
        title: const Text('Tools'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Name tools you own"),
            TextField(
              controller: _toolController,
              decoration: const InputDecoration(
                hintText: 'Enter a tool and press enter',
              ),
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  setState(() {
                    _tools.add(value.trim());
                    _toolController.clear();
                  });
                }
              },
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: _tools
                  .asMap()
                  .entries
                  .map(
                    (entry) => Chip(
                  label: Text(entry.value),
                  deleteIcon: const Icon(Icons.close),
                  onDeleted: () {
                    setState(() {
                      _tools.removeAt(entry.key);
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

  Widget _buildCheckboxList() {
    return Column(
      children: _jobCategories.map((category) {
        return CheckboxListTile(
          title: Text(category),
          value: _selectedCategories.contains(category),
          onChanged: (bool? value) {
            setState(() {
              if (value == true) {
                _selectedCategories.add(category);
              } else {
                _selectedCategories.remove(category);
              }
            });
          },
        );
      }).toList(),
    );
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
            const SizedBox(height: 16),
            _buildTextField(_aboutController, 'About'),
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
