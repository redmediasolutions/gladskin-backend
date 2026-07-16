class GstBreakupModel {
  final double cgst;

  final double sgst;

  final double igst;

  final double cess;

  final Map<String, dynamic> extra;

  const GstBreakupModel({
    required this.cgst,
    required this.sgst,
    required this.igst,
    required this.cess,
    required this.extra,
  });

  factory GstBreakupModel.fromMap(
    Map<String, dynamic>? map,
  ) {
    if (map == null) {
      return GstBreakupModel.empty();
    }

    double toDouble(dynamic value) {
      if (value == null) return 0;

      if (value is int) return value.toDouble();

      if (value is double) return value;

      return double.tryParse(
            value.toString(),
          ) ??
          0;
    }

    final extra =
        Map<String, dynamic>.from(map);

    extra.remove('cgst');
    extra.remove('sgst');
    extra.remove('igst');
    extra.remove('cess');

    return GstBreakupModel(
      cgst: toDouble(map['cgst']),
      sgst: toDouble(map['sgst']),
      igst: toDouble(map['igst']),
      cess: toDouble(map['cess']),
      extra: extra,
    );
  }

  factory GstBreakupModel.empty() {
    return const GstBreakupModel(
      cgst: 0,
      sgst: 0,
      igst: 0,
      cess: 0,
      extra: {},
    );
  }

  double get total =>
      cgst + sgst + igst + cess;

  Map<String, dynamic> toMap() {
    return {
      'cgst': cgst,
      'sgst': sgst,
      'igst': igst,
      'cess': cess,
      ...extra,
    };
  }

  GstBreakupModel copyWith({
    double? cgst,
    double? sgst,
    double? igst,
    double? cess,
    Map<String, dynamic>? extra,
  }) {
    return GstBreakupModel(
      cgst: cgst ?? this.cgst,
      sgst: sgst ?? this.sgst,
      igst: igst ?? this.igst,
      cess: cess ?? this.cess,
      extra: extra ?? this.extra,
    );
  }
}