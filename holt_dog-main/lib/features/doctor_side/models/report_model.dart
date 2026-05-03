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

  Report({
    required this.id,
    required this.title,
    required this.location,
    required this.date,
    required this.imageUrl,
    required this.status,
    this.reporterId = '',
    this.timestamp,
  });

  // ── Firestore serialisation ───────────────────────────────────────────────

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
    };
  }

  factory Report.fromMap(Map<String, dynamic> map, String docId) {
    final analysis = (map['analysis'] is Map)
        ? Map<String, dynamic>.from(map['analysis'] as Map)
        : const <String, dynamic>{};

    final disease = (analysis['disease'] ?? map['predictedDisease'])?.toString() ?? '';
    final mood = (analysis['mood'] ?? map['predictedMood'])?.toString() ?? '';
    final isDog = analysis['isDog'] == true;

    String title;
    if (map['title'] is String && (map['title'] as String).isNotEmpty) {
      title = map['title'] as String;
    } else if (isDog && disease.isNotEmpty && mood.isNotEmpty) {
      title = '$disease · $mood';
    } else if (isDog && disease.isNotEmpty) {
      title = disease;
    } else {
      title = 'Dog scan';
    }

    String location = '';
    final addr = map['address'];
    if (addr is String && addr.isNotEmpty) {
      location = addr;
    } else if (map['location'] is GeoPoint) {
      final gp = map['location'] as GeoPoint;
      location =
          '${gp.latitude.toStringAsFixed(4)}, ${gp.longitude.toStringAsFixed(4)}';
    } else if (map['location'] is String) {
      location = map['location'] as String;
    }

    final ts = (map['timestamp'] as Timestamp?)?.toDate();

    return Report(
      id: docId,
      title: title,
      location: location.isEmpty ? 'Unknown location' : location,
      date: _relativeDate(ts),
      imageUrl: map['imageUrl']?.toString() ?? '',
      reporterId: (map['userId'] ?? map['reporterId'])?.toString() ?? '',
      timestamp: ts,
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

  static String _relativeDate(DateTime? d) {
    if (d == null) return '—';
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) {
      final h = diff.inHours;
      return '$h hour${h == 1 ? '' : 's'} ago';
    }
    if (diff.inDays < 7) {
      final dy = diff.inDays;
      return '$dy day${dy == 1 ? '' : 's'} ago';
    }
    final w = (diff.inDays / 7).floor();
    return '$w week${w == 1 ? '' : 's'} ago';
  }

  factory Report.fromFirestore(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>? ?? {};
    return Report.fromMap(map, doc.id);
  }

  // ── UI helpers ────────────────────────────────────────────────────────────

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
