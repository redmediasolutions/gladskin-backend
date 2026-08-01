import 'package:cloud_firestore/cloud_firestore.dart';


class Customer {
  final String id;
  final String authUid;
  final String name;
  final String email;
  final String phone;
  final String photoUrl;
  final DateTime createdAt;
  final bool isProfileComplete;
  final bool isAnonymous;
  final bool isAdmin;

  /// NEW
  final String referredBy;
  final String influencerCode;

  Customer({
    required this.id,
    required this.authUid,
    required this.name,
    required this.email,
    required this.phone,
    required this.photoUrl,
    required this.createdAt,
    required this.isProfileComplete,
    required this.isAnonymous,
    required this.isAdmin,

    /// NEW
    required this.referredBy,
    required this.influencerCode,
  });

  factory Customer.fromFirestore(
    DocumentSnapshot doc,
  ) {
    final data =
        doc.data()
            as Map<String, dynamic>? ??
        {};

    final authUid =
        (data['uid'] ?? doc.id)
            .toString();

    return Customer(
      id: doc.id,

      authUid: authUid,

      name:
          data['full_name'] ?? '',

      email:
          data['email'] ?? '',

      phone:
          data['phoneNumber']
                  ?.toString() ??
              '',

      photoUrl:
          data['photo_url'] ?? '',

      createdAt:
          (data['createdAt']
                      as Timestamp?)
                  ?.toDate() ??
              DateTime.now(),

      isProfileComplete:
          data[
                  'isUserProfileComplete'] ??
              false,

      isAnonymous:
          data['isAnonymous'] ??
              false,

      isAdmin:
          data['isAdmin'] ??
              false,

      /// NEW
      referredBy:
          data['referredBy'] ??
              '',

      influencerCode:
          data['influencerCode'] ??
              '',
    );
  }

  List<String> toCsvRow() {
    return [
      id,

      authUid,

      name,

      email,

      phone,

      createdAt
          .toIso8601String(),

      isAnonymous
          ? 'Guest'
          : 'Registered',

      isAdmin
          ? 'Admin'
          : 'User',

      isProfileComplete
          ? 'Yes'
          : 'No',

      /// NEW
      influencerCode,

      referredBy,
    ];
  }
}
  final rows = <List<String>>[
  [
    'ID',
    'Auth UID',
    'Name',
    'Email',
    'Phone',
    'Joined Date',
    'User Type',
    'Role',
    'Profile Complete',
    'Influencer Code',
    'Referral Code',
  ],
];