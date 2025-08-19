import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:pdfx/pdfx.dart';
import 'package:http/http.dart' as http;
import 'package:vector_math/vector_math_64.dart' as vm;
import 'package:flutter/services.dart';
import 'package:screen_protector/screen_protector.dart';

class MyCoursesChapterDetailScreen extends StatefulWidget {
  final dynamic subjectId;
  final String chapterTitle;
  final Color accent;

  final String? materialPdfLink;
  final String? notesPdfLink;
  final String? youtubeLink;

  const MyCoursesChapterDetailScreen({
    super.key,
    required this.subjectId,
    required this.chapterTitle,
    required this.accent,
    this.materialPdfLink,
    this.notesPdfLink,
    this.youtubeLink,
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
  YoutubePlayerController? _ytController;

  @override
  void initState() {
    super.initState();
    debugPrint('[ScreenProtect] Initializing on MyCoursesChapterDetailScreen');
    // Disable screenshots and screen recording on this screen
    _enableScreenProtection();
    _tabController = TabController(length: tabs.length, vsync: this);
    final videoId = YoutubePlayer.convertUrlToId(widget.youtubeLink ?? '');
    if (videoId != null && videoId.isNotEmpty) {
      _ytController = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
      );
    }

    // Apply orientation based on initial tab and listen for changes
    _applyOrientationForIndex(_tabController.index);
    _tabController.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    // Restore portrait orientation when leaving this screen
    SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    // Re-enable screenshots/recording when leaving the screen
    _disableScreenProtection();
    _tabController.removeListener(_handleTabChange);
    _ytController?.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _enableScreenProtection() async {
    try {
      await ScreenProtector.preventScreenshotOn();
      debugPrint('[ScreenProtect] preventScreenshotOn enabled');
      await ScreenProtector.protectDataLeakageOn();
      debugPrint('[ScreenProtect] protectDataLeakageOn enabled');
      // FLAG_SECURE requires flutter_windowmanager; skipped due to build issues
      debugPrint(
          '[ScreenProtect] ACTIVE: screenshots and recording should be blocked');
    } catch (e) {
      debugPrint('[ScreenProtect] enable error: $e');
    }
  }

  Future<void> _disableScreenProtection() async {
    try {
      await ScreenProtector.preventScreenshotOff();
      debugPrint('[ScreenProtect] preventScreenshotOn disabled');
      await ScreenProtector.protectDataLeakageOff();
      debugPrint('[ScreenProtect] protectDataLeakageOn disabled');
      // FLAG_SECURE clear skipped (dependency removed)
      debugPrint(
          '[ScreenProtect] INACTIVE: screenshots and recording unblocked');
    } catch (e) {
      debugPrint('[ScreenProtect] disable error: $e');
    }
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      _applyOrientationForIndex(_tabController.index);
      // Rebuild to reflect UI changes (hide AppBar/TabBar on video tab)
      if (mounted) setState(() {});
    }
  }

  void _applyOrientationForIndex(int index) {
    if (index == 2) {
      SystemChrome.setPreferredOrientations(const [
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setPreferredOrientations(const [
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
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

  Future<List<dynamic>> fetchMaterials() async {
    final link = widget.materialPdfLink;
    if (link != null && link.isNotEmpty) {
      return [
        {
          'title': widget.chapterTitle,
          'desc': 'Material PDF',
          'url': link,
        }
      ];
    }
    return [];
  }

  Future<List<dynamic>> fetchNotes() async {
    final link = widget.notesPdfLink;
    if (link != null && link.isNotEmpty) {
      return [
        {
          'title': widget.chapterTitle,
          'desc': 'Notes PDF',
          'url': link,
        }
      ];
    }
    return [];
  }

  Future<List<dynamic>> fetchVideos() async {
    final link = widget.youtubeLink;
    if (link != null && link.isNotEmpty) {
      return [
        {
          'title': widget.chapterTitle,
          'desc': 'YouTube Video',
          'url': link,
        }
      ];
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.accent;
    final bool isVideoTab = _tabController.index == 2;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: isVideoTab
          ? null
          : AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              iconTheme: IconThemeData(color: Colors.grey[900]),
              title: Text(
                widget.chapterTitle,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[900],
                  fontSize: 16,
                ),
              ),
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: accent,
                labelColor: Colors.grey[900],
                unselectedLabelColor: Colors.blueGrey,
                indicatorWeight: 3,
                labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                tabs: tabs.map((t) => Tab(text: t)).toList(),
              ),
            ),
      body: isVideoTab
          ? _buildVideoFullScreen(url: widget.youtubeLink)
          : TabBarView(
              controller: _tabController,
              children: [
                _buildPdfOrFetch(
                  url: widget.materialPdfLink,
                  fallbackIcon: Icons.menu_book,
                  fallbackLabel: 'materials',
                  fetcher: fetchMaterials,
                ),
                _buildPdfOrFetch(
                  url: widget.notesPdfLink,
                  fallbackIcon: Icons.note_alt,
                  fallbackLabel: 'notes',
                  fetcher: fetchNotes,
                ),
                // Placeholder; real video UI rendered in full-screen branch above
                const SizedBox.shrink(),
              ],
            ),
    );
  }

  Widget _buildList(
      List<dynamic> data, Color accent, IconData icon, String fallback) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemCount: data.length,
      itemBuilder: (context, index) {
        final item = data[index] as Map<String, dynamic>;
        final title = (item['Title'] ?? item['title'] ?? fallback).toString();
        final subtitle = (item['Description'] ?? item['desc'] ?? '').toString();
        final url = (item['URL'] ?? item['url'] ?? '').toString();
        return Material(
          color: Colors.white,
          elevation: 0,
          borderRadius: BorderRadius.circular(12),
          child: ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: accent),
            ),
            title: Text(
              title,
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600, fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              softWrap: true,
            ),
            subtitle: Text(
              subtitle,
              style: GoogleFonts.poppins(
                  fontSize: 12, color: const Color(0xFF64748B)),
            ),
            onTap: () {
              debugPrint('Tapped "$title" -> url: $url');
              if (url.isNotEmpty &&
                  (url.startsWith('http://') || url.startsWith('https://'))) {
                _openPdf(url, title);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('No valid URL found for this item')),
                );
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildPdfOrFetch({
    required String? url,
    required IconData fallbackIcon,
    required String fallbackLabel,
    required Future<List<dynamic>> Function() fetcher,
  }) {
    if (url != null && url.isNotEmpty) {
      debugPrint('Loading $fallbackLabel via native PDF viewer: $url');
      return _InlinePdfViewer(
        url: url,
        title: widget.chapterTitle,
        showAppBar: false,
      );
    }
    return FutureBuilder<List<dynamic>>(
      future: fetcher(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return _buildPlaceholder(fallbackLabel, fallbackIcon);
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildPlaceholder(fallbackLabel, fallbackIcon);
        }
        final data = snapshot.data!;
        debugPrint(
            'Fetched ${data.length} $fallbackLabel item(s) from widget values.');
        if (data.isNotEmpty) {
          final first = data.first as Map<String, dynamic>;
          debugPrint('Example $fallbackLabel URL: '
              '${(first['URL'] ?? first['url'] ?? '').toString()}');
        }
        return _buildList(
            data,
            widget.accent,
            fallbackIcon,
            fallbackLabel.substring(0, 1).toUpperCase() +
                fallbackLabel.substring(1));
      },
    );
  }

  void _openPdf(String url, String title) {
    debugPrint('Opening PDF in native viewer: $url');
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            _InlinePdfViewer(url: url, title: title, showAppBar: true),
      ),
    );
  }

  Widget _buildVideoFullScreen({required String? url}) {
    if (url != null && url.isNotEmpty && _ytController != null) {
      return Stack(
        children: [
          Positioned.fill(child: YoutubePlayer(controller: _ytController!)),
          // Circular semi-transparent back button only
          Positioned(
            left: 8,
            top: 8,
            child: SafeArea(
              bottom: false,
              child: Material(
                color: Colors.black54,
                shape: const CircleBorder(),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    SystemChrome.setPreferredOrientations(const [
                      DeviceOrientation.portraitUp,
                      DeviceOrientation.portraitDown,
                    ]);
                    Navigator.of(context).maybePop();
                  },
                ),
              ),
            ),
          ),
        ],
      );
    }
    return _buildPlaceholder('videos', Icons.play_circle_fill);
  }
}

