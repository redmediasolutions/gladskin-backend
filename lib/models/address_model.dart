class AddressModel {
  final String firstName;

  final String lastName;

  final String company;

  final String address1;

  final String address2;

  final String city;

  final String state;

  final String postcode;

  final String country;

  final String email;

  final String phone;

  const AddressModel({
    required this.firstName,
    required this.lastName,
    required this.company,
    required this.address1,
    required this.address2,
    required this.city,
    required this.state,
    required this.postcode,
    required this.country,
    required this.email,
    required this.phone,
  });

  String get fullName =>
      "$firstName $lastName".trim();

  factory AddressModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return AddressModel(
      firstName:
          map['first_name']?.toString() ?? '',

      lastName:
          map['last_name']?.toString() ?? '',

      company:
          map['company']?.toString() ?? '',

      address1:
          map['address_1']?.toString() ?? '',

      address2:
          map['address_2']?.toString() ?? '',

      city:
          map['city']?.toString() ?? '',

      state:
          map['state']?.toString() ?? '',

      postcode:
          map['postcode']?.toString() ?? '',

      country:
          map['country']?.toString() ?? '',

      email:
          map['email']?.toString() ?? '',

      phone:
          map['phone']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'company': company,
      'address_1': address1,
      'address_2': address2,
      'city': city,
      'state': state,
      'postcode': postcode,
      'country': country,
      'email': email,
      'phone': phone,
    };
  }

  AddressModel copyWith({
    String? firstName,
    String? lastName,
    String? company,
    String? address1,
    String? address2,
    String? city,
    String? state,
    String? postcode,
    String? country,
    String? email,
    String? phone,
  }) {
    return AddressModel(
      firstName:
          firstName ?? this.firstName,
      lastName:
          lastName ?? this.lastName,
      company:
          company ?? this.company,
      address1:
          address1 ?? this.address1,
      address2:
          address2 ?? this.address2,
      city:
          city ?? this.city,
      state:
          state ?? this.state,
      postcode:
          postcode ?? this.postcode,
      country:
          country ?? this.country,
      email:
          email ?? this.email,
      phone:
          phone ?? this.phone,
    );
  }
}