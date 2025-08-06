import 'package:edu_rev_app/screens/watch_videos_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/custom_bottom_nav_bar.dart';

class StudyMaterialsScreen extends StatefulWidget {
  const StudyMaterialsScreen({super.key});

  @override
  State<StudyMaterialsScreen> createState() => _StudyMaterialsScreenState();
}

class _StudyMaterialsScreenState extends State<StudyMaterialsScreen>
    with TickerProviderStateMixin {
  int _selectedCategoryIndex = 0;
  int _selectedTypeIndex = 0;
  late AnimationController _animationController;

  final List<String> categories = [
    'All',
    'Mathematics',
    'English',
    'Science',
    'EVS'
  ];
  final List<String> materialTypes = [
    'Notes',
    'Worksheets',
    'Summary',
    'Practice'
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animationController.forward();
    _subjectsFuture = fetchSubjects(); // <-- This line is required!
  }

  late Future<List<dynamic>> _subjectsFuture;

  // Only one initState should exist
  @override
  Future<List<dynamic>> fetchSubjects() async {
    final response = await http.get(
      Uri.parse(
          'https://indiawebdesigns.in/app/eduapp/user-app/get_subjects.php'),
    );
    final data = jsonDecode(response.body);
    if (data['status'] == 'success') {
      return data['subjects'];
    } else {
      throw Exception('Failed to load subjects');
    }
  }

  IconData _getSubjectIcon(String iconName) {
    switch (iconName) {
      case 'biotech':
        return Icons.biotech;
      case 'science':
        return Icons.science;
      case 'flag':
        return Icons.flag;
      case 'calculate':
        return Icons.calculate;
      case 'language':
        return Icons.language;
      case 'computer':
        return Icons.computer;
      case 'attach_money':
        return Icons.attach_money;
      case 'public':
        return Icons.public;
      case 'history_edu':
        return Icons.history_edu;
      case 'account_balance':
        return Icons.account_balance;
      default:
        return Icons.menu_book;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Class Preview',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF14B8A6),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Subjects',
                      style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal[900])),
                  const SizedBox(height: 20),
                  Expanded(
                    child: FutureBuilder<List<dynamic>>(
                      future: _subjectsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: \\${snapshot.error}'));
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const Center(
                              child: Text('No subjects found.'));
                        }
                        final subjects = snapshot.data!;
                        return GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 1.2,
                          ),
                          itemCount: subjects.length,
                          itemBuilder: (context, index) {
                            final subject = subjects[index];
                            final color = subject['Color'] != null &&
                                    subject['Color'].toString().isNotEmpty
                                ? _parseColor(subject['Color'])
                                : Colors.teal[400];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => WatchVideosScreen(
                                      subjectId: subject['Id'],
                                      subjectName: subject['Name'],
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: (color ?? Colors.teal[400]!)
                                      .withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (color ?? Colors.teal[400]!)
                                          .withOpacity(0.08),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(_getSubjectIcon(subject['Icon']),
                                        color: color, size: 40),
                                    const SizedBox(height: 12),
                                    Text(
                                      subject['Name'],
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        color: Colors.teal[900],
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
                  ),
                ],
              ),
            ),
          ),
          CustomBottomNavBar(currentIndex: 2),
        ],
      ),
    );
  }

  Color _parseColor(String colorString) {
    try {
      if (colorString.startsWith('#')) {
        String hex = colorString.replaceFirst('#', '');
        if (hex.length == 6) {
          hex = 'FF' + hex;
        }
        return Color(int.parse(hex, radix: 16));
      }
    } catch (_) {}
    return Colors.teal[400]!;
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF14B8A6),
                Color(0xFF0D9488),
                Color(0xFF0F766E),
              ],
            ),
          ),
        ),
        title: Text(
          'Study Materials',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontSize: 24,
          ),
        ),
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.download_outlined, color: Colors.white),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.bookmark_border, color: Colors.white),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildWelcomeSection() {
    return FadeTransition(
      opacity: _animationController,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeOutBack,
        )),
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFFFFFF),
                Color(0xFFF1F5F9),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF14B8A6).withOpacity(0.1),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
            border: Border.all(
              color: Colors.white.withOpacity(0.8),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF14B8A6), Color(0xFF0D9488)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF14B8A6).withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.auto_stories_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Comprehensive Notes',
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Learn & Revise Anytime',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: const Color(0xFF14B8A6),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Access detailed study materials, notes, worksheets, and summaries for all UKG subjects. Download, read, and revise anytime, anywhere!',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: const Color(0xFF64748B),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedCategoryIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategoryIndex = index;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [Color(0xFF14B8A6), Color(0xFF0D9488)],
                      )
                    : null,
                color: isSelected ? null : Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? const Color(0xFF14B8A6).withOpacity(0.3)
                        : Colors.black.withOpacity(0.05),
                    blurRadius: isSelected ? 15 : 5,
                    offset: const Offset(0, 5),
                  ),
                ],
                border: isSelected
                    ? null
                    : Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Center(
                child: Text(
                  categories[index],
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : const Color(0xFF64748B),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMaterialTypeTabs() {
    return Container(
      height: 45,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: materialTypes.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedTypeIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedTypeIndex = index;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF14B8A6).withOpacity(0.1)
                    : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF14B8A6)
                      : const Color(0xFFE2E8F0),
                ),
              ),
              child: Text(
                materialTypes[index],
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? const Color(0xFF14B8A6)
                      : const Color(0xFF64748B),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProgressSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _buildProgressCard('24', 'Downloaded', const Color(0xFF14B8A6)),
          const SizedBox(width: 12),
          _buildProgressCard('18', 'Completed', const Color(0xFF3B82F6)),
          const SizedBox(width: 12),
          _buildProgressCard('6', 'Bookmarked', const Color(0xFFF59E0B)),
        ],
      ),
    );
  }

  Widget _buildProgressCard(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(
            color: color.withOpacity(0.2),
          ),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedMaterialsSection() {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Featured Materials',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'View All',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF14B8A6),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 4,
              itemBuilder: (context, index) {
                return _buildFeaturedMaterialCard(index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedMaterialCard(int index) {
    final colors = [
      const Color(0xFF14B8A6),
      const Color(0xFF3B82F6),
      const Color(0xFF8B5CF6),
      const Color(0xFFF59E0B),
    ];

    final titles = [
      'Math Fundamentals',
      'English Grammar',
      'Science Basics',
      'EVS Explorer',
    ];

    final descriptions = [
      'Complete number system guide',
      'Grammar rules & exercises',
      'Scientific concepts for kids',
      'Environmental awareness',
    ];

    final materialTypes = ['PDF Notes', 'Worksheet', 'Summary', 'Practice Set'];
    final pageCounts = ['12 pages', '8 pages', '6 pages', '15 pages'];

    return Container(
      width: 260,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colors[index].withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {},
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colors[index].withOpacity(0.8),
                      colors[index],
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getMaterialIcon(materialTypes[index]),
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          materialTypes[index],
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: colors[index],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titles[index],
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0F172A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      descriptions[index],
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF64748B),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.description_outlined,
                          size: 14,
                          color: colors[index],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          pageCounts[index],
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.download_outlined,
                          size: 16,
                          color: colors[index],
                        ),
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
  }

  IconData _getMaterialIcon(String type) {
    switch (type) {
      case 'PDF Notes':
        return Icons.picture_as_pdf_rounded;
      case 'Worksheet':
        return Icons.assignment_rounded;
      case 'Summary':
        return Icons.summarize_rounded;
      case 'Practice Set':
        return Icons.quiz_rounded;
      default:
        return Icons.menu_book_rounded;
    }
  }

  Widget _buildMaterialsByCategory() {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${categories[_selectedCategoryIndex]} ${materialTypes[_selectedTypeIndex]}',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(6, (index) => _buildEnhancedMaterialCard(index)),
        ],
      ),
    );
  }

  Widget _buildEnhancedMaterialCard(int index) {
    final colors = [
      const Color(0xFF14B8A6),
      const Color(0xFF3B82F6),
      const Color(0xFF8B5CF6),
      const Color(0xFFF59E0B),
      const Color(0xFFEF4444),
      const Color(0xFF06B6D4),
    ];

    final titles = [
      'Advanced Mathematics Guide',
      'English Communication Skills',
      'Scientific Exploration',
      'Environmental Studies',
      'Creative Arts & Crafts',
      'Physical Development',
    ];

    final descriptions = [
      'Complete guide to numbers, shapes & patterns',
      'Speaking, reading & writing fundamentals',
      'Simple experiments & natural phenomena',
      'Understanding our environment & society',
      'Creative expression through art & craft',
      'Physical activities & motor skills',
    ];

    final materialInfo = [
      {'type': 'PDF Notes', 'pages': '24 pages', 'size': '2.1 MB'},
      {'type': 'Worksheet', 'pages': '16 pages', 'size': '1.8 MB'},
      {'type': 'Summary', 'pages': '8 pages', 'size': '950 KB'},
      {'type': 'Practice Set', 'pages': '20 pages', 'size': '1.5 MB'},
      {'type': 'PDF Notes', 'pages': '12 pages', 'size': '1.2 MB'},
      {'type': 'Worksheet', 'pages': '18 pages', 'size': '2.0 MB'},
    ];

    final downloadCounts = ['1.2k', '856', '932', '1.5k', '743', '1.1k'];
    final ratings = ['4.8', '4.6', '4.9', '4.7', '4.5', '4.8'];

    return Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {},
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          colors[index].withOpacity(0.8),
                          colors[index],
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _getMaterialIcon(materialInfo[index]['type']!),
                          color: Colors.white,
                          size: 28,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          materialInfo[index]['size']!,
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
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
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                titles[index],
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: const Color(0xFF0F172A),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: colors[index].withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                materialInfo[index]['type']!,
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: colors[index],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          descriptions[index],
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: const Color(0xFF64748B),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.description_outlined,
                              size: 14,
                              color: colors[index],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              materialInfo[index]['pages']!,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Icon(
                              Icons.star,
                              size: 14,
                              color: const Color(0xFFF59E0B),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              ratings[index],
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Icon(
                              Icons.download_outlined,
                              size: 14,
                              color: const Color(0xFF64748B),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              downloadCounts[index],
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colors[index].withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.download_rounded,
                      color: colors[index],
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
