import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class ChapterDetailScreen extends StatefulWidget {
  final String subjectName;
  final String chapterTitle;
  final String topicId;

  const ChapterDetailScreen({
    super.key,
    required this.subjectName,
    required this.chapterTitle,
    required this.topicId,
  });

  @override
  State<ChapterDetailScreen> createState() => _ChapterDetailScreenState();
}

class _ChapterDetailScreenState extends State<ChapterDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late Future<List<dynamic>> _materialsFuture;
  late Future<List<dynamic>> _notesFuture;
  late Future<List<dynamic>> _videosFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _materialsFuture = fetchMaterials();
    _notesFuture = fetchNotes();
    _videosFuture = fetchVideos();
  }

  Future<List<dynamic>> fetchNotes() async {
    final response = await http.get(Uri.parse(
      'https://indiawebdesigns.in/app/eduapp/user-app/get_topic_notes.php?topic_id=${widget.topicId}',
    ));
    final data = jsonDecode(response.body);
    if (data['status'] == 'success') {
      return data['notes'];
    } else {
      throw Exception('Failed to load notes');
    }
  }

  Future<List<dynamic>> fetchVideos() async {
    final response = await http.get(Uri.parse(
      'https://indiawebdesigns.in/app/eduapp/user-app/get_topic_videos.php?topic_id=${widget.topicId}',
    ));
    final data = jsonDecode(response.body);
    if (data['status'] == 'success') {
      return data['videos'];
    } else {
      throw Exception('Failed to load videos');
    }
  }

  Future<List<dynamic>> fetchMaterials() async {
    final response = await http.get(Uri.parse(
      'https://indiawebdesigns.in/app/eduapp/user-app/get_topic_materials.php?topic_id=${widget.topicId}',
    ));
    final data = jsonDecode(response.body);
    if (data['status'] == 'success') {
      return data['materials'];
    } else {
      throw Exception('Failed to load materials');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildHeader() {
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.chapterTitle,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.subjectName,
                style: GoogleFonts.inter(
                  color: Colors.white.withOpacity(0.95),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Start',
              style: GoogleFonts.inter(
                  color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    Color color = const Color(0xFF14B8A6),
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
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
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
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

  Widget _buildTabBody(int index) {
    switch (index) {
      case 0:
        // Study Materials (dynamic)
        return FutureBuilder<List<dynamic>>(
          future: _materialsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: \\${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No study materials found'));
            }
            final materials = snapshot.data!;
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: materials.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final material = materials[i];
                return _buildSectionCard(
                  icon: Icons.description_rounded,
                  title: material['title'] ?? 'Material',
                  subtitle: material['type'] ?? '',
                  color: const Color(0xFF14B8A6),
                );
              },
            );
          },
        );
      case 1:
        // Notes (static for now)
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          itemBuilder: (_, i) => _buildSectionCard(
            icon: Icons.note_alt_rounded,
            title: 'Note \\${i + 1}',
            subtitle: 'Key points and summaries',
            color: const Color(0xFFF59E0B),
          ),
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemCount: 5,
        );
      case 2:
      default:
        // Video Lectures (static for now)
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          itemBuilder: (_, i) => _buildSectionCard(
            icon: Icons.play_circle_fill_rounded,
            title: 'Lecture \\${i + 1}',
            subtitle: '\\${12 + i * 3} min • HD',
            color: const Color(0xFF3B82F6),
          ),
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemCount: 6,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Chapter Details',
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blue[800],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          labelStyle: GoogleFonts.inter(
              fontWeight: FontWeight.w700, color: Colors.white),
          unselectedLabelStyle: GoogleFonts.inter(
              fontWeight: FontWeight.w600, color: Colors.white70),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Study Materials'),
            Tab(text: 'Notes'),
            Tab(text: 'Video Lectures'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTabBody(0),
                _buildTabBody(1),
                _buildTabBody(2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
