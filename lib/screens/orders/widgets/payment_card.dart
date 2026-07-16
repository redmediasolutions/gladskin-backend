import 'package:flutter/material.dart';
import 'package:gladskin_backend/models/order_model.dart';
import 'package:gladskin_backend/models/payment_model.dart';


class PaymentCard extends StatelessWidget {
  final OrderModel order;

  const PaymentCard({
    super.key,
    required this.order,
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

  Color _statusColor() {
    switch (order.status.toLowerCase()) {
      case "paid":
        return Colors.green;

      case "captured":
        return Colors.green;

      case "pending":
        return Colors.orange;

      case "failed":
        return Colors.red;

      case "refunded":
        return Colors.purple;

      default:
        return Colors.grey;
    }
  }

  String _formatDate() {
    if (order.paymentCapturedAt == null) {
      return "-";
    }

    final date =
        order.paymentCapturedAt!.toDate();

    return "${date.day}/${date.month}/${date.year} "
        "${date.hour.toString().padLeft(2, '0')}:"
        "${date.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final statusColor =
        _statusColor();

    return Card(
      elevation: 0,
      color: Colors.white,
      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(
          16,
        ),
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
                  Icons.credit_card,
                ),
                SizedBox(width: 8),
                Text(
                  "Payment",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 20,
            ),

            Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 8,
              ),
              decoration:
                  BoxDecoration(
                color: statusColor
                    .withOpacity(0.1),
                borderRadius:
                    BorderRadius.circular(
                  30,
                ),
              ),
              child: Text(
                order.paymentStatus
                    .toUpperCase(),
                style: TextStyle(
                  color: statusColor,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            _infoTile(
              "Payment Method",
              order.paymentMethod,
            ),

            _infoTile(
              "Payment Status",
              order.paymentStatus
            ),

            _infoTile(
              "Razorpay Order ID",
              order.razorpayOrderId,
            ),

            _infoTile(
              "Razorpay Payment ID",
              order.razorpayPaymentId,
            ),

            _infoTile(
              "Currency",
              order.courierName,
            ),

            _infoTile(
              "Amount",
              "₹${order.finalPayable.toStringAsFixed(2)}",
            ),

            _infoTile(
              "Captured At",
              _formatDate(),
            ),
          ],
        ),
      ),
    );
  }
}