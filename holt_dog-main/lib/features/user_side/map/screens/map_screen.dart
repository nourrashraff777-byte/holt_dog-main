import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/services/location_service.dart';
import '../../user_home/widgets/user_quick_actions_widgets.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  bool _hasLocationPermission = false;
  bool _loadingLocation = false;

  static const LatLng _defaultCity = LatLng(30.0444, 31.2357); // Cairo
  static const double _defaultZoom = 14;
  LatLng? _currentLocation;
  String _cityName = '';

  // ── Active filter chip index ──────────────────────────────────────────────
  int _selectedFilter = 0;
  final List<String> _filters = ['All', 'Vets', 'Shelters'];

  @override
  void initState() {
    super.initState();
    // Fetch location as soon as the widget is ready – don't wait for
    // onMapReady since that fires before setState is safe on some versions.
    WidgetsBinding.instance.addPostFrameCallback((_) => _initLocation());
  }

  Future<void> _initLocation() async {
    if (!mounted) return;
    setState(() => _loadingLocation = true);

    final position = await LocationService.getLocationWithPermission();

    if (!mounted) return;

    if (position == null) {
      setState(() {
        _hasLocationPermission = false;
        _loadingLocation = false;
      });
      return;
    }

    final userPoint = LatLng(position.latitude, position.longitude);
    final city =
        await LocationService.getCityName(position.latitude, position.longitude);

    if (!mounted) return;
    setState(() {
      _hasLocationPermission = true;
      _currentLocation = userPoint;
      _cityName = city;
      _loadingLocation = false;
    });

    // Move map to user's actual position
    _mapController.move(userPoint, 15);
  }

  Future<void> _goToMyLocation() async {
    if (_loadingLocation) return;

    if (!_hasLocationPermission) {
      await _initLocation();
      return;
    }

    if (_currentLocation != null) {
      _mapController.move(_currentLocation!, 15);
    } else {
      await _initLocation();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const UserQuickActionHeader(userName: '', showSearch: false),
          Expanded(
            child: Stack(
              children: [
                // ── Map ────────────────────────────────────────────────────
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _defaultCity,
                    initialZoom: _defaultZoom,
                    minZoom: 3,
                    maxZoom: 19,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                      subdomains: const ['a', 'b', 'c', 'd'],
                      retinaMode: RetinaMode.isHighDensity(context),
                      userAgentPackageName: 'com.example.holt_dog',
                    ),
                    if (_currentLocation != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _currentLocation!,
                            width: 44.w,
                            height: 44.w,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.primaryMagenta,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryMagenta
                                        .withValues(alpha: 0.4),
                                    blurRadius: 12,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.my_location,
                                color: Colors.white,
                                size: 20.w,
                              ),
                            ),
                          ),
                        ],
                      ),
                    const RichAttributionWidget(
                      showFlutterMapAttribution: false,
                      attributions: [
                        TextSourceAttribution(
                          'OpenStreetMap contributors · CARTO',
                          prependCopyright: false,
                        ),
                      ],
                    ),
                  ],
                ),

                // ── Search + filter bar ────────────────────────────────────
                Positioned(
                  top: 20.h,
                  left: 20.w,
                  right: 20.w,
                  child: Column(
                    children: [
                      _buildSearchBar(),
                      SizedBox(height: 12.h),
                      _buildFilterBar(),
                    ],
                  ),
                ),

                // ── Location status chip ───────────────────────────────────
                if (_cityName.isNotEmpty)
                  Positioned(
                    bottom: 220.h,
                    left: 20.w,
                    right: 20.w,
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 14.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.r),
                          boxShadow: const [
                            BoxShadow(color: Colors.black12, blurRadius: 8),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.location_on,
                                color: Colors.green, size: 16.w),
                            SizedBox(width: 6.w),
                            Text(
                              _cityName,
                              style: AppTypography.bodySmall.copyWith(
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // ── My-location FAB ────────────────────────────────────────
                Positioned(
                  bottom: 200.h,
                  right: 20.w,
                  child: FloatingActionButton.small(
                    heroTag: 'myLocationFab',
                    backgroundColor: Colors.white,
                    elevation: 4,
                    onPressed: _goToMyLocation,
                    child: _loadingLocation
                        ? SizedBox(
                            width: 18.w,
                            height: 18.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primaryMagenta,
                            ),
                          )
                        : Icon(
                            Icons.my_location,
                            color: _hasLocationPermission
                                ? AppColors.primaryMagenta
                                : Colors.grey,
                          ),
                  ),
                ),

                // ── Permission banner ──────────────────────────────────────
                if (!_hasLocationPermission && !_loadingLocation)
                  Positioned(
                    bottom: 200.h,
                    left: 20.w,
                    right: 70.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 14.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12.r),
                        border:
                            Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.location_off,
                              color: Colors.red, size: 18.w),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              'Location permission denied. Tap 🔄 to retry.',
                              style: AppTypography.caption
                                  .copyWith(color: Colors.red.shade700),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // ── Bottom sheet ───────────────────────────────────────────
                _buildDraggableBottomSheet(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Search bar ─────────────────────────────────────────────────────────────

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: TextField(
        decoration: InputDecoration(
          icon: const Icon(Icons.search, color: Colors.grey),
          hintText: 'Search Here',
          hintStyle: AppTypography.bodySmall,
          border: InputBorder.none,
        ),
      ),
    );
  }

  // ── Filter chips ────────────────────────────────────────────────────────────

  Widget _buildFilterBar() {
    return Row(
      children: List.generate(_filters.length, (i) {
        final isSelected = i == _selectedFilter;
        return GestureDetector(
          onTap: () => setState(() => _selectedFilter = i),
          child: Container(
            margin: EdgeInsets.only(right: 8.w),
            padding:
                EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryMagenta : Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: AppColors.primaryMagenta),
            ),
            child: Text(
              _filters[i],
              style: AppTypography.bodySmall.copyWith(
                color: isSelected
                    ? Colors.white
                    : AppColors.primaryMagenta,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }),
    );
  }

  // ── Draggable bottom sheet ──────────────────────────────────────────────────

  Widget _buildDraggableBottomSheet() {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.2,
      maxChildSize: 0.78,
      builder: (BuildContext context, ScrollController scrollController) {
        return _buildBottomPanel(scrollController);
      },
    );
  }

  Widget _buildBottomPanel(ScrollController scrollController) {
    return Container(
      padding: EdgeInsets.only(
          left: 25.w, right: 25.w, top: 0.w, bottom: 25.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.09),
            blurRadius: 18,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: ListView(
        padding: EdgeInsets.only(top: 18.w),
        controller: scrollController,
        children: [
          Center(
            child: Container(
              width: 42.w,
              height: 4.h,
              margin: EdgeInsets.only(bottom: 16.h),
              decoration: BoxDecoration(
                color: AppColors.textHint.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
          ),
          _locationRow(
            Icons.home,
            'Your Place',
            subtitle: _cityName.isNotEmpty ? _cityName : 'Detecting…',
          ),
          SizedBox(height: 6.h),
          Divider(height: 22.h),
          _locationRow(Icons.location_on, 'Your Destination'),
          SizedBox(height: 25.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _transportOption(Icons.directions_car, '30 min'),
              _transportOption(Icons.motorcycle, '40 min'),
              _transportOption(Icons.directions_bike, '1 Hour'),
              _transportOption(Icons.directions_walk, '1H 30m'),
            ],
          ),
          SizedBox(height: 25.h),
          SizedBox(
            width: double.infinity,
            height: 55.h,
            child: ElevatedButton(
              onPressed: _hasLocationPermission ? () {} : _goToMyLocation,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryMagenta,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.r),
                ),
              ),
              child: Text(
                _hasLocationPermission ? 'Go Now' : 'Enable Location',
                style: AppTypography.bodyLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _locationRow(IconData icon, String title, {String? subtitle}) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[700]),
        SizedBox(width: 15.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTypography.bodyMedium
                  .copyWith(fontWeight: FontWeight.w500),
            ),
            if (subtitle != null)
              Text(
                subtitle,
                style: AppTypography.caption
                    .copyWith(color: AppColors.textSecondary),
              ),
          ],
        ),
        const Spacer(),
        const Icon(Icons.import_export, color: Colors.grey),
      ],
    );
  }

  Widget _transportOption(IconData icon, String time) {
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: AppColors.primaryMagenta,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 20.w),
          SizedBox(height: 4.h),
          Text(
            time,
            style: AppTypography.caption.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
