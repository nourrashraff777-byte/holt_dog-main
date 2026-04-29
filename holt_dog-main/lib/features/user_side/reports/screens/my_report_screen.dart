import 'package:flutter/material.dart';

// Data model for reports
class Report {
  final String date;
  final String status;
  final Color statusColor;
  final String description;
  final String imageUrl;

  Report({
    required this.date,
    required this.status,
    required this.statusColor,
    required this.description,
    required this.imageUrl,
  });
}

// Main screen widget
class MyReportScreen extends StatelessWidget {
  static const String routeName = '/myReportScreen';
  const MyReportScreen({super.key});

  // Sample reports data
  List<Report> get reports => [
        Report(
          date: '1/1/2026',
          status: 'Pending',
          statusColor: Colors.red.shade600,
          description:
              'Hit by a car. Possible fractures and internal injuries. Needs emergency care.',
          imageUrl: 'https://via.placeholder.com/150',
        ),
        Report(
          date: '24/4/2026',
          status: 'Rescued',
          statusColor: Colors.green.shade500,
          description: 'Recovered from malnutrition. Now healthy and active.',
          imageUrl: 'https://via.placeholder.com/150',
        ),
        Report(
          date: '1/2/2026',
          status: 'Undercare',
          statusColor: Colors.orange.shade400,
          description:
              'Recovering from eye infection. Under medication and observation.',
          imageUrl: 'https://via.placeholder.com/150',
        ),
        Report(
          date: '23/3/2026',
          status: 'Pending',
          statusColor: Colors.red.shade600,
          description:
              'Severe dehydration and exhaustion. Needs fluids and immediate support.',
          imageUrl: 'https://via.placeholder.com/150',
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildCustomHeader(context),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: reports.length,
              itemBuilder: (context, index) {
                final report = reports[index];
                return ReportItemCard(report: report);
              },
            ),
          ),
        ],
      ),
    );
  }

  // Custom purple header
  Widget _buildCustomHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        bottom: 20,
        left: 20,
        right: 20,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF4A148C),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(15),
          bottomRight: Radius.circular(15),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF4A148C)),
              tooltip: 'Go back',
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ),
          // Title
          const Text(
            'My Reports',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          // Document icon
          IconButton(
            icon: const Icon(Icons.edit_document, color: Colors.white, size: 28),
            tooltip: 'Add new report',
            onPressed: () {
              // Add new report logic here
            },
          ),
        ],
      ),
    );
  }
}

// Reusable widget for each report card
class ReportItemCard extends StatelessWidget {
  final Report report;

  const ReportItemCard({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30.0),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background card
          Container(
            margin: const EdgeInsets.only(top: 15),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE6E6E6),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade400, width: 1),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  offset: Offset(2, 4),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    report.imageUrl,
                    width: 70,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 70,
                      height: 60,
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.image, color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                // Description text
                Expanded(
                  child: Text(
                    report.description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black87,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Date (top left)
          Positioned(
            top: -5,
            left: 5,
            child: Text(
              report.date,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black54,
                fontSize: 13,
              ),
            ),
          ),
          // Status badge (top right)
          Positioned(
            top: 2,
            right: 15,
            child: Chip(
              label: Text(
                report.status,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              backgroundColor: report.statusColor,
              elevation: 4,
            ),
          ),
        ],
      ),
    );
  }
}
