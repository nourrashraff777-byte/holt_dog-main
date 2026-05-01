import '../../../../core/services/location_service.dart';

enum ShelterStatus { available, closed }

class Shelter {
  final String id;
  final String name;
  final String address;
  final String phone;
  final ShelterStatus status;
  final double rating;
  final double? lat;
  final double? lng;
  double? distanceKm;

  Shelter({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.status,
    required this.rating,
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

  factory Shelter.fromMap(Map<String, dynamic> map, String id) {
    return Shelter(
      id: id,
      name: map['name']?.toString() ?? '',
      address: map['address']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      status: map['status'] == 'available'
          ? ShelterStatus.available
          : ShelterStatus.closed,
      rating: (map['rating'] is num)
          ? (map['rating'] as num).toDouble()
          : double.tryParse(map['rating']?.toString() ?? '') ?? 4.0,
      lat: LocationService.parseCoord(map['lat']),
      lng: LocationService.parseCoord(map['lng']),
    );
  }
}
