import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../utils/input_decoration_utils.dart';
import '../../home.dart';

class ClientProfilePage extends StatefulWidget {
  @override
  State<ClientProfilePage> createState() => _ClientProfilePageState();

}

class _ClientProfilePageState extends State<ClientProfilePage> {
  List<dynamic>? clientProfile;

  @override
  void initState() {
    super.initState();
    _loadClientProfile();
  }

  //region Variables
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  int _currentStep = 0;

  String? _selectedGender;
  final List<String> _gender = [
  'Male',
  'Female'];

  String? _selectedProvince;

  final List<String> _interests = [];

  final _stepFormKeys = List.generate(3, (_) => GlobalKey<FormState>());

  DateTime? selectedDate;

  final List<String> _provinces = [
    'Eastern Cape',
    'Free State',
    'Gauteng',
    'KwaZulu-Natal',
    'Limpopo',
    'Mpumalanga',
    'North West',
    'Northern Cape',
    'Western Cape',
  ];
  //endregion

  //region Controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  final _suburbController = TextEditingController();
  final _cityController = TextEditingController();
  final _cellphoneController = TextEditingController();
  final _interestController = TextEditingController();
  final _provinceController = TextEditingController();
  final _prefLanguageController = TextEditingController();


  //endregion

  //region Image Picking
  Future<bool> _requestPermissions() async {
    if (Platform.isAndroid) {
      final status = await Permission.photos.request();
      return status.isGranted || await Permission.storage.request().isGranted;
    } else {
      return (await Permission.photos.request()).isGranted;
    }
  }

  Future<void> _pickImage() async {
    if (!await _requestPermissions()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permission denied')),
      );
      return;
    }

    final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  Future<void> _uploadImage(int userId) async {
    if (_imageFile == null) return;

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('http://10.0.2.2:8080/clients/upload-profile-image/$userId'),
    );
    request.files.add(await http.MultipartFile.fromPath('image', _imageFile!.path));
    final response = await request.send();

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image uploaded successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image upload failed')),
      );
    }
  }
  //endregion

  //region Step Control
  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep -= 1;
      });
    }
  }

  Future<int> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId') ?? 0;
  }

  //endregion

  //region Other functions
  //region Load Client Profile
  Future<void> _loadClientProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt("userId");
    final token = prefs.getString("token");

    if (userId == null || token == null) {
      print('No userId or token in local storage');
      return;
    }

    try {
      final response = await http.get(
        Uri.parse("http://10.0.2.2:8080/clients/profile/$userId"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          _firstNameController.text = data['fullName']?.split(' ').first ?? '';
          _lastNameController.text = data['fullName']?.split(' ').skip(1).join(' ') ?? '';
          _dateOfBirthController.text = data['dateOfBirth'] ?? '';
          _selectedProvince = data['province'] ?? '';
          _cityController.text = data['city'] ?? '';
          _suburbController.text = data['suburb'] ?? '';
          _cellphoneController.text = data['phoneNumber'] ?? '';
          _selectedGender = data['gender'];
          if (data['interests'] != null && data['interests'] is List) {
            _interests.clear();
            _interests.addAll(List<String>.from(data['interests']));
          }
          _prefLanguageController.text = data['preferredLanguage'] ?? '';
          // If you want, you can also handle profileImageUrl, email, preferredLanguage, etc.
        });
      } else {
        print('Failed to fetch client profile: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error fetching client profile: $e');
    }
  }
  //endregion
  //region Update Client Profile
  Future<bool> _submitProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    if (userId == null) return false;

    final url = Uri.parse('http://10.0.2.2:8080/clients/profile/$userId');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      "profileImageUrl": _imageFile != null ? _imageFile!.path : null, // or null if no image yet
      "phoneNumber": _cellphoneController.text.trim(),
      "gender": _selectedGender,
      "dateOfBirth": _dateOfBirthController.text.trim(),
      "city": _cityController.text.trim(),
      "suburb": _suburbController.text.trim(),
      "province": _selectedProvince,
      "interests": _interests,
      "preferredLanguage": _prefLanguageController.text.trim(),
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      print('Submit profile response: ${response.statusCode} - ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      print('Submit error: $e');
      return false;
    }
  }
//endregion

  //endregion

  //region Build Text fields
  Widget _buildTextField(TextEditingController controller, String label,
      {TextInputType keyboard = TextInputType.text, bool isOptional = false,
        bool readOnly = false,bool enabled = true,}) {
    Icon? prefixIcon;

    // Set icon based on field label
    switch (label.toLowerCase()) {
      case 'first name':
        prefixIcon = const Icon(Icons.person,color: Colors.deepPurpleAccent);
        break;
      case 'last name':
        prefixIcon = const Icon(Icons.person_outline,color: Colors.deepPurpleAccent);
        break;
      case 'date of birth':
        prefixIcon = const Icon(Icons.cake,color: Colors.deepPurpleAccent);
        break;
      case 'phone number':
        prefixIcon = const Icon(Icons.phone,color: Colors.deepPurpleAccent);
        break;
      case 'province':
        prefixIcon = const Icon(Icons.map,color: Colors.deepPurpleAccent);
        break;
      case 'city':
        prefixIcon = const Icon(Icons.location_city,color: Colors.deepPurpleAccent);
        break;
      case 'suburb':
        prefixIcon = const Icon(Icons.location_on,color: Colors.deepPurpleAccent);
        break;
      default:
        prefixIcon = const Icon(Icons.edit,color: Colors.deepPurpleAccent);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        readOnly: readOnly,
        enabled: enabled,
        validator: (value) {
          if (isOptional) return null;
          if (value == null || value.isEmpty) return 'Required';
          if (label.toLowerCase() == 'phone number') {
            final phoneRegex = RegExp(r'^(0|\+27)[6-8][0-9]{8}$');
            if (!phoneRegex.hasMatch(value)) {
              return 'Enter a valid phone number';
            }
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          prefixIcon: prefixIcon,
        ),
      ),
    );
  }

