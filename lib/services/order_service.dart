import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gladskin_backend/models/status_history_model.dart';
import 'package:gladskin_backend/models/tracking_model.dart';
import 'package:gladskin_backend/models/user_model.dart';
import 'package:gladskin_backend/services/config.dart';

import '../models/order_model.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

class PaginatedOrders {
  final List<OrderModel> orders;

  final QueryDocumentSnapshot? lastDocument;

  final bool hasMore;

  PaginatedOrders({
    required this.orders,
    required this.lastDocument,
    required this.hasMore,
  });
}

class OrderService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference get _orders =>
      _db.collection('Orders');

    /// Cache users to avoid repeated Firestore reads
  final Map<String, UserModel?> _userCache = {};


  /// ============================================================
  /// FETCH ORDERS
  /// ============================================================

  /// ============================================================
/// FETCH ORDERS (PAGINATED)
/// ============================================================

Future<PaginatedOrders> fetchOrders({
  QueryDocumentSnapshot? lastDoc,
  int limit = 15,
  String? status,
  String? searchText,
}) async {
  try {
    final bool isSearching =
        searchText != null &&
        searchText.trim().isNotEmpty;

    Query query = _orders.orderBy(
      'createdAt',
      descending: true,
    );

    if (status != null &&
        status.isNotEmpty &&
        status != "all") {
      query = query.where(
        "status",
        isEqualTo: status,
      );
    }

    // Only paginate when NOT searching
    if (!isSearching) {
      query = query.limit(limit);

      if (lastDoc != null) {
        query = query.startAfterDocument(lastDoc);
      }
    }

    final snapshot = await query.get();

    List<OrderModel> orders = await Future.wait(
      snapshot.docs.map((doc) async {
        var order = OrderModel.fromFirestore(doc);

        // Fill missing phone from Users collection
        if (order.customer.phone.trim().isEmpty) {
          try {
            final user = await fetchUser(order.uid);

            final phone = user?.phoneNumber?.trim();

            if (phone != null && phone.isNotEmpty) {
              order = order.copyWith(
                customer: order.customer.copyWith(
                  phone: phone,
                ),
              );
            }
          } catch (e) {
            debugPrint(
              "User lookup failed (${order.uid}): $e",
            );
          }
        }

        return order;
      }),
    );

    // Remove duplicate orders
    final Map<String, OrderModel> latestOrders = {};

    for (final order in orders) {
      String key;

      if (order.wooOrderId > 0) {
        key = "woo_${order.wooOrderId}";
      } else if (order.razorpayOrderId.isNotEmpty) {
        key = "rzp_${order.razorpayOrderId}";
      } else if (order.orderNumber.isNotEmpty) {
        key = "order_${order.orderNumber}";
      } else {
        key = order.id;
      }

      final existing = latestOrders[key];

      if (existing == null) {
        latestOrders[key] = order;
        continue;
      }

      final existingTime =
          existing.updatedAt ?? existing.createdAt;

      final currentTime =
          order.updatedAt ?? order.createdAt;

      if (existingTime == null ||
          (currentTime != null &&
              currentTime.toDate().isAfter(
                    existingTime.toDate(),
                  ))) {
        latestOrders[key] = order;
      }
    }

    orders = latestOrders.values.toList();

    // Remove invalid orders
    orders = orders
        .where(
          (o) => o.orderNumber.trim().isNotEmpty,
        )
        .toList();

    // Client-side search
    if (isSearching) {
      final keyword =
          searchText!.trim().toLowerCase();

      orders = orders.where((order) {
        final orderNumber =
            order.orderNumber.toLowerCase();

        final customerName =
            order.customer.name.toLowerCase();

        final phone =
            order.customer.phone
                .replaceAll(" ", "")
                .replaceAll("+91", "")
                .replaceAll("-", "")
                .toLowerCase();

        final search =
            keyword
                .replaceAll(" ", "")
                .replaceAll("+91", "")
                .replaceAll("-", "")
                .toLowerCase();

        return orderNumber.contains(search) ||
            customerName.contains(search) ||
            phone.contains(search);
      }).toList();
    }

    // Sort newest first
    orders.sort((a, b) {
      final aTime =
          a.createdAt?.millisecondsSinceEpoch ?? 0;

      final bTime =
          b.createdAt?.millisecondsSinceEpoch ?? 0;

      return bTime.compareTo(aTime);
    });

    return PaginatedOrders(
      orders: orders,
      lastDocument: isSearching
          ? null
          : (snapshot.docs.isNotEmpty
              ? snapshot.docs.last
              : null),
      hasMore: isSearching
          ? false
          : snapshot.docs.length == limit,
    );
  } catch (e) {
    debugPrint("❌ fetchOrders(): $e");
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

Future<UserModel?> fetchUser(String uid) async {
  if (_userCache.containsKey(uid)) {
    return _userCache[uid];
  }

  final doc = await FirebaseFirestore.instance
      .collection("Users")
      .doc(uid)
      .get();

  if (!doc.exists) {
    _userCache[uid] = null;
    return null;
  }

  final user = UserModel.fromFirestore(doc);

  _userCache[uid] = user;

  return user;
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