import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NeetTestSeriesScreen extends StatelessWidget {
  const NeetTestSeriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Free NEET Test Series',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green[700],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          Text('Attempt free NEET mock tests and boost your preparation!',
              style: GoogleFonts.inter(fontSize: 16, color: Colors.black87)),
          const SizedBox(height: 24),
          ...List.generate(
              5,
              (index) => Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.green[100],
                        child: Icon(Icons.assignment, color: Colors.green[700]),
                      ),
                      title: Text('NEET Mock Test ${index + 1}',
                          style:
                              GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                      subtitle: Text('Full syllabus | 180 mins | 720 marks'),
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    'Start Test ${index + 1} (Demo only)')),
                          );
                        },
                        child: const Text('Start'),
                      ),
                    ),
                  )),
        ],
      ),
    );
  }
}
