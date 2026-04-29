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
  });

  factory Customer.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    // ✅ Gladskin uses 'uid' field
    final authUid = (data['uid'] ?? doc.id).toString();

    return Customer(
      id: doc.id,
      authUid: authUid,
      name: data['full_name'] ?? '',            // ✅ Gladskin field
      email: data['email'] ?? '',
      phone: data['phoneNumber']?.toString() ?? '', // ✅ Gladskin field
      photoUrl: data['photo_url'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(), // ✅ Gladskin field
      isProfileComplete: data['isUserProfileComplete'] ?? false,
      isAnonymous: data['isAnonymous'] ?? false,
      isAdmin: data['isAdmin'] ?? false,
    );
  }

  List<String> toCsvRow() {
    return [
      id,
      authUid,
      name,
      email,
      phone,
      createdAt.toIso8601String(),
      isAnonymous ? 'Guest' : 'Registered',
      isAdmin ? 'Admin' : 'User',
      isProfileComplete ? 'Yes' : 'No',
    ];
  }
}