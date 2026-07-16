import 'package:cloud_firestore/cloud_firestore.dart';

class StatusHistoryModel {
  final String status;

  final String description;

  final String performedBy;

  final Timestamp? createdAt;

  const StatusHistoryModel({
    required this.status,
    required this.description,
    required this.performedBy,
    this.createdAt,
  });

  factory StatusHistoryModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return StatusHistoryModel(
      status:
          map['status']?.toString() ??
              map['action']?.toString() ??
              '',

      description:
          map['description']?.toString() ?? '',

      performedBy:
          map['performedBy']?.toString() ??
              map['updatedBy']?.toString() ??
              'System',

      createdAt:
          map['createdAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'status': status,
      'description': description,
      'performedBy': performedBy,
      'createdAt': createdAt,
    };
  }

  StatusHistoryModel copyWith({
    String? status,
    String? description,
    String? performedBy,
    Timestamp? createdAt,
  }) {
    return StatusHistoryModel(
      status: status ?? this.status,
      description:
          description ?? this.description,
      performedBy:
          performedBy ?? this.performedBy,
      createdAt:
          createdAt ?? this.createdAt,
    );
  }
}