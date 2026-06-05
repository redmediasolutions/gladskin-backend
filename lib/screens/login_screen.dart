import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  bool _isOtpSent = false;
  bool _isLoading = false;

  String _reqId = "";

  final String baseUrl =
      "https://us-central1-glowfit-4dfe8.cloudfunctions.net";

  /// SEND OTP
  Future<void> _sendOtp() async {
    final phone =
        _phoneController.text.replaceAll(RegExp(r'\D'), '');

    if (phone.length < 10) {
      _showMessage("Enter valid mobile number");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/sendGladskinOtp"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "phoneNumber": phone,
          "isAdmin": true,
        }),
      );

      final data = jsonDecode(response.body);

      if (data["success"] != true) {
        throw Exception(data["message"]);
      }

      setState(() {
        _isOtpSent = true;
        _reqId = data["reqId"];
      });

      _showMessage("OTP sent successfully");
    } catch (e) {
      _showMessage(e.toString().replaceAll("Exception: ", ""));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// VERIFY OTP
  Future<void> _verifyOtp() async {
    final phone =
        _phoneController.text.replaceAll(RegExp(r'\D'), '');

    final otp = _otpController.text.trim();

    if (otp.length != 4) {
      _showMessage("Enter valid OTP");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/verifyGladskinOtp"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "phoneNumber": phone,
          "otp": otp,
          "reqId": _reqId,
          "isAdmin": true,
        }),
      );

      final data = jsonDecode(response.body);

      if (data["success"] != true) {
        throw Exception(data["message"]);
      }

      final token = data["token"];

      /// Firebase Login
      /// Firebase Login
final userCredential =
    await FirebaseAuth.instance.signInWithCustomToken(token);

final user = userCredential.user;

if (user == null) {
  throw Exception("Authentication failed");
}

/// CHECK ADMIN ACCESS
final adminDoc = await FirebaseFirestore.instance
    .collection('Users')
    .doc(user.uid)
    .get();

final isAdmin = adminDoc.data()?['isAdmin'] == true;

if (!isAdmin) {
  /// Immediately logout
  await FirebaseAuth.instance.signOut();

  throw Exception("Access denied");
}

_showMessage("Login successful");

// Navigate to dashboard here

      // Navigate to dashboard here

    } catch (e) {
      _showMessage(e.toString().replaceAll("Exception: ", ""));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F4F4),
      body: Center(
        child: Container(
          width: 380,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Gladskin',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFB5838D),
                ),
              ),

              const SizedBox(height: 4),

              const Text(
                'Admin Panel',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 32),

              /// PHONE FIELD
              TextField(
                controller: _phoneController,
                enabled: !_isOtpSent,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Mobile Number',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),

              /// OTP FIELD
              if (_isOtpSent) ...[
                const SizedBox(height: 16),

                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'OTP',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                ),
              ],

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : _isOtpSent
                          ? _verifyOtp
                          : _sendOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB5838D),
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : Text(
                          _isOtpSent
                              ? 'Verify OTP'
                              : 'Send OTP',
                        ),
                ),
              ),

              if (_isOtpSent) ...[
                const SizedBox(height: 12),

                TextButton(
                  onPressed: () {
                    setState(() {
                      _isOtpSent = false;
                      _otpController.clear();
                    });
                  },
                  child: const Text("Change Number"),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}