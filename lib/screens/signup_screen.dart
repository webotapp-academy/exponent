import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_screen.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

class SignupScreen extends HookWidget {
  final int? phone;
  const SignupScreen({Key? key, this.phone}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final fullNameController = useTextEditingController();
    final phoneController =
        useTextEditingController(text: phone != null ? phone.toString() : '');
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final isPasswordVisible = useState(false);
    final isTermsChecked = useState(false);
    final List<String> courseOptions = ['Class 12', 'NEET'];
    final selectedCourses = useState<List<String>>([]);

    // Signup method
    Future<void> signUpUser() async {
      // Validate inputs
      if (fullNameController.text.isEmpty ||
          phoneController.text.isEmpty ||
          selectedCourses.value.isEmpty ||
          emailController.text.isEmpty ||
          passwordController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Please fill all fields and select at least one course')),
        );
        return;
      }

      try {
        print(
            'Signup request: Name=${fullNameController.text}, Email=${emailController.text}, Password=${passwordController.text}');
        final response = await http.post(
          Uri.parse(
              'https://indiawebdesigns.in/app/eduapp/user-app/signup.php'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'Name': fullNameController.text,
            'Phone': phoneController.text,
            'Courses': selectedCourses.value,
            'Email': emailController.text,
            'Password': passwordController.text,
          }),
        );

        print('Signup response status: ${response.statusCode}');
        print('Signup response body: ${response.body}');

        final responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Registration Successful')),
          );
          // Navigate to course selection screen after signup
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text(responseData['message'] ?? 'Registration Failed')),
          );
        }
      } catch (e) {
        print('Signup error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFe3f0ff),
              Color(0xFFf5faff),
              Color(0xFFe6e9f0),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo with shadow
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.10),
                          blurRadius: 24,
                          spreadRadius: 2,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.school,
                        size: 64,
                        color: Colors.blue[800],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Create your account',
                    style: GoogleFonts.poppins(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign up to get started',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: Colors.blueGrey[700],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blueGrey.withOpacity(0.08),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('Personal Details',
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: Colors.blue[800])),
                        const SizedBox(height: 14),
                        _buildTextField(
                          controller: fullNameController,
                          hintText: 'Full Name',
                          prefixIcon: Icons.person_outline,
                        ),
                        const SizedBox(height: 14),
                        _buildTextField(
                          controller: phoneController,
                          hintText: 'Phone Number',
                          prefixIcon: Icons.phone_android,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 18),
                        Divider(color: Colors.grey[200], thickness: 1),
                        const SizedBox(height: 18),
                        Text('Select Course(s)',
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: Colors.blue[800])),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 12,
                          runSpacing: 8,
                          children: courseOptions.map((course) {
                            final isSelected =
                                selectedCourses.value.contains(course);
                            return FilterChip(
                              label: Text(course),
                              selected: isSelected,
                              selectedColor: Colors.blue[100],
                              backgroundColor: Colors.grey[100],
                              checkmarkColor: Colors.blue[800],
                              labelStyle: GoogleFonts.poppins(
                                color: isSelected
                                    ? Colors.blue[800]
                                    : Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              onSelected: (selected) {
                                final updated =
                                    List<String>.from(selectedCourses.value);
                                if (selected) {
                                  updated.add(course);
                                } else {
                                  updated.remove(course);
                                }
                                selectedCourses.value = updated;
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 18),
                        Divider(color: Colors.grey[200], thickness: 1),
                        const SizedBox(height: 18),
                        Text('Account Details',
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: Colors.blue[800])),
                        const SizedBox(height: 14),
                        _buildTextField(
                          controller: emailController,
                          hintText: 'Email',
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 14),
                        _buildTextField(
                          controller: passwordController,
                          hintText: 'Password',
                          prefixIcon: Icons.lock_outline,
                          obscureText: !isPasswordVisible.value,
                          suffixIcon: IconButton(
                            icon: Icon(
                              isPasswordVisible.value
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              isPasswordVisible.value =
                                  !isPasswordVisible.value;
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Checkbox(
                              value: isTermsChecked.value,
                              onChanged: (bool? value) {
                                isTermsChecked.value = value ?? false;
                              },
                              activeColor: Colors.blue,
                            ),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: GoogleFonts.poppins(
                                      color: Colors.black54, fontSize: 13),
                                  children: [
                                    const TextSpan(text: 'I agree to the '),
                                    TextSpan(
                                      text: 'EduRev\'s Terms & Conditions',
                                      style: GoogleFonts.poppins(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const TextSpan(text: ' and '),
                                    TextSpan(
                                      text: 'Privacy Policy',
                                      style: GoogleFonts.poppins(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        ElevatedButton(
                          onPressed: isTermsChecked.value
                              ? () {
                                  signUpUser();
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 52),
                            backgroundColor: Colors.blue[800],
                            disabledBackgroundColor: Colors.grey[300],
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Sign Up',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(child: Divider(color: Colors.grey[300])),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                'or',
                                style: GoogleFonts.poppins(
                                    color: Colors.grey, fontSize: 13),
                              ),
                            ),
                            Expanded(child: Divider(color: Colors.grey[300])),
                          ],
                        ),
                        const SizedBox(height: 18),
                        OutlinedButton(
                          onPressed: () {
                            // TODO: Implement Google Sign-In
                            print('Continue with Google');
                          },
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 52),
                            side: BorderSide(color: Colors.grey[300]!),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.login, color: Colors.red, size: 24),
                              const SizedBox(width: 10),
                              Text(
                                'Continue with Google',
                                style: GoogleFonts.poppins(
                                    color: Colors.black87, fontSize: 15),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account? ',
                              style: GoogleFonts.poppins(fontSize: 13),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const LoginScreen()),
                                );
                              },
                              child: Text(
                                'Log In',
                                style: GoogleFonts.poppins(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
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
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
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
}
