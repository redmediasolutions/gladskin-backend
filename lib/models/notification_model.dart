import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String? imageUrl;
  final String target;
  final String topic;
  final String status;
  final DateTime? createdAt;
  final DateTime? sentAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    this.imageUrl,
    required this.target,
    required this.topic,
    required this.status,
    this.createdAt,
    this.sentAt,
  });

  factory NotificationModel.fromFirestore(
    QueryDocumentSnapshot doc,
  ) {
    final data =
        doc.data() as Map<String, dynamic>;

    return NotificationModel(
      id: doc.id,
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      imageUrl: data['imageUrl'],
      target: data['target'] ?? 'topic',
      topic: data['topic'] ?? 'all',
      status: data['status'] ?? 'pending',
      createdAt:
          (data['createdAt'] as Timestamp?)
              ?.toDate(),
      sentAt:
          (data['sentAt'] as Timestamp?)
              ?.toDate(),
    );
  }
}