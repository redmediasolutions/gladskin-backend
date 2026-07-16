class OrderItemModel {
  final int productId;

  final int variationId;

  final String name;

  final String sku;

  final int quantity;

  final double price;

  final double subtotal;

  final double total;

  final String image;

  const OrderItemModel({
    required this.productId,
    required this.variationId,
    required this.name,
    required this.sku,
    required this.quantity,
    required this.price,
    required this.subtotal,
    required this.total,
    required this.image,
  });

  factory OrderItemModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return OrderItemModel(
      productId:
          map['productId'] ?? 0,

      variationId:
          map['variationId'] ?? 0,

      name:
          map['name']?.toString() ?? '',

      sku:
          map['sku']?.toString() ?? '',

      quantity:
          map['quantity'] ?? 0,

      price:
          (map['price'] ?? 0).toDouble(),

      subtotal:
          (map['subtotal'] ?? 0).toDouble(),

      total:
          (map['total'] ?? 0).toDouble(),

      image:
          map['image']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'variationId': variationId,
      'name': name,
      'sku': sku,
      'quantity': quantity,
      'price': price,
      'subtotal': subtotal,
      'total': total,
      'image': image,
    };
  }

  OrderItemModel copyWith({
    int? productId,
    int? variationId,
    String? name,
    String? sku,
    int? quantity,
    double? price,
    double? subtotal,
    double? total,
    String? image,
  }) {
    return OrderItemModel(
      productId:
          productId ?? this.productId,

      variationId:
          variationId ??
              this.variationId,

      name: name ?? this.name,

      sku: sku ?? this.sku,

      quantity:
          quantity ?? this.quantity,

      price: price ?? this.price,

      subtotal:
          subtotal ?? this.subtotal,

      total: total ?? this.total,

      image: image ?? this.image,
    );
  }
}