import 'package:cloud_firestore/cloud_firestore.dart';

import 'address_model.dart';
import 'coupon_order_model.dart';
import 'customer_model.dart';
import 'order_item_model.dart';
import 'status_history_model.dart';

class OrderModel {
  final String id;

  final String uid;

  final String orderNumber;

  final int wooOrderId;

  final String status;

  final String wooStatus;

  // PAYMENT
  final String paymentMethod;

  final String paymentStatus;

  final String razorpayOrderId;

  final String razorpayPaymentId;

  final Timestamp? paymentCapturedAt;

  // TOTALS
  final double subtotal;

  final double shipping;

  final double tax;

  final double grossTotal;

  final double discountedTotal;

  final double finalPayable;

  final double couponDiscount;

  final double walletUsed;

  final double walletBalance;

  final double codCharge;

  // REWARD
  final double rewardAmount;

  final bool rewardReleased;

  final bool rewardReversed;

  final Timestamp? rewardReleasedAt;

  final String referralRewardStatus;

  final String referralRewardGivenTo;

  // TRACKING
  final String trackingNumber;

  final String trackingUrl;

  final String courierName;

  final Timestamp? shippedAt;

  final Timestamp? deliveredAt;

  // STATS
  final int itemCount;

  final int totalQuantity;

  // GST
  final Map<String, dynamic> gstBreakup;

  final Map<String, dynamic> taxableBreakup;

  // OBJECTS
  final CustomerModel customer;

  final AddressModel billing;

  final AddressModel shippingAddress;

  final CouponModel coupon;

  final List<OrderItemModel> items;

  final List<StatusHistoryModel> statusHistory;

  final Timestamp? createdAt;

  final Timestamp? updatedAt;

  const OrderModel({
    required this.id,
    required this.uid,
    required this.orderNumber,
    required this.wooOrderId,
    required this.status,
    required this.wooStatus,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.razorpayOrderId,
    required this.razorpayPaymentId,
    this.paymentCapturedAt,
    required this.subtotal,
    required this.shipping,
    required this.tax,
    required this.grossTotal,
    required this.discountedTotal,
    required this.finalPayable,
    required this.couponDiscount,
    required this.walletUsed,
    required this.walletBalance,
    required this.codCharge,
    required this.rewardAmount,
    required this.rewardReleased,
    required this.rewardReversed,
    this.rewardReleasedAt,
    required this.referralRewardStatus,
    required this.referralRewardGivenTo,
    required this.trackingNumber,
    required this.trackingUrl,
    required this.courierName,
    this.shippedAt,
    this.deliveredAt,
    required this.itemCount,
    required this.totalQuantity,
    required this.gstBreakup,
    required this.taxableBreakup,
    required this.customer,
    required this.billing,
    required this.shippingAddress,
    required this.coupon,
    required this.items,
    required this.statusHistory,
    this.createdAt,
    this.updatedAt,
  });

