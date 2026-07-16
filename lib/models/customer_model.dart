class CustomerModel {
  final String uid;

  final String name;

  final String phone;

  final String email;

  const CustomerModel({
    required this.uid,
    required this.name,
    required this.phone,
    required this.email,
  });

  factory CustomerModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return CustomerModel(
      uid: map['uid']?.toString() ?? '',

      name: map['name']?.toString() ?? '',

      phone: map['phone']?.toString() ?? '',

      email: map['email']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'phone': phone,
      'email': email,
    };
  }

  CustomerModel copyWith({
    String? uid,
    String? name,
    String? phone,
    String? email,
  }) {
    return CustomerModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
    );
  }
}