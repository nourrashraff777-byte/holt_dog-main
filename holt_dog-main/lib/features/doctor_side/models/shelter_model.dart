enum ShelterStatus { available, closed }

class Shelter {
  final String id;
  final String name;
  final String address;
  final String phone;
  final ShelterStatus status;
  final double rating;

  Shelter({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.status,
    required this.rating,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'status': status.name,
      'rating': rating,
    };
  }

  factory Shelter.fromMap(Map<String, dynamic> map, String id) {
    return Shelter(
      id: id,
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      phone: map['phone'] ?? '',
      status: map['status'] == 'available' ? ShelterStatus.available : ShelterStatus.closed,
      rating: (map['rating'] ?? 4.0).toDouble(),
    );
  }
}
