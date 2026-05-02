import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum ReportStatus {
  solved,
  pending,
  missing,
}

class Report {
  final String id;
  final String title;
  final String location;
  final String date;
  final String imageUrl;
  final ReportStatus status;
  final String reporterId;
  final DateTime? timestamp;

  // AI analysis fields (optional — set when an analysis result is attached)
  final String predictedMood;
  final String predictedDisease;
  final int diseaseConfidence;
  final String uploaderName;
  final String uploaderEmail;

  Report({
    required this.id,
    required this.title,
    required this.location,
    required this.date,
    required this.imageUrl,
    required this.status,
    this.reporterId = '',
    this.timestamp,
    this.predictedMood = '',
    this.predictedDisease = '',
    this.diseaseConfidence = 0,
    this.uploaderName = '',
    this.uploaderEmail = '',
  });

  // ── Firestore serialisation ────────────────────────────────────────────────

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'location': location,
      'date': date,
      'imageUrl': imageUrl,
      'status': status.name,
      'reporterId': reporterId,
      'timestamp': timestamp != null
          ? Timestamp.fromDate(timestamp!)
          : FieldValue.serverTimestamp(),
      'predictedMood': predictedMood,
      'predictedDisease': predictedDisease,
      'diseaseConfidence': diseaseConfidence,
      'uploaderName': uploaderName,
      'uploaderEmail': uploaderEmail,
    };
  }

  factory Report.fromMap(Map<String, dynamic> map, String docId) {
    // Pull the AI analysis block (scans schema).
    final analysis = (map['analysis'] is Map)
        ? Map<String, dynamic>.from(map['analysis'] as Map)
        : const <String, dynamic>{};

    // Location: prefer the human-readable `address` string; fall back to
    // the GeoPoint coords; final fallback to a legacy `location` string.
    String locationStr = '';
    final address = map['address'];
    if (address is String && address.isNotEmpty) {
      locationStr = address;
    } else if (map['location'] is GeoPoint) {
      final gp = map['location'] as GeoPoint;
      locationStr =
          '${gp.latitude.toStringAsFixed(4)}, ${gp.longitude.toStringAsFixed(4)}';
    } else if (map['location'] is String) {
      locationStr = map['location'] as String;
    }

    return Report(
      id: docId,
      title: map['title']?.toString() ?? '',
      location: locationStr,
      date: map['date']?.toString() ?? '',
      imageUrl: map['imageUrl']?.toString() ?? '',
      reporterId: (map['userId'] ?? map['reporterId'])?.toString() ?? '',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate(),
      predictedMood:
          (analysis['mood'] ?? map['predictedMood'])?.toString() ?? '',
      predictedDisease:
          (analysis['disease'] ?? map['predictedDisease'])?.toString() ?? '',
      diseaseConfidence: ((analysis['diseaseConfidence'] ??
                  analysis['confidence'] ??
                  map['diseaseConfidence']) as num?)
              ?.toInt() ??
          0,
      uploaderName: map['uploaderName']?.toString() ?? '',
      uploaderEmail: map['uploaderEmail']?.toString() ?? '',
      status: _statusFromRaw(map['status']?.toString() ?? ''),
    );
  }

  static ReportStatus _statusFromRaw(String raw) {
    switch (raw.toLowerCase().trim()) {
      case 'solved':
      case 'rescued':
        return ReportStatus.solved;
      case 'pending':
      case 'undercare':
        return ReportStatus.pending;
      case 'missing':
      case 'need help':
      case 'needs help':
        return ReportStatus.missing;
      default:
        return ReportStatus.pending;
    }
  }

  factory Report.fromFirestore(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>? ?? {};
    return Report.fromMap(map, doc.id);
  }

  // ── UI helpers ─────────────────────────────────────────────────────────────

  Color get statusColor {
    switch (status) {
      case ReportStatus.solved:
        return const Color(0xFF2E7D32);
      case ReportStatus.pending:
        return const Color(0xFFE65100);
      case ReportStatus.missing:
        return const Color(0xFFC62828);
    }
  }

  String get statusText {
    switch (status) {
      case ReportStatus.solved:
        return 'Rescued';
      case ReportStatus.pending:
        return 'Undercare';
      case ReportStatus.missing:
        return 'Needs Help';
    }
  }
}
