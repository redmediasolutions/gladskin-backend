class CouponModel {
  final String id;

  final String code;

  final String type;

  final double discount;

  final bool isInfluencerCoupon;

  final String influencerId;

  final String influencerName;

  const CouponModel({
    required this.id,
    required this.code,
    required this.type,
    required this.discount,
    required this.isInfluencerCoupon,
    required this.influencerId,
    required this.influencerName,
  });

  factory CouponModel.fromMap(
    Map<String, dynamic>? map,
  ) {
    if (map == null) {
      return CouponModel.empty();
    }

    return CouponModel(
      id: map['id']?.toString() ?? '',

      code: map['code']?.toString() ?? '',

      type:
          map['type']?.toString() ??
              'fixed_cart',

      discount:
          (map['discount'] ?? 0).toDouble(),

      isInfluencerCoupon:
          map['isInfluencerCoupon'] ??
              false,

      influencerId:
          map['influencerId']
                  ?.toString() ??
              '',

      influencerName:
          map['influencerName']
                  ?.toString() ??
              '',
    );
  }

  factory CouponModel.empty() {
    return const CouponModel(
      id: '',
      code: '',
      type: '',
      discount: 0,
      isInfluencerCoupon: false,
      influencerId: '',
      influencerName: '',
    );
  }

  bool get hasCoupon =>
      code.isNotEmpty;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'type': type,
      'discount': discount,
      'isInfluencerCoupon':
          isInfluencerCoupon,
      'influencerId':
          influencerId,
      'influencerName':
          influencerName,
    };
  }

  CouponModel copyWith({
    String? id,
    String? code,
    String? type,
    double? discount,
    bool? isInfluencerCoupon,
    String? influencerId,
    String? influencerName,
  }) {
    return CouponModel(
      id: id ?? this.id,
      code: code ?? this.code,
      type: type ?? this.type,
      discount:
          discount ?? this.discount,
      isInfluencerCoupon:
          isInfluencerCoupon ??
              this.isInfluencerCoupon,
      influencerId:
          influencerId ??
              this.influencerId,
      influencerName:
          influencerName ??
              this.influencerName,
    );
  }
}