import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

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
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Failed to load videos'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No videos available'));
        }
        final videos = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: videos.length,
          itemBuilder: (context, index) {
            final v = videos[index];
            return Card(
              child: ListTile(
                leading: v['thumbnail'] != null &&
                        v['thumbnail'].toString().isNotEmpty
                    ? Image.network(v['thumbnail'],
                        width: 60, height: 40, fit: BoxFit.cover)
                    : Icon(Icons.play_circle_fill, color: Colors.blue[800]),
                title: Text(v['title'] ?? 'Video'),
                subtitle: Text(v['provider'] ?? ''),
                trailing: Text('${v['duration_seconds']}s'),
                onTap: () async {
                  if (v['url'] != null && v['url'].toString().isNotEmpty) {
                    final url = v['url'].toString();
                    final uri = Uri.parse(url);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri,
                          mode: LaunchMode.externalApplication);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Could not open video URL')),
                      );
                    }
                  }
                },
              ),
            );
          },
        );
      },
    );
  }
}
