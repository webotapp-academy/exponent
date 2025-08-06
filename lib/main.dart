import 'package:edu_rev_app/screens/home_screen.dart';
import 'package:edu_rev_app/screens/signup_screen.dart';
import 'package:edu_rev_app/screens/watch_videos_screen.dart';
import 'package:edu_rev_app/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/splash_screen.dart';

void main() {
  // Ensure Flutter binding is initialized before running the app
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations to reduce unnecessary layout calculations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Run the app with performance optimizations
  runApp(const EduRevApp());
}

class EduRevApp extends StatelessWidget {
  const EduRevApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EduRev',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Use a more efficient text theme
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ),
        // Reduce visual density to improve rendering performance
        visualDensity: VisualDensity.compact,
        // Optimize button and input themes
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            textStyle: const TextStyle(fontSize: 16),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        ),
      ),
      // Use const constructor for splash screen to reduce object creation
      home: const SplashScreen(),
      routes: {
        '/watch_videos': (context) =>
            WatchVideosScreen(), // Make sure this screen exists
        // ...other routes...
      },
    );
  }
}
