import 'package:flutter/material.dart';

class OrderStatusChip extends StatelessWidget {
  final String status;

  const OrderStatusChip({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final s = status.toLowerCase();

    Color background;
    Color foreground;
    IconData icon;

    switch (s) {
      case "pending":
        background = Colors.orange.shade50;
        foreground = Colors.orange.shade800;
        icon = Icons.schedule;
        break;

      case "processing":
        background = Colors.blue.shade50;
        foreground = Colors.blue.shade800;
        icon = Icons.sync;
        break;

      case "shipped":
        background = Colors.indigo.shade50;
        foreground = Colors.indigo.shade700;
        icon = Icons.local_shipping_outlined;
        break;

      case "out_for_delivery":
        background = Colors.deepPurple.shade50;
        foreground = Colors.deepPurple.shade700;
        icon = Icons.delivery_dining;
        break;

      case "completed":
        background = Colors.green.shade50;
        foreground = Colors.green.shade700;
        icon = Icons.check_circle_outline;
        break;

      case "cancelled":
        background = Colors.red.shade50;
        foreground = Colors.red.shade700;
        icon = Icons.cancel_outlined;
        break;

      case "refunded":
        background = Colors.purple.shade50;
        foreground = Colors.purple.shade700;
        icon = Icons.currency_exchange;
        break;

      case "failed":
        background = Colors.red.shade50;
        foreground = Colors.red.shade700;
        icon = Icons.error_outline;
        break;

      default:
        background = Colors.grey.shade200;
        foreground = Colors.grey.shade700;
        icon = Icons.help_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: foreground,
          ),
          const SizedBox(width: 6),
          Text(
            status
                .replaceAll("_", " ")
                .split(" ")
                .map(
                  (e) =>
                      e.isEmpty
                          ? e
                          : "${e[0].toUpperCase()}${e.substring(1)}",
                )
                .join(" "),
            style: TextStyle(
              color: foreground,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}