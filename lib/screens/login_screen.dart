import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'home_screen.dart';
import 'signup_screen.dart';
import 'otp_screen.dart';

class LoginScreen extends HookWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final phoneController = useTextEditingController();
    final isLoading = useState(false);

    // Route to OTP screen with phone number
    void goToOtpScreen() {
      if (phoneController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please enter your phone number')),
        );
        return;
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => OtpScreen(phone: phoneController.text),
        ),
      );
    }

    // No inline OTP logic here; handled in OtpScreen

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE3ECFA), Color(0xFFFFFFFF)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // App Logo
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.10),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/icons/logo.png',
                        fit: BoxFit.cover,
                        width: 90,
                        height: 90,
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    'Welcome Back',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 26,
                      color: const Color(0xFF1A3A6C),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to your Exponent Classes account',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w400,
                      fontSize: 15,
                      color: Colors.blueGrey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  // Phone Field
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.07),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: _buildTextField(
                      controller: phoneController,
                      hintText: 'Enter your phone number',
                      prefixIcon: Icons.phone_android,
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                  const SizedBox(height: 22),
                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: goToOtpScreen,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A3A6C),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                        textStyle: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      child: Text('Continue',
                          style: GoogleFonts.poppins(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 28),
                  // Divider
                  Row(
                    children: [
                      Expanded(
                          child:
                              Divider(color: Colors.grey[300], thickness: 1)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text('or',
                            style:
                                GoogleFonts.poppins(color: Colors.grey[500])),
                      ),
                      Expanded(
                          child:
                              Divider(color: Colors.grey[300], thickness: 1)),
                    ],
                  ),

                  const SizedBox(height: 14),

                  const SizedBox(height: 24),
                  // Signup redirect
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'New to Exponent Classes?',
                        style: GoogleFonts.poppins(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SignupScreen(phone: null),
                            ),
                          );
                        },
                        child: Text(
                          'Create an account',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF1A3A6C),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.poppins(color: Colors.grey),
        prefixIcon: Icon(prefixIcon, color: Colors.grey),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      ),
    );
  }

  Widget _buildSocialLoginButton({
    String? icon,
    Widget? iconWidget,
    required String text,
    required VoidCallback onPressed,
    Color backgroundColor = Colors.white,
    Color textColor = Colors.black87,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        backgroundColor: backgroundColor,
        side: BorderSide(color: Colors.grey[300]!),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (iconWidget != null) iconWidget,
          if (iconWidget != null) const SizedBox(width: 10),
          Text(
            text,
            style: GoogleFonts.poppins(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
