import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../user_home/widgets/user_quick_actions_widgets.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  bool _hasLocationPermission = false;

  static const LatLng _defaultCity = LatLng(30.0444, 31.2357);
  static const double _defaultZoom = 14;
  LatLng? _currentLocation;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (!mounted) return;
      setState(() {
        _hasLocationPermission = permission == LocationPermission.always ||
            permission == LocationPermission.whileInUse;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _hasLocationPermission = false;
      });
    }
  }

  Future<void> _goToMyLocation() async {
    if (!_hasLocationPermission) return;
    try {
      final Position position = await Geolocator.getCurrentPosition();
      final LatLng userPoint = LatLng(position.latitude, position.longitude);
      if (!mounted) return;

      setState(() {
        _currentLocation = userPoint;
      });

      _mapController.move(userPoint, 15);
    } catch (_) {
      // Keep the default camera position if current location is unavailable.
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
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _defaultCity,
                    initialZoom: _defaultZoom,
                    minZoom: 3,
                    maxZoom: 19,
                    onMapReady: _goToMyLocation,
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
                _buildDraggableBottomSheet(),
              ],
            ),
          ),
        ],
      ),
    );
  }

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

  Widget _buildFilterBar() {
    return Row(
      children: [
        _filterChip('All', true),
        _filterChip('Vets', false),
        _filterChip('Shelters', false),
      ],
    );
  }

  Widget _filterChip(String label, bool isSelected) {
    return Container(
      margin: EdgeInsets.only(right: 8.w),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primaryMagenta : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.primaryMagenta),
      ),
      child: Text(
        label,
        style: AppTypography.bodySmall.copyWith(
          color: isSelected ? Colors.white : AppColors.primaryMagenta,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

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
      padding: EdgeInsets.only(left: 25.w, right: 25.w, top: 0.w, bottom: 25.w),
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
          _locationRow(Icons.home, 'Your Place'),
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
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryMagenta,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.r),
                ),
              ),
              child: Text(
                'Go Now',
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

  Widget _locationRow(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[700]),
        SizedBox(width: 15.w),
        Text(
          title,
          style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w500),
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
