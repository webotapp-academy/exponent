import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NeetTestSeriesScreen extends StatelessWidget {
  const NeetTestSeriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final primary = Colors.blue[800]; // match HomeScreen AppBar
    final pillBg = Colors.blue[50];
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Free NEET Test Series',
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          // header pill to align with home style accents
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: pillBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.stacked_line_chart, color: primary, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Attempt free NEET mock tests',
                  style: GoogleFonts.inter(
                      fontSize: 14.5, color: Colors.blueGrey[800]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ...List.generate(
            5,
            (index) => Card(
              elevation: 2,
              shadowColor: Colors.black.withOpacity(0.06),
              margin: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: pillBg,
                  child: Icon(Icons.assignment, color: primary),
                ),
                title: Text(
                  'NEET Mock Test ${index + 1}',
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0F172A)),
                ),
                subtitle: Text(
                  'Full syllabus | 180 mins | 720 marks',
                  style: GoogleFonts.inter(
                      color: const Color(0xFF64748B), fontSize: 13),
                ),
                trailing: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Start Test ${index + 1} (Demo only)')),
                    );
                  },
                  icon: const Icon(Icons.play_arrow_rounded, size: 18),
                  label: const Text('Start'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
