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

    return FadeTransition(
      opacity: _headerFadeAnimation,
      child: SlideTransition(
        position: _cardSlideAnimation,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          itemCount: filteredCourses.length,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
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

            return Material(
              color: Colors.white,
              elevation: 2,
              shadowColor: Colors.black.withOpacity(0.06),
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Thumbnail with graceful fallback
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: (imageUrlStr.isEmpty ||
                                !(imageUrlStr.startsWith('http://') ||
                                    imageUrlStr.startsWith('https://')))
                            ? Container(
                                width: 64,
                                height: 64,
                                color: Colors.blue[50],
                                child: Icon(Icons.menu_book,
                                    color: Colors.blue[700]),
                              )
                            : Image.network(
                                imageUrlStr,
                                width: 64,
                                height: 64,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 64,
                                  height: 64,
                                  color: Colors.blue[50],
                                  child: Icon(Icons.menu_book,
                                      color: Colors.blue[700]),
                                ),
                                loadingBuilder: (context, child, progress) {
                                  if (progress == null) return child;
                                  return Container(
                                    width: 64,
                                    height: 64,
                                    alignment: Alignment.center,
                                    color: Colors.grey[200],
                                    child: const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                      const SizedBox(width: 14),
                      // Title + description
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              nameStr,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              descStr,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 12.5,
                                height: 1.35,
                                color: const Color(0xFF475569),
                              ),
                            ),
                            const SizedBox(height: 10),
                            // Light divider feel
                            Container(
                              height: 1,
                              color: const Color(0xFFE2E8F0),
                            ),
                            const SizedBox(height: 10),
                            // Subtle meta row (kept generic, no new static info)
                            Row(
                              children: [
                                Icon(Icons.play_circle_fill,
                                    size: 18, color: Colors.blue[700]),
                                const SizedBox(width: 6),
                                Text(
                                  'Continue',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue[800],
                                  ),
                                ),
                                const Spacer(),
                                Icon(Icons.chevron_right,
                                    color: Colors.grey[400]),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'My Courses',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.blue[800],
        elevation: 0,
      ),
      body: Column(
        children: [
          // Segmented tabs – improved depth and ripple
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Material(
              color: Colors.white,
              elevation: 1,
              shadowColor: Colors.black.withOpacity(0.04),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    _SegmentTab(
                      label: 'Class 12',
                      selected: _selectedTab == 0,
                      onTap: () => setState(() => _selectedTab = 0),
                      color: Colors.blue[800]!,
                    ),
                    _SegmentTab(
                      label: 'NEET',
                      selected: _selectedTab == 1,
                      onTap: () => setState(() => _selectedTab = 1),
                      color: Colors.blue[800]!,
                    ),
                  ],
                ),
              ),
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
}

// Segmented control tab button with ripple and animated background
class _SegmentTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color color;

  const _SegmentTab({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 12),
          margin: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: selected ? color : Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.25),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 14.5,
                color: selected ? Colors.white : color,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
