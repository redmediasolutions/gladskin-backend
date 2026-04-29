import 'package:cloud_firestore/cloud_firestore.dart';

class RewardTransaction {
  final String id;
  final String type;      // credit / debit
  final String status;    // pending / credited / debited / reversed
  final double amount;
  final String reason;
  final String? wooOrderId;
  final DateTime? createdAt;

  RewardTransaction({
    required this.id,
    required this.type,
    required this.status,
    required this.amount,
    required this.reason,
    this.wooOrderId,
    this.createdAt,
  });

  factory RewardTransaction.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return RewardTransaction(
      id: doc.id,
      type: data['type'] ?? 'credit',
      status: data['status'] ?? 'credited',
      amount: (data['amount'] ?? 0).toDouble(),
      reason: data['reason'] ?? 'Wallet Transaction',
      wooOrderId: data['orderId']?.toString(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}