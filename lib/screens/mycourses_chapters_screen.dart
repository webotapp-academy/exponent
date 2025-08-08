import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'mycourses_chapter_detail_screen.dart';

class MyCoursesChaptersScreen extends StatelessWidget {
  final String courseName;
  final bool isNeet;
  final dynamic subjectId;
  const MyCoursesChaptersScreen({
    super.key,
    required this.courseName,
    required this.isNeet,
    required this.subjectId,
  });

  Future<List<dynamic>> fetchChapters() async {
    final res = await http.get(Uri.parse(
        'https://indiawebdesigns.in/app/eduapp/user-app/get_topics.php?subject_id=$subjectId'));
    print('API response: ' + res.body);
    final data = jsonDecode(res.body);
    if (data['status'] == 'success') {
      final List chapters = data['topics'] ?? [];
      print('Parsed chapters: ' + chapters.toString());
      return chapters.cast<dynamic>();
    }
    print('API error: ' + (data['message']?.toString() ?? 'Unknown error'));
    throw Exception('Failed to load chapters');
  }

  @override
  Widget build(BuildContext context) {
    final accent = isNeet ? const Color(0xFF16A34A) : const Color(0xFF1D4ED8);
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(courseName,
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        backgroundColor: accent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: fetchChapters(),
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
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            itemCount: chapters.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final ch = chapters[index];
              final chapterId =
                  ch['TopicID'] ?? ch['topic_id'] ?? ch['id'] ?? ch['ID'];
              final chapterTitle = ch['Name'] ??
                  ch['name'] ??
                  ch['title'] ??
                  ch['TopicName'] ??
                  'Chapter';
              final chapterDesc = ch['Description'] ??
                  ch['description'] ??
                  ch['desc'] ??
                  ch['TopicDescription'] ??
                  '';
              return Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                elevation: 1,
                shadowColor: Colors.black.withOpacity(0.04),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MyCoursesChapterDetailScreen(
                          subjectId: subjectId,
                          chapterTitle: chapterTitle,
                          accent: accent,
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: accent.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${index + 1}',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w700,
                              color: accent,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(chapterTitle,
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              Text(
                                chapterDesc,
                                style: GoogleFonts.poppins(
                                    fontSize: 12.5, color: Color(0xFF64748B)),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right,
                            color: Color(0xFF94A3B8)),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
