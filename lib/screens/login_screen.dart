import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'signup_screen.dart';
import 'otp_screen.dart';
import 'package:flutter/services.dart';

class LoginScreen extends HookWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final phoneController = useTextEditingController();
    final isLoading = useState(false);
    final isValidPhone = useState(false);

    // Login API endpoint
    const apiUrl = 'https://indiawebdesigns.in/app/eduapp/user-app/login.php';

    Future<void> handleLogin() async {
      final phone = phoneController.text.trim();
      debugPrint('Login input phone: $phone'); // <-- Debug print input

      // Comprehensive phone number validation
      if (phone.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Please enter your phone number',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red[400],
          ),
        );
        return;
      }

      if (phone.length != 10) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Please enter a valid 10-digit mobile number',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red[400],
          ),
        );
        return;
      }

      // Check if the number starts with valid Indian mobile prefixes
      final validPrefixes = ['6', '7', '8', '9'];
      if (!validPrefixes.contains(phone[0])) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Please enter a valid Indian mobile number',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red[400],
          ),
        );
        return;
      }

      isLoading.value = true;
      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'Phone': phone, 'Userphone': phone}),
        );
        debugPrint(
            'Login API response: ${response.body}'); // <-- Debug print response
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          // Pass only phone to OTP screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => OtpScreen(
                phone: phone,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                data['message'] ?? 'Login failed',
                style: GoogleFonts.poppins(),
              ),
              backgroundColor: Colors.red[400],
            ),
          );
        }
      } catch (e) {
        debugPrint('Login error: $e'); // <-- Debug print error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Network error: $e',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red[400],
          ),
        );
      } finally {
        isLoading.value = false;
      }
    }

    // Update phone validation on each change
    useEffect(() {
      final phone = phoneController.text.trim();
      isValidPhone.value =
          phone.length == 10 && ['6', '7', '8', '9'].contains(phone[0]);
      return null;
    }, [phoneController.text]);

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
                      child: Padding(
                        padding: const EdgeInsets.all(
                            12), // Add padding to avoid cut
                        child: Image.asset(
                          'assets/icons/logo.png',
                          fit: BoxFit.contain, // Use contain for better fit
                          width: 66,
                          height: 66,
                        ),
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
                      isValidPhone: isValidPhone.value,
                    ),
                  ),
                  const SizedBox(height: 22),
                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isLoading.value ? null : handleLogin,
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
                      child: isLoading.value
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Text('Continue',
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
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'New to Exponent Classes?',
                        style: GoogleFonts.poppins(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
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
    required bool isValidPhone,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ],
      style: GoogleFonts.poppins(
        color: const Color(0xFF1A3A6C),
        fontSize: 16,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        counterText: '', // Hide character count
        hintStyle: GoogleFonts.poppins(
          color: Colors.grey[500],
          fontSize: 15,
        ),
        prefixIcon: Icon(
          prefixIcon,
          color: const Color(0xFF1A3A6C).withOpacity(0.7),
          size: 22,
        ),
        suffixIcon: isValidPhone
            ? Icon(
                Icons.check_circle,
                color: Colors.green[600],
                size: 22,
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.blue[100]!,
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: const Color(0xFF1A3A6C),
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 15,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.red[400]!,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}
