class OrderItemModel {
  final int productId;

  final String name;

  final String image;

  final String brand;

  final String packing;

  final int quantity;

  final double mrp;

  final double salePrice;

  final double lineSubtotal;

  final double lineTax;

  final double lineTotal;

  final double taxRate;

  final String taxClass;

  final String taxStatus;

  const OrderItemModel({
    required this.productId,
    required this.name,
    required this.image,
    required this.brand,
    required this.packing,
    required this.quantity,
    required this.mrp,
    required this.salePrice,
    required this.lineSubtotal,
    required this.lineTax,
    required this.lineTotal,
    required this.taxRate,
    required this.taxClass,
    required this.taxStatus,
  });

  factory OrderItemModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return OrderItemModel(
      productId:
          map["productId"] ?? 0,

      name:
          map["name"]?.toString() ??
              "",

      image:
          map["image"]?.toString() ??
              "",

      brand:
          map["brand"]?.toString() ??
              "",

      packing:
          map["packing"]?.toString() ??
              "",

      quantity:
          map["quantity"] ?? 0,

      mrp:
          (map["mrp"] ?? 0)
              .toDouble(),

      salePrice:
          (map["salePrice"] ?? 0)
              .toDouble(),

      lineSubtotal:
          (map["lineSubtotal"] ?? 0)
              .toDouble(),

      lineTax:
          (map["lineTax"] ?? 0)
              .toDouble(),

      lineTotal:
          (map["lineTotal"] ?? 0)
              .toDouble(),

      taxRate:
          (map["taxRate"] ?? 0)
              .toDouble(),

      taxClass:
          map["taxClass"]
                  ?.toString() ??
              "",

      taxStatus:
          map["taxStatus"]
                  ?.toString() ??
              "",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "productId": productId,
      "name": name,
      "image": image,
      "brand": brand,
      "packing": packing,
      "quantity": quantity,
      "mrp": mrp,
      "salePrice": salePrice,
      "lineSubtotal": lineSubtotal,
      "lineTax": lineTax,
      "lineTotal": lineTotal,
      "taxRate": taxRate,
      "taxClass": taxClass,
      "taxStatus": taxStatus,
    };
  }

  OrderItemModel copyWith({
    int? productId,
    String? name,
    String? image,
    String? brand,
    String? packing,
    int? quantity,
    double? mrp,
    double? salePrice,
    double? lineSubtotal,
    double? lineTax,
    double? lineTotal,
    double? taxRate,
    String? taxClass,
    String? taxStatus,
  }) {
    return OrderItemModel(
      productId:
          productId ??
              this.productId,

      name:
          name ?? this.name,

      image:
          image ?? this.image,

      brand:
          brand ?? this.brand,

      packing:
          packing ?? this.packing,

      quantity:
          quantity ?? this.quantity,

      mrp:
          mrp ?? this.mrp,

      salePrice:
          salePrice ??
              this.salePrice,

      lineSubtotal:
          lineSubtotal ??
              this.lineSubtotal,

      lineTax:
          lineTax ??
              this.lineTax,

      lineTotal:
          lineTotal ??
              this.lineTotal,

      taxRate:
          taxRate ??
              this.taxRate,

      taxClass:
          taxClass ??
              this.taxClass,

      taxStatus:
          taxStatus ??
              this.taxStatus,
    );
  }
}