import 'package:flutter/material.dart';
import 'package:holt_dog/features/insurance_side/widgets/insurance_quick_actions_widgets.dart';
import 'package:holt_dog/features/user_side/user_home/screens/custom_drawer.dart';

class InsuranceResultModel {
  final String uploadedBy;
  final String userEmail;
  final String uploadDate;
  final String location;
  final String predictedMood;
  final String predictedDisease;
  final int diseaseConfidence;

  const InsuranceResultModel({
    required this.uploadedBy,
    required this.userEmail,
    required this.uploadDate,
    required this.location,
    required this.predictedMood,
    required this.predictedDisease,
    required this.diseaseConfidence,
  });
}

class InsuranceResultsScreen extends StatelessWidget {
  const InsuranceResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<InsuranceResultModel> results = [
      const InsuranceResultModel(
        uploadedBy: 'Ahmed Samir',
        userEmail: 'ahmed.samir@gmail.com',
        uploadDate: '2026-04-18 09:30 AM',
        location: 'Maadi, Cairo',
        predictedMood: 'Happy',
        predictedDisease: 'None',
        diseaseConfidence: 96,
      ),
      const InsuranceResultModel(
        uploadedBy: 'Mona Adel',
        userEmail: 'mona.adel@yahoo.com',
        uploadDate: '2026-04-17 04:10 PM',
        location: 'Dokki, Giza',
        predictedMood: 'Calm',
        predictedDisease: 'Mild Dermatitis',
        diseaseConfidence: 88,
      ),
      const InsuranceResultModel(
        uploadedBy: 'Youssef Nabil',
        userEmail: 'youssef.nabil@outlook.com',
        uploadDate: '2026-04-16 11:05 AM',
        location: 'Heliopolis, Cairo',
        predictedMood: 'Anxious',
        predictedDisease: 'Fungal Infection',
        diseaseConfidence: 91,
      ),
    ];

    return Scaffold(
      // appBar: AppBar(title: const Text("Analysis Results")),
      drawer: const CustomDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const InsuranceQuickActionHeader(userName: '', showSearch: true),
            ...results.map((result) => _buildResultItemCard(result)),
          ],
        ),
      ),
    );
  }

  Widget _buildResultItemCard(InsuranceResultModel result) {
    final confidenceValue = result.diseaseConfidence;
    final confidenceColor = confidenceValue >= 90
        ? Colors.green
        : confidenceValue >= 75
            ? Colors.orange
            : Colors.red;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFFFFFFFF), Color(0xFFF7F8FC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.analytics_outlined,
                    color: Colors.deepPurple,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Result',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text(
                    'Analyzed',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildSectionTitle('Uploaded By'),
            _buildUploaderSection(
              name: result.uploadedBy,
              email: result.userEmail,
              date: result.uploadDate,
            ),
            const SizedBox(height: 10),
            _buildSectionTitle('Dog & Analysis'),
            _buildResultCard(
              "Location",
              result.location,
              Icons.location_on_outlined,
            ),
            _buildResultCard(
              "Dog Mood",
              result.predictedMood,
              Icons.mood_outlined,
            ),
            _buildResultCard(
              "Skin Condition",
              result.predictedDisease,
              Icons.health_and_safety_outlined,
            ),
            _buildResultCard(
              "Confidence",
              "${result.diseaseConfidence}%",
              Icons.check_circle_outline,
              valueColor: confidenceColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          color: Color(0xFF666666),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildUploaderSection({
    required String name,
    required String email,
    required String date,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F1FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5D7F6)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFFEEE0FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_outline,
              color: Colors.deepPurple,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2F2F2F),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  style: const TextStyle(
                    color: Color(0xFF616161),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Uploaded: $date',
                  style: const TextStyle(
                    color: Color(0xFF7A7A7A),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(
    String title,
    String value,
    IconData icon, {
    Color valueColor = Colors.black87,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE9ECF3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.deepOrange, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF3A3A3A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    color: valueColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
