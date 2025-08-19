import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CareerCounsellingFormScreen extends StatefulWidget {
  const CareerCounsellingFormScreen({super.key});

  @override
  State<CareerCounsellingFormScreen> createState() =>
      _CareerCounsellingFormScreenState();
}

class _CareerCounsellingFormScreenState
    extends State<CareerCounsellingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController messageController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    messageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _prefillFromPrefs();
  }

  Future<void> _prefillFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedName = (prefs.getString('name') ?? '').trim();
      final savedPhone = (prefs.getString('phone') ??
              prefs.getString('Userphone') ??
              prefs.getString('Phone') ??
              '')
          .trim();
      final savedEmail = (prefs.getString('email') ?? '').trim();

      if (savedName.isNotEmpty && nameController.text.trim().isEmpty) {
        nameController.text = savedName;
      }
      if (savedPhone.isNotEmpty && phoneController.text.trim().isEmpty) {
        phoneController.text = savedPhone;
      }
      if (savedEmail.isNotEmpty && emailController.text.trim().isEmpty) {
        emailController.text = savedEmail;
      }
    } catch (_) {
      // ignore
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);
    try {
      // Prefer JSON POST
      final uri = Uri.parse(
          'https://indiawebdesigns.in/app/eduapp/user-app/save_career_counselling.php');
      // If your deployment path differs, update the URL above accordingly.

      final resp = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': nameController.text.trim(),
          'phone': phoneController.text.trim(),
          'email': emailController.text.trim().isEmpty
              ? null
              : emailController.text.trim(),
          'message': messageController.text.trim().isEmpty
              ? null
              : messageController.text.trim(),
        }),
      );

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final data = jsonDecode(resp.body);
        if (data is Map && (data['status'] == 'success')) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Your request has been submitted!')),
          );
          Navigator.pop(context);
          return;
        }
      }
      // Parse error body (if any) for better feedback
      String message =
          'Submission failed (${resp.statusCode}). Please try again.';
      try {
        final err = jsonDecode(resp.body);
        if (err is Map) {
          final serverMsg = err['message'];
          final errors = err['errors'];
          if (serverMsg is String && serverMsg.isNotEmpty) {
            message = serverMsg;
          }
          if (errors is List && errors.isNotEmpty) {
            message = '$message\n- ${errors.join('\n- ')}';
          }
        }
      } catch (_) {}
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error: $e')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColor =
        const Color(0xFF1A3A6C); // Align accent with dashboard theme

    InputDecoration _input(String label, {IconData? icon, String? hint}) {
      return InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: GoogleFonts.poppins(
          color: const Color(0xFF64748B),
          fontSize: 13,
        ),
        hintStyle: GoogleFonts.poppins(
          color: const Color(0xFF94A3B8),
          fontSize: 12,
        ),
        prefixIcon: icon == null
            ? null
            : Container(
                margin: const EdgeInsets.only(left: 8, right: 6),
                decoration: BoxDecoration(
                  color: themeColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                width: 40,
                child: Icon(icon, color: themeColor),
              ),
        prefixIconConstraints:
            const BoxConstraints(minWidth: 46, minHeight: 46),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: themeColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFF43F5E), width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFF43F5E), width: 1.4),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.grey[900]),
        title: Text(
          'Exponent Classes',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: Colors.grey[900],
            fontSize: 16,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded),
            tooltip: 'Notifications',
          ),
          const SizedBox(width: 4),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleAvatar(
              radius: 14,
              backgroundColor: Colors.blue[50],
              child: Icon(Icons.person, size: 18, color: Colors.blue[700]),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header panel aligned to dashboard pattern
            Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1A3A6C), Color(0xFF3D6DB5)],
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1A3A6C).withOpacity(0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Career Counselling',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Book a free session and get expert guidance',
                          style: GoogleFonts.poppins(
                            color: Colors.white.withOpacity(0.95),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 10,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Icon(Icons.support_agent,
                        color: Colors.blue[700], size: 32),
                  ),
                ],
              ),
            ),

            // Form card
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Card(
                elevation: 6,
                shadowColor: Colors.black.withOpacity(0.08),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: Form(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    key: _formKey,
                    child: Column(
                      children: [
                        // Section title
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color:
                                    const Color(0xFF1A3A6C).withOpacity(0.10),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.edit_calendar,
                                  color: Color(0xFF1A3A6C), size: 18),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Your Details',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        TextFormField(
                          controller: nameController,
                          textCapitalization: TextCapitalization.words,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: const Color(0xFF0F172A),
                          ),
                          decoration: _input(
                            'Full Name',
                            icon: Icons.person_outline,
                            hint: 'Enter your full name',
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Please enter your name'
                              : null,
                        ),
                        const SizedBox(height: 14),

                        TextFormField(
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: const Color(0xFF0F172A),
                          ),
                          decoration: _input(
                            'Phone Number',
                            icon: Icons.phone,
                            hint: '10-digit mobile number',
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Please enter your phone number';
                            }
                            final digits = v.replaceAll(RegExp(r'[^0-9]'), '');
                            if (digits.length < 10)
                              return 'Enter a valid phone number';
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        TextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: const Color(0xFF0F172A),
                          ),
                          decoration: _input(
                            'Email (optional)',
                            icon: Icons.email_outlined,
                            hint: 'you@example.com',
                          ),
                        ),
                        const SizedBox(height: 14),

                        TextFormField(
                          controller: messageController,
                          textCapitalization: TextCapitalization.sentences,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: const Color(0xFF0F172A),
                          ),
                          decoration: _input(
                            'How can we help? (optional)',
                            icon: Icons.message_outlined,
                            hint: 'Tell us about your goals or questions',
                          ),
                          maxLines: 4,
                        ),

                        const SizedBox(height: 18),
                        // Info helper
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFDBEAFE)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.lock_outline,
                                  color: themeColor, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Your details are safe with us. We will contact you within 24 hours.',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: const Color(0xFF1F2937),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: _submitting
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.send_rounded, size: 18),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: themeColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            onPressed: _submitting ? null : _submit,
                            label: Text(
                              _submitting
                                  ? 'Submitting...'
                                  : 'Book Counselling',
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Small footer support
            Center(
              child: Text(
                'Need immediate help? \n Write to support@exponent.edu',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
