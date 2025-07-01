import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProviderProfileEditPage extends StatefulWidget {
  final Map<String, dynamic> profile;
  final VoidCallback onDone;

  const ProviderProfileEditPage({Key? key, required this.profile, required this.onDone}) : super(key: key);

  @override
  State<ProviderProfileEditPage> createState() => _ProviderProfileEditPageState();
}

class _ProviderProfileEditPageState extends State<ProviderProfileEditPage> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  int _currentStep = 0;

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

  final List<String> _weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final Set<String> _selectedDays = {};

  TimeOfDay? _startTime;
  TimeOfDay? _endTime;


  // Controllers
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _servicesController = TextEditingController();
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _suburbController = TextEditingController();
  final TextEditingController _businessHoursController = TextEditingController();
  final TextEditingController _minRateController = TextEditingController();
  final TextEditingController _maxRateController = TextEditingController();

  String _formatTime(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return TimeOfDay.fromDateTime(dt).format(context);
  }

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

  Future<void> _uploadImage(int userId) async {
    if (_imageFile == null) return;

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('http://10.0.2.2:8080/providers/upload-profile-image/$userId'),
    );

    request.files.add(await http.MultipartFile.fromPath('image', _imageFile!.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image uploaded successfully')),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image upload failed')),
      );
    }
  }

  @override
  void initState() {
    super.initState();

    _businessNameController.text = widget.profile['businessName'] ?? '';
    _descriptionController.text = widget.profile['description'] ?? '';
    _cityController.text = widget.profile['city'] ?? '';
    _suburbController.text = widget.profile['suburb'] ?? '';
    _selectedCategories = widget.profile['category'];
    _selectedDays.addAll(List<String>.from(widget.profile['workingDays'] ?? []));
    _startTime = _parseTime(widget.profile['startTime']);
    _endTime = _parseTime(widget.profile['endTime']);
    _businessHoursController.text = '${widget.profile['startTime']} - ${widget.profile['endTime']}';
    _services = List<String>.from(widget.profile['services'] ?? []);
    _minRateController.text = widget.profile['minRate']?.toString() ?? '';
    _maxRateController.text = widget.profile['maxRate']?.toString() ?? '';
  }

  TimeOfDay? _parseTime(String? timeString) {
    if (timeString == null) return null;

    try {
      final dateTime = DateFormat.jm().parse(timeString); // handles "8:00 AM" or "6:30 PM"
      return TimeOfDay.fromDateTime(dateTime);
    } catch (e) {
      debugPrint("Time parse error: $e");
      return null;
    }
  }
  @override
  void dispose() {
    _businessNameController.dispose();
    _descriptionController.dispose();
    _cityController.dispose();
    _suburbController.dispose();
    _businessHoursController.dispose();
    _minRateController.dispose();
    _maxRateController.dispose();
    _servicesController.dispose();

    super.dispose();
  }

  // Form Steps
  List<Step> _buildSteps() {
    return [
      Step(
        title: const Text('Business details'),
        content: Column(
          children: [
            _buildTextField(_businessNameController, 'Business Name'),
            _buildTextField(_descriptionController, 'Description'),
            _buildTextField(_cityController, 'City'),
            _buildTextField(_suburbController, 'Suburb')
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
            const SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Select Working Days',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: _weekDays.map((day) {
                    final isSelected = _selectedDays.contains(day);
                    return FilterChip(
                      label: Text(day),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedDays.add(day);
                          } else {
                            _selectedDays.remove(day);
                          }
                        });
                      },
                      selectedColor: Colors.deepPurpleAccent,
                      showCheckmark: false,
                      backgroundColor: Colors.grey[200],
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.deepPurple : Colors.black,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),

            const SizedBox(height: 20),
            TextFormField(
              controller: _businessHoursController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Working Hours',
                suffixIcon: Icon(Icons.access_time),
              ),
              onTap: () async {
                TimeOfDay? pickedStart = await showTimePicker(
                  context: context,
                  initialTime: _startTime ?? TimeOfDay(hour: 8, minute: 0),
                );

                if (pickedStart == null) return;

                TimeOfDay? pickedEnd = await showTimePicker(
                  context: context,
                  initialTime: _endTime ?? TimeOfDay(hour: 17, minute: 0),
                );

                if (pickedEnd == null) return;

                setState(() {
                  _startTime = pickedStart;
                  _endTime = pickedEnd;
                  _businessHoursController.text = '${_formatTime(_startTime!)} - ${_formatTime(_endTime!)}';
                });
              },
            ),
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

            const Text(
              'Your Rate (e.g. R400 - R1000)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _minRateController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Min Rate',
                      prefixText: 'R',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter min rate';
                      }
                      final val = int.tryParse(value);
                      if (val == null || val < 0) {
                        return 'Invalid number';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: TextFormField(
                    controller: _maxRateController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Max Rate',
                      prefixText: 'R',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter max rate';
                      }
                      final min = int.tryParse(_minRateController.text);
                      final max = int.tryParse(value);
                      if (max == null || max < 0) {
                        return 'Invalid number';
                      }
                      if (min != null && max < min) {
                        return 'Max < Min';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),

        isActive: _currentStep >= 2,
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

  Future<int> _getUserIdFromLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt("userId") ?? 0;
  }

  void _onStepContinue() async {
    if (_currentStep < _buildSteps().length - 1) {
      setState(() => _currentStep += 1);
    } else if (_formKey.currentState!.validate()) {
      // Collect form data
      final userId = await _getUserIdFromLocalStorage(); // Update this to match your storage method
      final profile = {
        "businessName": _businessNameController.text.trim(),
        "description": _descriptionController.text.trim(),
        "city": _cityController.text.trim(),
        "suburb": _suburbController.text.trim(),
        "category": _selectedCategories,
        "workingDays": _selectedDays.toList(),
        "startTime": _startTime?.format(context),
        "endTime": _endTime?.format(context),
        "services": _services,
        "minRate": double.tryParse(_minRateController.text) ?? 0,
        "maxRate": double.tryParse(_maxRateController.text) ?? 0,
        // skip image for now; upload separately
      };

      // Send to backend
      try {
        final userId = await _getUserIdFromLocalStorage();
        final response = await http.post(
          Uri.parse("http://10.0.2.2:8080/providers/$userId"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(profile),
        );

        if (response.statusCode == 200) {
          await _uploadImage(userId);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile saved successfully')),
          );
          widget.onDone();
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save profile: ${response.body}')),
          );
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
        print("Error: $e");
      }
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
      appBar: AppBar(title: const Text("Add Business")),
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
