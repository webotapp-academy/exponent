import 'package:edu_rev_app/screens/watch_videos_screen.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'subjects_list_screen.dart';
import '../widgets/custom_bottom_nav_bar.dart';

class StudyMaterialsScreen extends StatefulWidget {
  const StudyMaterialsScreen({super.key});

  @override
  State<StudyMaterialsScreen> createState() => _StudyMaterialsScreenState();
}

class _StudyMaterialsScreenState extends State<StudyMaterialsScreen>
    with TickerProviderStateMixin {
  late Future<List<dynamic>> _videosFuture;

  @override
  void initState() {
    super.initState();
    _videosFuture = fetchVideos();
  }

  Future<List<dynamic>> fetchVideos() async {
    final response = await http.get(
      Uri.parse(
          'https://indiawebdesigns.in/app/eduapp/user-app/get_all_videos.php'),
    );
    final data = jsonDecode(response.body);
    if (data['status'] == 'success') {
      return data['videos'];
    } else {
      throw Exception('Failed to load videos');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Study Materials',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.blue[800],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: VideosListWidget(videosFuture: _videosFuture),
      bottomNavigationBar: CustomBottomNavBar(currentIndex: 2),
    );
  }
}

class VideosListWidget extends StatelessWidget {
  final Future<List<dynamic>> videosFuture;

  const VideosListWidget({Key? key, required this.videosFuture})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: videosFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No videos found'));
        } else {
          final videos = snapshot.data!;
          return ListView.builder(
            itemCount: videos.length,
            itemBuilder: (context, index) {
              final video = videos[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue[100],
                    child: Icon(Icons.play_circle_fill,
                        color: Colors.blue[800], size: 28),
                  ),
                  title: Text(
                    video['title'] ?? 'No Title',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (video['description'] != null &&
                          video['description'].toString().isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            video['description'],
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: Colors.grey[700],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      if (video['provider'] != null &&
                          video['provider'].toString().isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2.0),
                          child: Text(
                            'By ${video['provider']}',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.blueGrey,
                            ),
                          ),
                        ),
                    ],
                  ),
                  trailing: Icon(Icons.arrow_forward_ios,
                      color: Colors.blue[800], size: 18),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WatchVideosScreen(video: video),
                      ),
                    );
                  },
                ),
              );
            },
          );
        }
      },
    );
  }
}

class WatchVideosScreen extends StatefulWidget {
  final Map<String, dynamic> video;
  const WatchVideosScreen({Key? key, required this.video}) : super(key: key);

  @override
  State<WatchVideosScreen> createState() => _WatchVideosScreenState();
}

class _WatchVideosScreenState extends State<WatchVideosScreen> {
  YoutubePlayerController? _controller;
  String? videoId;

  @override
  void initState() {
    super.initState();
    final url = widget.video['url'] ?? '';
    videoId = YoutubePlayer.convertUrlToId(url);
    if (videoId != null && videoId!.isNotEmpty) {
      _controller = YoutubePlayerController(
        initialVideoId: videoId!,
        flags: const YoutubePlayerFlags(
          autoPlay: true,
          mute: false,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.video['title'] ?? 'Video Player'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: videoId == null || videoId!.isEmpty || _controller == null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'Invalid or unsupported YouTube video URL.',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.red,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  YoutubePlayer(
                    controller: _controller!,
                    showVideoProgressIndicator: true,
                    progressIndicatorColor: Colors.blueAccent,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    widget.video['title'] ?? '',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.video['provider'] ?? '',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.blueGrey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
      ),
    );
  }
}
