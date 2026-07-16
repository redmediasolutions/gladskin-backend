import 'package:flutter/material.dart';

import '../../../models/address_model.dart';

class ShippingCard extends StatelessWidget {
  final AddressModel address;

  const ShippingCard({
    super.key,
    required this.address,
  });

  Widget _infoTile(
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 14,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          SelectableText(
            value.isEmpty ? "-" : value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fullAddress = [
      address.address1,
      address.address2,
    ].where((e) => e.isNotEmpty).join(", ");

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.grey.shade200,
        ),
      ),
      child: Padding(
        padding:
            const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.local_shipping_outlined,
                ),
                SizedBox(width: 8),
                Text(
                  "Shipping Address",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            _infoTile(
              "Recipient",
              address.fullName,
            ),

            _infoTile(
              "Phone",
              address.phone,
            ),

            if (address.email.isNotEmpty)
              _infoTile(
                "Email",
                address.email,
              ),

            _infoTile(
              "Address",
              fullAddress,
            ),

            _infoTile(
              "City",
              address.city,
            ),

            _infoTile(
              "State",
              address.state,
            ),

            _infoTile(
              "Postal Code",
              address.postcode,
            ),

            _infoTile(
              "Country",
              address.country,
            ),

            if (address.company.isNotEmpty)
              _infoTile(
                "Company",
                address.company,
              ),
          ],
        ),
      ),
    );
  }
}