class _InlinePdfViewer extends StatefulWidget {
  final String url;
  final String title;
  final bool showAppBar;
  const _InlinePdfViewer({
    required this.url,
    required this.title,
    this.showAppBar = true,
  });

  @override
  State<_InlinePdfViewer> createState() => _InlinePdfViewerState();
}

class _InlinePdfViewerState extends State<_InlinePdfViewer> {
  PdfControllerPinch? _pdfController;
  String? _error;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      debugPrint('Pdfx: loading ${widget.url}');
      final response = await http.get(Uri.parse(widget.url));
      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }
      final futureDoc = PdfDocument.openData(response.bodyBytes);
      setState(() {
        _pdfController = PdfControllerPinch(document: futureDoc);
      });
    } catch (e) {
      debugPrint('Pdfx error: $e');
      setState(() => _error = e.toString());
    }
  }

  @override
  void dispose() {
    _pdfController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pdfContent = _error != null
        ? Center(child: Text('Failed to load PDF\n$_error'))
        : (_pdfController == null)
            ? const Center(child: CircularProgressIndicator())
            : PdfViewPinch(controller: _pdfController!);

    final controls = (_pdfController == null)
        ? const SizedBox.shrink()
        : Positioned(
            right: 12,
            bottom: 12,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ZoomButton(icon: Icons.zoom_in, onTap: () => _zoomBy(1.2)),
                const SizedBox(height: 8),
                _ZoomButton(
                    icon: Icons.zoom_out, onTap: () => _zoomBy(1 / 1.2)),
                const SizedBox(height: 8),
                _ZoomButton(icon: Icons.fit_screen, onTap: _fitToPage),
              ],
            ),
          );

    final body = Stack(
      children: [
        Positioned.fill(child: pdfContent),
        controls,
      ],
    );

    if (widget.showAppBar) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            widget.title,
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
        ),
        body: body,
      );
    }
    return body;
  }

  Future<void> _zoomBy(double factor) async {
    if (_pdfController == null) return;
    final controller = _pdfController!;
    final current = controller.zoomRatio;
    final newScale = (current * factor).clamp(0.5, 6.0);
    final rect = controller.viewRect;
    final destination = vm.Matrix4.compose(
      vm.Vector3(-rect.left, -rect.top, 0),
      vm.Quaternion.identity(),
      vm.Vector3(newScale.toDouble(), newScale.toDouble(), 1),
    );
    await controller.goTo(destination: destination);
  }

  Future<void> _fitToPage() async {
    if (_pdfController == null) return;
    final controller = _pdfController!;
    final pageNum = controller.page;
    final matrix =
        controller.calculatePageFitMatrix(pageNumber: pageNum, padding: 16);
    await controller.goTo(destination: matrix);
  }
}

class _ZoomButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _ZoomButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.6),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}
