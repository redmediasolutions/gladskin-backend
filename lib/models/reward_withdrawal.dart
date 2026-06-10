import 'package:cloud_firestore/cloud_firestore.dart';

class RewardWithdrawal {
  final String id;
  final String uid;

  final String customerName;
  final String phoneNumber;

  final double amount;
  final String upiId;
  final String status;

  final DateTime? createdAt;
  final DateTime? approvedAt;

  RewardWithdrawal({
    required this.id,
    required this.uid,
    required this.customerName,
    required this.phoneNumber,
    required this.amount,
    required this.upiId,
    required this.status,
    this.createdAt,
    this.approvedAt,
  });

  factory RewardWithdrawal.fromDoc(
    DocumentSnapshot doc,
  ) {
    final data =
        doc.data() as Map<String, dynamic>;

    return RewardWithdrawal(
      id: doc.id,

      uid: data['uid'] ?? '',

      customerName:
          data['customerName'] ??
          data['displayName'] ??
          '',

      phoneNumber:
          data['phone_number']
                  ?.toString() ??
              '',

      amount:
          ((data['amount'] ?? 0) as num)
              .toDouble(),

      upiId:
          data['upiId'] ?? '',

      status:
          data['status'] ?? 'pending',

      createdAt:
          (data['createdAt']
                  as Timestamp?)
              ?.toDate(),

      approvedAt:
          (data['approvedAt']
                  as Timestamp?)
              ?.toDate(),
    );
  }
}