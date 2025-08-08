import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'chapters_screen.dart';

class SubjectsListScreen extends StatefulWidget {
  final String trackTitle; // e.g., "Class 12" or "NEET"

  const SubjectsListScreen({super.key, required this.trackTitle});

  @override
  State<SubjectsListScreen> createState() => _SubjectsListScreenState();
}

class _SubjectsListScreenState extends State<SubjectsListScreen> {
  late Future<List<dynamic>> _subjectsFuture;

  @override
  void initState() {
    super.initState();
    _subjectsFuture = fetchSubjects();
  }

  Future<List<dynamic>> fetchSubjects() async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://indiawebdesigns.in/app/eduapp/user-app/get_subjects.php'),
      );
      final contentType = response.headers['content-type'] ?? '';
      final body = response.body.trimLeft();
      final looksLikeJson = body.startsWith('{') || body.startsWith('[');
      debugPrint('API Response Status: \\${response.statusCode}');
      debugPrint('API Response Body: \\${body}');
      if (!contentType.contains('application/json') && !looksLikeJson) {
        debugPrint('API response is not JSON.');
        return <dynamic>[];
      }
      final data = jsonDecode(body);
      debugPrint('Decoded API Data: \\${data}');
      if (data is Map && data['status'] == 'success') {
        final List subjects = data['subjects'] ?? [];
        debugPrint('Subjects fetched: \\${subjects.length}');
        return subjects.cast<dynamic>();
      }
      debugPrint('API returned unsuccessful status or missing subjects.');
      return <dynamic>[];
    } catch (e) {
      debugPrint('Error fetching subjects: \\${e}');
      return <dynamic>[];
    }
  }

  IconData _getSubjectIcon(String? iconName) {
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
        if (hex.length == 6) {
          hex = 'FF$hex';
        }
        return Color(int.parse(hex, radix: 16));
      }
    } catch (_) {}
    return const Color(0xFF14B8A6);
  }

  Future<void> _refresh() async {
    setState(() {
      _subjectsFuture = fetchSubjects();
    });
    await _subjectsFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.trackTitle,
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700, color: Colors.white),
            ),
            Text(
              'Choose a subject to continue',
              style: GoogleFonts.inter(
                  fontSize: 12, color: Colors.white.withOpacity(0.9)),
            ),
          ],
        ),
        backgroundColor: Colors.blue[800],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _subjectsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingSkeleton();
          }
          if (snapshot.hasError) {
            return _buildError(snapshot.error);
          }

          final subjects = snapshot.data ?? [];

          return RefreshIndicator(
            onRefresh: _refresh,
            color: const Color(0xFF14B8A6),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildHeader(subjects.length)),
                if (subjects.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Text(
                        'No subjects found',
                        style: GoogleFonts.inter(
                            fontSize: 16, color: const Color(0xFF64748B)),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    sliver: SliverList.separated(
                      itemCount: subjects.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final subject = subjects[index] as Map<String, dynamic>;
                        return _SubjectCard(
                          subject: subject,
                          getIcon: _getSubjectIcon,
                          parseColor: _parseColor,
                          onTap: () {
                            final String subjectName = (subject['Name'] ??
                                    subject['name'] ??
                                    'Subject')
                                .toString();
                            final String subjectId =
                                (subject['SubjectID'] ?? subject['id'] ?? '')
                                    .toString();
                            debugPrint(
                                'Tapped Subject Card: subjectId=$subjectId, subjectName=$subjectName, fullData=$subject');
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChaptersScreen(
                                  subjectId: subjectId,
                                  subjectName: subjectName,
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
          );
        },
      ),
    );
  }

  Widget _buildHeader(int count) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF14B8A6), Color(0xFF0D9488)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF14B8A6).withOpacity(0.25),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(12),
            child: const Icon(Icons.auto_stories_rounded,
                color: Colors.white, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.trackTitle} Subjects',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$count available',
                  style: GoogleFonts.inter(
                    color: Colors.white.withOpacity(0.95),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Study',
              style: GoogleFonts.inter(
                  color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    Widget shimmerBox({double height = 64}) {
      return Container(
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(14),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: 6,
      itemBuilder: (_, i) => Padding(
        padding: EdgeInsets.only(bottom: i == 5 ? 0 : 12),
        child: shimmerBox(height: 84),
      ),
    );
  }

  Widget _buildError(Object? error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
            const SizedBox(height: 12),
            Text(
              'Failed to load subjects',
              style:
                  GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: const Color(0xFF64748B)),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF14B8A6),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: _refresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubjectCard extends StatelessWidget {
  final Map<String, dynamic> subject;
  final IconData Function(String?) getIcon;
  final Color Function(String?) parseColor;
  final VoidCallback onTap;

  const _SubjectCard({
    required this.subject,
    required this.getIcon,
    required this.parseColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final title = (subject['Name'] ?? subject['name'] ?? 'Subject').toString();
    final iconName =
        (subject['Icon'] ?? subject['icon'] ?? subject['subject_icon'])
            ?.toString();
    final colorStr =
        (subject['Color'] ?? subject['color'] ?? subject['subject_color'])
            ?.toString();

    final icon = getIcon(iconName);
    final color = parseColor(colorStr);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _InfoPill(
                          icon: Icons.menu_book_outlined,
                          label: (subject['type'] ?? 'Subject').toString(),
                          color: color,
                        ),
                        const SizedBox(width: 8),
                        if (subject['chapters'] != null)
                          _InfoPill(
                            icon: Icons.list_alt_rounded,
                            label: '${subject['chapters']} chapters',
                            color: const Color(0xFF64748B),
                            light: true,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool light;

  const _InfoPill({
    required this.icon,
    required this.label,
    required this.color,
    this.light = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = light ? const Color(0xFFF1F5F9) : color.withOpacity(0.10);
    final fg = light ? const Color(0xFF475569) : color;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: light ? const Color(0xFFE2E8F0) : color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}
