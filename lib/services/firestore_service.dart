import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<QueryDocumentSnapshot>> fetchUsersPage({
    QueryDocumentSnapshot? lastDoc,
    int limit = 20,
    String? searchText,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    Query query;

    if (searchText != null && searchText.trim().isNotEmpty) {
      // ✅ Gladskin uses 'phoneNumber' not 'phone_number'
      query = _db
          .collection('users')
          .where('phoneNumber', isEqualTo: searchText.trim())
          .limit(limit);
    } else {
      // ✅ Gladskin uses 'createdAt' not 'created_time'
      query = _db
          .collection('users')
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (startDate != null) {
        query = query.where(
          'createdAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
        );
      }

      if (endDate != null) {
        final endOfDay =
            DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
        query = query.where(
          'createdAt',
          isLessThanOrEqualTo: Timestamp.fromDate(endOfDay),
        );
      }

      if (lastDoc != null) {
        query = query.startAfterDocument(lastDoc);
      }
    }

    try {
      final snapshot = await query.get();
      return snapshot.docs;
    } catch (e) {
      print('❌ Error fetching users: $e');
      rethrow;
    }
  }
}