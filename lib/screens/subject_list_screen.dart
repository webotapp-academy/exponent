import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import 'mycourses_chapters_screen.dart';

class SubjectListScreen extends StatefulWidget {
  final String trackTitle; // e.g., "Class 12" or "NEET"
  final dynamic courseId;
  const SubjectListScreen(
      {super.key, required this.trackTitle, required this.courseId});

  @override
  State<SubjectListScreen> createState() => _SubjectListScreenState();
}

class _SubjectListScreenState extends State<SubjectListScreen> {
  late Future<List<dynamic>> _subjectsFuture;

  @override
  void initState() {
    super.initState();
    _subjectsFuture = _fetchSubjects();
  }

  Future<List<dynamic>> _fetchSubjects() async {
    final res = await http.get(Uri.parse(
        'https://indiawebdesigns.in/app/eduapp/user-app/get_subjects.php?course_id=${widget.courseId}'));
    final data = jsonDecode(res.body);
    if (data['status'] == 'success') {
      final List subjects = data['subjects'] ?? [];
      return subjects.cast<dynamic>();
    }
    throw Exception('Failed to load subjects');
  }

  IconData _iconFor(String? iconName) {
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

  Color _parseColor(String? colorString) {
    try {
      if (colorString != null && colorString.startsWith('#')) {
        String hex = colorString.replaceFirst('#', '');
        if (hex.length == 6) hex = 'FF$hex';
        return Color(int.parse(hex, radix: 16));
      }
    } catch (_) {}
    return const Color(0xFF14B8A6);
  }

  Future<void> _refresh() async {
    setState(() {
      _subjectsFuture = _fetchSubjects();
    });
    await _subjectsFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          widget.trackTitle,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue[800],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _subjectsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              itemCount: 6,
              itemBuilder: (_, i) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                height: 84,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
              ),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline,
                        color: Colors.redAccent, size: 40),
                    const SizedBox(height: 8),
                    Text(
                      'Failed to load subjects',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _refresh,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[800],
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    )
                  ],
                ),
              ),
            );
          }

          final subjects = snapshot.data ?? [];
          if (subjects.isEmpty) {
            return Center(
              child: Text(
                'No subjects found',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: const Color(0xFF64748B),
                ),
              ),
            );
          }

          return RefreshIndicator(
            color: Colors.blue[800],
            onRefresh: _refresh,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              itemCount: subjects.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final subject = subjects[index] as Map<String, dynamic>;
                // Try all possible keys for subject name
                final title = (subject['Name'] ??
                        subject['name'] ??
                        subject['subject_name'] ??
                        'Subject')
                    .toString();
                final iconName = (subject['Icon'] ??
                        subject['icon'] ??
                        subject['subject_icon'])
                    ?.toString();
                final colorStr = (subject['Color'] ??
                        subject['color'] ??
                        subject['subject_color'])
                    ?.toString();
                final subjectId = subject['SubjectID'] ??
                    subject['subject_id'] ??
                    subject['id'] ??
                    subject['ID'];

                final icon = _iconFor(iconName);
                final color = _parseColor(colorStr);

                return Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  elevation: 0,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MyCoursesChaptersScreen(
                            courseName: title,
                            isNeet: widget.trackTitle
                                .toLowerCase()
                                .contains('neet'),
                            subjectId: subjectId,
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [color.withOpacity(0.85), color],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(icon, color: Colors.white, size: 28),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              title,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: const Color(0xFF0F172A),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.chevron_right_rounded,
                              color: Color(0xFF94A3B8)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
