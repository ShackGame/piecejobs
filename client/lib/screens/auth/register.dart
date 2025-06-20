import 'dart:convert';

import 'package:client/screens/auth/verification.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:client/enums.dart';


class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _personalFormKey = GlobalKey<FormState>();
  final _accountFormKey = GlobalKey<FormState>();

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  DateTime? selectedDate;
  int _currentStep = 0;
  bool _agreedToTerms = false;
  bool _isLoading = false; // <-- Loading state

  final List<String> _userTypes = ['JobSeeker', 'Employer'];
  String? _selectedUserType;

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
  String? _selectedProvince;

  bool _emailValid = false;
  bool _passwordValid = false;

  final RegExp emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  final RegExp passwordRegExp = RegExp(r'^(?=.*?[A-Z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$');

  String? _emailError;
  String? _passwordError;

  void _validateEmail(String value) {
    setState(() {
      if (value.isEmpty) {
        _emailError = 'Email cannot be empty';
        _emailValid = false;
      } else if (!emailRegExp.hasMatch(value)) {
        _emailError = 'Enter a valid email';
        _emailValid = false;
      } else {
        _emailError = null;
        _emailValid = true;
      }
    });
  }

  void _validatePassword(String value) {
    setState(() {
      if (value.isEmpty) {
        _passwordError = 'Password cannot be empty';
        _passwordValid = false;
      } else if (!passwordRegExp.hasMatch(value)) {
        _passwordError = 'Password must be 8+ chars, include uppercase, number & symbol';
        _passwordValid = false;
      } else {
        _passwordError = null;
        _passwordValid = true;
      }
    });
  }

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
        _dateController.text = picked.toIso8601String().split('T')[0];
      });
    }
  }

  void _continue() {
    if (_isLoading) return; // disable continue while loading

    if (_currentStep == 0) {
      if (_personalFormKey.currentState!.validate()) {
        setState(() => _currentStep++);
      }
    } else if (_currentStep == 1) {
      if (_accountFormKey.currentState!.validate()) {
        if (_agreedToTerms) {
          _registerUser();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please accept the Terms & Conditions.')),
          );
        }
      }
    }
  }

  void _cancel() {
    if (_isLoading) return; // disable cancel while loading

    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _registerUser() async {
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept the Terms & Conditions.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse('http://10.0.2.2:8080/auth/register');

    final Map<String, dynamic> userData = {
      "firstName": _firstNameController.text.trim(),
      "lastName": _lastNameController.text.trim(),
      "dateOfBirth": _dateController.text.trim(),
      "province": _selectedProvince,
      "userType": _selectedUserType,
      "email": _emailController.text.trim(),
      "password": _passwordController.text.trim(),
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(userData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful. Check your email for OTP.')),
        );

        await Future.delayed(const Duration(seconds: 2));

        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VerifyOtpScreen(
              email: _emailController.text.trim(),
              verificationType: VerificationType.accountVerification,
            ),
          ),
        );

        _clear(); // clear form instead of redirect
      } else {
        try {
          final errorMsg = jsonDecode(response.body)['message'] ?? 'Unknown error';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Registration failed: $errorMsg')),

          );
        } catch (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration failed: Unexpected server response')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _clear() {
    _personalFormKey.currentState?.reset();
    _accountFormKey.currentState?.reset();
    _firstNameController.clear();
    _lastNameController.clear();
    _dateController.clear();
    _emailController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();

    setState(() {
      _selectedProvince = null;
      _selectedUserType = null;
      _agreedToTerms = false;
      _currentStep = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Form(
                key: _personalFormKey,
                child: Stepper(
                  currentStep: _currentStep,
                  onStepContinue: _continue,
                  onStepCancel: _cancel,
                  physics: const ClampingScrollPhysics(),
                  controlsBuilder: (context, details) {
                    return Row(
                      children: <Widget>[
                        ElevatedButton(
                          onPressed: (_isLoading || (_currentStep == 1 && (!_emailValid || !_passwordValid)))
                              ? null
                              : details.onStepContinue,
                          child: Text(_currentStep == 1 ? 'Submit' : 'Next'),
                        ),
                        const SizedBox(width: 8),
                        if (_currentStep > 0)
                          OutlinedButton(
                            onPressed: _isLoading ? null : details.onStepCancel,
                            child: const Text('Back'),
                          ),
                      ],
                    );
                  },
                  steps: [
                    Step(
                      title: const Text('Personal Info'),
                      isActive: _currentStep >= 0,
                      state: _currentStep > 0 ? StepState.complete : StepState.indexed,
                      content: Column(
                        children: [
                          TextFormField(
                            controller: _firstNameController,
                            decoration: InputDecoration(
                              labelText: 'First name',
                              hintText: 'Enter your first name',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            validator: (value) {
                              final isValid = value != null && value.isNotEmpty;
                              return isValid ? null : 'Please enter your name';
                            },
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _lastNameController,
                            decoration: InputDecoration(
                              labelText: 'Surname',
                              hintText: 'Enter your Surname',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            validator: (value) {
                              final isValid = value != null && value.isNotEmpty;
                              return isValid ? null : 'Please enter your last name';
                            },
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _dateController,
                            readOnly: true,
                            onTap: () => _selectDate(context),
                            decoration: InputDecoration(
                              labelText: "Date of Birth",
                              suffixIcon: const Icon(Icons.calendar_today, color: Colors.deepPurpleAccent),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            validator: (value) {
                              final isValid = value != null && value.isNotEmpty;
                              return isValid ? null : 'Please select your birth date';
                            },
                          ),
                          const SizedBox(height: 20),
                          DropdownButtonFormField<String>(
                            value: _selectedProvince,
                            decoration: InputDecoration(
                              labelText: 'Province',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            items: _provinces.map((String province) {
                              return DropdownMenuItem(value: province, child: Text(province));
                            }).toList(),
                            onChanged: (value) => setState(() => _selectedProvince = value),
                            validator: (value) {
                              final isValid = value != null && value.isNotEmpty;
                              return isValid ? null : 'Please select a province';
                            },
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                    Step(
                      title: const Text('Account Info'),
                      isActive: _currentStep >= 1,
                      state: StepState.indexed,
                      content: Form(
                        key: _accountFormKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                errorText: _emailError,
                                labelText: 'Email',
                                prefixIcon: const Icon(Icons.email, color: Colors.deepPurpleAccent),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onChanged: _validateEmail,
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                errorText: _passwordError,
                                labelText: 'Password',
                                prefixIcon: const Icon(Icons.lock, color: Colors.deepPurpleAccent),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onChanged: _validatePassword,
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: 'Confirm Password',
                                prefixIcon: const Icon(Icons.lock, color: Colors.deepPurpleAccent),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'Please confirm your password';
                                if (value != _passwordController.text) return 'Passwords do not match';
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            DropdownButtonFormField<String>(
                              value: _selectedUserType,
                              decoration: InputDecoration(
                                labelText: 'User Type',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              items: _userTypes.map((String userType) {
                                return DropdownMenuItem(value: userType, child: Text(userType));
                              }).toList(),
                              onChanged: (value) => setState(() => _selectedUserType = value),
                              validator: (value) {
                                final isValid = value != null && value.isNotEmpty;
                                return isValid ? null : 'Please select user type';
                              },
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Checkbox(
                                  value: _agreedToTerms,
                                  onChanged: (value) {
                                    setState(() {
                                      _agreedToTerms = value ?? false;
                                    });
                                  },
                                ),
                                const Flexible(
                                  child: Text('I agree to the Terms & Conditions'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_isLoading)
              Container(
                color: Colors.black54,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
