import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'subject_list_screen.dart';
import 'mycourses_chapters_screen.dart';
import 'home_screen.dart';
// import 'mycourses_chapters_screen.dart';
// import 'mycourses_chapter_detail_screen.dart';

class MyCoursesScreen extends StatefulWidget {
  final int? subjectId; // Optional: when provided, fetch chapters here
  const MyCoursesScreen({super.key, this.subjectId});

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
  late Future<List<dynamic>> _coursesFuture; // will hold subjects per course
  Future<List<dynamic>>? _topicsFuture; // optional when subjectId provided
  late Future<Map<String, String>> _profileFuture;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
    _coursesFuture = fetchSubjects('class12');
    _profileFuture = _loadProfileFromPrefs();
    if (widget.subjectId != null) {
      _topicsFuture = fetchTopics(widget.subjectId!);
    }
  }

  void _onReload() {
    setState(() {
      _coursesFuture = fetchSubjects(_selectedTab == 0
          ? 'class12'
          : _selectedTab == 1
              ? 'class12Assamese'
              : _selectedTab == 2
                  ? 'neet'
                  : 'class12');
      if (widget.subjectId != null) {
        _topicsFuture = fetchTopics(widget.subjectId!);
      }
    });
  }

  Future<Map<String, String>> _loadProfileFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final name = (prefs.getString('name') ?? '').trim();
      final phone = (prefs.getString('phone') ??
              prefs.getString('Userphone') ??
              prefs.getString('Phone') ??
              '')
          .trim();
      return {
        'name': name,
        'phone': phone,
      };
    } catch (_) {
      return {'name': '', 'phone': ''};
    }
  }

  Future<List<dynamic>> fetchTopics(int subjectId) async {
    final response = await http.get(
      Uri.parse(
          'https://indiawebdesigns.in/app/eduapp/user-app/get_topics.php?subject_id=$subjectId'),
    );
    final data = jsonDecode(response.body);
    if (data['status'] == 'success') {
      // API returns { status, topics: [...] }
      final List topics = data['topics'] ?? [];
      return topics.cast<dynamic>();
    }
    throw Exception(data['message'] ?? 'Failed to load chapters');
  }

  Future<List<dynamic>> fetchSubjects(String course) async {
    final response = await http.get(
      Uri.parse(
          'https://indiawebdesigns.in/app/eduapp/user-app/get_topics.php?course=$course'),
    );
    final data = jsonDecode(response.body);
    if (data['status'] == 'success') {
      final List subjects = data['subjects'] ?? [];
      return subjects.cast<dynamic>();
    }
    throw Exception(data['message'] ?? 'Failed to load subjects');
  }

  Future<List<dynamic>> fetchCourses() async {
    final response = await http.get(
      Uri.parse(
          'https://indiawebdesigns.in/app/eduapp/user-app/get_topics.php'),
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
            final courseId =
                course['CourseID'] ?? course['id'] ?? course['course_id'];

            return Material(
              color: Colors.white,
              elevation: 2,
              shadowColor: Colors.black.withOpacity(0.06),
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {
                  // Navigate to Subject List screen with courseId
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SubjectListScreen(
                        courseId: courseId,
                        trackTitle: nameStr,
                      ),
                    ),
                  );
                },
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
    // final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.grey[900]),
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
          'My Courses',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: Colors.grey[900],
            fontSize: 16,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Reload',
            onPressed: _onReload,
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          // Header panel to add hierarchy
          Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[700]!, Colors.blue[900]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.18),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child:
                      const Icon(Icons.menu_book_rounded, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Learning',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Browse your enrolled courses',
                        style: GoogleFonts.poppins(
                          color: Colors.white.withOpacity(0.95),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Segmented tabs – refined visual
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Material(
              color: Colors.white,
              elevation: 0,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    _SegmentTab(
                      label: 'Class-12 English',
                      selected: _selectedTab == 0,
                      onTap: () => setState(() {
                        _selectedTab = 0;
                        _coursesFuture = fetchSubjects('class12');
                      }),
                      color: Colors.blue[800]!,
                    ),
                    _SegmentTab(
                      label: 'Class-12 Assamese',
                      selected: _selectedTab == 1,
                      onTap: () => setState(() {
                        _selectedTab = 1; // Corrected from 0 to 1
                        _coursesFuture = fetchSubjects('class12Assamese');
                      }),
                      color: Colors.blue[800]!,
                    ),
                    _SegmentTab(
                      label: 'NEET',
                      selected: _selectedTab == 2,
                      onTap: () => setState(() {
                        _selectedTab = 2; // Corrected from 1 to 2
                        _coursesFuture = fetchSubjects('neet');
                      }),
                      color: Colors.blue[800]!,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // If subjectId is provided, show chapters list first
          if (widget.subjectId != null)
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: _topicsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Failed to load chapters'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No chapters found.'));
                  }
                  final chapters = snapshot.data!;
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                    itemCount: chapters.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final ch = chapters[index];
                      final title =
                          (ch['Name'] ?? ch['title'] ?? 'Chapter').toString();
                      final desc = (ch['Description'] ?? '').toString();
                      return Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        elevation: 1,
                        shadowColor: Colors.black.withOpacity(0.04),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.12),
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Text('${index + 1}',
                                    style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w700,
                                        color: Colors.blue[700])),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(title,
                                        style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14.5,
                                            color: const Color(0xFF0F172A))),
                                    const SizedBox(height: 4),
                                    Text(desc,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.poppins(
                                            fontSize: 12.5,
                                            color: const Color(0xFF64748B))),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            )
          else
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: _coursesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                      itemCount: 6,
                      itemBuilder: (context, index) => Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        height: 90,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.error_outline,
                                color: Colors.redAccent, size: 40),
                            const SizedBox(height: 8),
                            Text('Failed to load subjects',
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w700, fontSize: 16)),
                            const SizedBox(height: 6),
                            Text('${snapshot.error}',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                    color: const Color(0xFF64748B))),
                          ],
                        ),
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Center(
                        child: Text('No subjects found.',
                            style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: const Color(0xFF64748B),
                                fontWeight: FontWeight.w500)),
                      ),
                    );
                  }
                  final subjects = snapshot.data!;
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                    itemCount: subjects.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final s = subjects[index];
                      final name = (s['msub_name'] ?? '').toString();
                      final desc = (s['msub_desc'] ?? '').toString();
                      final dbId = s['id'];
                      return Material(
                        color: Colors.white,
                        elevation: 2,
                        shadowColor: Colors.black.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(14),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () {
                            // Navigate to chapters screen with this subject
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (_) =>
                            //         MyCoursesScreen(subjectId: dbId),
                            //   ),
                            // );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 46,
                                  height: 46,
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text('${index + 1}',
                                      style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w700,
                                          color: Colors.blue[700])),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(name,
                                          style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14.5,
                                              color: const Color(0xFF0F172A))),
                                      const SizedBox(height: 4),
                                      Text(desc,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.poppins(
                                              fontSize: 12.5,
                                              color: const Color(0xFF64748B))),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                OutlinedButton(
                                  onPressed: () {
                                    final String subjectName = name;
                                    final String courseLabel =
                                        _selectedTab == 0 ? 'Class 12' : 'NEET';
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => MyCoursesChaptersScreen(
                                          subjectName: subjectName,
                                          courseLabel: courseLabel,
                                          isNeet: _selectedTab == 1,
                                          subjectId: dbId,
                                        ),
                                      ),
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    side: BorderSide(color: Colors.blue[200]!),
                                    foregroundColor: Colors.blue[700],
                                    textStyle: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12),
                                  ),
                                  child: const Text('View'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
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

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
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
    // Split the label into words
    final words = label.split(' ');

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 8),
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
            child: words.length > 1
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: words
                        .map((word) => Text(
                              word,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 10,
                                height: 1.2,
                                color: selected ? Colors.white : color,
                              ),
                            ))
                        .toList(),
                  )
                : Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: selected ? Colors.white : color,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
