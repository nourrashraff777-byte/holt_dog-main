import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:holt_dog/features/user_side/user_home/screens/custom_drawer.dart';
import 'package:holt_dog/features/insurance_side/widgets/insurance_quick_actions_widgets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_styles.dart';

class InsuranceHomeScreen extends StatefulWidget {
  static const String routeName = '/insuranceHome';
  const InsuranceHomeScreen({super.key});

  @override
  State<InsuranceHomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<InsuranceHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(),
      backgroundColor: Colors.white,
      body: const _InsuranceHomeBody(),
      bottomNavigationBar: _InsuranceNavBarSimple(),
    );
  }
}

// ─── Simple nav bar with only Home visible ───────────────────────────────────

class _InsuranceNavBarSimple extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80.h,
      decoration: BoxDecoration(
        color: AppColors.primaryPurple,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurple.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Icon(Icons.home,
                  color: AppColors.primaryPurple, size: 28.w),
            ),
            SizedBox(height: 4.h),
            Text(
              'Home',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Insurance home body — streams from 'scans' ───────────────────────────────

class _InsuranceHomeBody extends StatelessWidget {
  const _InsuranceHomeBody();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('scans')
          .orderBy('timestamp', descending: true)
          .limit(20)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF4A148C)),
          );
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final docs = snapshot.data?.docs ?? [];

        return SingleChildScrollView(
          child: Column(
            children: [
              const InsuranceQuickActionHeader(userName: '', showSearch: true),
              if (docs.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 60.h),
                  child: Column(
                    children: [
                      Icon(Icons.pets, size: 64.w, color: Colors.grey[400]),
                      SizedBox(height: 12.h),
                      Text(
                        'No results found',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: docs.length,
                    itemBuilder: (context, i) {
                      final data = docs[i].data() as Map<String, dynamic>;
                      return _ResultCard(data: data, docId: docs[i].id);
                    },
                  ),
                ),
              SizedBox(height: 100.h),
            ],
          ),
        );
      },
    );
  }
}

// ─── Result Card — displays detailed analysis ─────────────────────────────────

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
    final reporterId = (data['userId'] ?? data['reporterId'])?.toString() ?? '';

    return Container(
      margin: EdgeInsets.only(bottom: 16.h, top: 4.h),
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

            // ── Uploaded by section (Insurance specific) ──────────────────────
            if (reporterId.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'Uploaded By',
                style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF666666),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4),
              ),
              const SizedBox(height: 8),
              _UploadedByCard(userId: reporterId, dateStr: dateStr),
              const SizedBox(height: 14),
            ],

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

// ─── "Uploaded By" card — shows user details with name, email, and upload date ─────────

class _UploadedByCard extends StatelessWidget {
  final String userId;
  final String dateStr;
  const _UploadedByCard({required this.userId, required this.dateStr});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return Container(
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
          );
        }

        String name = '';
        String email = '';
        if (snap.hasData && snap.data!.exists) {
          final data = snap.data!.data() as Map<String, dynamic>? ?? {};
          name = (data['displayName'] ??
                  data['name'] ??
                  data['username'] ??
                  '')
              .toString()
              .trim();
          email = (data['email'] ?? '').toString().trim();
        }

        if (name.isEmpty) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF3E5F5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFE1BEE7),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryPurple.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.account_circle_outlined,
                  size: 24,
                  color: Color(0xFF4A148C),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF3A3A3A),
                        fontWeight: FontWeight.w800,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Uploaded: $dateStr',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
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
