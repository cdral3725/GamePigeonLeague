import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  _PhoneAuthScreenState createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  String _verificationId = "";
  String _errorMessage = "";

  Future<void> _verifyPhone() async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: _phoneController.text.trim(),
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
          Navigator.pushReplacementNamed(context, "/home");
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() => _errorMessage = e.message ?? "Verification failed.");
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() => _verificationId = verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          setState(() => _verificationId = verificationId);
        },
      );
    } catch (e) {
      setState(() => _errorMessage = "Phone verification failed.");
    }
  }

  Future<void> _verifyOTP() async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: _otpController.text.trim(),
      );
      await _auth.signInWithCredential(credential);
      Navigator.pushReplacementNamed(context, "/home");
    } catch (e) {
      setState(() => _errorMessage = "Invalid OTP.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Phone Authentication")),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(controller: _phoneController, decoration: InputDecoration(labelText: "Phone Number")),
              ElevatedButton(onPressed: _verifyPhone, child: Text("Send OTP")),
              TextField(controller: _otpController, decoration: InputDecoration(labelText: "Enter OTP")),
              ElevatedButton(onPressed: _verifyOTP, child: Text("Verify OTP")),
              if (_errorMessage.isNotEmpty) Text(_errorMessage, style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ),
    );
  }
}
