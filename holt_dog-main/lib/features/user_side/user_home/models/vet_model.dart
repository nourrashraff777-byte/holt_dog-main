enum VetStatus { available, closed }

class Vet {
  final String id;
  final String name;
  final String address;
  final String phone;
  final VetStatus status;
  final double rating;

  Vet({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.status,
    this.rating = 4.5,
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

  factory Vet.fromMap(Map<String, dynamic> map, String id) {
    return Vet(
      id: id,
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      phone: map['phone'] ?? '',
      status: map['status'] == 'available' ? VetStatus.available : VetStatus.closed,
      rating: (map['rating'] ?? 4.5).toDouble(),
    );
  }
}
