import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MyCoursesScreen extends StatefulWidget {
  const MyCoursesScreen({super.key});

  @override
  State<MyCoursesScreen> createState() => _MyCoursesScreenState();
}

class _MyCoursesScreenState extends State<MyCoursesScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerAnimationController;
  late AnimationController _cardAnimationController;
  late Animation<double> _headerFadeAnimation;
  late Animation<Offset> _cardSlideAnimation;

  int _selectedTab = 0; // 0: Class 12, 1: NEET
  late Future<List<dynamic>> _coursesFuture;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
    _coursesFuture = fetchCourses();
  }

  Future<List<dynamic>> fetchCourses() async {
    final response = await http.get(
      Uri.parse(
          'https://indiawebdesigns.in/app/eduapp/user-app/get_courses.php'),
    );
    final data = jsonDecode(response.body);
    if (data['status'] == 'success') {
      return data['courses'];
    } else {
      throw Exception('Failed to load courses');
    }
  }

  Widget _buildCoursesList(List<dynamic> courses, String filter) {
    final filteredCourses = courses.where((course) {
      final name = course['Name'];
      final description = course['Description'];
      // Safely coerce to string
      final nameStr = (name is String) ? name : (name?.toString() ?? '');
      final descStr = (description is String)
          ? description
          : (description?.toString() ?? '');
      final haystack = '${nameStr} ${descStr}'.toLowerCase();
      return haystack.contains(filter.toLowerCase());
    }).toList();

    if (filteredCourses.isEmpty) {
      return Center(child: Text('No $filter course found.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: filteredCourses.length,
      itemBuilder: (context, index) {
        final course = filteredCourses[index];
        final imageUrl = course['ImageURL'];
        final imageUrlStr =
            (imageUrl is String) ? imageUrl : (imageUrl?.toString() ?? '');
        final nameStr = (course['Name'] is String)
            ? course['Name']
            : (course['Name']?.toString() ?? 'Untitled');
        final descStr = (course['Description'] is String)
            ? course['Description']
            : (course['Description']?.toString() ?? '');

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: ListTile(
            leading: () {
              final imageUrl = course['ImageURL'];
              final imageUrlStr = (imageUrl is String)
                  ? imageUrl
                  : (imageUrl?.toString() ?? '');

              if (imageUrlStr.isEmpty ||
                  !(imageUrlStr.startsWith('http://') ||
                      imageUrlStr.startsWith('https://'))) {
                // Fallback avatar if URL is missing/invalid
                return Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.menu_book, color: Colors.blue),
                );
              }

              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrlStr,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  // Prevent crashes on redirect/404/SSL issues
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.menu_book, color: Colors.blue),
                    );
                  },
                  // Optional: show a lightweight placeholder while loading
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      width: 48,
                      height: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          value: loadingProgress.expectedTotalBytes != null
                              ? (loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!)
                              : null,
                        ),
                      ),
                    );
                  },
                ),
              );
            }(),
            title: Text(
              nameStr,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            subtitle: Text(
              descStr,
              style: GoogleFonts.poppins(fontSize: 14),
            ),
          ),
        );
      },
    );
  }

  void _initializeAnimations() {
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _headerFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeInOut,
    ));

    _cardSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _cardAnimationController,
      curve: Curves.easeOutBack,
    ));
  }

  void _startAnimations() {
    _headerAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _cardAnimationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _cardAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Courses',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue[800],
        elevation: 0,
      ),
      body: Column(
        children: [
          // Tabs for Class 12 and NEET
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTab = 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color:
                            _selectedTab == 0 ? Colors.blue[800] : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue[800]!),
                      ),
                      child: Center(
                        child: Text(
                          'Class 12',
                          style: GoogleFonts.poppins(
                            color: _selectedTab == 0
                                ? Colors.white
                                : Colors.blue[800],
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTab = 1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color:
                            _selectedTab == 1 ? Colors.blue[800] : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue[800]!),
                      ),
                      child: Center(
                        child: Text(
                          'NEET',
                          style: GoogleFonts.poppins(
                            color: _selectedTab == 1
                                ? Colors.white
                                : Colors.blue[800],
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _coursesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: \\${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No courses found.'));
                }
                return _buildCoursesList(
                  snapshot.data!,
                  _selectedTab == 0 ? 'Class 12' : 'NEET',
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 1),
    );
  }

  // Removed old hardcoded content methods

  Widget _buildContentSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800])),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: items
              .map((item) => Chip(
                    label: Text(item,
                        style:
                            GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                    backgroundColor: Colors.blue[50],
                    labelStyle: TextStyle(color: Colors.blue[900]),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ))
              .toList(),
        ),
      ],
    );
  }
}
