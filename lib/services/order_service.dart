import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gladskin_backend/models/status_history_model.dart';
import 'package:gladskin_backend/models/tracking_model.dart';
import 'package:gladskin_backend/models/user_model.dart';
import 'package:gladskin_backend/services/config.dart';

import '../models/order_model.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

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
      query = query.startAfterDocument(lastDoc);
    }

    final snapshot = await query.get();

    final List<OrderModel> orders = [];

    for (final doc in snapshot.docs) {
      final order = OrderModel.fromFirestore(doc);

      // Fallback to Users table if phone is missing
      if (order.customer.phone.trim().isEmpty) {
        try {
          final user = await fetchUser(order.uid);

         if (user?.phoneNumber?.trim().isNotEmpty == true) {
}
        } catch (_) {
          // Ignore if user not found
        }
      }

      orders.add(order);
    }

    // Client-side search
    if (searchText != null &&
        searchText.trim().isNotEmpty) {
      final keyword = searchText.toLowerCase();

      return orders.where((order) {
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
    print("❌ fetchOrders(): $e");
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

  Future<void> updateFirestoreOrderStatus({
  required String orderId,
  required String status,
}) async {
  await FirebaseFirestore.instance
      .collection("Orders")
      .doc(orderId)
      .update({
    "status": status,
    "wooStatus": status,
    "updatedAt": FieldValue.serverTimestamp(),
    "wooUpdatedAt": Timestamp.now(),
    "statusHistory": FieldValue.arrayUnion([
      {
        "status": status,
        "at": Timestamp.now(),
      }
    ]),
  });
}

Future<void> updateWooCommerceOrderStatus({
  required int wooOrderId,
  required String status,
}) async {
  final auth = base64Encode(
    utf8.encode(
      "${Config.consumerKey}:${Config.consumerSecret}",
    ),
  );

  final response = await http.put(
    Uri.parse(
      "${Config.baseUrl}${Config.apiPath}wc/v3/orders/$wooOrderId",
    ),
    headers: {
      "Authorization": "Basic $auth",
      "Content-Type": "application/json",
    },
    body: jsonEncode({
      "status": status,
    }),
  );

  if (response.statusCode != 200) {
    throw Exception(
      "WooCommerce update failed:\n${response.body}",
    );
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
  Future<UserModel?> fetchUser(
  String uid,
) async {
  final doc =
      await FirebaseFirestore.instance
          .collection("Users")
          .doc(uid)
          .get();

  if (!doc.exists) {
    return null;
  }

  return UserModel.fromFirestore(doc);
}


Future<void> updateTrackingInfo({
  required String orderId,
  required TrackingInfo tracking,
}) async {
  final trackingUrl =
      tracking.trackingUrl ??
          _buildTrackingUrl(
            tracking.courier,
            tracking.trackingNumber,
          );

  await FirebaseFirestore.instance
      .collection("Orders")
      .doc(orderId)
      .update({
    "tracking": {
      "courier": tracking.courier,
      "trackingNumber": tracking.trackingNumber,
      "trackingUrl": trackingUrl,
      "notes": tracking.notes ?? "",
      "updatedAt": Timestamp.now(),
    },

    "updatedAt":
        FieldValue.serverTimestamp(),
  });
}

String _buildTrackingUrl(
  String courier,
  String trackingNumber,
) {
  switch (courier.toLowerCase()) {
    case "delhivery":
      return "https://www.delhivery.com/track/package/$trackingNumber";

    case "bluedart":
    case "blue dart":
      return "https://www.bluedart.com/tracking?tracking=$trackingNumber";

    case "dtdc":
      return "https://www.dtdc.in/tracking/tracking_results.asp?strcnno=$trackingNumber";

    case "xpressbees":
      return "https://www.xpressbees.com/shipment/tracking/$trackingNumber";

    case "ekart":
      return "https://ekartlogistics.com/shipmenttrack/$trackingNumber";

    case "speed post":
    case "india post":
      return "https://www.indiapost.gov.in/_layouts/15/dop.portal.tracking/trackconsignment.aspx?ConsignmentNo=$trackingNumber";

    default:
      return "";
  }
}

}