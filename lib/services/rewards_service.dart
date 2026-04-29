import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/reward_transaction.dart';

class RewardsService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Stream wallet transactions for a user
  Stream<List<RewardTransaction>> streamRewardTransactions(String userId) {
    return _db
        .collection('users')                    // ← lowercase
        .doc(userId)
        .collection('walletTransactions')       // ← same subcollection name
        .orderBy('createdAt', descending: true)
        .snapshots()
        .handleError((e) => print('Error streaming transactions: $e'))
        .map((snap) =>
            snap.docs.map(RewardTransaction.fromFirestore).toList());
  }

  /// Adjust wallet points (credit / debit)
  Future<void> adjustPoints({
    required String userId,
    required int amount,
    required String type,
    required String status,
    String reason = 'Admin Adjustment',
  }) async {
    final userRef = _db.collection('users').doc(userId); // ← lowercase

    await _db.runTransaction((tx) async {
      final snap = await tx.get(userRef);
      final current = snap.data()?['rewardPoints'] ?? 0;

      final updated = type == 'credit' ? current + amount : current - amount;

      tx.update(userRef, {
        'rewardPoints': updated < 0 ? 0 : updated,
      });

      tx.set(
        userRef.collection('walletTransactions').doc(),
        {
          'type': type,
          'status': status,
          'amount': amount,
          'reason': reason,
          'createdAt': FieldValue.serverTimestamp(),
        },
      );
    });
  }
}