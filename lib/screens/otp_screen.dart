import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';

class OtpScreen extends HookWidget {
  final String phone;
  const OtpScreen({Key? key, required this.phone}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final otpController = useTextEditingController();
    final isResending = useState(false);
    final secondsRemaining = useState<int>(0);
    final isVerifying = useState(false);

    // APIs
    const loginApiUrl =
        'https://indiawebdesigns.in/app/eduapp/user-app/login.php';
    const verifyApiUrl =
        'https://indiawebdesigns.in/app/eduapp/user-app/verify_otp.php';

    // Cooldown timer for resend button
    useEffect(() {
      Timer? timer;
      if (secondsRemaining.value > 0) {
        timer = Timer.periodic(const Duration(seconds: 1), (t) {
          if (secondsRemaining.value <= 1) {
            t.cancel();
            secondsRemaining.value = 0;
          } else {
            secondsRemaining.value = secondsRemaining.value - 1;
          }
        });
      }
      return () => timer?.cancel();
    }, [secondsRemaining.value]);

    Future<void> resendOtp() async {
      if (secondsRemaining.value > 0 || isResending.value) return;
      isResending.value = true;
      try {
        final payload = {'Phone': phone, 'Userphone': phone};
        debugPrint('[RESEND_OTP] → POST $loginApiUrl');
        debugPrint('[RESEND_OTP] Payload: ${jsonEncode(payload)}');

        final response = await http.post(
          Uri.parse(loginApiUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(payload),
        );

        debugPrint('[RESEND_OTP] ← Status: ${response.statusCode}');
        debugPrint('[RESEND_OTP] Response: ${response.body}');

        Map<String, dynamic> data;
        try {
          data = jsonDecode(response.body) as Map<String, dynamic>;
        } catch (e) {
          debugPrint('[RESEND_OTP] JSON decode error: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Invalid server response',
                    style: GoogleFonts.poppins())),
          );
          return;
        }

        if (response.statusCode == 200 && data['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('OTP resent successfully',
                    style: GoogleFonts.poppins())),
          );
          secondsRemaining.value = 30; // cooldown
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    data['message']?.toString() ?? 'Failed to resend OTP',
                    style: GoogleFonts.poppins())),
          );
        }
      } catch (e) {
        debugPrint('[RESEND_OTP] Error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Network error: $e', style: GoogleFonts.poppins())),
        );
      } finally {
        isResending.value = false;
      }
    }

    Future<void> verifyOtp() async {
      final otp = otpController.text.trim();
      if (otp.length != 4) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Please enter the 4-digit OTP',
                  style: GoogleFonts.poppins())),
        );
        return;
      }
      isVerifying.value = true;
      try {
        final payload = {'phone': phone, 'otp': otp};
        debugPrint('[VERIFY_OTP] → POST $verifyApiUrl');
        debugPrint('[VERIFY_OTP] Payload: ${jsonEncode(payload)}');

        final response = await http.post(
          Uri.parse(verifyApiUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(payload),
        );

        debugPrint('[VERIFY_OTP] ← Status: ${response.statusCode}');
        debugPrint('[VERIFY_OTP] Response: ${response.body}');

        Map<String, dynamic> data;
        try {
          data = jsonDecode(response.body) as Map<String, dynamic>;
        } catch (e) {
          debugPrint('[VERIFY_OTP] JSON decode error: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Invalid server response',
                    style: GoogleFonts.poppins())),
          );
          return;
        }

        if (response.statusCode == 200 && data['status'] == 'success') {
          // Save to SharedPreferences (guarded)
          try {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool('isLoggedIn', true);
            await prefs.setString(
                'phone', data['user']['Phone']?.toString() ?? phone);
            await prefs.setString(
                'userId', (data['user']['UserID'] ?? '').toString());
            await prefs.setString(
                'name', data['user']['Name']?.toString() ?? '');
            await prefs.setString(
                'email', data['user']['Email']?.toString() ?? '');
            await prefs.setString(
                'userType', data['user']['UserType']?.toString() ?? '');
            await prefs.setString(
                'courses', data['user']['Courses']?.toString() ?? '');
            debugPrint('[VERIFY_OTP] SharedPreferences saved successfully');
          } catch (e) {
            debugPrint('[VERIFY_OTP] SharedPreferences error: $e');
          }

          if (!context.mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  HomeScreen(userData: data['user'] ?? {'Userphone': phone}),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(data['message']?.toString() ?? 'Invalid OTP',
                    style: GoogleFonts.poppins())),
          );
        }
      } catch (e) {
        debugPrint('[VERIFY_OTP] Error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Network error: $e', style: GoogleFonts.poppins())),
        );
      } finally {
        isVerifying.value = false;
      }
    }

    final isOtpComplete = otpController.text.length == 4;

    return Scaffold(
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey[300]!),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.10),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.lock_outline,
                        size: 60,
                        color: Colors.blue[800],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'OTP Verification',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 26,
                      color: const Color(0xFF1A3A6C),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Enter the 4-digit OTP sent to',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w400,
                      fontSize: 15,
                      color: Colors.blueGrey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    phone,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.blue[800],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 10),
                      child: TextField(
                        controller: otpController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(4),
                        ],
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 8,
                        ),
                        decoration: InputDecoration(
                          hintText: '____',
                          counterText: '',
                          hintStyle: GoogleFonts.poppins(color: Colors.grey),
                          prefixIcon: Icon(Icons.lock, color: Colors.grey),
                          suffixIcon: isOtpComplete
                              ? Icon(Icons.check_circle, color: Colors.green)
                              : null,
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 18, horizontal: 15),
                        ),
                        onChanged: (_) {
                          // Trigger rebuild for suffix icon state update
                          (context as Element).markNeedsBuild();
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isOtpComplete && !isVerifying.value
                          ? verifyOtp
                          : null,
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
                      child: isVerifying.value
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : Text('Verify OTP',
                              style: GoogleFonts.poppins(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextButton(
                    onPressed: (secondsRemaining.value > 0 || isResending.value)
                        ? null
                        : resendOtp,
                    child: Text(
                      secondsRemaining.value > 0
                          ? 'Resend OTP (${secondsRemaining.value}s)'
                          : 'Resend OTP',
                      style: GoogleFonts.poppins(
                        color: (secondsRemaining.value > 0 || isResending.value)
                            ? Colors.grey
                            : Colors.blue[800],
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
