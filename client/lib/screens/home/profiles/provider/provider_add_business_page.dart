
import 'dart:convert';
import 'dart:io';

import 'package:client/screens/home/bookings/provider_bookings_page.dart';
import 'package:client/screens/home/home.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../utils/business.dart';
import '../../../../utils/business_product_image.dart';
import 'dart:typed_data';

class ProviderAddBusinessPage extends StatefulWidget {
  final Map<String, dynamic>? business;
  const ProviderAddBusinessPage({super.key, this.business});

  @override
  State<ProviderAddBusinessPage> createState() => _ProviderAddBusinessPage();
}

class _ProviderAddBusinessPage extends State<ProviderAddBusinessPage> {

  //region Variables
  Uint8List? _existingProfileImage;
  late Business b;
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  List<XFile> _pickedImages = [];

  List<Map<String, dynamic>> _existingImages = []; // For images loaded from the DB, each with an 'id' and base64


  bool _isLoading = false;
  int _currentStep = 0;

  late bool isEditing;

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

  TimeOfDay? _stylistStartTime;
  TimeOfDay? _stylistEndTime;

  final _formKeys = List.generate(4, (_) => GlobalKey<FormState>());
  //endregion

  //region Controllers
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _servicesController = TextEditingController();
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _suburbController = TextEditingController();
  final TextEditingController _businessHoursController = TextEditingController();
  final TextEditingController _minRateController = TextEditingController();
  final TextEditingController _maxRateController = TextEditingController();
  final TextEditingController _businessPhoneController = TextEditingController();

  //Stylists
  final TextEditingController _stylistFirstNameController = TextEditingController();
  final TextEditingController _stylistLastNameController = TextEditingController();
  final TextEditingController _stylistHoursController = TextEditingController();
//endregion

  //region Image Picking Functions
  //region Image Picking functions For Profile
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
          _profileImage = File(pickedFile.path);
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

  Future<void> _uploadProfileImage(int businessId) async {
    if (_profileImage == null) return;

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('http://10.0.2.2:8080/businesses/$businessId/profile/upload'),
    );

    request.files.add(await http.MultipartFile.fromPath('image', _profileImage!.path));

