import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:holt_dog/core/services/location_service.dart';
import 'package:holt_dog/core/widgets/app_drawer.dart';
import 'package:holt_dog/features/auth/cubit/auth_cubit.dart';
import 'package:holt_dog/features/auth/cubit/auth_state.dart';
import 'package:holt_dog/features/auth/models/user_model.dart';
import 'package:holt_dog/features/insurance_side/widgets/insurance_quick_actions_widgets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';

class InsuranceHomeScreen extends StatefulWidget {
  static const String routeName = '/insuranceHome';
  const InsuranceHomeScreen({super.key});

  @override
  State<InsuranceHomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<InsuranceHomeScreen> {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<AuthCubit>().state;
    final UserModel? user = state is Authenticated ? state.user : null;

    return Scaffold(
      drawer: user != null ? AppDrawer(user: user) : const Drawer(),
      backgroundColor: Colors.white,
      body: _InsuranceHomeBody(userName: user?.name ?? ''),
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
              child:
                  Icon(Icons.home, color: AppColors.primaryPurple, size: 28.w),
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
  final String userName;

  const _InsuranceHomeBody({this.userName = ''});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('scans')
          .orderBy('timestamp', descending: true)
          .limit(250)
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
              InsuranceQuickActionHeader(userName: userName, showSearch: true),
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
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  child: _CityAggregatesList(docs: docs),
                ),
              SizedBox(height: 100.h),
            ],
          ),
        );
      },
    );
  }
}

// ─── City-level aggregates ───────────────────────────────────────────────────

(double, double)? _tryLonLatPair(String s) {
  final parts = s.split(',');
  if (parts.length < 2) return null;
  final lat = LocationService.parseCoord(parts[0].trim());
  final lng = LocationService.parseCoord(parts[1].trim());
  if (lat == null || lng == null) return null;
  if (lat.abs() > 90 || lng.abs() > 180) return null;
  return (lat, lng);
}

String _guessCityLabelFromAddress(String raw) {
  final parts =
      raw.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
  if (parts.isEmpty) return '';
  if (parts.length == 1) return parts.single;
  final last = parts.last.toLowerCase();
  if ((last == 'egypt' || last == 'eg') && parts.length >= 2) {
    return parts[parts.length - 2];
  }
  return parts.length >= 2 ? parts[parts.length - 2] : parts.last;
}

/// True when AI skin / disease prediction suggests attention (not “healthy”).
bool _dogLooksIll(Map<String, dynamic> data) {
  final analysis = (data['analysis'] is Map)
      ? Map<String, dynamic>.from(data['analysis'] as Map)
      : <String, dynamic>{};
  final disease =
      (analysis['disease'] ?? data['predictedDisease'] ?? '').toString().trim();
  final lc = disease.toLowerCase();
  if (lc.isEmpty || lc == '-' || lc == 'none' || lc == 'unknown') {
    return false;
  }
  if (lc.contains('healthy') ||
      lc == 'normal' ||
      lc.contains('no disease') ||
      lc.contains('no skin')) {
    return false;
  }
  return disease.isNotEmpty;
}

class _GroupedScanBucket {
  final String key;
  final GeoPoint? geo;

  /// Human hint when grouping by address row (shown before geo resolves).
  final String labelHint;

  const _GroupedScanBucket({
    required this.key,
    this.geo,
    this.labelHint = '',
  });
}

