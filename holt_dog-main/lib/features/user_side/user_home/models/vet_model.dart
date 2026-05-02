import '../../../../core/services/location_service.dart';

enum VetStatus { available, closed }

class Vet {
  final String id;
  final String name;
  final String address;
  final String phone;
  final VetStatus status;
  final double rating;
  final double? lat;
  final double? lng;
  double? distanceKm;

  Vet({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.status,
    this.rating = 4.5,
    this.lat,
    this.lng,
    this.distanceKm,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'status': status.name,
      'rating': rating,
      'lat': lat,
      'lng': lng,
    };
  }

  factory Vet.fromMap(Map<String, dynamic> map, String id) {
    final location = map['location'];

    return Vet(
      id: id,
      name: map['name']?.toString() ?? '',
      address: map['address']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      status:
          map['status'] == 'available' ? VetStatus.available : VetStatus.closed,
      rating: (map['rating'] is num)
          ? (map['rating'] as num).toDouble()
          : double.tryParse(map['rating']?.toString() ?? '') ?? 4.5,
      lat: LocationService.parseCoord(map['lat']) ??
          LocationService.parseCoord(map['latitude']) ??
          _coordFromLocation(location, 'latitude'),
      lng: LocationService.parseCoord(map['lng']) ??
          LocationService.parseCoord(map['longitude']) ??
          _coordFromLocation(location, 'longitude'),
    );
  }

  static double? _coordFromLocation(dynamic location, String key) {
    if (location == null) return null;
    if (location is Map) return LocationService.parseCoord(location[key]);

    try {
      final coord = key == 'latitude' ? location.latitude : location.longitude;
      return LocationService.parseCoord(coord);
    } catch (_) {
      return null;
    }
  }
}
