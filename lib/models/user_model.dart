import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String? fullName;
  final String? phoneNumber;
  final String? email;
  final String? referralCode;
  final String? referredBy;
  final String? referredByPhone;
  final int walletBalance;
  final int rewardPoints;

  UserModel({
    required this.uid,
    this.fullName,
    this.phoneNumber,
    this.email,
    this.referralCode,
    this.referredBy,
    this.referredByPhone,
    required this.walletBalance,
    required this.rewardPoints,
  });

  factory UserModel.fromFirestore(
    DocumentSnapshot doc,
  ) {
    final json =
        doc.data() as Map<String, dynamic>;

    return UserModel(
      uid: doc.id,
      fullName: json["full_name"],
      phoneNumber: json["phone_number"],
      email: json["email"],
      referralCode: json["referralCode"],
      referredBy: json["referredBy"],
      referredByPhone:
          json["referredByPhone"],
      walletBalance:
          json["walletBalance"] ?? 0,
      rewardPoints:
          json["rewardPoints"] ?? 0,
    );
  }
}