import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:client/enums.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:flutter/services.dart';


class VerifyOtpScreen extends StatefulWidget {
  final String email;
  final VerificationType verificationType;

  const VerifyOtpScreen({
    super.key,
    required this.email,
    required this.verificationType,
  });

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _otpController = TextEditingController();

  int _resendCooldown = 30; // seconds
  bool _canResend = true;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void _startCooldown() {
    setState(() {
      _canResend = false;
      _resendCooldown = 30;
    });

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_resendCooldown == 0) {
        setState(() {
          _canResend = true;
        });
        _timer?.cancel();
      } else {
        setState(() {
          _resendCooldown--;
        });
      }
    });
  }

  Future<void> _submitVerificationCode() async {
    if (_formKey.currentState!.validate()) {
      final otp = _otpController.text.trim();

      // Choose URL based on verification type
      final String urlStr = widget.verificationType == VerificationType.accountVerification
          ? 'http://10.0.2.2:8080/auth/verify-otp'
          : 'http://10.0.2.2:8080/auth/verify-reset-otp';

      final url = Uri.parse(urlStr);

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': widget.email, 'otp': otp}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.body)),
          
        );
        await Future.delayed(const Duration(seconds: 2));

        if (widget.verificationType == VerificationType.accountVerification) {
          Navigator.pushReplacementNamed(context, '/login');
        } else {
          // For password reset, navigate to reset password screen, passing the email
          Navigator.pushReplacementNamed(context, '/reset-password', arguments: widget.email);
        }
      } else {
        String errorMessage = 'Verification failed';
        try {
          print('Status code: ${response.statusCode}');
          print('Response body: ${response.body}');

          final data = jsonDecode(response.body);
          if (data['message'] != null) {
            errorMessage = data['message'];
          }
        } catch (_) {}

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    }
  }

  Future<void> _sendOtp() async {
    if (!_canResend) return; // prevent spamming

    final String urlStr = widget.verificationType ==
        VerificationType.accountVerification
        ? 'http://10.0.2.2:8080/auth/send-otp'
        : 'http://10.0.2.2:8080/auth/send-reset-otp';

    final url = Uri.parse(urlStr);

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': widget.email}),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP resent successfully')),
      );
      _startCooldown();
    } else {
      String error = 'Failed to resend OTP';
      try {
        final body = jsonDecode(response.body);
        if (body['message'] != null) error = body['message'];
      } catch (_) {}
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.verificationType == VerificationType.accountVerification
              ? 'Verify Account OTP'
              : 'Verify Password Reset OTP',
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Check your email and enter the OTP code below.',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

            PinCodeTextField(
              appContext: context,
              length: 6,
              obscureText: false,
              animationType: AnimationType.fade,
              keyboardType: TextInputType.number,
              autoDisposeControllers: false,
              controller: _otpController,
              autoFocus: true,
              enablePinAutofill: true, // Keep this for clipboard auto-detection
              animationDuration: const Duration(milliseconds: 300),
              pinTheme: PinTheme(
                shape: PinCodeFieldShape.box,
                borderRadius: BorderRadius.circular(8),
                fieldHeight: 50,
                fieldWidth: 40,
                activeFillColor: Colors.white,
                selectedColor: Colors.deepPurpleAccent,
                activeColor: Colors.deepPurpleAccent,
                inactiveColor: Colors.grey,
              ),
              onChanged: (value) {},
              onCompleted: (value) {
                _submitVerificationCode();
              },
            ),

            const SizedBox(height: 10),

              // Resend OTP with cooldown timer & disabled state
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: _canResend ? _sendOtp : null,
                  child: Text(
                    _canResend
                        ? 'Resend OTP'
                        : 'Resend OTP in $_resendCooldown s',
                    style: TextStyle(
                      color: _canResend ? Colors.black87 : Colors.grey,
                      decoration:
                      _canResend ? TextDecoration.underline : TextDecoration.none,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitVerificationCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white70,
                  minimumSize: const Size.fromHeight(50),
                ),
                child: const Text(
                  'Verify OTP',
                  style: TextStyle(color: Colors.deepPurpleAccent),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }



}
