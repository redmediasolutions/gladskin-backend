import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gladskin_backend/models/coupon_model.dart';
import 'package:gladskin_backend/models/influencer_model.dart';
import 'package:gladskin_backend/models/reward_withdrawal.dart';

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
  try {
    Query query =
        _db.collection('Users');

    /// SEARCH BY PHONE
    if (searchText != null &&
        searchText.trim().isNotEmpty) {
      final snapshot =
          await query
              .where(
                'phoneNumber',
                isEqualTo:
                    searchText.trim(),
              )
              .limit(limit)
              .get();

      return snapshot.docs;
    }

    /// LOAD ALL USERS
    final snapshot =
        await query.get();

    final docs =
        snapshot.docs.toList();

    /// SORT USING createdAt OR created_time
    docs.sort((a, b) {
      final aData =
          a.data()
              as Map<String, dynamic>;

      final bData =
          b.data()
              as Map<String, dynamic>;

      final aDate =
          (aData['createdAt']
                      as Timestamp?) ??
              (aData['created_time']
                  as Timestamp?);

      final bDate =
          (bData['createdAt']
                      as Timestamp?) ??
              (bData['created_time']
                  as Timestamp?);

      final aMillis =
          aDate?.millisecondsSinceEpoch ??
              0;

      final bMillis =
          bDate?.millisecondsSinceEpoch ??
              0;

      return bMillis.compareTo(
          aMillis);
    });

    /// DATE FILTER
    List<QueryDocumentSnapshot>
        filteredDocs = docs;

    if (startDate != null) {
      filteredDocs =
          filteredDocs.where((doc) {
        final data =
            doc.data()
                as Map<String, dynamic>;

        final ts =
            (data['createdAt']
                        as Timestamp?) ??
                (data['created_time']
                    as Timestamp?);

        if (ts == null) return false;

        return ts
            .toDate()
            .isAfter(
              startDate.subtract(
                const Duration(
                    seconds: 1),
              ),
            );
      }).toList();
    }

    if (endDate != null) {
      final endOfDay =
          DateTime(
        endDate.year,
        endDate.month,
        endDate.day,
        23,
        59,
        59,
      );

      filteredDocs =
          filteredDocs.where((doc) {
        final data =
            doc.data()
                as Map<String, dynamic>;

        final ts =
            (data['createdAt']
                        as Timestamp?) ??
                (data['created_time']
                    as Timestamp?);

        if (ts == null) return false;

        return ts
            .toDate()
            .isBefore(
              endOfDay.add(
                const Duration(
                    seconds: 1),
              ),
            );
      }).toList();
    }

    /// MANUAL PAGINATION
    int startIndex = 0;

    if (lastDoc != null) {
      startIndex =
          filteredDocs.indexWhere(
                (d) =>
                    d.id ==
                    lastDoc.id,
              ) +
              1;

      if (startIndex < 0) {
        startIndex = 0;
      }
    }

    final endIndex =
        (startIndex + limit)
            .clamp(
      0,
      filteredDocs.length,
    );

    return filteredDocs.sublist(
      startIndex,
      endIndex,
    );
  } catch (e) {
    print(
      '❌ Error fetching Users: $e',
    );
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

Future<List<RewardWithdrawal>>
    fetchRewardWithdrawals() async {

  print(
    '📥 Loading reward withdrawals...',
  );

  final snap =
      await FirebaseFirestore.instance
          .collection('rewardWithdrawals')
          .get();

  print(
    '📊 Docs Found: ${snap.docs.length}',
  );

  final List<RewardWithdrawal>
      withdrawals = [];

  for (final doc in snap.docs) {

    final data =
        doc.data();

    final uid =
        data['uid'] ?? '';

    print(
      '🔍 Looking up user: $uid',
    );

    String customerName = '';
    String phoneNumber = '';

    try {

      final userSnap =
          await FirebaseFirestore
              .instance
              .collection('Users')
              .doc(uid)
              .get();

      if (userSnap.exists) {

        final userData =
            userSnap.data()!;

        customerName =
            userData['full_name'] ??
                '';

        phoneNumber =
            userData['phone_number']
                    ?.toString() ??
                '';

        print(
          '👤 User Found: $customerName ($phoneNumber)',
        );
      }

    } catch (e) {

      print(
        '❌ User Lookup Failed: $uid',
      );

      print(e);
    }

    withdrawals.add(
      RewardWithdrawal(
        id: doc.id,

        uid: uid,

        customerName:
            customerName,

        phoneNumber:
            phoneNumber,

        amount:
            ((data['amount'] ?? 0)
                    as num)
                .toDouble(),

        upiId:
            data['upiId'] ?? '',

        status:
            data['status'] ??
                'pending',

        createdAt:
            (data['createdAt']
                    as Timestamp?)
                ?.toDate(),

        approvedAt:
            (data['approvedAt']
                    as Timestamp?)
                ?.toDate(),
      ),
    );
  }

  print(
    '✅ Parsed Withdrawals: ${withdrawals.length}',
  );

  return withdrawals;
}

Future<void> approveRewardWithdrawal(
  String withdrawalId,
) async {

  final db = FirebaseFirestore.instance;

  await db.runTransaction((tx) async {

    final withdrawalRef =
        db.collection('rewardWithdrawals')
            .doc(withdrawalId);

    final withdrawalSnap =
        await tx.get(withdrawalRef);

    if (!withdrawalSnap.exists) {
      throw Exception(
        'Withdrawal not found',
      );
    }

    final withdrawalData =
        withdrawalSnap.data()!;

    final uid =
        withdrawalData['uid'];

    /// Update withdrawal request
    tx.update(
      withdrawalRef,
      {
        'status': 'approved',
        'approvedAt':
            FieldValue.serverTimestamp(),
      },
    );
    //TEST 91823

    /// Find matching wallet transaction
    final walletTxQuery =
        await db
            .collection('Users')
            .doc(uid)
            .collection(
              'walletTransactions',
            )
            .where(
              'withdrawalId',
              isEqualTo: withdrawalId,
            )
            .limit(1)
            .get();

    if (walletTxQuery.docs.isNotEmpty) {

      final walletTxRef =
          walletTxQuery.docs.first.reference;

      tx.update(
        walletTxRef,
        {
          'status': 'approved',
          'approvedAt':
              FieldValue.serverTimestamp(),
        },
      );
    }
  });
}

Future<void> rejectRewardWithdrawal(
  String id,
) async {

  await FirebaseFirestore.instance
      .collection(
        'rewardWithdrawals',
      )
      .doc(id)
      .update({

    'status': 'rejected',

    'rejectedAt':
        FieldValue.serverTimestamp(),
  });
}
}