_GroupedScanBucket _bucketForScan(Map<String, dynamic> data) {
  final rawAddress = (data['address'] as String?)?.trim() ?? '';

  if (data['location'] is GeoPoint) {
    final g = data['location'] as GeoPoint;
    final latKey = g.latitude.toStringAsFixed(3);
    final lngKey = g.longitude.toStringAsFixed(3);
    final hint =
        rawAddress.isNotEmpty ? _guessCityLabelFromAddress(rawAddress) : '';
    return _GroupedScanBucket(
        key: 'g|$latKey|$lngKey', geo: g, labelHint: hint);
  }

  String locStr = '';
  if (data['location'] is String) {
    locStr = (data['location'] as String).trim();
  } else if (rawAddress.isNotEmpty && _tryLonLatPair(rawAddress) != null) {
    locStr = rawAddress;
  }

  final coordPair =
      locStr.isNotEmpty ? _tryLonLatPair(locStr) : _tryLonLatPair(rawAddress);
  if (coordPair != null) {
    final lat = coordPair.$1;
    final lng = coordPair.$2;
    return _GroupedScanBucket(
      key: 'g|${lat.toStringAsFixed(3)}|${lng.toStringAsFixed(3)}',
      geo: GeoPoint(lat, lng),
      labelHint:
          rawAddress.isNotEmpty ? _guessCityLabelFromAddress(rawAddress) : '',
    );
  }

  if (rawAddress.isNotEmpty) {
    final lbl = _guessCityLabelFromAddress(rawAddress).toLowerCase();
    final k = lbl.isEmpty ? 'a|${_hashStable(rawAddress)}' : 'a|$lbl';
    return _GroupedScanBucket(
      key: k,
      geo: null,
      labelHint: _guessCityLabelFromAddress(rawAddress),
    );
  }

  return const _GroupedScanBucket(
      key: 'z|unknown', labelHint: 'Unknown location');
}

int _hashStable(String s) {
  var h = 0;
  for (final cu in s.codeUnits) {
    h = (h * 31 + cu) & 0x7fffffff;
  }
  return h;
}

class _CityAggStats {
  GeoPoint? repGeo;
  String labelHint = '';
  int goodDogs = 0;
  int illDogs = 0;
  final LinkedHashSet<String> uploaderIds = LinkedHashSet<String>();

  void absorbReporter(String? uid) {
    final u = uid?.trim() ?? '';
    if (u.isNotEmpty) uploaderIds.add(u);
  }

  int get scans => goodDogs + illDogs;
}

class _CityAggregatesList extends StatelessWidget {
  final List<QueryDocumentSnapshot> docs;

  const _CityAggregatesList({required this.docs});

  @override
  Widget build(BuildContext context) {
    final aggs = <String, _CityAggStats>{};
    for (final doc in docs) {
      final raw = doc.data();
      final data = raw is Map<String, dynamic> ? raw : <String, dynamic>{};
      final bucket = _bucketForScan(data);
      final row = aggs.putIfAbsent(bucket.key, () => _CityAggStats());

      row.repGeo ??= bucket.geo;
      if (bucket.labelHint.isNotEmpty &&
          bucket.labelHint.length > row.labelHint.length) {
        row.labelHint = bucket.labelHint;
      }

      if (_dogLooksIll(data)) {
        row.illDogs += 1;
      } else {
        row.goodDogs += 1;
      }

      row.absorbReporter((data['userId'] ?? data['reporterId'])?.toString());
    }

    final sortedKeys = aggs.keys.toList()
      ..sort((a, b) => aggs[b]!.scans.compareTo(aggs[a]!.scans));

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sortedKeys.length,
      itemBuilder: (context, index) {
        final k = sortedKeys[index];
        return Padding(
          padding: EdgeInsets.only(bottom: 14.h),
          child: _CityOverviewCard(stats: aggs[k]!),
        );
      },
    );
  }
}

class _CityOverviewCard extends StatelessWidget {
  final _CityAggStats stats;

  const _CityOverviewCard({required this.stats});

