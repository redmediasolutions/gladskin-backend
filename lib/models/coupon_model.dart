import 'package:cloud_firestore/cloud_firestore.dart';

class CouponModel {
  final String id;

  final String code;

  final double discount;

  final int usedCount;

  /// -1 means unlimited usage
  final int maxUsage;

  final bool isActive;

  /// Influencer coupon
  final bool isInfluencerCoupon;

  final String? influencerId;

  final String? influencerName;

  final Timestamp? startDate;

  final Timestamp? endDate;

  final Timestamp? createdAt;

  CouponModel({
    required this.id,
    required this.code,
    required this.discount,
    required this.usedCount,
    required this.maxUsage,
    required this.isActive,
    required this.isInfluencerCoupon,
    this.influencerId,
    this.influencerName,
    this.startDate,
    this.endDate,
    this.createdAt,
  });

  factory CouponModel.fromFirestore(
    DocumentSnapshot doc,
  ) {
    final data =
        doc.data() as Map<String, dynamic>;

    return CouponModel(
      id: doc.id,

      code: data['code'] ?? '',

      discount:
          (data['discount'] ?? 0)
              .toDouble(),

      usedCount:
          data['usedCount'] ?? 0,

      maxUsage:
          data['maxUsage'] ?? 0,

      isActive:
          data['isActive'] ?? false,

      isInfluencerCoupon:
          data['isInfluencerCoupon'] ??
              false,

      influencerId:
          data['influencerId'],

      influencerName:
          data['influencerName'],

      startDate:
          data['startDate'],

      endDate:
          data['endDate'],

      createdAt:
          data['createdAt'],
    );
  }

  bool get isUnlimitedUsage =>
      maxUsage == -1;

  bool get canStillBeUsed {
    if (isUnlimitedUsage) {
      return true;
    }

    return usedCount < maxUsage;
  }

  Map<String, dynamic> toMap() {
    return {
      'code': code,

      'discount': discount,

      'usedCount': usedCount,

      'maxUsage': maxUsage,

      'isActive': isActive,

      'isInfluencerCoupon':
          isInfluencerCoupon,

      'influencerId':
          influencerId,

      'influencerName':
          influencerName,

      'startDate': startDate,

      'endDate': endDate,

      'createdAt': createdAt,
    };
  }
}