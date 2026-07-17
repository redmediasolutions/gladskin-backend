import 'package:flutter/material.dart';
import 'package:gladskin_backend/models/address_model.dart';
import 'package:gladskin_backend/models/order_model.dart';


class InvoiceCustomer extends StatelessWidget {
  final OrderModel order;

  const InvoiceCustomer({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _addressCard(
            title: "Billing Address",
            address: order.billing,
          ),
        ),

        const SizedBox(width: 24),

        Expanded(
          child: _addressCard(
            title: "Shipping Address",
            address: order.shippingAddress,
          ),
        ),
      ],
    );
  }

  Widget _addressCard({
    required String title,
    required AddressModel address,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.shade300,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          _value(
            "${address.firstName} ${address.lastName}"
                .trim(),
            bold: true,
          ),

          if ((address.company ?? "").isNotEmpty)
            _value(address.company!),

          _value(address.address1),

          if ((address.address2 ?? "").isNotEmpty)
            _value(address.address2!),

          _value(
            "${address.city}, ${address.state}",
          ),

          _value(address.postcode),

          _value(address.country),

          const SizedBox(height: 14),

          if ((address.phone ?? "").isNotEmpty)
            _infoRow(
              Icons.phone_outlined,
              address.phone!,
            ),

          if ((address.email ?? "").isNotEmpty)
            _infoRow(
              Icons.email_outlined,
              address.email!,
            ),
        ],
      ),
    );
  }

  Widget _value(
    String text, {
    bool bold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: TextStyle(
          fontWeight:
              bold
                  ? FontWeight.w600
                  : FontWeight.normal,
          fontSize: 14,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _infoRow(
    IconData icon,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}