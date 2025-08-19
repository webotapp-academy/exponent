import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'home_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Controllers for editable fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _classController = TextEditingController();

  // Dropdown for class selection
  final List<String> _classOptions = ['IX', 'X', 'XI', 'XII'];

  // Loading state for save button
  bool _isSaving = false;

  // Profile photo
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserData();

    // Log user ID for debugging
    _getSafeUserId().then((userId) {
      debugPrint(
          'Loaded User ID in initState: $userId (${userId.runtimeType})');
    });
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Safely load user data with type checking
      setState(() {
        _nameController.text = prefs.getString('name') ?? '';
        _emailController.text = prefs.getString('email') ?? '';
        _phoneController.text = prefs.getString('phone') ?? '';
        _addressController.text = prefs.getString('address') ?? '';
        _classController.text = prefs.getString('class') ?? '';
      });

      // Fetch user ID
      final userId = await _getSafeUserId();
      if (userId == null) {
        debugPrint('No user ID found');
        return;
      }

      // Fetch profile photo URL from API
      await _fetchProfilePhotoUrl(userId);
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  Future<void> _fetchProfilePhotoUrl(int userId) async {
    try {
      final response = await http.get(Uri.parse(
          'https://indiawebdesigns.in/app/eduapp/user-app/get_profile_photo.php?user_id=$userId'));

      debugPrint('Profile Photo API Response: ${response.body}');

      final responseData = jsonDecode(response.body);

      if (responseData['status'] == 'success') {
        final photoUrl = responseData['photo_url'];

        // Save to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('profile_photo', photoUrl);

        // Set the profile image
        setState(() {
          _profileImage = File(photoUrl);
        });
      } else {
        debugPrint('No profile photo found: ${responseData['message']}');
      }
    } catch (e) {
      debugPrint('Error fetching profile photo: $e');
    }
  }

  Future<void> _saveUserData() async {
    // Set loading state
    setState(() {
      _isSaving = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();

      // Robust user ID retrieval and conversion
      dynamic userIdRaw = prefs.get('userId');
      int? userId;

      if (userIdRaw is int) {
        userId = userIdRaw;
      } else if (userIdRaw is String) {
        userId = int.tryParse(userIdRaw);
      }

      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Invalid User ID. Please log in again.',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Validate input fields
      if (!_validateInputs()) {
        return;
      }

      // Prepare data for saving
      final profileData = {
        'user_id': userId.toString(), // Explicitly convert to string
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'class': _classController.text.trim(),
      };

      // Save to SharedPreferences
      await prefs.setString('name', profileData['name']!);
      await prefs.setString('email', profileData['email']!);
      await prefs.setString('phone', profileData['phone']!);
      await prefs.setString('address', profileData['address']!);
      await prefs.setString('class', profileData['class']!);

      // Debug print to verify data
      debugPrint('Saving Profile Data: $profileData');

      // Save to Database via API
      final response = await http.post(
        Uri.parse(
            'https://indiawebdesigns.in/app/eduapp/user-app/update_profile.php'),
        body: profileData,
      );

      // Log full response for debugging
      debugPrint('Profile Update Raw Response: ${response.body}');
      debugPrint('Profile Update Status Code: ${response.statusCode}');

      final responseData = jsonDecode(response.body);

      if (responseData['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Profile updated successfully!',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              responseData['message'] ?? 'Failed to update profile',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e, stackTrace) {
      // Comprehensive error logging
      debugPrint('Profile Update Error: $e');
      debugPrint('Stack Trace: $stackTrace');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unexpected error updating profile: $e',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      // Always reset loading state
      setState(() {
        _isSaving = false;
      });
    }
  }

  // Enhanced method to safely retrieve user ID
  Future<int?> _getSafeUserId() async {
    final prefs = await SharedPreferences.getInstance();

    // Attempt to retrieve user ID
    dynamic userIdRaw = prefs.get('userId');

    // Detailed logging for debugging
    debugPrint('Raw userId retrieval:');
    debugPrint('Value: $userIdRaw');
    debugPrint('Type: ${userIdRaw.runtimeType}');

    // Convert to int safely
    if (userIdRaw is int) {
      return userIdRaw;
    } else if (userIdRaw is String) {
      return int.tryParse(userIdRaw);
    }

    return null;
  }

  bool _validateInputs() {
    // Name validation
    if (_nameController.text.trim().isEmpty) {
      _showValidationError('Please enter your name');
      return false;
    }

    // Email validation
    if (!_isValidEmail(_emailController.text)) {
      _showValidationError('Please enter a valid email address');
      return false;
    }

    // Phone validation
    if (!_isValidPhone(_phoneController.text)) {
      _showValidationError('Please enter a valid 10-digit phone number');
      return false;
    }

    // Class validation
    if (_classController.text.isEmpty) {
      _showValidationError('Please select your class');
      return false;
    }

    return true;
  }

  bool _isValidEmail(String email) {
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email.trim());
  }

  bool _isValidPhone(String phone) {
    final phoneRegex = RegExp(r'^[6-9]\d{9}$');
    return phoneRegex.hasMatch(phone.trim());
  }

  void _showValidationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        backgroundColor: Colors.red,
      ),
    );
  }

  // Photo upload methods
  Future<void> _pickProfilePhoto() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50, // Reduce image quality to minimize file size
        maxWidth: 500, // Limit max width
        maxHeight: 500, // Limit max height
      );

      if (pickedFile != null) {
        // Verify file type before uploading
        final mimeType = _getMimeType(pickedFile.path);
        debugPrint('Selected Image MIME Type: $mimeType');

        setState(() {
          _profileImage = File(pickedFile.path);
        });

        // Optionally upload the image immediately
        await _uploadProfilePhoto(mimeType);
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error picking image: $e',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Helper method to determine MIME type
  String _getMimeType(String path) {
    final extension = path.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      default:
        return 'application/octet-stream';
    }
  }

  Future<void> _uploadProfilePhoto(String mimeType) async {
    if (_profileImage == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();

      // Robust user ID retrieval
      dynamic userIdRaw = prefs.get('userId');
      int? userId;

      // Attempt to convert user ID to int
      if (userIdRaw is int) {
        userId = userIdRaw;
      } else if (userIdRaw is String) {
        userId = int.tryParse(userIdRaw);
      }

      // Validate user ID
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Unable to identify user. Please log in again.',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Create multipart request
      var request = http.MultipartRequest(
          'POST',
          Uri.parse(
              'https://indiawebdesigns.in/app/eduapp/user-app/upload_profile_photo.php'));

      // Add user ID to the request
      request.fields['user_id'] = userId.toString();

      // Add file to the request with explicit MIME type
      request.files.add(await http.MultipartFile.fromPath(
          'profile_photo', _profileImage!.path,
          filename:
              'profile_photo_$userId.${_profileImage!.path.split('.').last}'));

      // Send the request
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      debugPrint('Photo Upload Response: $responseBody');

      final responseData = jsonDecode(responseBody);

      if (responseData['status'] == 'success') {
        // Update SharedPreferences with new photo URL
        await prefs.setString('profile_photo', responseData['photo_url']);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Profile photo updated successfully!',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              responseData['message'] ?? 'Failed to upload photo',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Photo Upload Error: $e');
      debugPrint('Stack Trace: $stackTrace');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error uploading photo: $e',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Update profile picture widget to support network image
  Widget _buildProfilePicture() {
    ImageProvider? backgroundImage;

    if (_profileImage != null) {
      // Check if it's a network URL or local file
      if (_profileImage!.path.startsWith('http')) {
        backgroundImage = NetworkImage(_profileImage!.path);
      } else {
        backgroundImage = FileImage(_profileImage!);
      }
    }

    return Stack(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: Colors.blue[100],
          backgroundImage: backgroundImage,
          child: backgroundImage == null
              ? Icon(
                  Icons.person,
                  size: 60,
                  color: Colors.blue[800],
                )
              : null,
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue[700],
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
              onPressed: _pickProfilePhoto,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey[900]),
          onPressed: () {
            // Navigate to home screen, clearing previous routes
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const HomeScreen(
                  // Pass an empty map or retrieve user data from SharedPreferences
                  userData: {},
                ),
              ),
              (Route<dynamic> route) => false,
            );
          },
        ),
        title: Text(
          'Profile',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: Colors.grey[900],
            fontSize: 16,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Picture
              _buildProfilePicture(),
              const SizedBox(height: 20),

              // Profile Details
              _buildProfileField(
                label: 'Name',
                controller: _nameController,
                icon: Icons.person,
              ),
              const SizedBox(height: 16),
              _buildProfileField(
                label: 'Email',
                controller: _emailController,
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              _buildProfileField(
                label: 'Phone',
                controller: _phoneController,
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              _buildProfileField(
                label: 'Address',
                controller: _addressController,
                icon: Icons.location_on,
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Class Dropdown
              _buildClassDropdown(),
              const SizedBox(height: 16),

              _buildSaveButton(),
              // Save Button
              const SizedBox(height: 24),
              // Additional Profile Information
              _buildProfileInfoCard(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 3),
    );
  }

  Widget _buildProfileField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: GoogleFonts.poppins(
          color: Colors.black,
        ),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.blue[700]),
          labelText: label,
          labelStyle: GoogleFonts.poppins(
            color: Colors.grey[600],
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue[100]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue[100]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue[700]!),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildClassDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: _classController.text.isNotEmpty ? _classController.text : null,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.school, color: Colors.blue[700]),
          labelText: 'Class',
          labelStyle: GoogleFonts.poppins(
            color: Colors.grey[600],
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue[100]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue[100]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue[700]!),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        items: _classOptions
            .map((classOption) => DropdownMenuItem(
                  value: classOption,
                  child: Text(
                    classOption,
                    style: GoogleFonts.poppins(),
                  ),
                ))
            .toList(),
        onChanged: (value) {
          setState(() {
            _classController.text = value ?? '';
          });
        },
      ),
    );
  }

  Widget _buildProfileInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Profile Information',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.blue[900],
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('User Type', 'Student'),
          _buildInfoRow('Joined On', '15 May 2024'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.grey[700],
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: Colors.black87,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Save button widget with loading state
  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: _isSaving
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[700]!),
              ),
            )
          : ElevatedButton(
              onPressed: _saveUserData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
              child: Text(
                'Save Profile',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _classController.dispose();
    super.dispose();
  }
}
