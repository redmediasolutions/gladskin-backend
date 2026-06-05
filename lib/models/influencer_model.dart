import 'package:cloud_firestore/cloud_firestore.dart';

class InfluencerModel {
  final String id;

  final String fullName;

  final String phoneNumber;

  final String couponCode;

  final String referralCode;

  final bool isInfluencer;

  final Map<String, dynamic>?
      influencerData;

  InfluencerModel({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.couponCode,
    required this.referralCode,
    required this.isInfluencer,
    this.influencerData,
  });

  factory InfluencerModel.fromFirestore(
    DocumentSnapshot doc,
  ) {
    final data =
        doc.data()
            as Map<String, dynamic>;

    return InfluencerModel(
      id: doc.id,

      fullName:
          data['full_name'] ??
              'Unnamed',

      /// USING YOUR CURRENT DB FIELD
      phoneNumber:
          data['phone_number'] ??
              '',

      couponCode:
          data['influencerCouponCode'] ??
              '',

      referralCode:
          data['referralCode'] ??
              '',

      isInfluencer:
          data['isInfluencer'] ??
              false,

      influencerData:
          data['influencerData'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'full_name': fullName,

      'phone_number':
          phoneNumber,

      'influencerCouponCode':
          couponCode,

      'referralCode':
          referralCode,

      'isInfluencer':
          isInfluencer,

      'influencerData':
          influencerData,
    };
  }
}