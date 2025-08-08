import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../widgets/custom_bottom_nav_bar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerAnimationController;
  late AnimationController _contentAnimationController;
  late Animation<double> _headerFadeAnimation;
  late Animation<Offset> _contentSlideAnimation;

  Map<String, dynamic>? userData;
  Future<void> _profileFuture = Future.value();

  // Enhanced activity data
  final List<Map<String, dynamic>> recentActivities = [
    {
      'title': 'Completed Math Quiz',
      'subtitle': 'Scored 95% in Numbers & Counting',
      'time': '2 hours ago',
      'icon': Icons.quiz,
      'color': Colors.green[400],
      'type': 'quiz',
    },
    {
      'title': 'Watched Video Lesson',
      'subtitle': 'Alphabets and Phonics - Chapter 3',
      'time': '1 day ago',
      'icon': Icons.play_circle,
      'color': Colors.blue[400],
      'type': 'video',
    },
    {
      'title': 'Downloaded Study Material',
      'subtitle': 'English Worksheets for Practice',
      'time': '2 days ago',
      'icon': Icons.download,
      'color': Colors.orange[400],
      'type': 'download',
    },
    {
      'title': 'Earned Achievement',
      'subtitle': 'Completed 7-day learning streak',
      'time': '3 days ago',
      'icon': Icons.emoji_events,
      'color': Colors.amber[400],
      'type': 'achievement',
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
    _profileFuture = fetchUserProfile();
  }

  void _initializeAnimations() {
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _contentAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _headerFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeInOut,
    ));

    _contentSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _contentAnimationController,
      curve: Curves.easeOutBack,
    ));
  }

  void _startAnimations() {
    _headerAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _contentAnimationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _contentAnimationController.dispose();
    super.dispose();
  }

  Future<void> fetchUserProfile() async {
    // Replace with actual userId (e.g., from login/session)
    const userId = 127;
    final url = Uri.parse(
        'https://indiawebdesigns.in/app/eduapp/user-app/get_user_profile.php?user_id=$userId');
    final response = await http.get(url);
    final body = response.body.trimLeft();
    debugPrint('Profile API Response: $body');
    final data = jsonDecode(body);
    if (data['status'] == 'success') {
      setState(() {
        userData = data['user'];
      });
    } else {
      debugPrint('Profile API error: ${data['message'] ?? 'Unknown error'}');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Removed unused locals to satisfy lints

    return Scaffold(
      body: FutureBuilder<void>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              userData == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final collapsedTitle = (userData?['Name'] as String?)?.trim();
          return DefaultTabController(
            length: 3,
            child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                SliverAppBar(
                  expandedHeight: 260, // slightly reduced for better fit
                  floating: false,
                  pinned: true,
                  elevation: innerBoxIsScrolled ? 2 : 0,
                  shadowColor:
                      innerBoxIsScrolled ? Colors.black12 : Colors.transparent,
                  surfaceTintColor: Colors.white,
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue[900],
                  title: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: innerBoxIsScrolled ? 1 : 0,
                    child: Text(
                      collapsedTitle?.isNotEmpty == true
                          ? collapsedTitle!
                          : 'Profile',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: Colors.blue[900],
                      ),
                    ),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: _buildEnhancedProfileHeader(),
                  ),
                  actions: [
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.settings, color: Colors.blue[900]),
                      ),
                      onPressed: () {},
                    ),
                    const SizedBox(width: 8),
                  ],
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(48),
                    child: Container(
                      color: Colors.white,
                      child: TabBar(
                        labelStyle: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        unselectedLabelStyle: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                        labelColor: Colors.blue[900],
                        unselectedLabelColor: Colors.grey[600],
                        indicator: UnderlineTabIndicator(
                          borderSide: BorderSide(
                            color: Colors.blue[900]!,
                            width: 3,
                          ),
                        ),
                        tabs: const [
                          Tab(text: 'Overview'),
                          Tab(text: 'Analysis'),
                          Tab(text: 'Activity'),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
              body: TabBarView(
                children: [
                  _buildOverviewTab(),
                  _buildEnhancedAnalysisTab(),
                  _buildEnhancedActivityTab(),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 3),
    );
  }

  Widget _buildEnhancedProfileHeader() {
    if (userData == null) return const SizedBox.shrink();
    // Rounded bottom for header
    return ClipPath(
      clipper: _HeaderClipper(),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue[700]!, Colors.blue[900]!],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: FadeTransition(
              opacity: _headerFadeAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Profile Picture
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: CircleAvatar(
                      radius: 48,
                      backgroundColor: Colors.white,
                      backgroundImage: (userData?['profile_photo'] != null &&
                              userData?['profile_photo'] != '')
                          ? NetworkImage(userData?['profile_photo'])
                          : null,
                      child: (userData?['profile_photo'] == null ||
                              userData?['profile_photo'] == '')
                          ? Icon(
                              Icons.person,
                              size: 56,
                              color: Colors.blue[800],
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Name
                  Text(
                    (userData?['Name'] ?? '').toString(),
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Email chip
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      (userData?['Email'] ?? '').toString(),
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Quick stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildQuickStat('UserID',
                          userData?['UserID']?.toString() ?? '', Icons.badge),
                      _buildQuickStat('Phone', userData?['Userphone'] ?? '',
                          Icons.phone_rounded),
                      _buildQuickStat('Joined', userData?['CreatedAt'] ?? '',
                          Icons.calendar_today_rounded),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: SlideTransition(
        position: _contentSlideAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Only dynamic content: Learning Progress Card (if userData available)
            if (userData != null) _buildLearningProgressCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildLearningProgressCard() {
    final completed = (userData?['completedCourses'] ?? 0) as num;
    final total = (userData?['totalCourses'] ?? 1) as num;
    final progress =
        total > 0 ? (completed / total).clamp(0, 1).toDouble() : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          // Radial progress ring
          SizedBox(
            height: 84,
            width: 84,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: 1,
                  strokeWidth: 8,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.grey.shade200),
                ),
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 8,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.purple[400]!),
                  backgroundColor: Colors.transparent,
                ),
                Center(
                  child: Text(
                    '${(progress * 100).toInt()}%(',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Learning Progress',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$completed of $total courses completed',
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

  Widget _buildEnhancedAnalysisTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: SlideTransition(
        position: _contentSlideAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // My Exam Section
            _buildMyExamSection(),
            const SizedBox(height: 24),

            // Enhanced Learning Analysis
            _buildEnhancedLearningAnalysis(),
          ],
        ),
      ),
    );
  }

  Widget _buildMyExamSection() {
    return const SizedBox.shrink(); // Remove static exam section
  }

  Widget _buildEnhancedLearningAnalysis() {
    final isWide = MediaQuery.of(context).size.width > 600;
    final crossAxisCount = isWide ? 3 : 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Learning Analysis',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: isWide ? 1.2 : 1.1,
          children: [
            _buildEnhancedAnalysisCard(
              icon: Icons.document_scanner,
              title: 'Docs & Videos',
              value: userData?['docsViewed']?.toString() ?? '0',
              subtitle: 'viewed',
              color: Colors.teal[400]!,
            ),
            _buildEnhancedAnalysisCard(
              icon: Icons.checklist,
              title: 'Tests',
              value: userData?['testsAttempted']?.toString() ?? '0',
              subtitle: 'attempted',
              color: Colors.orange[400]!,
            ),
            _buildEnhancedAnalysisCard(
              icon: Icons.timer,
              title: 'Learning Time',
              value: userData?['totalTime'] ?? '0',
              subtitle: 'total',
              color: Colors.purple[400]!,
            ),
            _buildEnhancedAnalysisCard(
              icon: Icons.local_fire_department,
              title: 'Streak',
              value: userData?['streak']?.toString() ?? '0',
              subtitle: 'days',
              color: Colors.red[400]!,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEnhancedAnalysisCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[800],
                ),
              ),
              Text(
                '$title $subtitle',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedActivityTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: SlideTransition(
        position: _contentSlideAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Activity',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            if (recentActivities.isEmpty)
              _buildEmptyActivityState()
            else
              ...recentActivities
                  .map((activity) => _buildActivityItem(activity)),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> activity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: activity['color'].withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              activity['icon'],
              color: activity['color'],
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['title'],
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  activity['subtitle'],
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activity['time'],
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 14,
            color: Colors.grey[400],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyActivityState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No activity yet',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start learning to see your activity here',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 40,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
