import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'dart:convert'; // Added for jsonDecode
import 'package:http/http.dart' as http; // Added for http

class NeetTestSeriesScreen extends StatefulWidget {
  const NeetTestSeriesScreen({super.key});

  @override
  State<NeetTestSeriesScreen> createState() => _NeetTestSeriesScreenState();
}

class _NeetTestSeriesScreenState extends State<NeetTestSeriesScreen> {
  // Controllers for form fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _fatherNameController = TextEditingController();
  final TextEditingController _parentMobileController = TextEditingController();
  final TextEditingController _collegeNameController = TextEditingController();
  final TextEditingController _classPercentageController =
      TextEditingController();

  // Gender selection
  String _selectedGender = 'Male';
  final List<String> _genderOptions = ['Male', 'Female', 'Other'];

  // Loading and registration state
  bool _isSubmitting = false;
  bool _hasAlreadyApplied = false;
  int? _registrationId; // New variable to store registration ID

  // Future method to get profile photo URL
  Future<String?> _getProfilePhotoUrl() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('profile_photo');
    } catch (e) {
      debugPrint('Error retrieving profile photo URL: $e');
      return null;
    }
  }

  // Method to build form fields with compact styling
  Widget _buildCompactFormField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool isRequired = true,
    int? maxLength,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLength: maxLength,
        style: GoogleFonts.poppins(fontSize: 14),
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          prefixIcon: Icon(icon, size: 20, color: Colors.blue[700]),
          labelText: isRequired ? '$label *' : label,
          labelStyle: GoogleFonts.poppins(
            color: Colors.grey[600],
            fontSize: 14,
          ),
          counterText: '',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.blue[100]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.blue[100]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.blue[700]!),
          ),
        ),
      ),
    );
  }

  // Compact gender dropdown
  Widget _buildCompactGenderDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: _selectedGender,
        style: GoogleFonts.poppins(fontSize: 14, color: Colors.black),
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          prefixIcon:
              Icon(Icons.person_outline, size: 20, color: Colors.blue[700]),
          labelText: 'Gender *',
          labelStyle: GoogleFonts.poppins(
            color: Colors.grey[600],
            fontSize: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.blue[100]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.blue[100]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.blue[700]!),
          ),
        ),
        items: _genderOptions
            .map((gender) => DropdownMenuItem(
                  value: gender,
                  child: Text(
                    gender,
                    style: GoogleFonts.poppins(fontSize: 14),
                  ),
                ))
            .toList(),
        onChanged: (value) {
          setState(() {
            _selectedGender = value!;
          });
        },
      ),
    );
  }

  // Validate form inputs
  bool _validateInputs() {
    if (_nameController.text.trim().isEmpty) {
      _showError('Please enter student\'s name');
      return false;
    }
    if (_mobileController.text.trim().isEmpty ||
        !RegExp(r'^[6-9]\d{9}$').hasMatch(_mobileController.text.trim())) {
      _showError('Please enter a valid 10-digit mobile number');
      return false;
    }
    if (_fatherNameController.text.trim().isEmpty) {
      _showError('Please enter father\'s name');
      return false;
    }
    if (_parentMobileController.text.trim().isEmpty ||
        !RegExp(r'^[6-9]\d{9}$')
            .hasMatch(_parentMobileController.text.trim())) {
      _showError('Please enter a valid parent\'s mobile number');
      return false;
    }
    if (_collegeNameController.text.trim().isEmpty) {
      _showError('Please enter college name');
      return false;
    }
    if (_classPercentageController.text.trim().isEmpty) {
      _showError('Please enter 10th percentage');
      return false;
    }
    return true;
  }

  // Show error method
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _hasAlreadyApplied && _registrationId != null
              ? 'You have already applied. Your Registration ID is: $_registrationId'
              : message,
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        backgroundColor: _hasAlreadyApplied ? Colors.orange : Colors.red,
      ),
    );
  }

  // Future method to check existing registration
  Future<void> _checkExistingRegistration() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = await _getSafeUserId();

      debugPrint('Checking registration for userId: $userId');

      if (userId == null) {
        _showError('Unable to identify user');
        return;
      }

      debugPrint('Sending request to check registration');
      final response = await http.get(Uri.parse(
          'https://indiawebdesigns.in/app/eduapp/user-app/check_neet_registration.php?user_id=$userId'));

      debugPrint('Check Registration Response Status: ${response.statusCode}');
      debugPrint('Check Registration Response Body: ${response.body}');

      final responseData = jsonDecode(response.body);

      setState(() {
        _hasAlreadyApplied = responseData['status'] == 'success';
        // Store registration ID if available
        _registrationId = responseData['registration_id'] is int
            ? responseData['registration_id']
            : int.tryParse(responseData['registration_id']?.toString() ?? '');
      });

      debugPrint(
          'Registration check completed. Already applied: $_hasAlreadyApplied, Registration ID: $_registrationId');
    } catch (e) {
      debugPrint('Error checking registration: $e');
    }
  }

  // Method to fetch user details from shared preferences
  Future<void> _fetchUserDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Fetch name
      final userName = prefs.getString('name');
      if (userName != null) {
        _nameController.text = userName;
      }

      // Fetch mobile number
      final userMobile = prefs.getString('phone');
      if (userMobile != null) {
        _mobileController.text = userMobile;
      }

      debugPrint('Fetched user details - Name: $userName, Mobile: $userMobile');
    } catch (e) {
      debugPrint('Error fetching user details: $e');
    }
  }

  // Method to safely retrieve user ID (already exists, just for reference)
  Future<int?> _getSafeUserId() async {
    final prefs = await SharedPreferences.getInstance();
    dynamic userIdRaw = prefs.get('userId');

    if (userIdRaw is int) {
      return userIdRaw;
    } else if (userIdRaw is String) {
      return int.tryParse(userIdRaw);
    }

    return null;
  }

  @override
  void initState() {
    super.initState();
    _checkExistingRegistration();

    // Fetch user details after checking registration
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchUserDetails();
    });
  }

  // Submit registration method
  Future<void> _submitRegistration() async {
    // Check if already applied
    if (_hasAlreadyApplied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'You have already applied for NEET Test Series.',
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Validate inputs
    if (!_validateInputs()) return;

    // Set submitting state
    setState(() {
      _isSubmitting = true;
    });

    try {
      // Get user ID
      final userId = await _getSafeUserId();
      if (userId == null) {
        _showError('Unable to identify user');
        return;
      }

      // Prepare request body
      final registrationData = {
        'user_id': userId.toString(),
        'student_name': _nameController.text.trim(),
        'mobile_number': _mobileController.text.trim(),
        'gender': _selectedGender,
        'father_name': _fatherNameController.text.trim(),
        'parent_mobile': _parentMobileController.text.trim(),
        'college_name': _collegeNameController.text.trim(),
        'tenth_percentage': _classPercentageController.text.trim(),
      };

      // Send registration request
      final response = await http.post(
        Uri.parse(
            'https://indiawebdesigns.in/app/eduapp/user-app/neet_registration.php'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(registrationData),
      );

      // Log full response for debugging
      debugPrint('Registration Response Status: ${response.statusCode}');
      debugPrint('Registration Response Body: ${response.body}');

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 201 || responseData['status'] == 'success') {
        // Update local state
        setState(() {
          _hasAlreadyApplied = true;
          _registrationId = responseData['registration_id'] is int
              ? responseData['registration_id']
              : int.tryParse(responseData['registration_id']?.toString() ?? '');
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Registration successful!',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            backgroundColor: Colors.green,
          ),
        );

        // Reset form
        _nameController.clear();
        _mobileController.clear();
        _fatherNameController.clear();
        _parentMobileController.clear();
        _collegeNameController.clear();
        _classPercentageController.clear();
        setState(() {
          _selectedGender = 'Male';
        });
      } else {
        // Handle specific error messages
        _showError(responseData['message'] ??
            'Registration failed. Please try again.');
      }
    } catch (e) {
      debugPrint('Registration Error: $e');
      _showError('Error submitting registration: $e');
    } finally {
      // Always reset submitting state
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  // Submit button widget
  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: _isSubmitting
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[700]!),
              ),
            )
          : ElevatedButton(
              onPressed: _submitRegistration,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _hasAlreadyApplied ? Colors.grey : Colors.blue[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
              child: Text(
                _hasAlreadyApplied
                    ? 'Registration ID: $_registrationId'
                    : 'Submit Registration',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Image.asset(
              'assets/icons/logo.png',
              height: 40,
              width: 40,
            ),
            const SizedBox(width: 10),
            Text(
              'NEET Test Series',
              style: GoogleFonts.poppins(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
        actions: [
          // Search Icon
          IconButton(
            icon: Icon(Icons.search, color: Colors.grey[900]),
            onPressed: () {
              // TODO: Implement search functionality
            },
          ),
          // Profile Avatar
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: FutureBuilder<String?>(
                future: _getProfilePhotoUrl(),
                builder: (context, snapshot) {
                  return CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.blue[50],
                    backgroundImage: snapshot.data != null
                        ? NetworkImage(snapshot.data!)
                        : null,
                    child: snapshot.data == null
                        ? Icon(
                            Icons.person,
                            size: 18,
                            color: Colors.blue[700],
                          )
                        : null,
                  );
                },
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.blue[700]!, Colors.blue[900]!],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NEET Test Series Registration',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Complete your registration to access our comprehensive NEET test series.',
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Conditionally show registration form or completed message
              _hasAlreadyApplied
                  ? _buildRegistrationCompletedWidget()
                  : _buildRegistrationForm(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 2),
    );
  }

  // New method to build registration completed widget
  Widget _buildRegistrationCompletedWidget() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle,
            color: Colors.green[700],
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            'Registration Completed',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.green[900],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your NEET Test Series Registration is Confirmed',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.green[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Registration ID: $_registrationId',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.blue[700],
            ),
          ),
          const SizedBox(height: 8),
          // Show saved user details
          Text(
            'Registered Name: ${_nameController.text}',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[800],
            ),
          ),
          Text(
            'Mobile Number: ${_mobileController.text}',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  // New method to build the full registration form
  Widget _buildRegistrationForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Personal Details Title
        Text(
          'Personal Details',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[900],
          ),
        ),
        const SizedBox(height: 16),

        // Compact Form Fields
        _buildCompactFormField(
          label: 'Student\'s Name',
          controller: _nameController,
          icon: Icons.person,
        ),
        _buildCompactFormField(
          label: 'Mobile Number',
          controller: _mobileController,
          icon: Icons.phone,
          keyboardType: TextInputType.phone,
          maxLength: 10,
        ),
        _buildCompactGenderDropdown(),
        _buildCompactFormField(
          label: 'Father\'s Name',
          controller: _fatherNameController,
          icon: Icons.family_restroom,
        ),
        _buildCompactFormField(
          label: 'Parent\'s Mobile Number',
          controller: _parentMobileController,
          icon: Icons.phone_android,
          keyboardType: TextInputType.phone,
          maxLength: 10,
        ),
        _buildCompactFormField(
          label: 'College Name',
          controller: _collegeNameController,
          icon: Icons.school,
        ),
        _buildCompactFormField(
          label: 'Class 10th Percentage',
          controller: _classPercentageController,
          icon: Icons.percent,
          keyboardType: TextInputType.number,
          maxLength: 5,
        ),

        const SizedBox(height: 24),

        // Submit Button
        _buildSubmitButton(),
      ],
    );
  }
}
