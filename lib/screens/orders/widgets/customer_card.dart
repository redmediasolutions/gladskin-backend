import 'package:flutter/material.dart';

import '../../../models/customer_model.dart';

class CustomerCard extends StatelessWidget {
  final CustomerModel customer;

  const CustomerCard({
    super.key,
    required this.customer,
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
                  Icons.person_outline,
                  size: 22,
                ),
                SizedBox(width: 8),
                Text(
                  "Customer",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Center(
              child: CircleAvatar(
                radius: 32,
                backgroundColor:
                    const Color(
                  0xFFF6ECEE,
                ),
                child: Text(
                  customer.name.isEmpty
                      ? "?"
                      : customer.name[0]
                          .toUpperCase(),
                  style:
                      const TextStyle(
                    fontSize: 24,
                    fontWeight:
                        FontWeight.bold,
                    color: Color(
                      0xFFB5838D,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            _infoTile(
              "Name",
              customer.name,
            ),

            _infoTile(
              "Phone",
              customer.phone,
            ),

            _infoTile(
              "Email",
              customer.email,
            ),

            _infoTile(
              "User ID",
              customer.uid,
            ),
          ],
        ),
      ),
    );
  }
}