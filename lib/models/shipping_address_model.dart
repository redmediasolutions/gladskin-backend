class ShippingAddressModel {
  final String name;
  final String phone;
  final String address;
  final String city;
  final String state;
  final String postalCode;
  final String country;

  final String shippingMethod;
  final String trackingNumber;
  final String courier;

  const ShippingAddressModel({
    required this.name,
    required this.phone,
    required this.address,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    required this.shippingMethod,
    required this.trackingNumber,
    required this.courier,
  });

  factory ShippingAddressModel.fromMap(
    Map<String, dynamic>? map,
  ) {
    if (map == null) {
      return ShippingAddressModel.empty();
    }

    return ShippingAddressModel(
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      city: map['city'] ?? '',
      state: map['state'] ?? '',
      postalCode: map['postalCode'] ?? '',
      country: map['country'] ?? '',
      shippingMethod:
          map['shippingMethod'] ?? '',
      trackingNumber:
          map['trackingNumber'] ?? '',
      courier: map['courier'] ?? '',
    );
  }

  factory ShippingAddressModel.empty() {
    return const ShippingAddressModel(
      name: '',
      phone: '',
      address: '',
      city: '',
      state: '',
      postalCode: '',
      country: '',
      shippingMethod: '',
      trackingNumber: '',
      courier: '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'address': address,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'country': country,
      'shippingMethod': shippingMethod,
      'trackingNumber': trackingNumber,
      'courier': courier,
    };
  }
}