  Widget _titleText() {
    final g = stats.repGeo;
    final hint =
        stats.labelHint.isNotEmpty ? stats.labelHint : 'Unknown location';

    if (g != null) {
      return FutureBuilder<String>(
        future: LocationService.getCityName(g.latitude, g.longitude),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return Text(
              hint == 'Unknown location' ? 'Looking up city…' : hint,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            );
          }
          if (snap.hasData && snap.data!.isNotEmpty) {
            return Text(
              snap.data!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            );
          }
          return Text(hint, maxLines: 2, overflow: TextOverflow.ellipsis);
        },
      );
    }
    return Text(
      hint,
      style: AppTypography.bodyLarge.copyWith(
        fontWeight: FontWeight.w800,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18.r),
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
        padding: EdgeInsets.all(14.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: AppColors.primaryPurple.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.location_city_rounded,
                      color: AppColors.primaryPurple, size: 24.w),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'City / area',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textHint,
                          letterSpacing: 0.3,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      DefaultTextStyle(
                        style: AppTypography.bodyLarge.copyWith(
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        child: stats.repGeo != null
                            ? _titleText()
                            : Text(
                                stats.labelHint.isNotEmpty
                                    ? stats.labelHint
                                    : 'Unknown location',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 14.h),
            Row(
              children: [
                Expanded(
                  child: _pillStat(
                    icon: Icons.pets_rounded,
                    bg: AppColors.statusRescuedBg,
                    fg: AppColors.statusRescued,
                    value: '${stats.goodDogs}',
                    label: 'Good dogs\n(healthy scans)',
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: _pillStat(
                    icon: Icons.monitor_heart_outlined,
                    bg: AppColors.statusNeedsHelpBg,
                    fg: AppColors.statusNeedsHelp,
                    value: '${stats.illDogs}',
                    label: 'Ill dogs\n(needs attention)',
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Text(
              '${stats.scans} scans · ${stats.uploaderIds.length} uploaders',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              'Uploaders',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 8.h),
            _UploaderChips(ids: stats.uploaderIds.toList()),
          ],
        ),
      ),
    );
  }

  Widget _pillStat({
    required IconData icon,
    required Color bg,
    required Color fg,
    required String value,
    required String label,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: fg.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
                color: bg, borderRadius: BorderRadius.circular(10.r)),
            child: Icon(icon, color: fg, size: 22.w),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w900,
                    color: fg,
                    height: 1,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    height: 1.15,
                    color: AppColors.textSecondary,
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

Future<List<(String display, String subtitle)>> _loadUploaderSummary(
    List<String> ids) async {
  final out = <(String display, String subtitle)>[];
  for (final id in ids) {
    try {
      final snap =
          await FirebaseFirestore.instance.collection('users').doc(id).get();
      if (!snap.exists) {
        continue;
      }
      final m = snap.data() ?? {};
      final name = (m['displayName'] ?? m['name'] ?? m['username'] ?? '')
          .toString()
          .trim();
      final email = (m['email'] ?? '').toString().trim();
      if (name.isEmpty && email.isEmpty) {
        continue;
      }
      out.add((
        name.isNotEmpty ? name : email,
        name.isNotEmpty ? email : 'User #$id'
      ));
    } catch (_) {
      continue;
    }
  }
  out.sort((a, b) => a.$1.toLowerCase().compareTo(b.$1.toLowerCase()));
  return out;
}

class _UploaderChips extends StatelessWidget {
  final List<String> ids;

  const _UploaderChips({required this.ids});

  @override
  Widget build(BuildContext context) {
    if (ids.isEmpty) {
      return Text(
        'No linked user IDs on these scans.',
        style: TextStyle(fontSize: 12.sp, color: AppColors.textHint),
      );
    }

    return FutureBuilder<List<(String display, String subtitle)>>(
      future: _loadUploaderSummary(ids),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: 36.h,
            child: Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                height: 22.h,
                width: 22.h,
                child: const CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }
        final rows = snapshot.data ?? [];
        if (rows.isEmpty) {
          return Text(
            '${ids.length} contributor(s) — profiles not found',
            style: TextStyle(fontSize: 12.sp, color: AppColors.textHint),
          );
        }
        return Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: rows.map((row) {
            final (displayName, subtitle) = row;
            final t = displayName.trim();
            final initial = t.isEmpty ? '?' : t.substring(0, 1).toUpperCase();
            return Chip(
              avatar: CircleAvatar(
                backgroundColor: AppColors.primaryPurple.withValues(alpha: 0.2),
                foregroundColor: AppColors.primaryPurple,
                child: Text(
                  initial,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              label: SizedBox(
                width: 130.w,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      displayName,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle.isNotEmpty)
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              visualDensity: VisualDensity.compact,
              shape:
                  StadiumBorder(side: BorderSide(color: Colors.grey.shade300)),
              padding: EdgeInsets.only(left: 2.w),
            );
          }).toList(),
        );
      },
    );
  }
}
