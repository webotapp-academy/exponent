import 'practice_tests_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'welcome_screen.dart';
// import 'login_screen.dart';
import 'my_courses_screen.dart';
// import 'profile_screen.dart';
// import 'store_screen.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import 'watch_videos_screen.dart' as videos;

import 'career_counselling_form_screen.dart';
import 'neet_test_series_screen.dart';

import 'study_materials_screen.dart' as materials;

import 'assignments_screen.dart';

import 'profile_screen.dart';
import 'splash_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class HomeScreen extends StatelessWidget {
  final Map<String, dynamic> userData;
  const HomeScreen({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    final List<String> sliderImages = [
      'https://images.unsplash.com/photo-1524995997946-a1c2e315a42f?w=1200&auto=format&fit=crop&q=70',
      'https://images.unsplash.com/photo-1503676382389-4809596d5290?w=1200&auto=format&fit=crop&q=70',
      'https://images.unsplash.com/photo-1465101046530-73398c7f28ca?w=1200&auto=format&fit=crop&q=70',
    ];

    // final theme = Theme.of(context);

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
              'Exponent Classes',
              style: GoogleFonts.poppins(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
        iconTheme: IconThemeData(color: Colors.grey[900]),
        actions: [
          // Search Icon
          IconButton(
            icon: Icon(Icons.search, color: Colors.grey[900]),
            onPressed: () {
              showSearch(
                context: context,
                delegate: HomeSearchDelegate(parentContext: context),
              );
            },
          ),
          // Profile Avatar
          GestureDetector(
            onTap: () {
              // Navigate to Profile Screen
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
                    radius: 14,
                    backgroundColor: Colors.blue[50],
                    backgroundImage: snapshot.data != null
                        ? NetworkImage(snapshot.data!)
                        : null,
                    child: snapshot.data == null
                        ? Icon(Icons.person, size: 18, color: Colors.blue[700])
                        : null,
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      drawer: EnhancedHomeDrawer(userData: userData),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Greeting header
          _buildGreetingHeader(context),

          // Search Bar
          _buildSearchBar(context),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 1),
            child: Column(
              children: [
                // Featured carousel

                // Categories chips

                Row(
                  children: [
                    Expanded(
                      child: _DashboardCard(
                        color: Colors.blue,
                        bg: Colors.blue[50]!,
                        icon: Icons.menu_book,
                        title: 'My Course',
                        subtitle: 'View your enrolled courses',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MyCoursesScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _DashboardCard(
                        color: Colors.orange,
                        bg: Colors.orange[50]!,
                        icon: Icons.play_circle_fill,
                        title: 'Try a Class',
                        subtitle: 'Experience a free class',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PracticeTestsScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _DashboardCard(
                        color: Colors.green,
                        bg: Colors.green[50]!,
                        icon: Icons.support_agent,
                        title: 'Free Career Counselling',
                        subtitle: 'Book a free session',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const CareerCounsellingFormScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _DashboardCard(
                        color: Colors.purple,
                        bg: Colors.purple[50]!,
                        icon: Icons.assignment,
                        title: 'Free NEET Test Series',
                        subtitle: 'Attempt mock tests',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const NeetTestSeriesScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // HERO SLIDER: auto-scrolling with rounded corners
          _HeroSlider(),
          // Stats
          //_buildStatsCard(),
          // Cards Section – visual polish only (depth, spacing, touch feedback)
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 0),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.indigo[400]!, Colors.indigo[600]!],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child:
                _buildStatItem('12', 'Courses\nCompleted', Icons.check_circle),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.white.withOpacity(0.3),
          ),
          Expanded(
            child: _buildStatItem('89%', 'Average\nScore', Icons.trending_up),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.white.withOpacity(0.3),
          ),
          Expanded(
            child: _buildStatItem('45h', 'Study\nTime', Icons.schedule),
          ),
        ],
      ),
    );
  }

  Widget _buildGreetingHeader(BuildContext context) {
    return FutureBuilder<String?>(
      future: _readNameFromPrefs(),
      builder: (context, snapshot) {
        final saved = snapshot.data;
        final userName = (saved?.trim().isNotEmpty == true)
            ? saved!.trim()
            : ((userData['Name'] as String?)?.trim().isNotEmpty == true
                ? (userData['Name'] as String).trim()
                : 'Learner');
        return Container(
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
                      'Welcome back,',
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userName,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.local_fire_department,
                            color: Colors.orangeAccent, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          'Keep your streak going!',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    )
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
                child: Icon(Icons.school_rounded,
                    color: Colors.blue[700], size: 32),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<String?> _readNameFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('name');
    } catch (_) {
      return null;
    }
  }

  Future<String?> _getProfilePhotoUrl() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('profile_photo');
    } catch (e) {
      debugPrint('Error retrieving profile photo URL: $e');
      return null;
    }
  }

  Widget _buildFeatured(BuildContext context) {
    final List<Map<String, String>> featured = [
      {
        'title': 'Toppers Math Tricks',
        'subtitle': 'Boost your speed',
        'image':
            'https://images.unsplash.com/photo-1509228468518-180dd4864904?w=1200&auto=format&fit=crop&q=70'
      },
      {
        'title': 'Physics Made Simple',
        'subtitle': 'Visualization first',
        'image':
            'https://plus.unsplash.com/premium_photo-1661409082728-525f262714d4?w=900&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8OXx8Y29hY2hpbmd8ZW58MHx8MHx8fDA%3D'
      },
      {
        'title': 'Organic Chemistry',
        'subtitle': 'Master reactions',
        'image':
            'https://images.unsplash.com/photo-1517048676732-d65bc937f952?w=900&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MjB8fGNvYWNoaW5nfGVufDB8fDB8fHww'
      },
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Featured',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.grey[900],
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text('See all',
                  style: GoogleFonts.poppins(
                    color: Colors.blue[800],
                    fontWeight: FontWeight.w600,
                  )),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 170,
          child: ListView.separated(
            padding: const EdgeInsets.only(right: 16),
            scrollDirection: Axis.horizontal,
            itemCount: featured.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final item = featured[index];
              return Container(
                width: 280,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 14,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      item['image']!,
                      fit: BoxFit.cover,
                      loadingBuilder: (c, w, e) =>
                          e == null ? w : Container(color: Colors.grey[200]),
                    ),
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Color(0xAA000000),
                            Color(0x33000000),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            item['title']!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item['subtitle']!,
                            style: GoogleFonts.poppins(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChips() {
    final categories = [
      {'label': 'All', 'color': Colors.blue},
      {'label': 'Math', 'color': Colors.purple},
      {'label': 'Physics', 'color': Colors.green},
      {'label': 'Chemistry', 'color': Colors.orange},
      {'label': 'Biology', 'color': Colors.teal},
    ];
    return SizedBox(
      height: 36,
      child: ListView.separated(
        padding: const EdgeInsets.only(right: 16),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final item = categories[index];
          final Color c = item['color'] as Color;
          return Container(
            margin: EdgeInsets.only(left: index == 0 ? 0 : 0),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: c.withOpacity(0.08),
              borderRadius: BorderRadius.circular(18),
            ),
            alignment: Alignment.center,
            child: Text(
              item['label'] as String,
              style: GoogleFonts.poppins(
                color: _approxShade700(c),
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemCount: categories.length,
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        elevation: 0,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            showSearch(
              context: context,
              delegate: HomeSearchDelegate(parentContext: context),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.search_rounded, color: Colors.grey[600]),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Search courses, videos, tests...',
                    style: GoogleFonts.poppins(
                      color: Colors.grey[600],
                      fontSize: 10,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Explore',
                    style: GoogleFonts.poppins(
                      color: Colors.blue[700],
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          _QuickAction(
            color: Colors.indigo,
            bg: Colors.indigo[50]!,
            icon: Icons.video_library_rounded,
            label: 'Videos',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => videos.WatchVideosScreen()),
              );
            },
          ),
          const SizedBox(width: 12),
          _QuickAction(
            color: Colors.teal,
            bg: Colors.teal[50]!,
            icon: Icons.menu_book_rounded,
            label: 'Materials',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        const materials.StudyMaterialsScreen()),
              );
            },
          ),
          const SizedBox(width: 12),
          _QuickAction(
            color: Colors.orange,
            bg: Colors.orange[50]!,
            icon: Icons.quiz_rounded,
            label: 'Tests',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PracticeTestsScreen()),
              );
            },
          ),
          const SizedBox(width: 12),
          _QuickAction(
            color: Colors.pink,
            bg: Colors.pink[50]!,
            icon: Icons.assignment_turned_in_rounded,
            label: 'Tasks',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const AssignmentsScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.white.withOpacity(0.8),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildMyCoursesSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'My Courses',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'View All',
                  style: GoogleFonts.poppins(
                    color: Colors.blue[800],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildEnhancedCourseCard(
            title: 'Maths for UKG',
            subtitle: 'Basic Mathematics',
            progress: 0.7,
            icon: Icons.calculate,
            color: Colors.purple[400]!,
          ),
          const SizedBox(height: 12),
          _buildEnhancedCourseCard(
            title: 'English Grammar',
            subtitle: 'Language Skills',
            progress: 0.4,
            icon: Icons.language,
            color: Colors.teal[400]!,
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedCourseCard({
    required String title,
    required String subtitle,
    required double progress,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
                const SizedBox(height: 4),
                Text(
                  '${(progress * 100).toInt()}% Complete',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Colors.grey[400],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(
      String title, String time, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[800],
                  ),
                ),
                Text(
                  time,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Logout method
  Future<void> _performLogout(BuildContext context) async {
    try {
      // Clear SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Navigate to Splash Screen, removing all previous routes
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const SplashScreen(),
        ),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      // Handle any errors during logout
      debugPrint('Logout Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error logging out. Please try again.',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class EnhancedHomeDrawer extends StatelessWidget {
  final Map<String, dynamic> userData;
  const EnhancedHomeDrawer({super.key, required this.userData});

  // Logout method
  Future<void> _performLogout(BuildContext context) async {
    try {
      // Clear SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Navigate to Splash Screen, removing all previous routes
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const SplashScreen(),
        ),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      // Handle any errors during logout
      debugPrint('Logout Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error logging out. Please try again.',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white, // Replace gradient with solid white
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Professional Profile Header
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.blue[700]!, Colors.blue[900]!],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Profile Photo with Professional Border
                      FutureBuilder<String?>(
                        future: _getProfilePhotoUrl(),
                        builder: (context, snapshot) {
                          return Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.white,
                              backgroundImage: snapshot.data != null
                                  ? NetworkImage(snapshot.data!)
                                  : null,
                              child: snapshot.data == null
                                  ? Icon(
                                      Icons.person,
                                      size: 60,
                                      color: Colors.blue[800],
                                    )
                                  : null,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      // Professional Name and Email Display
                      Text(
                        userData['Name'] ?? 'User',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        userData['Email'] ?? '',
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Drawer Menu Items with Improved Styling
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 16),
                children: [
                  // Dashboard
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.dashboard_rounded,
                    title: 'Dashboard',
                    onTap: () => Navigator.pop(context),
                  ),

                  // My Courses
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.menu_book_rounded,
                    title: 'My Courses',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const MyCoursesScreen(),
                        ),
                      );
                    },
                  ),

                  // Materials
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.library_books_rounded,
                    title: 'Materials',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              const materials.StudyMaterialsScreen(),
                        ),
                      );
                    },
                  ),

                  // Profile
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.person_rounded,
                    title: 'Profile',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ProfileScreen(),
                        ),
                      );
                    },
                  ),

                  const Divider(indent: 16, endIndent: 16),

                  // Logout
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.logout_rounded,
                    title: 'Logout',
                    color: Colors.red[700],
                    onTap: () => _performLogout(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Method to retrieve profile photo URL
  Future<String?> _getProfilePhotoUrl() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('profile_photo');
    } catch (e) {
      debugPrint('Error retrieving profile photo URL: $e');
      return null;
    }
  }

  // Enhanced drawer item builder method
  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: color ?? Colors.blue[800],
                  size: 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.poppins(
                      color: color ?? Colors.grey[900],
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: color ?? Colors.grey[600],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Polished card widget with better depth, spacing and ripple
class _DashboardCard extends StatelessWidget {
  final Color color;
  final Color bg;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.color,
    required this.bg,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(18),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        splashColor: color.withOpacity(0.12),
        highlightColor: color.withOpacity(0.06),
        child: Container(
          height: 140,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.12),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color.withOpacity(0.9), size: 40),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.grey[900],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.blueGrey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final Color color;
  final Color bg;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({
    required this.color,
    required this.bg,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          splashColor: color.withOpacity(0.12),
          highlightColor: color.withOpacity(0.06),
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[900],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Utility to approximate a darker shade for simple Colors that are not MaterialColor
Color _approxShade700(Color base) {
  // If it's a MaterialColor (like Colors.blue), try shade700; otherwise darken
  try {
    // This cast can fail for non-MaterialColor, hence try/catch
    final dynamic dyn = base;
    final candidate = dyn.shade700 as Color?;
    if (candidate != null) return candidate;
  } catch (_) {}
  // Fallback: darken by 30%
  const double factor = 0.7;
  return Color.fromARGB(
    base.alpha,
    (base.red * factor).clamp(0, 255).toInt(),
    (base.green * factor).clamp(0, 255).toInt(),
    (base.blue * factor).clamp(0, 255).toInt(),
  );
}

class _SearchItem {
  final String label;
  final IconData icon;
  final List<String> keywords;
  final VoidCallback onTap;

  _SearchItem({
    required this.label,
    required this.icon,
    required this.keywords,
    required this.onTap,
  });
}

class HomeSearchDelegate extends SearchDelegate<String> {
  final BuildContext parentContext;
  HomeSearchDelegate({required this.parentContext});

  List<_SearchItem> _items(BuildContext ctx) => [
        _SearchItem(
          label: 'My Courses',
          icon: Icons.menu_book,
          keywords: ['course', 'courses', 'my course', 'my courses', 'cou'],
          onTap: () {
            Navigator.of(parentContext).push(
              MaterialPageRoute(builder: (_) => const MyCoursesScreen()),
            );
          },
        ),
        _SearchItem(
          label: 'Career Counselling',
          icon: Icons.support_agent,
          keywords: ['career', 'counselling', 'counseling', 'council', 'coun'],
          onTap: () {
            Navigator.of(parentContext).push(
              MaterialPageRoute(
                  builder: (_) => const CareerCounsellingFormScreen()),
            );
          },
        ),
        _SearchItem(
          label: 'NEET Test Series',
          icon: Icons.assignment,
          keywords: ['neet', 'test', 'series', 'mock', 'exam', 'tes'],
          onTap: () {
            Navigator.of(parentContext).push(
              MaterialPageRoute(builder: (_) => const NeetTestSeriesScreen()),
            );
          },
        ),
      ];

  @override
  String get searchFieldLabel => 'Search courses, tests, counselling...';

  @override
  TextStyle? get searchFieldStyle => GoogleFonts.poppins(
        color: Colors.grey[900],
        fontSize: 16,
        fontWeight: FontWeight.w600,
      );

  @override
  InputDecorationTheme? get searchFieldDecorationTheme => InputDecorationTheme(
        hintStyle: GoogleFonts.poppins(
          color: Colors.grey[500],
          fontSize: 14,
        ),
        border: InputBorder.none,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
      );

  @override
  ThemeData appBarTheme(BuildContext context) {
    final base = Theme.of(context);
    return base.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.grey[900]),
        titleTextStyle: GoogleFonts.poppins(
          color: Colors.grey[900],
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      ),
      scaffoldBackgroundColor: Colors.white,
      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => query = '',
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, ''),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final items = _filterItems(context);
    if (items.isEmpty) {
      return Center(
        child: Text('No results',
            style: GoogleFonts.poppins(color: Colors.grey[600])),
      );
    }
    // Navigate to the first match and close
    final first = items.first;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      close(context, first.label);
      first.onTap();
    });
    return const SizedBox.shrink();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final items = _filterItems(context);
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return ListTile(
          leading: Icon(item.icon, color: Colors.blue[700]),
          title: Text(item.label, style: GoogleFonts.poppins()),
          onTap: () {
            close(context, item.label);
            item.onTap();
          },
        );
      },
    );
  }

  List<_SearchItem> _filterItems(BuildContext context) {
    final items = _items(context);
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return items;
    return items.where((it) {
      if (it.label.toLowerCase().contains(q)) return true;
      return it.keywords.any((k) => k.toLowerCase().contains(q));
    }).toList();
  }
}

class _HeroSlider extends StatefulWidget {
  const _HeroSlider();

  @override
  State<_HeroSlider> createState() => _HeroSliderState();
}

class _HeroSliderState extends State<_HeroSlider> {
  late final PageController _controller;
  int _current = 0;
  Timer? _timer;
  List<String> _images = [];

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.95);
    _fetchImages();
    _startAutoScroll();
  }

  Future<void> _fetchImages() async {
    final images = await fetchSliderImages();
    if (mounted) {
      setState(() {
        _images = images;
      });
    }
  }

  void _startAutoScroll() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || _images.isEmpty) return;
      final next = (_current + 1) % _images.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
    _controller.addListener(() {
      final page = _controller.page ?? 0;
      final idx = page.round();
      if (idx != _current) {
        setState(() => _current = idx);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_images.isEmpty) {
      return const SizedBox(
        height: 180,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return SizedBox(
      height: 180,
      child: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: _images.length,
            itemBuilder: (context, index) {
              final page = (_controller.page ?? 0.0);
              final distance = (page - index).abs().clamp(0.0, 1.0);
              final scale = 1 - (distance * 0.04);
              return Transform.scale(
                scale: scale,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          _images[index],
                          fit: BoxFit.cover,
                          loadingBuilder: (c, w, e) => e == null
                              ? w
                              : Container(color: Colors.grey[200]),
                        ),
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              stops: [0.0, 0.4, 1.0],
                              colors: [
                                Color(0x99000000),
                                Color(0x33000000),
                                Color(0x11000000),
                              ],
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              color: Colors.white.withOpacity(0.95),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.play_arrow_rounded,
                                      color: Colors.blue[800], size: 18),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Explore',
                                    style: GoogleFonts.poppins(
                                      color: Colors.blue[800],
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _images.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 6,
                  width: _current == i ? 18 : 6,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(_current == i ? 1 : 0.6),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<List<String>> fetchSliderImages() async {
  try {
    final response = await http.get(
      Uri.parse(
          'https://indiawebdesigns.in/app/eduapp/user-app/get_sliders.php'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = json.decode(response.body);

      if (responseBody['status'] == 'success') {
        final List<dynamic> sliders = responseBody['sliders'];
        return sliders.map((slider) => slider['image_path'] as String).toList();
      } else {
        // Fallback to hardcoded images if API returns error
        return [
          // 'https://images.unsplash.com/photo-1524995997946-a1c2e315a42f?w=1200&auto=format&fit=crop&q=70',
          // 'https://images.unsplash.com/photo-1503676382389-4809596d5290?w=1200&auto=format&fit=crop&q=70',
          // 'https://images.unsplash.com/photo-1465101046530-73398c7f28ca?w=1200&auto=format&fit=crop&q=70',
        ];
      }
    } else {
      // Fallback to hardcoded images if API fails
      return [
        // 'https://images.unsplash.com/photo-1524995997946-a1c2e315a42f?w=1200&auto=format&fit=crop&q=70',
        // 'https://images.unsplash.com/photo-1503676382389-4809596d5290?w=1200&auto=format&fit=crop&q=70',
        // 'https://images.unsplash.com/photo-1465101046530-73398c7f28ca?w=1200&auto=format&fit=crop&q=70',
      ];
    }
  } catch (e) {
    debugPrint('Error fetching slider images: $e');
    // Fallback to hardcoded images if API fails
    return [
      'https://images.unsplash.com/photo-1524995997946-a1c2e315a42f?w=1200&auto=format&fit=crop&q=70',
      'https://images.unsplash.com/photo-1503676382389-4809596d5290?w=1200&auto=format&fit=crop&q=70',
      'https://images.unsplash.com/photo-1465101046530-73398c7f28ca?w=1200&auto=format&fit=crop&q=70',
    ];
  }
}
