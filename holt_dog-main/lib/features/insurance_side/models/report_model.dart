import 'package:flutter/material.dart';

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

  Report({
    required this.id,
    required this.title,
    required this.location,
    required this.date,
    required this.imageUrl,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'location': location,
      'date': date,
      'imageUrl': imageUrl,
      'status': status.name,
    };
  }

  factory Report.fromMap(Map<String, dynamic> map, String id) {
    return Report(
      id: id,
      title: map['title'] ?? '',
      location: map['location'] ?? '',
      date: map['date'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      status: ReportStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => ReportStatus.pending,
      ),
    );
  }

  Color get statusColor {
    switch (status) {
      case ReportStatus.solved:
        return const Color(0xFF4CAF50);
      case ReportStatus.pending:
        return const Color(0xFFFF9800);
      case ReportStatus.missing:
        return const Color(0xFFF44336);
    }
  }

  String get statusText {
    switch (status) {
      case ReportStatus.solved:
        return 'Resued';
      case ReportStatus.pending:
        return 'undercare';
      case ReportStatus.missing:
        return 'Needs Help';
    }
  }
}
