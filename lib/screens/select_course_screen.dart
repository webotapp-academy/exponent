import 'package:edu_rev_app/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SelectCourseScreen extends StatelessWidget {
  const SelectCourseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 8),
              Text(
                'Hi Rajat Pradhan!',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'What are you preparing for?',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              _buildMainCourseCard(
                context,
                'Class 1 to Class 12',
                'assets/images/class1-12.png',
                () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          HomeScreen(userData: {'Name': 'User'}),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildMainCourseCard(
                context,
                'Entrance Exams',
                'assets/images/entrance-exams.png',
                () {},
              ),
              const SizedBox(height: 28),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Popular Exams',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildExamGrid(context, _popularExams),
              const SizedBox(height: 28),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Other Trending Exams',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildExamGrid(context, _otherExams),
              const SizedBox(height: 28),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Others',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _buildOthersCard(),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.flag, color: Colors.amber, size: 20),
                  const SizedBox(width: 6),
                  Text('India',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainCourseCard(BuildContext context, String title,
      String imagePath, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            // Use a placeholder icon if asset not available
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.menu_book, color: Colors.blue[700], size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildExamGrid(
      BuildContext context, List<Map<String, dynamic>> exams) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: exams.length,
      itemBuilder: (context, index) {
        final exam = exams[index];
        return GestureDetector(
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey[200]!),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.06),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey[100],
                  radius: 18,
                  child: Icon(exam['icon'], color: Colors.blue[700], size: 22),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    exam['label'],
                    style: GoogleFonts.poppins(
                        fontSize: 13, fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOthersCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Others',
            style:
                GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            'Graduation, Coding, Language, Startups etc',
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

// Example data for exams (replace icons with asset images if available)
final List<Map<String, dynamic>> _popularExams = [
  {'label': 'UPSC CSE', 'icon': Icons.account_balance},
  {'label': 'CAT', 'icon': Icons.school},
  {'label': 'NEET', 'icon': Icons.local_hospital},
  {'label': 'JEE', 'icon': Icons.check_circle},
  {'label': 'GATE', 'icon': Icons.engineering},
  {'label': 'SSC CGL', 'icon': Icons.badge},
  {'label': 'State PSC Exams', 'icon': Icons.account_balance_wallet},
  {'label': 'Teaching Exams', 'icon': Icons.cast_for_education},
  {'label': 'UGC NET', 'icon': Icons.book},
  {'label': 'CTET', 'icon': Icons.menu_book},
  {'label': 'CLAT', 'icon': Icons.balance},
  {'label': 'GMAT', 'icon': Icons.public},
];

final List<Map<String, dynamic>> _otherExams = [
  {'label': 'Bank Exams', 'icon': Icons.account_balance},
  {'label': 'SSC Exams', 'icon': Icons.badge},
  {'label': 'IELTS', 'icon': Icons.language},
  {'label': 'CUET', 'icon': Icons.check_circle},
  {'label': 'IIT JAM', 'icon': Icons.science},
  {'label': 'CSIR NET', 'icon': Icons.science_outlined},
  {'label': 'CA/CS Exams', 'icon': Icons.account_balance_wallet},
  {'label': 'B Com', 'icon': Icons.business_center},
  {'label': 'State Exams', 'icon': Icons.account_balance},
  {'label': 'Judiciary - State PCS J', 'icon': Icons.gavel},
  {'label': 'Railways Exams', 'icon': Icons.train},
  {'label': 'AE & JE Exams', 'icon': Icons.settings},
  {'label': 'Insurance Exams', 'icon': Icons.verified_user},
  {'label': 'Agriculture Exams', 'icon': Icons.agriculture},
  {'label': 'CDS', 'icon': Icons.shield},
  {'label': 'Defence Exams', 'icon': Icons.security},
  {'label': 'Police Exams', 'icon': Icons.local_police},
  {'label': 'Startup Basics', 'icon': Icons.lightbulb},
  {'label': 'GRE', 'icon': Icons.text_snippet},
  {'label': 'International Exams', 'icon': Icons.public},
  {'label': 'Software Development', 'icon': Icons.computer},
  {'label': 'Interview Preparation', 'icon': Icons.question_answer},
];