//endregion

  //region Date
  Future<void> _selectDate(BuildContext context) async {
    final today = DateTime.now();
    final eighteenYearsAgo = DateTime(today.year - 18, today.month, today.day);
    final sixtyFiveYearsAgo = DateTime(today.year - 65, today.month, today.day);


    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? eighteenYearsAgo, // Default to 18 years ago
      firstDate: sixtyFiveYearsAgo, // Maximum age 65
      lastDate: eighteenYearsAgo, // Minimum age 18
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        _dateOfBirthController.text = picked.toIso8601String().split('T')[0];
      });
    }
  }
  //endregion

  //region Steps
  List<Step> _buildSteps() {
    return [
      Step(
        title: const Text('Personal Info'),
        isActive: _currentStep >= 0,
        content: Form(
          key: _stepFormKeys[0],
          child: Column(
            children: [
              _buildTextField(_firstNameController, 'First Name',readOnly: true, enabled: false),
              _buildTextField(_lastNameController, 'Last Name',readOnly: true, enabled: false),
              TextFormField(
                controller: _dateOfBirthController,
                readOnly: true,
                enabled: false,
                onTap: () => _selectDate(context),
                decoration: buildInputDecoration('Date of Birth', Icons.cake).copyWith(
                  suffixIcon: const Icon(Icons.calendar_today, color: Colors.deepPurpleAccent),
                ),
                validator: (value) {
                  final isValid = value != null && value.isNotEmpty;
                  return isValid ? null : 'Please select your birth date';
                },
              ),

              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedGender,

                decoration: InputDecoration(
                  labelText: 'Gender',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                items: _gender.map((String province) {
                  return DropdownMenuItem(value: province, child: Text(province));
                }).toList(),
                onChanged: null,
                validator: (value) {
                  final isValid = value != null && value.isNotEmpty;
                  return isValid ? null : 'Please select a province';
                },
              ),
              const SizedBox(height: 8),
              _buildTextField(_cellphoneController, 'Phone Number', keyboard: TextInputType.phone),
            ],
          ),
        ),
      ),
      Step(
        title: const Text('Location'),
        isActive: _currentStep >= 1,
        content: Form(
          key: _stepFormKeys[1],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedProvince,
                decoration: buildInputDecoration('Province', Icons.map),
                items: _provinces.map((String province) {
                  return DropdownMenuItem(value: province, child: Text(province));
                }).toList(),
                onChanged: (value) => setState(() => _selectedProvince = value),
                validator: (value) {
                  final isValid = value != null && value.isNotEmpty;
                  return isValid ? null : 'Please select a province';
                },
              ),
              _buildTextField(_cityController, 'City'),
              _buildTextField(_suburbController, 'Suburb'),
              _buildTextField(_prefLanguageController, 'Preferred Language'),
            ],
          ),
        ),
      ),
      Step(
        title: const Text('Interests'),
        isActive: _currentStep >= 2,
        content: Form(
          key: _stepFormKeys[2],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Mention services you are interested in:"),
              TextFormField(
                controller: _interestController,
                decoration: const
                InputDecoration(hintText: 'e.g., Cleaning — press Enter to add'),
                onFieldSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    setState(() {
                      _interests.add(value.trim());
                      _interestController.clear();
                    });
                  }
                },
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _interests
                    .asMap()
                    .entries
                    .map((entry) => Chip(
                  label: Text(entry.value),
                  deleteIcon: const Icon(Icons.close),
                  onDeleted: () => setState(() => _interests.removeAt(entry.key)),
                ))
                    .toList(),
              ),
              const SizedBox(height: 8),
              FormField<List<String>>(
                initialValue: _interests,
                validator: (val) =>
                (val == null || val.isEmpty) ? 'Please add at least one interest' : null,
                builder: (state) =>
                state.hasError ? Text(state.errorText!, style: const TextStyle(color: Colors.red)) : const SizedBox(),
              ),
            ],
          ),
        ),
      ),
    ];
  }

  //endregion

  //region Widget Build
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile"),),
      body: ListView(
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
          const SizedBox(height: 8),
          Stepper(
            physics: const ClampingScrollPhysics(),
            currentStep: _currentStep,
            onStepContinue: () {}, // no-op
            onStepCancel: _onStepCancel, // you can keep _onStepCancel as is
            steps: _buildSteps(),
            controlsBuilder: (context, details) {
              return Row(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      // Validate current step form
                      final isValid = _stepFormKeys[_currentStep].currentState?.validate() ?? false;
                      if (!isValid) return;

                      if (_currentStep == _buildSteps().length - 1) {
                        // Last step: submit profile
                        bool success = await _submitProfile();
                        if (success) {
                          final userId = await _getUserId();
                          await _uploadImage(userId);

                          if (!mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Profile updated successfully')),
                          );

                          if (!mounted) return;

                          await _loadClientProfile();
                          setState(() {
                            _currentStep = 0;
                          });
                        } else {
                          if (!mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Failed to save profile')),
                          );
                        }
                      } else {
                        // Not last step: go to next step
                        setState(() {
                          _currentStep += 1;
                        });
                      }
                    },
                    child: Text(_currentStep == _buildSteps().length - 1 ? 'Save' : 'Next'),
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
    );
  }
  //endregion
}
