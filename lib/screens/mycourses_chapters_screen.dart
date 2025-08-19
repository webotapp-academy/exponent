import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'mycourses_chapter_detail_screen.dart';

class MyCoursesChaptersScreen extends StatelessWidget {
  final String subjectName;
  final String courseLabel; // e.g., 'Class 12' or 'NEET'
  final bool isNeet;
  final dynamic subjectId;
  const MyCoursesChaptersScreen({
    super.key,
    required this.subjectName,
    required this.courseLabel,
    required this.isNeet,
    required this.subjectId,
  });

  Future<List<dynamic>> fetchChapters() async {
    final res = await http.get(Uri.parse(
        'https://indiawebdesigns.in/app/eduapp/user-app/fetch_chapters.php?subject_id=$subjectId'));
    print('API response: ------>>>' + res.body);
    final data = jsonDecode(res.body);
    if (data['status'] == 'success') {
      final List chapters = data['chapters'] ?? [];
      print('Parsed chapters: ' + chapters.toString());
      return chapters.cast<dynamic>();
    }
    print('API error: ' + (data['message']?.toString() ?? 'Unknown error'));
    throw Exception('Failed to load chapters');
  }

  @override
  Widget build(BuildContext context) {
    final accent = isNeet ? const Color(0xFF16A34A) : const Color(0xFF1A3A6C);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.grey[900]),
        title: Text(
          subjectName,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: Colors.grey[900],
            fontSize: 14,
          ),
        ),
      ),
      body: Column(
        children: [
          // Header banner
          Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [accent, Color.alphaBlend(Colors.white24, accent)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: accent.withOpacity(0.2),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
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
                      const Icon(Icons.view_list_rounded, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Chapters',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Explore the topics under $subjectName - $courseLabel',
                        style: GoogleFonts.poppins(
                          color: Colors.white.withOpacity(0.95),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: fetchChapters(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // Skeleton loaders
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                    itemCount: 6,
                    itemBuilder: (context, index) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      height: 80,
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
                          Text(
                            'Failed to load chapters',
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w700, fontSize: 16),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${snapshot.error}',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                                color: const Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      'No chapters found.',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }
                final chapters = snapshot.data!;
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  itemCount: chapters.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final ch = chapters[index];
                    final chapterId =
                        ch['id'] ?? ch['TopicID'] ?? ch['topic_id'];
                    final chapterTitle = (ch['chapter_title'] ??
                            ch['title'] ??
                            ch['Name'] ??
                            'Chapter')
                        .toString();
                    final chapterDesc =
                        (ch['chapter_desc'] ?? ch['Description'] ?? '')
                            .toString();
                    final materialPdfLink =
                        (ch['chapter_material_pdf_link'] ?? '').toString();
                    final notesPdfLink =
                        (ch['chapter_notes_pdf_link'] ?? '').toString();
                    final youtubeLink =
                        (ch['chapter_youtube_link'] ?? '').toString();
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MyCoursesChapterDetailScreen(
                                subjectId: subjectId,
                                chapterTitle: chapterTitle,
                                accent: accent,
                                materialPdfLink: materialPdfLink,
                                notesPdfLink: notesPdfLink,
                                youtubeLink: youtubeLink,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
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
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [accent.withOpacity(0.95), accent],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '${index + 1}',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      chapterTitle,
                                      maxLines: 2,
                                      softWrap: true,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13, // Reduced from 15
                                        color: const Color(0xFF0F172A),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      chapterDesc,
                                      style: GoogleFonts.poppins(
                                        fontSize: 12.5,
                                        height: 1.35,
                                        color: const Color(0xFF64748B),
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.chevron_right_rounded,
                                  color: Color(0xFF94A3B8),
                                ),
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
    );
  }
}
