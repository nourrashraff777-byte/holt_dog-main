import 'dart:async';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/services/location_service.dart';
import '../../user_home/widgets/user_quick_actions_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Model
// ─────────────────────────────────────────────────────────────────────────────

enum ProviderType { vet, shelter }

class NearbyProvider {
  final String id;
  final String name;
  final String address;
  final String phone;
  final ProviderType type;
  final LatLng position;
  final double distanceKm;

  const NearbyProvider({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.type,
    required this.position,
    required this.distanceKm,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();

  // Location state
  bool _hasLocationPermission = false;
  bool _loadingLocation = true;
  LatLng? _currentLocation;
  String _cityName = '';

  // Providers from Firestore
  List<NearbyProvider> _providers = [];
  bool _loadingProviders = false;

  // UI state
  int _selectedFilter = 0; // 0=All, 1=Vets, 2=Shelters
  NearbyProvider? _selectedProvider;
  final List<String> _filters = ['All', 'Vets', 'Shelters'];

  static const LatLng _defaultCity = LatLng(30.0444, 31.2357); // Cairo
  static const double _defaultZoom = 13;

  // ── Lifecycle ───────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initLocation());
  }

  // ── Location ────────────────────────────────────────────────────────────────

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
    final city = await LocationService.getCityName(
        position.latitude, position.longitude);

    if (!mounted) return;
    setState(() {
      _hasLocationPermission = true;
      _currentLocation = userPoint;
      _cityName = city;
      _loadingLocation = false;
    });

    _mapController.move(userPoint, 14);

    // Load nearby providers once we have coordinates
    _loadNearbyProviders(position.latitude, position.longitude);
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

  // ── Firestore nearby providers ──────────────────────────────────────────────

  Future<void> _loadNearbyProviders(double userLat, double userLon) async {
    if (!mounted) return;
    setState(() => _loadingProviders = true);

    try {
      final db = FirebaseFirestore.instance;

      // Query both DOCTOR (vet) and CHARITY (shelter) roles in parallel
      final results = await Future.wait([
        db.collection('users').where('role', isEqualTo: 'DOCTOR').get(),
        db.collection('users').where('role', isEqualTo: 'CHARITY').get(),
      ]);

      final List<NearbyProvider> found = [];

      for (final snapshot in results) {
        for (final doc in snapshot.docs) {
          final data = doc.data();
          double? lat, lon;

          // Support both flat lat/lng fields and GeoPoint 'location' field
          if (data.containsKey('lat') && data['lat'] != null) {
            lat = double.tryParse(data['lat'].toString());
            lon = double.tryParse(data['lng']?.toString() ?? '');
          } else if (data['location'] is GeoPoint) {
            final gp = data['location'] as GeoPoint;
            lat = gp.latitude;
            lon = gp.longitude;
          }

          if (lat == null || lon == null) continue;

          final dist = _haversineKm(userLat, userLon, lat, lon);
          if (dist > 50) continue; // 50 km radius

          final role = data['role']?.toString() ?? '';
          found.add(NearbyProvider(
            id: doc.id,
            name: data['name']?.toString() ?? 'Unknown',
            address: data['address']?.toString() ??
                data['extraData']?['clinicAddress']?.toString() ??
                '',
            phone: data['phone']?.toString() ??
                data['extraData']?['phone']?.toString() ??
                '',
            type: role == 'DOCTOR' ? ProviderType.vet : ProviderType.shelter,
            position: LatLng(lat, lon),
            distanceKm: dist,
          ));
        }
      }

      // Sort nearest-first
      found.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));

      if (!mounted) return;
      setState(() {
        _providers = found;
        _loadingProviders = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingProviders = false);
    }
  }

  double _haversineKm(
      double lat1, double lon1, double lat2, double lon2) {
    const p = math.pi / 180;
    final a = 0.5 -
        math.cos((lat2 - lat1) * p) / 2 +
        math.cos(lat1 * p) *
            math.cos(lat2 * p) *
            (1 - math.cos((lon2 - lon1) * p)) /
            2;
    return 12742 * math.asin(math.sqrt(a));
  }

  // ── Filtered list ───────────────────────────────────────────────────────────

