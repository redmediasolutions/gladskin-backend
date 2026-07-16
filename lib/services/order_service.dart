import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gladskin_backend/models/status_history_model.dart';

import '../models/order_model.dart';

class OrderService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference get _orders =>
      _db.collection('Orders');

  /// ============================================================
  /// FETCH ORDERS
  /// ============================================================

  Future<List<OrderModel>> fetchOrders({
    QueryDocumentSnapshot? lastDoc,
    int limit = 20,
    String? status,
    String? searchText,
  }) async {
    try {
      Query query = _orders
          .orderBy(
            'createdAt',
            descending: true,
          )
          .limit(limit);

      if (status != null &&
          status.isNotEmpty &&
          status != 'all') {
        query = query.where(
          'status',
          isEqualTo: status,
        );
      }

      if (lastDoc != null) {
        query = query.startAfterDocument(
          lastDoc,
        );
      }

      final snapshot = await query.get();

      List<OrderModel> orders =
          snapshot.docs
              .map(
                (e) => OrderModel.fromFirestore(
                  e,
                ),
              )
              .toList();

      /// Client side search
      if (searchText != null &&
          searchText.trim().isNotEmpty) {
        final keyword =
            searchText.toLowerCase();

        orders =
            orders.where((order) {
              return order.orderNumber
                      .toLowerCase()
                      .contains(keyword) ||
                  order.customer.name
                      .toLowerCase()
                      .contains(keyword) ||
                  order.customer.phone
                      .toLowerCase()
                      .contains(keyword);
            }).toList();
      }

      return orders;
    } catch (e) {
      print(
        "❌ fetchOrders(): $e",
      );

      rethrow;
    }
  }

  /// ============================================================
  /// FETCH SINGLE ORDER
  /// ============================================================

  Future<OrderModel?> fetchOrder(
    String orderId,
  ) async {
    try {
      final doc =
          await _orders.doc(orderId).get();

      if (!doc.exists) return null;

      return OrderModel.fromFirestore(doc);
    } catch (e) {
      print(
        "❌ fetchOrder(): $e",
      );

      rethrow;
    }
  }

  /// ============================================================
  /// WATCH ALL ORDERS
  /// ============================================================

  Stream<List<OrderModel>> watchOrders() {
    return _orders
        .orderBy(
          'createdAt',
          descending: true,
        )
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (e) =>
                    OrderModel.fromFirestore(e),
              )
              .toList(),
        );
  }

  /// ============================================================
  /// WATCH SINGLE ORDER
  /// ============================================================

  Stream<OrderModel> watchOrder(
    String orderId,
  ) {
    return _orders
        .doc(orderId)
        .snapshots()
        .map(
          (e) =>
              OrderModel.fromFirestore(e),
        );
  }

  /// ============================================================
  /// UPDATE STATUS
  /// ============================================================

  Future<void> updateOrderStatus({
  required String orderId,
  required String status,
  String performedBy = "Admin",
  String description = "",
}) async {
  try {
    await _orders.doc(orderId).update({
      'status': status,
      'updatedAt':
          FieldValue.serverTimestamp(),

      'statusHistory':
          FieldValue.arrayUnion([
        StatusHistoryModel(
          status: status,
          description: description,
          performedBy: performedBy,
          createdAt: Timestamp.now(),
        ).toMap(),
      ]),
    });

    debugPrint(
      "✅ Order status updated: $status",
    );
  } catch (e) {
    debugPrint(
      "❌ updateOrderStatus(): $e",
    );
    rethrow;
  }
}

  /// ============================================================
  /// UPDATE TRACKING
  /// ============================================================

  Future<void> updateTracking({
    required String orderId,
    required Map<String, dynamic>
        tracking,
  }) async {
    try {
      await _orders.doc(orderId).update({
        'tracking': tracking,
        'updatedAt':
            FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print(
        "❌ updateTracking(): $e",
      );

      rethrow;
    }
  }

  /// ============================================================
  /// UPDATE PAYMENT
  /// ============================================================

  Future<void> updatePayment({
    required String orderId,
    required Map<String, dynamic>
        payment,
  }) async {
    try {
      await _orders.doc(orderId).update({
        'payment': payment,
        'updatedAt':
            FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print(
        "❌ updatePayment(): $e",
      );

      rethrow;
    }
  }

  /// ============================================================
  /// DELETE ORDER
  /// ============================================================

  Future<void> deleteOrder(
    String orderId,
  ) async {
    try {
      await _orders.doc(orderId).delete();
    } catch (e) {
      print(
        "❌ deleteOrder(): $e",
      );

      rethrow;
    }
  }

  /// ============================================================
  /// WOOCOMMERCE SYNC (Coming later)
  /// ============================================================

  Future<void> syncToWooCommerce(
    String orderId,
  ) async {
    // TODO
  }

  Future<void> pullFromWooCommerce(
    String orderId,
  ) async {
    // TODO
  }

  Future<void> syncOrderStatus(
    String orderId,
  ) async {
    // TODO
  }

  Future<void> refundOrder(
    String orderId,
  ) async {
    // TODO
  }

  Future<void> cancelOrder(
    String orderId,
  ) async {
    // TODO
  }
}