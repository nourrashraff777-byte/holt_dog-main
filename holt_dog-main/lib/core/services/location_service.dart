import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:dio/dio.dart';
import 'package:flutter_map/flutter_map.dart';

/// A centralised location helper used by all screens that need GPS access.
class LocationService {
  LocationService._();

  // ──────────────────────────────────────────────────────────────────────────
  // Permission helpers
  // ──────────────────────────────────────────────────────────────────────────

  /// Returns `true` when the device has location services enabled **and** the
  /// app has at least "while-in-use" permission.
  static Future<bool> requestPermission() async {
    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return false;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) return false;

      return permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
    } catch (_) {
      return false;
    }
  }

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
        timeLimit: const Duration(seconds: 8),
      );
    } catch (e) {
      print("Error getting location: $e");
      return null;
    }
  }

  /// Convenience method that checks permission **then** fetches the position.
  /// Returns `null` if permission is denied or GPS is unavailable.
  static Future<Position?> getLocationWithPermission() async {
    final bool granted = await requestPermission();
    if (!granted) return null;
    return getCurrentPosition();
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
