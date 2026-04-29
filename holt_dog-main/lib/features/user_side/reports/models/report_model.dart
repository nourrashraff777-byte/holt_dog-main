import 'package:cloud_firestore/cloud_firestore.dart';

class ReportModel {
  final String id;
  final String reporterId;
  final String imageUrl;
  final String status;
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final String? description;

  ReportModel({
    required this.id,
    required this.reporterId,
    required this.imageUrl,
    required this.status,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.description,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'] ?? '',
      reporterId: json['reporterId'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      status: json['status'] ?? 'pending',
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
      timestamp: (json['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reporterId': reporterId,
      'imageUrl': imageUrl,
      'status': status,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': Timestamp.fromDate(timestamp),
      'description': description,
    };
  }
}
