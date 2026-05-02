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
    return Report(
      id: docId,
      title: map['title'] ?? '',
      location: map['location'] ?? '',
      date: map['date'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      reporterId: map['reporterId'] ?? '',
      timestamp:
          (map['timestamp'] as Timestamp?)?.toDate(),
      status: ReportStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => ReportStatus.pending,
      ),
    );
  }

  factory Report.fromFirestore(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>? ?? {};
    return Report.fromMap(map, doc.id);
  }

  // ── UI helpers ────────────────────────────────────────────────────────────

  Color get statusColor {
    switch (status) {
      case ReportStatus.solved:
        return const Color(0xFF2E7D32); // deep green
      case ReportStatus.pending:
        return const Color(0xFFE65100); // deep orange
      case ReportStatus.missing:
        return const Color(0xFFC62828); // deep red
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
