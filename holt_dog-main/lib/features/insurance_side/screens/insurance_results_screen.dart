import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:holt_dog/core/widgets/app_drawer.dart';
import 'package:intl/intl.dart';
import 'package:holt_dog/features/insurance_side/widgets/insurance_quick_actions_widgets.dart';
import '../models/report_model.dart';

class InsuranceResultsScreen extends StatelessWidget {
  const InsuranceResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('scans')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF4A148C)),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red)),
            );
          }

          final docs = snapshot.data?.docs ?? [];
          final reports = docs.map((d) => Report.fromFirestore(d)).toList();

          return SingleChildScrollView(
            child: Column(
              children: [
                const InsuranceQuickActionHeader(
                    userName: '', showSearch: true),
                if (reports.isEmpty) ...[
                  const SizedBox(height: 60),
                  Icon(Icons.pets, size: 72, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text('No reports found',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[500])),
                ] else
                  ...reports.map((r) => _InsuranceReportCard(report: r)),
                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── Card matching the screenshot ─────────────────────────────────────────────

class _InsuranceReportCard extends StatelessWidget {
  final Report report;
  const _InsuranceReportCard({required this.report});

  Color _confidenceColor(int c) =>
      c >= 90 ? Colors.green : c >= 75 ? Colors.orange : Colors.red;

  @override
  Widget build(BuildContext context) {
    final conf = report.diseaseConfidence;
    final confColor = _confidenceColor(conf);
    final dateStr = report.timestamp != null
        ? DateFormat('yyyy-MM-dd  hh:mm a').format(report.timestamp!)
        : '—';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
            // ── "Result" header row ──────────────────────────────────────
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.analytics_outlined,
                      color: Colors.deepPurple, size: 22),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Result',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
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
                        color: Colors.green, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ── "Uploaded By" section ────────────────────────────────────
            _sectionLabel('Uploaded By'),
            Container(
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
                    child: const Icon(Icons.person_outline,
                        color: Colors.deepPurple),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // if (report.uploaderName.isNotEmpty)
                        //   Text(
                        //     report.uploaderName,
                        //     style: const TextStyle(
                        //         fontWeight: FontWeight.w700,
                        //         color: Color(0xFF2F2F2F)),
                        //   ),
                        // if (report.uploaderEmail.isNotEmpty)
                        //   Text(
                        //     report.uploaderEmail,
                        //     style: const TextStyle(
                        //         color: Color(0xFF616161), fontSize: 12),
                        //   ),
                        Text(
                          'Uploaded: $dateStr',
                          style: const TextStyle(
                              color: Color(0xFF7A7A7A),
                              fontSize: 12,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── "Dog & Analysis" section ─────────────────────────────────
            _sectionLabel('Dog & Analysis'),
            _infoRow(
              report.location.isNotEmpty ? report.location : '—',
              'Location',
              Icons.location_on_outlined,
            ),
            _infoRow(
              report.predictedMood.isNotEmpty ? report.predictedMood : '—',
              'Dog Mood',
              Icons.mood_outlined,
            ),
            _infoRow(
              report.predictedDisease.isNotEmpty
                  ? report.predictedDisease
                  : '—',
              'Skin Condition',
              Icons.health_and_safety_outlined,
            ),
            if (conf > 0)
              _infoRow(
                '$conf%',
                'Confidence',
                Icons.check_circle_outline,
                valueColor: confColor,
              ),

            const SizedBox(height: 14),

            // ── Status update buttons ────────────────────────────────────
            _StatusButtons(docId: report.id, current: report.status.name),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF666666),
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4)),
      );

  Widget _infoRow(String value, String label, IconData icon,
      {Color valueColor = Colors.black87}) {
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
                Text(label,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF3A3A3A))),
                const SizedBox(height: 4),
                Text(value,
                    style: TextStyle(
                        fontSize: 15,
                        color: valueColor,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Status toggle buttons ────────────────────────────────────────────────────

class _StatusButtons extends StatelessWidget {
  final String docId;
  final String current;
  const _StatusButtons({required this.docId, required this.current});

  Future<void> _set(String s) => FirebaseFirestore.instance
      .collection('scans')
      .doc(docId)
      .update({'status': s});

  String _canonical(String s) {
    switch (s.toLowerCase().trim()) {
      case 'solved':
      case 'rescued':
        return 'solved';
      case 'pending':
      case 'undercare':
        return 'pending';
      case 'missing':
      case 'need help':
      case 'needs help':
        return 'missing';
      default:
        return s.toLowerCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    const opts = [
      ('missing', 'Needs Help', Color(0xFFC62828)),
      ('pending', 'Undercare', Color(0xFFE65100)),
      ('solved', 'Rescued', Color(0xFF2E7D32)),
    ];
    final canonicalCurrent = _canonical(current);
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: opts.map(((String, String, Color) o) {
        final active = canonicalCurrent == o.$1;
        return GestureDetector(
          onTap: active ? null : () => _set(o.$1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: active ? o.$3 : o.$3.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: o.$3, width: active ? 0 : 1),
            ),
            child: Text(o.$2,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: active ? Colors.white : o.$3)),
          ),
        );
      }).toList(),
    );
  }
}
