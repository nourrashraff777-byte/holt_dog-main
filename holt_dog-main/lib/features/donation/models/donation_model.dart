import 'package:cloud_firestore/cloud_firestore.dart';

class DonationModel {
  final String id;
  final String donorId;
  final double amount;
  final String status;
  final DateTime timestamp;

  DonationModel({
    required this.id,
    required this.donorId,
    required this.amount,
    required this.status,
    required this.timestamp,
  });

  factory DonationModel.fromJson(Map<String, dynamic> json) {
    return DonationModel(
      id: json['id'] ?? '',
      donorId: json['donorId'] ?? '',
      amount: json['amount']?.toDouble() ?? 0.0,
      status: json['status'] ?? 'pending',
      timestamp: (json['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'donorId': donorId,
      'amount': amount,
      'status': status,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
