class TotalsModel {
  final double subtotal;

  final double shipping;

  final double tax;

  final double grossTotal;

  final double discountedTotal;

  final double couponDiscount;

  final double walletUsed;

  final double walletBalance;

  final double codCharge;

  final double rewardAmount;

  final double finalPayable;

  const TotalsModel({
    required this.subtotal,
    required this.shipping,
    required this.tax,
    required this.grossTotal,
    required this.discountedTotal,
    required this.couponDiscount,
    required this.walletUsed,
    required this.walletBalance,
    required this.codCharge,
    required this.rewardAmount,
    required this.finalPayable,
  });

  factory TotalsModel.fromMap(
    Map<String, dynamic> map,
  ) {
    double _toDouble(dynamic value) {
      if (value == null) return 0;

      if (value is int) return value.toDouble();

      if (value is double) return value;

      return double.tryParse(
            value.toString(),
          ) ??
          0;
    }

    return TotalsModel(
      subtotal:
          _toDouble(map['subtotal']),

      shipping:
          _toDouble(map['shipping']),

      tax:
          _toDouble(map['tax']),

      grossTotal:
          _toDouble(map['grossTotal']),

      discountedTotal:
          _toDouble(
            map['discountedTotal'],
          ),

      couponDiscount:
          _toDouble(
            map['couponDiscount'],
          ),

      walletUsed:
          _toDouble(
            map['walletUsed'],
          ),

      walletBalance:
          _toDouble(
            map['walletBalance'],
          ),

      codCharge:
          _toDouble(
            map['codCharge'],
          ),

      rewardAmount:
          _toDouble(
            map['rewardAmount'],
          ),

      finalPayable:
          _toDouble(
            map['finalPayable'],
          ),
    );
  }

  factory TotalsModel.empty() {
    return const TotalsModel(
      subtotal: 0,
      shipping: 0,
      tax: 0,
      grossTotal: 0,
      discountedTotal: 0,
      couponDiscount: 0,
      walletUsed: 0,
      walletBalance: 0,
      codCharge: 0,
      rewardAmount: 0,
      finalPayable: 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'subtotal': subtotal,
      'shipping': shipping,
      'tax': tax,
      'grossTotal': grossTotal,
      'discountedTotal': discountedTotal,
      'couponDiscount': couponDiscount,
      'walletUsed': walletUsed,
      'walletBalance': walletBalance,
      'codCharge': codCharge,
      'rewardAmount': rewardAmount,
      'finalPayable': finalPayable,
    };
  }

  TotalsModel copyWith({
    double? subtotal,
    double? shipping,
    double? tax,
    double? grossTotal,
    double? discountedTotal,
    double? couponDiscount,
    double? walletUsed,
    double? walletBalance,
    double? codCharge,
    double? rewardAmount,
    double? finalPayable,
  }) {
    return TotalsModel(
      subtotal:
          subtotal ?? this.subtotal,

      shipping:
          shipping ?? this.shipping,

      tax:
          tax ?? this.tax,

      grossTotal:
          grossTotal ?? this.grossTotal,

      discountedTotal:
          discountedTotal ??
              this.discountedTotal,

      couponDiscount:
          couponDiscount ??
              this.couponDiscount,

      walletUsed:
          walletUsed ??
              this.walletUsed,

      walletBalance:
          walletBalance ??
              this.walletBalance,

      codCharge:
          codCharge ??
              this.codCharge,

      rewardAmount:
          rewardAmount ??
              this.rewardAmount,

      finalPayable:
          finalPayable ??
              this.finalPayable,
    );
  }
}