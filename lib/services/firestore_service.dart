import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gladskin_backend/models/coupon_model.dart';
import 'package:gladskin_backend/models/influencer_model.dart';

class FirestoreService {
  final FirebaseFirestore _db =
      FirebaseFirestore.instance;

  /// ================= Users =================

  Future<List<QueryDocumentSnapshot>>
      fetchUsersPage({
    QueryDocumentSnapshot? lastDoc,
    int limit = 20,
    String? searchText,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    Query query;

    if (searchText != null &&
        searchText.trim().isNotEmpty) {
      query = _db
          .collection('Users')
          .where(
            'phoneNumber',
            isEqualTo: searchText.trim(),
          )
          .limit(limit);
    } else {
      query = _db
          .collection('Users')
          .orderBy(
            'createdAt',
            descending: true,
          )
          .limit(limit);

      if (startDate != null) {
        query = query.where(
          'createdAt',
          isGreaterThanOrEqualTo:
              Timestamp.fromDate(startDate),
        );
      }

      if (endDate != null) {
        final endOfDay = DateTime(
          endDate.year,
          endDate.month,
          endDate.day,
          23,
          59,
          59,
        );

        query = query.where(
          'createdAt',
          isLessThanOrEqualTo:
              Timestamp.fromDate(endOfDay),
        );
      }

      if (lastDoc != null) {
        query = query.startAfterDocument(
          lastDoc,
        );
      }
    }

    try {
      final snapshot = await query.get();

      return snapshot.docs;
    } catch (e) {
      print('❌ Error fetching Users: $e');
      rethrow;
    }
  }

  /// ================= COUPONS =================

  Future<List<CouponModel>>
      fetchCoupons({
    QueryDocumentSnapshot? lastDoc,
    int limit = 20,
    String? searchText,
  }) async {
    Query query;

    if (searchText != null &&
        searchText.trim().isNotEmpty) {
      query = _db
          .collection('coupons')
          .where(
            'code',
            isEqualTo:
                searchText.trim().toUpperCase(),
          )
          .limit(limit);
    } else {
      query = _db
          .collection('coupons')
          .orderBy(
            'createdAt',
            descending: true,
          )
          .limit(limit);

      if (lastDoc != null) {
        query = query.startAfterDocument(
          lastDoc,
        );
      }
    }

    try {
      final snapshot = await query.get();

      return snapshot.docs
          .map(
            (doc) =>
                CouponModel.fromFirestore(doc),
          )
          .toList();
    } catch (e) {
      print('❌ Error fetching coupons: $e');
      rethrow;
    }
  }

  /// CREATE COUPON
  Future<void> createCoupon({
    required CouponModel coupon,
  }) async {
    try {
      await _db
          .collection('coupons')
          .add(coupon.toMap());
    } catch (e) {
      print('❌ Error creating coupon: $e');
      rethrow;
    }
  }

  /// UPDATE COUPON
  Future<void> updateCoupon({
    required String couponId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _db
          .collection('coupons')
          .doc(couponId)
          .update(data);
    } catch (e) {
      print('❌ Error updating coupon: $e');
      rethrow;
    }
  }

  /// DELETE COUPON
  Future<void> deleteCoupon(
    String couponId,
  ) async {
    try {
      await _db
          .collection('coupons')
          .doc(couponId)
          .delete();
    } catch (e) {
      print('❌ Error deleting coupon: $e');
      rethrow;
    }
  }

  /// ================= INFLUENCERS =================

Stream<List<InfluencerModel>>
    getInfluencers() {
  return _db
      .collection('Users')
      .where(
        'isInfluencer',
        isEqualTo: true,
      )
      .snapshots()
      .map(
        (snapshot) =>
            snapshot.docs
                .map(
                  (doc) =>
                      InfluencerModel
                          .fromFirestore(
                    doc,
                  ),
                )
                .toList(),
      );
}

/// REMOVE INFLUENCER
Future<void> removeInfluencer(
  String userId,
) async {
  try {
    await _db
        .collection('Users')
        .doc(userId)
        .update({
      'isInfluencer': false,

      'influencerCouponCode':
          FieldValue.delete(),

      'influencerData':
          FieldValue.delete(),
    });
  } catch (e) {
    print(
      '❌ Error removing influencer: $e',
    );

    rethrow;
  }
}
}