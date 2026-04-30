import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/services/location_service.dart';
import '../models/vet_model.dart';
import '../widgets/user_quick_actions_widgets.dart';

class VetsScreen extends StatefulWidget {
  const VetsScreen({super.key});

  @override
  State<VetsScreen> createState() => _VetsScreenState();
}

class _VetsScreenState extends State<VetsScreen> {
  String _cityName = 'Detecting location…';
  bool _locationGranted = false;
  bool _loadingLocation = true;

  List<Vet> _vets = [];
  bool _loadingVets = true;
  String? _vetsError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchLocation();
      _fetchVets();
    });
  }

  Future<void> _fetchVets() async {
    if (!mounted) return;
    setState(() {
      _loadingVets = true;
      _vetsError = null;
    });

    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('vets').get();

      final vets = snapshot.docs.map((doc) {
        return Vet.fromMap(doc.data(), doc.id);
      }).toList();

      if (!mounted) return;
      setState(() {
        _vets = vets;
        _loadingVets = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _vetsError = 'Failed to load vets: $e';
        _loadingVets = false;
      });
    }
  }

  Future<void> _fetchLocation() async {
    setState(() {
      _loadingLocation = true;
      _cityName = 'Detecting location…';
    });

    final position = await LocationService.getLocationWithPermission();

    if (!mounted) return;

    if (position == null) {
      setState(() {
        _locationGranted = false;
        _loadingLocation = false;
        _cityName = 'Location unavailable';
      });
      return;
    }

    setState(() {
      _locationGranted = true;
    });

    final city =
        await LocationService.getCityName(position.latitude, position.longitude);

    if (!mounted) return;
    setState(() {
      _cityName = city;
      _loadingLocation = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const UserQuickActionHeader(
            userName: '',
            showSearch: false,
            showBackButton: true,
            title: 'Nearby Veterinarians',
            subtitle: 'get fast veterinary assistance',
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await Future.wait([_fetchLocation(), _fetchVets()]);
              },
              color: AppColors.primaryMagenta,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(20.w),
                child: Column(
                  children: [
                    _LocationInfoCard(
                      cityName: _cityName,
                      isLoading: _loadingLocation,
                      isGranted: _locationGranted,
                      onRetry: _fetchLocation,
                    ),
                    SizedBox(height: 20.h),
                    if (_loadingVets)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 40.h),
                        child: Center(
                          child: CircularProgressIndicator(
                              color: AppColors.primaryMagenta),
                        ),
                      )
                    else if (_vetsError != null)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 40.h),
                        child: Center(
                          child: Text(
                            _vetsError!,
                            style: AppTypography.caption
                                .copyWith(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    else if (_vets.isEmpty)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 40.h),
                        child: Center(
                          child: Text(
                            'No vets found.',
                            style: AppTypography.caption
                                .copyWith(color: AppColors.textSecondary),
                          ),
                        ),
                      )
                    else
                      ..._vets.map((vet) => _VetCard(vet: vet)),
                    SizedBox(height: 100.h),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Location info card
// ─────────────────────────────────────────────────────────────────────────────

class _LocationInfoCard extends StatelessWidget {
  final String cityName;
  final bool isLoading;
  final bool isGranted;
  final VoidCallback onRetry;

  const _LocationInfoCard({
    required this.cityName,
    required this.isLoading,
    required this.isGranted,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: Colors.black.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Status icon
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: _iconBgColor,
              shape: BoxShape.circle,
            ),
            child: isLoading
                ? SizedBox(
                    width: 16.w,
                    height: 16.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Icon(
                    isGranted ? Icons.check : Icons.location_off,
                    color: Colors.white,
                    size: 16.w,
                  ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cityName,
                  style: AppTypography.h3.copyWith(fontSize: 16.sp),
                ),
                SizedBox(height: 4.h),
                Text(
                  isGranted
                      ? 'Your location has been detected. Showing nearby vets.'
                      : 'Location permission denied. Tap retry to enable.',
                  style: AppTypography.caption
                      .copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          if (!isGranted && !isLoading)
            IconButton(
              onPressed: onRetry,
              icon: Icon(Icons.refresh, color: AppColors.primaryMagenta),
            ),
        ],
      ),
    );
  }

  Color get _iconBgColor {
    if (isLoading) return Colors.blue;
    return isGranted ? Colors.green : Colors.red;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Vet card
// ─────────────────────────────────────────────────────────────────────────────

class _VetCard extends StatelessWidget {
  final Vet vet;
  const _VetCard({required this.vet});

  @override
  Widget build(BuildContext context) {
    final bool isAvailable = vet.status == VetStatus.available;
    final Color statusColor = isAvailable ? Colors.green : Colors.red;

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
        border:
            Border.all(color: statusColor.withValues(alpha: 0.8), width: 1.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vet.name,
                  style: GoogleFonts.inter(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Icon(Icons.room, color: AppColors.textHint, size: 14.w),
                    SizedBox(width: 4.w),
                    Text(vet.address, style: AppTypography.caption),
                  ],
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(Icons.check_circle_outline,
                        color: statusColor, size: 14.w),
                    SizedBox(width: 4.w),
                    Text(
                      isAvailable ? 'Available' : 'Closed',
                      style: AppTypography.caption.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  vet.phone,
                  style: AppTypography.bodySmall
                      .copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: statusColor.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(Icons.phone_in_talk, color: Colors.white, size: 28.w),
          ),
        ],
      ),
    );
  }
}
