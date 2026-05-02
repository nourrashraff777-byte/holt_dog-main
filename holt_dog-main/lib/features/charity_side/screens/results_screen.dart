import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

// Shared Results screen used by both Doctor tab and Charity tab.
// Same card design as Insurance but WITHOUT the "Uploaded By" section.

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('scans')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child:
                        CircularProgressIndicator(color: Color(0xFF4A148C)),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red)),
                  );
                }

                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return _buildEmpty();
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  itemCount: docs.length,
                  itemBuilder: (context, i) {
                    final data =
                        docs[i].data() as Map<String, dynamic>;
                    return _ResultCard(data: data, docId: docs[i].id);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        bottom: 20,
        left: 20,
        right: 20,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4A148C), Color(0xFF7B1FA2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.assignment_outlined,
              color: Colors.white70, size: 26),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Report Results',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('scans')
                .snapshots(),
            builder: (_, snap) {
              final count = snap.data?.docs.length ?? 0;
              return Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$count reports',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.pets, size: 72, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('No reports yet',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[500])),
          const SizedBox(height: 6),
          Text('Reports from users will appear here.',
              style: TextStyle(fontSize: 13, color: Colors.grey[400])),
        ],
      ),
    );
  }
}

// ─── Card (same layout as insurance, WITHOUT uploader row) ───────────────────

class _ResultCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final String docId;
  const _ResultCard({required this.data, required this.docId});

  String _canonicalStatus(String s) {
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

  Color _statusColor(String s) {
    switch (_canonicalStatus(s)) {
      case 'solved':
        return const Color(0xFF2E7D32);
      case 'pending':
        return const Color(0xFFE65100);
      default:
        return const Color(0xFFC62828);
    }
  }

  String _statusLabel(String s) {
    switch (_canonicalStatus(s)) {
      case 'solved':
        return 'Rescued';
      case 'pending':
        return 'Undercare';
      default:
        return 'Needs Help';
    }
  }

  Color _confColor(int c) =>
      c >= 90 ? Colors.green : c >= 75 ? Colors.orange : Colors.red;

  @override
  Widget build(BuildContext context) {
    final status = (data['status'] as String?) ?? 'Need Help';

    final analysis = (data['analysis'] is Map)
        ? Map<String, dynamic>.from(data['analysis'] as Map)
        : const <String, dynamic>{};

    String location = (data['address'] as String?) ?? '';
    if (location.isEmpty && data['location'] is GeoPoint) {
      final gp = data['location'] as GeoPoint;
      location =
          '${gp.latitude.toStringAsFixed(4)}, ${gp.longitude.toStringAsFixed(4)}';
    }
    if (location.isEmpty && data['location'] is String) {
      location = data['location'] as String;
    }

    final mood = (analysis['mood'] ?? data['predictedMood'])?.toString() ?? '';
    final disease =
        (analysis['disease'] ?? data['predictedDisease'])?.toString() ?? '';
    final conf = ((analysis['diseaseConfidence'] ??
                analysis['confidence'] ??
                data['diseaseConfidence']) as num?)
            ?.toInt() ??
        0;
    final timestamp = (data['timestamp'] as Timestamp?)?.toDate();
    final dateStr = timestamp != null
        ? DateFormat('d MMM yyyy · h:mm a').format(timestamp)
        : '—';

    return Container(
      margin: const EdgeInsets.only(bottom: 16, top: 4),
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
            // ── Header row ───────────────────────────────────────────────
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
                Expanded(
                  child: Text(
                    dateStr,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _statusColor(status).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    _statusLabel(status),
                    style: TextStyle(
                        color: _statusColor(status),
                        fontWeight: FontWeight.w700,
                        fontSize: 12),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // ── "Dog & Analysis" label ───────────────────────────────────
            const Text(
              'Dog & Analysis',
              style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF666666),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4),
            ),

            _row('Location', location.isNotEmpty ? location : '—',
                Icons.location_on_outlined),
            _row('Dog Mood', mood.isNotEmpty ? mood : '—',
                Icons.mood_outlined),
            _row(
                'Skin Condition',
                disease.isNotEmpty ? disease : '—',
                Icons.health_and_safety_outlined),
            if (conf > 0)
              _row('Confidence', '$conf%', Icons.check_circle_outline,
                  valueColor: _confColor(conf)),

            const SizedBox(height: 14),

            // ── Status buttons ───────────────────────────────────────────
            _StatusButtons(docId: docId, current: status),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value, IconData icon,
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

// ─── Shared status toggle buttons ─────────────────────────────────────────────

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
