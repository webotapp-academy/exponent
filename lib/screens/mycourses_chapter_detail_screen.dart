import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MyCoursesChapterDetailScreen extends StatefulWidget {
  final dynamic subjectId;
  final String chapterTitle;
  final Color accent;
  const MyCoursesChapterDetailScreen({
    super.key,
    required this.subjectId,
    required this.chapterTitle,
    required this.accent,
  });

  @override
  State<MyCoursesChapterDetailScreen> createState() =>
      _MyCoursesChapterDetailScreenState();
}

class _MyCoursesChapterDetailScreenState
    extends State<MyCoursesChapterDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final tabs = const ['Materials', 'Notes', 'Videos'];

  Future<List<dynamic>> fetchMaterials() async {
    final res = await http.get(Uri.parse(
        'https://indiawebdesigns.in/app/eduapp/user-app/get_topic_materials.php?topic_id=${widget.subjectId}'));
    final data = jsonDecode(res.body);
    if (data['status'] == 'success') {
      return data['materials'] ?? [];
    }
    throw Exception('Failed to load materials');
  }

  Future<List<dynamic>> fetchNotes() async {
    final url =
        'https://indiawebdesigns.in/app/eduapp/user-app/get_topic_notes.php?topic_id=${widget.subjectId}';
    debugPrint('Fetching notes from: $url');
    final res = await http.get(Uri.parse(url));
    debugPrint('Notes API response: ${res.body}');
    final data = jsonDecode(res.body);
    if (data['status'] == 'success') {
      return data['notes'] ?? [];
    }
    throw Exception('Failed to load notes');
  }

  Future<List<dynamic>> fetchVideos() async {
    final url =
        'https://indiawebdesigns.in/app/eduapp/user-app/get_topic_videos.php?topic_id=${widget.subjectId}';
    debugPrint('Fetching videos from: $url');
    final res = await http.get(Uri.parse(url));
    debugPrint('Videos API response: ${res.body}');
    final data = jsonDecode(res.body);
    if (data['status'] == 'success') {
      return data['videos'] ?? [];
    }
    throw Exception('Failed to load videos');
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildPlaceholder(String label, IconData icon) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: const Color(0xFF94A3B8)),
          const SizedBox(height: 12),
          Text(
            'No $label available yet',
            style: GoogleFonts.poppins(
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.accent;
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          widget.chapterTitle,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: Colors.white, // <-- Changed to white
          ),
        ),
        backgroundColor: accent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          tabs: tabs.map((t) => Tab(text: t)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          FutureBuilder<List<dynamic>>(
            future: fetchMaterials(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return _buildPlaceholder('materials', Icons.menu_book);
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return _buildPlaceholder('materials', Icons.menu_book);
              }
              final materials = snapshot.data!;
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: materials.length,
                itemBuilder: (context, index) {
                  final m = materials[index];
                  return Card(
                    child: ListTile(
                      leading: Icon(Icons.menu_book, color: accent),
                      title: Text(m['Title'] ?? m['title'] ?? 'Material'),
                      subtitle: Text(m['Description'] ?? m['desc'] ?? ''),
                    ),
                  );
                },
              );
            },
          ),
          FutureBuilder<List<dynamic>>(
            future: fetchNotes(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return _buildPlaceholder('notes', Icons.note_alt);
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return _buildPlaceholder('notes', Icons.note_alt);
              }
              final notes = snapshot.data!;
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  final n = notes[index];
                  return Card(
                    child: ListTile(
                      leading: Icon(Icons.note_alt, color: accent),
                      title: Text(n['Title'] ?? n['title'] ?? 'Note'),
                      subtitle: Text(n['Description'] ?? n['desc'] ?? ''),
                    ),
                  );
                },
              );
            },
          ),
          FutureBuilder<List<dynamic>>(
            future: fetchVideos(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return _buildPlaceholder('videos', Icons.play_circle_fill);
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return _buildPlaceholder('videos', Icons.play_circle_fill);
              }
              final videos = snapshot.data!;
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: videos.length,
                itemBuilder: (context, index) {
                  final v = videos[index];
                  return Card(
                    child: ListTile(
                      leading: Icon(Icons.play_circle_fill, color: accent),
                      title: Text(v['Title'] ?? v['title'] ?? 'Video'),
                      subtitle: Text(v['Description'] ?? v['desc'] ?? ''),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
