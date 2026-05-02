import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

// ─── Status helpers ──────────────────────────────────────────────────────────

Color _statusColor(String status) {
  switch (status.toLowerCase()) {
    case 'rescued':
    case 'solved':
      return const Color(0xFF2E7D32); // deep green
    case 'undercare':
    case 'pending':
      return const Color(0xFFE65100); // deep orange
    case 'needs help':
    case 'missing':
    default:
      return const Color(0xFFC62828); // deep red
  }
}

String _statusLabel(String status) {
  switch (status.toLowerCase()) {
    case 'solved':
      return 'Rescued';
    case 'pending':
      return 'Undercare';
    case 'missing':
      return 'Needs Help';
    default:
      // capitalise first letter
      return status.isNotEmpty
          ? status[0].toUpperCase() + status.substring(1)
          : 'Unknown';
  }
}

// ─── Screen ──────────────────────────────────────────────────────────────────

class MyReportScreen extends StatelessWidget {
  static const String routeName = '/myReportScreen';
  const MyReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: uid == null
                ? const Center(child: Text('Please log in to view reports.'))
                : StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('scans')
                        .where('userId', isEqualTo: uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF4A148C),
                          ),
                        );
                      }
                      if (snapshot.hasError) {
                        return Center(
                          child: Text('Error: ${snapshot.error}'),
                        );
                      }
                      final docs = [...?snapshot.data?.docs];
                      if (docs.isEmpty) {
                        return _buildEmptyState();
                      }
                      // Sort newest first in Dart so we don't need a
                      // composite Firestore index.
                      docs.sort((a, b) {
                        final ta = (a.data() as Map<String, dynamic>)['timestamp']
                            as Timestamp?;
                        final tb = (b.data() as Map<String, dynamic>)['timestamp']
                            as Timestamp?;
                        if (ta == null && tb == null) return 0;
                        if (ta == null) return 1;
                        if (tb == null) return -1;
                        return tb.compareTo(ta);
                      });
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final data =
                              docs[index].data() as Map<String, dynamic>;
                          return _ReportCard(data: data);
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
        top: MediaQuery.of(context).padding.top + 10,
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          Material(
            color: Colors.white,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => Navigator.of(context).maybePop(),
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(Icons.arrow_back, color: Color(0xFF4A148C)),
              ),
            ),
          ),
          const Text(
            'My Reports',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const Icon(Icons.pets, color: Colors.white70, size: 28),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.assignment_outlined, size: 72, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No reports yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your submitted reports will appear here.',
            style: TextStyle(fontSize: 13, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}

// ─── Card ─────────────────────────────────────────────────────────────────────

class _ReportCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const _ReportCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final status = (data['status'] as String?) ?? 'pending';
    final imageUrl = (data['imageUrl'] as String?) ?? '';
    final address = (data['address'] as String?) ?? '';

    final analysis = (data['analysis'] is Map)
        ? Map<String, dynamic>.from(data['analysis'] as Map)
        : const <String, dynamic>{};
    final disease = (analysis['disease'] as String?) ?? '';
    final mood = (analysis['mood'] as String?) ?? '';
    final isDog = analysis['isDog'] == true;

    final timestamp = (data['timestamp'] as Timestamp?)?.toDate();
    final dateStr = timestamp != null
        ? DateFormat('d/M/yyyy').format(timestamp)
        : '—';

    final color = _statusColor(status);
    final label = _statusLabel(status);

    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ── Main card ──
          Container(
            margin: const EdgeInsets.only(top: 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.07),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dog image (full-width hero)
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          width: double.infinity,
                          height: 180,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            height: 180,
                            color: Colors.grey[200],
                            child: const Center(
                                child: CircularProgressIndicator()),
                          ),
                          errorWidget: (_, __, ___) => _dogPlaceholder(),
                        )
                      : _dogPlaceholder(),
                ),
                // ── Info section ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isDog && (disease.isNotEmpty || mood.isNotEmpty))
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            if (disease.isNotEmpty)
                              _MetaChip(
                                icon: Icons.healing,
                                label: disease,
                                color: const Color(0xFF4A148C),
                              ),
                            if (mood.isNotEmpty)
                              _MetaChip(
                                icon: Icons.mood,
                                label: mood,
                                color: const Color(0xFFE65100),
                              ),
                          ],
                        ),
                      if (isDog && (disease.isNotEmpty || mood.isNotEmpty))
                        const SizedBox(height: 8),
                      if (address.isNotEmpty)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.location_on_outlined,
                                size: 16, color: Color(0xFF7B1FA2)),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                address,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF333333),
                                  height: 1.4,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        )
                      else
                        const Text(
                          'No address recorded.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Date label (top-left) ──
          Positioned(
            top: 2,
            left: 8,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                dateStr,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
            ),
          ),

          // ── Status badge (top-right) ──
          Positioned(
            top: 2,
            right: 8,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dogPlaceholder() {
    return Container(
      height: 180,
      color: const Color(0xFFEDE7F6),
      child: const Center(
        child: Icon(Icons.pets, color: Color(0xFF7B1FA2), size: 60),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _MetaChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