  factory OrderModel.fromFirestore(
    DocumentSnapshot doc,
  ) {
    final map =
        doc.data() as Map<String, dynamic>;

    return OrderModel(
      id: doc.id,

      uid: map['uid'] ?? '',

      orderNumber:
          map['orderNumber'] ?? '',

      wooOrderId:
          map['wooOrderId'] ?? 0,

      status:
          map['status'] ?? '',

      wooStatus:
          map['wooStatus'] ?? '',

      paymentMethod:
          map['paymentMethod'] ?? '',

      paymentStatus:
          map['paymentStatus'] ?? '',

      razorpayOrderId:
          map['razorpayOrderId'] ?? '',

      razorpayPaymentId:
          map['razorpayPaymentId'] ?? '',

      paymentCapturedAt:
          map['paymentCapturedAt'],

      subtotal:
          (map['subtotal'] ?? 0).toDouble(),

      shipping:
          (map['shipping'] ?? 0).toDouble(),

      tax:
          (map['tax'] ?? 0).toDouble(),

      grossTotal:
          (map['grossTotal'] ?? 0).toDouble(),

      discountedTotal:
          (map['discountedTotal'] ?? 0)
              .toDouble(),

      finalPayable:
          (map['finalPayable'] ?? 0)
              .toDouble(),

      couponDiscount:
          (map['couponDiscount'] ?? 0)
              .toDouble(),

      walletUsed:
          (map['walletUsed'] ?? 0)
              .toDouble(),

      walletBalance:
          (map['walletBalance'] ?? 0)
              .toDouble(),

      codCharge:
          (map['codCharge'] ?? 0)
              .toDouble(),

      rewardAmount:
          (map['rewardAmount'] ?? 0)
              .toDouble(),

      rewardReleased:
          map['rewardReleased'] ?? false,

      rewardReversed:
          map['rewardReversed'] ?? false,

      rewardReleasedAt:
          map['rewardReleasedAt'],

      referralRewardStatus:
          map['referralRewardStatus'] ?? '',

      referralRewardGivenTo:
          map['referralRewardGivenTo'] ?? '',

      trackingNumber:
          map['trackingNumber'] ?? '',

      trackingUrl:
          map['trackingUrl'] ?? '',

      courierName:
          map['courierName'] ?? '',

      shippedAt:
          map['shippedAt'],

      deliveredAt:
          map['deliveredAt'],

      itemCount:
          map['itemCount'] ?? 0,

      totalQuantity:
          map['totalQuantity'] ?? 0,

      gstBreakup:
          Map<String, dynamic>.from(
        map['gstBreakup'] ?? {},
      ),

      taxableBreakup:
          Map<String, dynamic>.from(
        map['taxableBreakup'] ?? {},
      ),

      customer:
          CustomerModel.fromMap(
        Map<String, dynamic>.from(
          map['customer'] ?? {},
        ),
      ),

      billing:
          AddressModel.fromMap(
        Map<String, dynamic>.from(
          map['billing'] ?? {},
        ),
      ),

      shippingAddress:
          AddressModel.fromMap(
        Map<String, dynamic>.from(
          map['shippingAddress'] ?? {},
        ),
      ),

      coupon:
          CouponModel.fromMap(
        Map<String, dynamic>.from(
          map['coupon'] ?? {},
        ),
      ),

      items:
          (map['items']
                      as List<dynamic>? ??
                  [])
              .map(
                (e) =>
                    OrderItemModel.fromMap(
                  Map<String, dynamic>.from(
                    e,
                  ),
                ),
              )
              .toList(),

      statusHistory:
          (map['statusHistory']
                      as List<dynamic>? ??
                  [])
              .map(
                (e) =>
                    StatusHistoryModel.fromMap(
                  Map<String, dynamic>.from(
                    e,
                  ),
                ),
              )
              .toList(),

      createdAt:
          map['createdAt'],

      updatedAt:
          map['updatedAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'orderNumber': orderNumber,
      'wooOrderId': wooOrderId,
      'status': status,
      'wooStatus': wooStatus,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'razorpayOrderId': razorpayOrderId,
      'razorpayPaymentId': razorpayPaymentId,
      'paymentCapturedAt': paymentCapturedAt,
      'subtotal': subtotal,
      'shipping': shipping,
      'tax': tax,
      'grossTotal': grossTotal,
      'discountedTotal': discountedTotal,
      'finalPayable': finalPayable,
      'couponDiscount': couponDiscount,
      'walletUsed': walletUsed,
      'walletBalance': walletBalance,
      'codCharge': codCharge,
      'rewardAmount': rewardAmount,
      'rewardReleased': rewardReleased,
      'rewardReversed': rewardReversed,
      'rewardReleasedAt': rewardReleasedAt,
      'referralRewardStatus': referralRewardStatus,
      'referralRewardGivenTo': referralRewardGivenTo,
      'trackingNumber': trackingNumber,
      'trackingUrl': trackingUrl,
      'courierName': courierName,
      'shippedAt': shippedAt,
      'deliveredAt': deliveredAt,
      'itemCount': itemCount,
      'totalQuantity': totalQuantity,
      'gstBreakup': gstBreakup,
      'taxableBreakup': taxableBreakup,
      'customer': customer.toMap(),
      'billing': billing.toMap(),
      'shippingAddress': shippingAddress.toMap(),
      'coupon': coupon.toMap(),
      'items': items.map((e) => e.toMap()).toList(),
      'statusHistory':
          statusHistory.map((e) => e.toMap()).toList(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}