class OrderTotalsModel {
  final double subTotal;

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

  const OrderTotalsModel({
    required this.subTotal,
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

  factory OrderTotalsModel.fromMap(
    Map<String, dynamic>? map,
  ) {
    if (map == null) {
      return OrderTotalsModel.empty();
    }

    return OrderTotalsModel(
      subTotal:
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

      finalPayable:
          (map['finalPayable'] ?? 0)
              .toDouble(),
    );
  }

  factory OrderTotalsModel.empty() {
    return const OrderTotalsModel(
      subTotal: 0,
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
      'subtotal': subTotal,
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

  OrderTotalsModel copyWith({
    double? subTotal,
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
    return OrderTotalsModel(
      subTotal:
          subTotal ?? this.subTotal,
      shipping:
          shipping ?? this.shipping,
      tax: tax ?? this.tax,
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