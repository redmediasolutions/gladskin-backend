import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentModel {
  final String method;

  final String status;

  final String razorpayOrderId;

  final String razorpayPaymentId;

  final double amount;

  final String currency;

  final Timestamp? paidAt;

  const PaymentModel({
    required this.method,
    required this.status,
    required this.razorpayOrderId,
    required this.razorpayPaymentId,
    required this.amount,
    required this.currency,
    this.paidAt,
  });

  factory PaymentModel.fromMap(
    Map<String, dynamic> map,
  ) {
    double toDouble(dynamic value) {
      if (value == null) return 0;

      if (value is int) return value.toDouble();

      if (value is double) return value;

      return double.tryParse(
            value.toString(),
          ) ??
          0;
    }

    return PaymentModel(
      method:
          map['paymentMethod']
                  ?.toString() ??
              '',

      status:
          map['paymentStatus']
                  ?.toString() ??
              'pending',

      razorpayOrderId:
          map['razorpayOrderId']
                  ?.toString() ??
              '',

      razorpayPaymentId:
          map['razorpayPaymentId']
                  ?.toString() ??
              '',

      amount:
          toDouble(
        map['finalPayable'],
      ),

      currency:
          map['currency']
                  ?.toString() ??
              'INR',

      paidAt:
          map['paymentCapturedAt']
              as Timestamp?,
    );
  }

  bool get isPaid =>
      status.toLowerCase() == 'paid' ||
      status.toLowerCase() == 'captured';

  Map<String, dynamic> toMap() {
    return {
      'paymentMethod': method,
      'paymentStatus': status,
      'razorpayOrderId': razorpayOrderId,
      'razorpayPaymentId':
          razorpayPaymentId,
      'finalPayable': amount,
      'currency': currency,
      'paymentCapturedAt': paidAt,
    };
  }

  PaymentModel copyWith({
    String? method,
    String? status,
    String? razorpayOrderId,
    String? razorpayPaymentId,
    double? amount,
    String? currency,
    Timestamp? paidAt,
  }) {
    return PaymentModel(
      method: method ?? this.method,
      status: status ?? this.status,
      razorpayOrderId:
          razorpayOrderId ??
              this.razorpayOrderId,
      razorpayPaymentId:
          razorpayPaymentId ??
              this.razorpayPaymentId,
      amount: amount ?? this.amount,
      currency:
          currency ?? this.currency,
      paidAt: paidAt ?? this.paidAt,
    );
  }
}