  List<NearbyProvider> get _filtered {
    if (_selectedFilter == 1) {
      return _providers.where((p) => p.type == ProviderType.vet).toList();
    } else if (_selectedFilter == 2) {
      return _providers.where((p) => p.type == ProviderType.shelter).toList();
    }
    return _providers;
  }

  // ── Build ───────────────────────────────────────────────────────────────────

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
                // ── OpenStreetMap (CARTO Light tiles — no API key needed) ──
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _defaultCity,
                    initialZoom: _defaultZoom,
                    minZoom: 3,
                    maxZoom: 19,
                    onTap: (_, __) => setState(() => _selectedProvider = null),
                  ),
                  children: [
                    // ── Tile layer — OpenStreetMap via CARTO ─────────────
                    TileLayer(
                      urlTemplate:
                          'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                      subdomains: const ['a', 'b', 'c', 'd'],
                      retinaMode: RetinaMode.isHighDensity(context),
                      userAgentPackageName: 'com.holtdog.app',
                    ),

                    // ── Nearby provider markers ──────────────────────────
                    MarkerLayer(
                      markers: [
                        ..._filtered.map((p) => _buildProviderMarker(p)),

                        // ── User location marker ─────────────────────────
                        if (_currentLocation != null)
                          Marker(
                            point: _currentLocation!,
                            width: 44.w,
                            height: 44.w,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.primaryMagenta,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Colors.white, width: 3),
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

                    // ── Attribution ──────────────────────────────────────
                    const RichAttributionWidget(
                      showFlutterMapAttribution: false,
                      attributions: [
                        TextSourceAttribution(
                          '© OpenStreetMap contributors · CARTO',
                          prependCopyright: false,
                        ),
                      ],
                    ),
                  ],
                ),

                // ── Search + filter overlay ──────────────────────────────
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

                // ── Provider loading indicator ───────────────────────────
                if (_loadingProviders)
                  Positioned(
                    top: 130.h,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.r),
                          boxShadow: const [
                            BoxShadow(
                                color: Colors.black12, blurRadius: 8)
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 14.w,
                              height: 14.w,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primaryMagenta),
                            ),
                            SizedBox(width: 8.w),
                            Text('Finding nearby providers…',
                                style: AppTypography.caption),
                          ],
                        ),
                      ),
                    ),
                  ),

                // ── City chip ────────────────────────────────────────────
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
                            BoxShadow(
                                color: Colors.black12, blurRadius: 8)
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

                // ── My-location FAB ──────────────────────────────────────
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
                                color: AppColors.primaryMagenta),
                          )
                        : Icon(
                            Icons.my_location,
                            color: _hasLocationPermission
                                ? AppColors.primaryMagenta
                                : Colors.grey,
                          ),
                  ),
                ),

                // ── Permission banner ────────────────────────────────────
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
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.location_off,
                              color: Colors.red, size: 18.w),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              'Location denied. Tap 🔄 to retry.',
                              style: AppTypography.caption
                                  .copyWith(color: Colors.red.shade700),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // ── Provider detail card (tapped marker) ─────────────────
                if (_selectedProvider != null)
                  Positioned(
                    bottom: 190.h,
                    left: 16.w,
                    right: 16.w,
                    child: _buildProviderCard(_selectedProvider!),
                  ),

                // ── Bottom sheet ─────────────────────────────────────────
                _buildDraggableBottomSheet(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Provider marker ─────────────────────────────────────────────────────────

  Marker _buildProviderMarker(NearbyProvider p) {
    final isVet = p.type == ProviderType.vet;
    final color = isVet ? Colors.blue : Colors.orange;

    return Marker(
      point: p.position,
      width: 44.w,
      height: 44.w,
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedProvider = p);
          _mapController.move(p.position, 16);
        },
        child: Container(
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Icon(
            isVet ? Icons.local_hospital : Icons.home_work,
            color: Colors.white,
            size: 20.w,
          ),
        ),
      ),
    );
  }

  // ── Provider info card ───────────────────────────────────────────────────────

  Widget _buildProviderCard(NearbyProvider p) {
    final isVet = p.type == ProviderType.vet;
    final color = isVet ? Colors.blue : Colors.orange;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isVet ? Icons.local_hospital : Icons.home_work,
              color: color,
              size: 24.w,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.name,
                  style: AppTypography.bodyMedium
                      .copyWith(fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (p.address.isNotEmpty)
                  Text(
                    p.address,
                    style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                Text(
                  '${p.distanceKm.toStringAsFixed(1)} km away',
                  style: AppTypography.caption
                      .copyWith(color: color, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _selectedProvider = null),
            child: Icon(Icons.close, color: Colors.grey, size: 20.w),
          ),
        ],
      ),
    );
  }

  // ── Search bar ───────────────────────────────────────────────────────────────

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

  // ── Filter chips ─────────────────────────────────────────────────────────────

  Widget _buildFilterBar() {
    return Row(
      children: List.generate(_filters.length, (i) {
        final isSelected = i == _selectedFilter;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedFilter = i;
              _selectedProvider = null;
            });
          },
          child: Container(
            margin: EdgeInsets.only(right: 8.w),
            padding:
                EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryMagenta : Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: AppColors.primaryMagenta),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _filters[i],
                  style: AppTypography.bodySmall.copyWith(
                    color: isSelected
                        ? Colors.white
                        : AppColors.primaryMagenta,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (!isSelected && _providers.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(left: 4.w),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 5.w, vertical: 1.h),
                      decoration: BoxDecoration(
                        color: AppColors.primaryMagenta,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Text(
                        i == 1
                            ? '${_providers.where((p) => p.type == ProviderType.vet).length}'
                            : i == 2
                                ? '${_providers.where((p) => p.type == ProviderType.shelter).length}'
                                : '${_providers.length}',
                        style: AppTypography.caption.copyWith(
                            color: Colors.white, fontSize: 10.sp),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }

  // ── Bottom sheet ─────────────────────────────────────────────────────────────

  Widget _buildDraggableBottomSheet() {
    return DraggableScrollableSheet(
      initialChildSize: 0.22,
      minChildSize: 0.12,
      maxChildSize: 0.55,
      builder: (context, scrollController) {
        return Container(
          padding:
              EdgeInsets.only(left: 20.w, right: 20.w, top: 0, bottom: 20.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(30.r)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.09),
                blurRadius: 18,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: ListView(
            padding: EdgeInsets.only(top: 12.h),
            controller: scrollController,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 42.w,
                  height: 4.h,
                  margin: EdgeInsets.only(bottom: 16.h),
                  decoration: BoxDecoration(
                    color: AppColors.textHint.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),

              // Summary row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _loadingProviders
                        ? 'Loading nearby…'
                        : '${_filtered.length} place${_filtered.length == 1 ? '' : 's'} nearby',
                    style: AppTypography.h3
                        .copyWith(fontSize: 16.sp),
                  ),
                  if (_filtered.isNotEmpty)
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: AppColors.primaryMagenta
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.location_on,
                              color: AppColors.primaryMagenta, size: 12.w),
                          SizedBox(width: 4.w),
                          Text(
                            _cityName.isEmpty ? '…' : _cityName,
                            style: AppTypography.caption.copyWith(
                                color: AppColors.primaryMagenta),
                          ),
                        ],
                      ),
                    ),
                ],
              ),

              SizedBox(height: 14.h),

              // Provider list
              if (_filtered.isEmpty && !_loadingProviders)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.h),
                  child: Center(
                    child: Text(
                      _hasLocationPermission
                          ? 'No ${_selectedFilter == 1 ? 'vets' : _selectedFilter == 2 ? 'shelters' : 'providers'} found nearby.'
                          : 'Enable location to find nearby places.',
                      style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary),
                    ),
                  ),
                ),

              ..._filtered.map((p) => _buildListTile(p)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildListTile(NearbyProvider p) {
    final isVet = p.type == ProviderType.vet;
    final color = isVet ? Colors.blue : Colors.orange;
    final isSelected = _selectedProvider?.id == p.id;

    return GestureDetector(
      onTap: () {
        setState(() => _selectedProvider = p);
        _mapController.move(p.position, 16);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.08)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade200,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isVet ? Icons.local_hospital : Icons.home_work,
                color: color,
                size: 18.w,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.name,
                    style: AppTypography.bodySmall
                        .copyWith(fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (p.address.isNotEmpty)
                    Text(
                      p.address,
                      style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${p.distanceKm.toStringAsFixed(1)} km',
                  style: AppTypography.caption.copyWith(
                      color: color, fontWeight: FontWeight.w700),
                ),
                Text(
                  isVet ? 'Vet' : 'Shelter',
                  style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
