import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gladskin_backend/models/order_model.dart';
import 'package:intl/intl.dart';


class InvoiceHeader extends StatelessWidget {
  final OrderModel order;

  const InvoiceHeader({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 2,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: const [
                  Text(
                    "GladSkin",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "Tax Invoice",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 24),

            SizedBox(
              width: 320,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _row(
                      "Invoice No",
                      order.orderNumber ?? order.id,
                    ),
                    _row(
                      "Order No",
                      order.orderNumber ?? "-",
                    ),
                    _row(
                      "Woo Order",
                      order.wooOrderId?.toString() ??
                          "-",
                    ),
                    _row(
                      "Date",
                      _formatDate(
                        order.createdAt,
                      ),
                    ),
                    _row(
                      "Status",
                      order.status,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 32),

        Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _infoCard(
                title: "Payment",
                children: [
                  _row(
                    "Method",
                    order.paymentMethod,
                  ),
                  _row(
                    "Status",
                    order.paymentStatus,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 20),

            Expanded(
              child: _infoCard(
                title: "Invoice Summary",
                children: [
                  _row(
                    "Items",
                    order.items.length.toString(),
                  ),
                  _row(
                    "Grand Total",
                    currency.format(
                      order.finalPayable,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _infoCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.shade300,
        ),
        borderRadius:
            BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _row(
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 6,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              title,
              style: TextStyle(
                color: Colors.grey.shade700,
              ),
            ),
          ),

          const SizedBox(width: 12),

          Flexible(
            child: Text(
              value,
              softWrap: true,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic value) {
    if (value == null) return "-";

    if (value is Timestamp) {
      return DateFormat(
        "dd MMM yyyy",
      ).format(value.toDate());
    }

    if (value is DateTime) {
      return DateFormat(
        "dd MMM yyyy",
      ).format(value);
    }

    return "-";
  }
}