    try {
      final response = await request.send();

      if (response.statusCode != 200) {
        final error = await response.stream.bytesToString();
        debugPrint('Profile upload failed: $error');
        throw Exception('Profile image upload failed');
      }else{

      }
    } catch (e) {
      debugPrint('Upload profile image error: $e');
      rethrow;
    }
  }

  //endregion

  //region Image Picking functions For Business Products
  Future<void> _selectImages() async {
    final List<XFile>? selected = await _picker.pickMultiImage();

    if (selected != null) {
      int total = b.products.length;

      if ((total + selected.length) > 5) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You can only have a maximum of 5 product images')),
        );
        return;
      }

      List<BusinessProductImage> newImages = [];
      for (XFile image in selected) {
        final bytes = await image.readAsBytes();
        final base64Image = base64Encode(bytes);
        newImages.add(BusinessProductImage(id: -1, imageData: base64Image));
      }

      setState(() {
        _pickedImages.addAll(selected); // optional, if you use it elsewhere
        b.products.addAll(newImages);
      });
    }
  }

  Future<void> _uploadProductImages(int businessId) async {
    if (_pickedImages.isEmpty) return;

    final uri = Uri.parse('http://10.0.2.2:8080/businesses/$businessId/products/upload');
    final request = http.MultipartRequest('POST', uri);

    for (final image in _pickedImages) {
      request.files.add(await http.MultipartFile.fromPath('images', image.path));
    }

    try {
      final response = await request.send();

      if (response.statusCode != 200) {
        final error = await response.stream.bytesToString();
        debugPrint('Profile upload failed: $error');
        throw Exception('Profile image upload failed');
      }else
        {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile pic saved successfully')),
          );
        }
    } catch (e) {
      debugPrint('Upload product images error: $e');
      rethrow;
    }
  }
  //endregion
  //endregion

  //region Date-Time Formatting Functions
  String _formatTime(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat.jm().format(dt); // This uses regular spacing
  }


  TimeOfDay? _parseTime(String timeStr) {
    try {
      // Replace all Unicode spaces (non-breaking, narrow, etc.) with a normal space
      final cleaned = timeStr.replaceAll(RegExp(r'\s+'), ' ').replaceAll('\u202F', ' ').trim();

      final parsed = DateFormat.jm().parse(cleaned); // 'jm' = hour + am/pm
      return TimeOfDay.fromDateTime(parsed);
    } catch (e) {
      debugPrint("Time parse error: $e");
      return null;
    }
  }
  //endregion

  //region Step Functions
  void _onStepContinue() async {
    final isLastStep = _currentStep == _formKeys.length - 1;
    final isValid = _formKeys[_currentStep].currentState?.validate() ?? false;

    if (!isValid) return;

    if (!isLastStep) {
      setState(() => _currentStep += 1);
      return;
    }

    final userId = await _getUserIdFromLocalStorage();

    final profile = {
      "businessName": _businessNameController.text.trim(),
      "description": _descriptionController.text.trim(),
      "city": _cityController.text.trim(),
      "suburb": _suburbController.text.trim(),
      "businessPhone": _businessPhoneController.text.trim(),
      "category": _selectedCategories,
      "workingDays": _selectedDays.toList(),
      "startTime": _startTime?.format(context),
      "endTime": _endTime?.format(context),
      "services": _services,
      "minRate": double.tryParse(_minRateController.text) ?? 0,
      "maxRate": double.tryParse(_maxRateController.text) ?? 0,
    };

    try {
      final uri = isEditing
          ? Uri.parse("http://10.0.2.2:8080/businesses/${widget.business!['id']}")
          : Uri.parse("http://10.0.2.2:8080/businesses/user/$userId");

      final response = await (isEditing
          ? http.put(uri, headers: {"Content-Type": "application/json"}, body: jsonEncode(profile))
          : http.post(uri, headers: {"Content-Type": "application/json"}, body: jsonEncode(profile)));

      if (response.statusCode == 200) {
        final responseJson = jsonDecode(response.body);
        final businessId = responseJson['id'];

        try {
          await _uploadProfileImage(businessId);
          await _uploadProductImages(businessId);
        } catch (e) {
          debugPrint('Image upload failed: $e');
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to upload images: $e')),
          );
          return;
        }

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Business saved successfully')),
        );

        final prefs = await SharedPreferences.getInstance();
        final userId = prefs.getInt('userId');

        if (userId == null) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User ID not found')),
          );
          return;
        }

        if (isEditing) {
          try {
            final updatedBusiness = await fetchBusinessByUser(userId);

            if (!mounted) return;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomeScreen(initialIndex: 0,
                    business: updatedBusiness),
              ),
            );
          } catch (e) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to load updated business: $e')),
            );
          }
        } else {
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(initialIndex: 1),
            ),
          );
        }
      } else {
        // 👇 Add this to handle error cases
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save business: ${response.statusCode}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unexpected error: $e')),
      );
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep -= 1);
    }
  }
  //endregion

  //region Other Functions
  @override
  void dispose() {
    _businessNameController.dispose();
    _descriptionController.dispose();
    _cityController.dispose();
    _suburbController.dispose();
    _businessPhoneController.dispose();
    _businessHoursController.dispose();
    _minRateController.dispose();
    _maxRateController.dispose();
    _servicesController.dispose();

    super.dispose();
  }

  Future<int> _getUserIdFromLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt("userId") ?? 0;
  }

  @override
  void initState() {
    super.initState();
    isEditing = widget.business != null;

    if (isEditing) {
      b = Business.fromJson(widget.business!);
      _existingImages = b.products.map((img) => {
        'id': img.id,
        'imageData': img.imageData,
      }).toList();

      _existingProfileImage = b.profileImageBytes;
      _businessNameController.text = b.businessName;
      _descriptionController.text = b.description;
      _cityController.text = b.city;
      _suburbController.text = b.suburb;
      _businessPhoneController.text = b.businessPhone;
      _selectedCategories = b.category;
      _selectedDays.addAll(b.workingDays);
      _startTime = _parseTime(b.startTime);
      _endTime = _parseTime(b.endTime);

      if (_startTime != null && _endTime != null) {
        _businessHoursController.text =
        '${_formatTime(_startTime!)} - ${_formatTime(_endTime!)}';
      }

      _services.addAll(b.services);
      _minRateController.text = b.minRate.toString();
      _maxRateController.text = b.maxRate.toString();


    }else {
      // ✅ Create a new blank business
      b = Business(
        id: 0,
        businessName: '',
        description: '',
        province: '',
        category: '',
        city: '',
        suburb: '',
        businessPhone: '',
        services: [],
        workingDays: [],
        startTime: '',
        endTime: '',
        minRate: 0.0,
        maxRate: 0.0,
        profileImageUrl: '',
        rating: 0.0,
        products: [],
      );
    }
  }

  Future<Business> fetchBusinessByUser(int userId) async {
    final response = await http.get(
      Uri.parse("http://10.0.2.2:8080/businesses/user/$userId/single"),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return Business.fromJson(json);
    } else {
      throw Exception('Failed to load business');
    }
  }


  //endregion

  //region Delete Handlers
  void _removePickedImage(int index) {
    setState(() {
      _pickedImages.removeAt(index);
    });
  }

  Future<void> _deleteExistingImage(int index, int imageId) async {
    try {
      await _deleteImageFromServer(imageId); // your API call
      setState(() {
        _existingImages.removeAt(index);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image deleted')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete image: $e')),
      );
    }
  }


  //endregion

  //region CRUID Functions
  Future<void> _deleteImageFromServer(int imageId) async {
    final response = await http.delete(
      Uri.parse('http://10.0.2.2:8080/businesses/products/$imageId'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete image');
    }
  }
  //endregion

  List<Step> _buildSteps() {
    return [
      //Business Details step
      Step(
          title: const Text('Business details'),
          content: Form(
          key: _formKeys[0],
        child: Column(
          children: [
            _buildTextField(_businessNameController, 'Business Name'),
            _buildTextField(_descriptionController, 'Description'),
            _buildTextField(_cityController, 'City'),
            _buildTextField(_suburbController, 'Suburb'),
            _buildTextField(
              _businessPhoneController,
              'Business Number',
              keyboard: TextInputType.phone,
            ),
          ],
        ),
      ),
      isActive: _currentStep >= 0,
      ),
      //More business info step
      Step(
        title: const Text('More business info'),
        content: Form(
          key: _formKeys[1], // <-- Make sure you initialized this in your State
          child: Column(
            children: [
              // Category Dropdown
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
              // Working Days
              FormField<List<String>>(
                initialValue: _selectedDays.toList(),
                validator: (days) => days == null || days.isEmpty ? 'Select at least one working day' : null,
                builder: (state) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Select Working Days',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                              state.didChange(_selectedDays.toList());
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
                      if (state.hasError)
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Text(state.errorText!, style: TextStyle(color: Colors.red)),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              // Working Hours Picker
              FormField<String>(
                validator: (value) => _startTime == null || _endTime == null ? 'Please select working hours' : null,
                builder: (state) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _businessHoursController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Working Hours',
                        suffixIcon: Icon(Icons.access_time),
                      ),
                      onTap: () async {
                        // Pick start time, defaulting to _startTime or 8:00 AM
                        final pickedStart = await showTimePicker(
                          context: context,
                          initialTime: _startTime ?? const TimeOfDay(hour: 8, minute: 0),
                        );
                        if (pickedStart == null) return;

                        // Pick end time, defaulting to _endTime or 5:00 PM
                        final pickedEnd = await showTimePicker(
                          context: context,
                          initialTime: _endTime ?? const TimeOfDay(hour: 17, minute: 0),
                        );
                        if (pickedEnd == null) return;

                        // Update state with the picked times and update the controller text
                        setState(() {
                          _startTime = pickedStart;
                          _endTime = pickedEnd;
                          _businessHoursController.text =
                          '${_formatTime(_startTime!)} - ${_formatTime(_endTime!)}';
                        });

                        // If this is inside a FormField, notify the state change
                        state.didChange("set");
                      },
                    ),
                    if (state.hasError)
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Text(state.errorText!, style: TextStyle(color: Colors.red)),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        isActive: _currentStep >= 1,
      ),
      //Services step
      Step(
        title: const Text('Services'),
        content: Form(
          key: _formKeys[2], // Step 2 form key
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Name your services"),
              TextFormField(
                controller: _servicesController,
                decoration: const InputDecoration(
                  hintText: 'Enter a service and press enter',
                ),
                onFieldSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    setState(() {
                      _services.add(value.trim());
                      _servicesController.clear();
                    });
                  }
                },
              ),

              const SizedBox(height: 10),

              // Chip list with delete buttons
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _services
                    .asMap()
                    .entries
                    .map((entry) => Chip(
                  label: Text(entry.value),
                  deleteIcon: const Icon(Icons.close),
                  onDeleted: () {
                    setState(() {
                      _services.removeAt(entry.key);
                    });
                  },
                ))
                    .toList(),
              ),

              const SizedBox(height: 10),

              // Validate at least 1 service using FormField
              FormField<List<String>>(
                initialValue: _services,
                validator: (services) => services == null || services.isEmpty ? 'Please add at least one service' : null,
                builder: (state) {
                  return state.hasError
                      ? Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Text(state.errorText!, style: const TextStyle(color: Colors.red)),
                  )
                      : const SizedBox();
                },
              ),

              const SizedBox(height: 20),

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
                        final val = double.tryParse(value);
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
                        final min = double.tryParse(_minRateController.text);
                        final max = double.tryParse(value);
                        if (max == null || max < 0) return 'Invalid number';
                        if (min != null && max < min) return 'Max < Min';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        isActive: _currentStep >= 2,
      ),
      //Product Images step
      Step(
        title: const Text('Products'),
        content: Form(
          key: _formKeys[3],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ElevatedButton.icon(
                onPressed: _selectImages,
                icon: const Icon(Icons.add_photo_alternate),
                label: const Text("Select Product Images"),
              ),
              const SizedBox(height: 10),

              // ---------- Product Images from Business.products ----------
              SizedBox(
                height: 180,
                child: b.products.isNotEmpty
                    ? ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: b.products.length,
                  itemBuilder: (context, index) {
                    final img = b.products[index];
                    return Stack(
                      children: [
                        Container(
                          width: 180,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.memory(
                              base64Decode(img.imageData),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () async {
                              final img = b.products[index];
                              if (img.id == -1) {
                                setState(() => b.products.removeAt(index));
                              } else {
                                try {
                                  await _deleteImageFromServer(img.id);
                                  setState(() => b.products.removeAt(index));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Image deleted')),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Failed to delete image')),
                                  );
                                }
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.all(4),
                              child: const Icon(Icons.delete, color: Colors.white, size: 20),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                )
                    : const Center(child: Text('No product images')),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
        isActive: _currentStep >= 3,
      ),
    ];
  }

  //region Build Texts
  Widget _buildTextField(
      TextEditingController controller,
      String label, {
        bool isOptional = false,
        TextInputType keyboard = TextInputType.text,
        String? hint,
      }) {
    Icon? icon;

    switch (label) {
      case 'Business Name':
        icon = const Icon(Icons.business,color: Colors.deepPurpleAccent);
        break;
      case 'Description':
        icon = const Icon(Icons.description,color: Colors.deepPurpleAccent);
        break;
      case 'City':
        icon = const Icon(Icons.location_city,color: Colors.deepPurpleAccent);
        break;
      case 'Suburb':
        icon = const Icon(Icons.location_on,color: Colors.deepPurpleAccent);
        break;
      case 'Business Number':
        icon = const Icon(Icons.phone,color: Colors.deepPurpleAccent);
        break;
      case 'Min Rate':
        icon = const Icon(Icons.money,color: Colors.deepPurpleAccent);
        break;
      case 'Max Rate':
        icon = const Icon(Icons.attach_money,color: Colors.deepPurpleAccent);
        break;
      case 'First Name':
        icon = const Icon(Icons.person,color: Colors.deepPurpleAccent);
        break;
      case 'Last Name':
        icon = const Icon(Icons.person_outline,color: Colors.deepPurpleAccent);
        break;
      default:
        icon = const Icon(Icons.text_fields,color: Colors.deepPurpleAccent);
    }

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

          if (label == 'Business Number') {
            final phoneRegex = RegExp(r'^(0|\+27)[6-8][0-9]{8}$');
            if (!phoneRegex.hasMatch(value)) {
              return 'Enter a valid phone number';
            }
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
          prefixIcon: icon,
        ),
      ),
    );
  }

  Widget _buildImageCard({XFile? file, String? base64, required VoidCallback onDelete}) {
    return Container(
      width: 180,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: file != null
                ? Image.file(File(file.path), fit: BoxFit.cover, width: 180, height: 180)
                : Image.memory(base64Decode(base64!), fit: BoxFit.cover, width: 180, height: 180),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: onDelete,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(4),
                child: const Icon(Icons.delete, size: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

//endregion

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'Editing ${widget.business?['businessName'] ?? ''}' : 'New Business',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
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