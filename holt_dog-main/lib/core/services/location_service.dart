import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:dio/dio.dart';
import 'package:flutter_map/flutter_map.dart';

enum LocationFailure {
  serviceDisabled,
  denied,
  deniedForever,
  timeout,
  unknown,
}

class LocationResult {
  final Position? position;
  final LocationFailure? failure;
  final String? message;

  const LocationResult.success(this.position)
      : failure = null,
        message = null;
  const LocationResult.error(this.failure, this.message) : position = null;

  bool get ok => position != null;
}

/// A centralised location helper used by all screens that need GPS access.
class LocationService {
  LocationService._();

  // ──────────────────────────────────────────────────────────────────────────
  // Permission helpers
  // ──────────────────────────────────────────────────────────────────────────

  static Future<LocationPermission> _ensurePermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission;
  }

  /// Returns `true` when the device has location services enabled **and** the
  /// app has at least "while-in-use" permission.
  static Future<bool> requestPermission() async {
    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return false;

      final permission = await _ensurePermission();
      return permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
    } catch (_) {
      return false;
    }
  }

  /// Opens the OS app-settings page so the user can grant location manually.
  static Future<bool> openAppSettings() => Geolocator.openAppSettings();

  /// Opens the OS location-services page (turn GPS on).
  static Future<bool> openLocationSettings() =>
      Geolocator.openLocationSettings();

  // ──────────────────────────────────────────────────────────────────────────
  // Position helpers
  // ──────────────────────────────────────────────────────────────────────────

  /// Fetches the device's current [Position]. Returns `null` on any failure.
  /// Tries the cached last-known position first (instant) and falls back to
  /// a fresh medium-accuracy fix with a short timeout to avoid ANRs.
  static Future<Position?> getCurrentPosition() async {
    try {
      final last = await Geolocator.getLastKnownPosition();
      if (last != null) return last;

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 12),
      );
    } catch (e) {
      print("Error getting location: $e");
      return null;
    }
  }

  /// Convenience method that checks permission **then** fetches the position.
  /// Returns `null` if permission is denied or GPS is unavailable.
  static Future<Position?> getLocationWithPermission() async {
    final result = await getLocationDetailed();
    return result.position;
  }

  /// Same as [getLocationWithPermission] but reports *why* it failed so the
  /// UI can show a useful message (or open settings).
  static Future<LocationResult> getLocationDetailed() async {
    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return const LocationResult.error(
          LocationFailure.serviceDisabled,
          'Location (GPS) is turned off on this device.',
        );
      }

      final permission = await _ensurePermission();
      if (permission == LocationPermission.deniedForever) {
        return const LocationResult.error(
          LocationFailure.deniedForever,
          'Location permission is permanently denied. Open settings to enable it.',
        );
      }
      if (permission != LocationPermission.always &&
          permission != LocationPermission.whileInUse) {
        return const LocationResult.error(
          LocationFailure.denied,
          'Location permission denied.',
        );
      }

      final last = await Geolocator.getLastKnownPosition();
      if (last != null) return LocationResult.success(last);

      try {
        final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
          timeLimit: const Duration(seconds: 12),
        );
        return LocationResult.success(pos);
      } catch (e) {
        return LocationResult.error(
          LocationFailure.timeout,
          'Could not get a GPS fix. Move near a window and try again.',
        );
      }
    } catch (e) {
      return LocationResult.error(LocationFailure.unknown, e.toString());
    }
  }

  /// Converts a [Position] to a [LatLng] for use with flutter_map.
  static LatLng toLatLng(Position position) =>
      LatLng(position.latitude, position.longitude);

  // ──────────────────────────────────────────────────────────────────────────
  // Reverse-geocoding (city name from coordinates)
  // ──────────────────────────────────────────────────────────────────────────

  /// Returns a human-readable city string for the given [lat]/[lng] using the
  /// free Nominatim API (OpenStreetMap).  Falls back to the raw coordinates if
  /// the network request fails.
  static Future<String> getCityName(double lat, double lng) async {
    try {
      final dio = Dio();
      dio.options
        ..connectTimeout = const Duration(seconds: 8)
        ..receiveTimeout = const Duration(seconds: 8)
        ..headers = {
          'User-Agent': 'HoltDog/1.0 (holtdogapp@example.com)',
        };

      final response = await dio.get(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {
          'lat': lat,
          'lon': lng,
          'format': 'json',
          'accept-language': 'en',
        },
      );

      final data = response.data as Map<String, dynamic>;
      final address = data['address'] as Map<String, dynamic>?;
      if (address == null) return _coordsFallback(lat, lng);

      // Pick the most specific available place name
      final city = address['city'] ??
          address['town'] ??
          address['village'] ??
          address['county'] ??
          address['state'] ??
          '';
      final country = address['country'] ?? '';

      if (city.toString().isNotEmpty) {
        return '$city, $country';
      }
      return _coordsFallback(lat, lng);
    } catch (_) {
      return _coordsFallback(lat, lng);
    }
  }

  static String _coordsFallback(double lat, double lng) =>
      '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}';
}
