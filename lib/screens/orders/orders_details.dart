import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gladskin_backend/models/order_totals_model.dart';

import '../../models/order_model.dart';
import '../../models/totals_model.dart';
import '../../services/order_service.dart';

import 'widgets/customer_card.dart';
import 'widgets/order_items_card.dart';
import 'widgets/order_status_chip.dart';
import 'widgets/payment_card.dart';
import 'widgets/shipping_card.dart';
import 'widgets/timeline_card.dart';
import 'widgets/totals_card.dart';

class OrderDetails extends StatefulWidget {
  final String orderId;

  const OrderDetails({
    super.key,
    required this.orderId,
  });

  @override
  State<OrderDetails> createState() =>
      _OrderDetailsState();
}

class _OrderDetailsState
    extends State<OrderDetails> {
  final OrderService _service =
      OrderService();

  late Future<OrderModel?> _future;

  @override
  void initState() {
    super.initState();

    _future = _service.fetchOrder(
      widget.orderId,
    );
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _service.fetchOrder(
        widget.orderId,
      );
    });
  }

  String _formatDate(
    Timestamp? timestamp,
  ) {
    if (timestamp == null) {
      return "-";
    }

    final date =
        timestamp.toDate();

    return "${date.day}/${date.month}/${date.year} "
        "${date.hour.toString().padLeft(2, '0')}:"
        "${date.minute.toString().padLeft(2, '0')}";
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(
      0xFFF8F4F4,
    ),

    body: FutureBuilder<OrderModel?>(
      future: _future,

      builder: (
        context,
        snapshot,
      ) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Center(
            child:
                CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              snapshot.error.toString(),
            ),
          );
        }

        final order = snapshot.data;

        if (order == null) {
          return const Center(
            child: Text(
              "Order not found",
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _refresh,

          child: SingleChildScrollView(
            physics:
                const AlwaysScrollableScrollPhysics(),

            padding:
                const EdgeInsets.all(24),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                /// HEADER
Row(
  mainAxisAlignment:
      MainAxisAlignment.spaceBetween,
  crossAxisAlignment:
      CrossAxisAlignment.start,
  children: [
    Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          "Order ${order.orderNumber}",
          style: const TextStyle(
            fontSize: 30,
            fontWeight:
                FontWeight.bold,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          "Woo Order #${order.wooOrderId}",
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          _formatDate(
            order.createdAt,
          ),
          style: TextStyle(
            color: Colors.grey.shade600,
          ),
        ),
      ],
    ),

    Row(
      children: [
        OrderStatusChip(
          status: order.status,
        ),

        const SizedBox(width: 12),

        ElevatedButton.icon(
          onPressed: _refresh,
          icon: const Icon(
            Icons.refresh,
          ),
          label: const Text(
            "Refresh",
          ),
        ),
      ],
    ),
  ],
),

const SizedBox(height: 24),
/// CUSTOMER + PAYMENT
Row(
  crossAxisAlignment:
      CrossAxisAlignment.start,
  children: [
    Expanded(
      flex: 1,
      child: CustomerCard(
        customer: order.customer,
      ),
    ),

    const SizedBox(width: 20),

    Expanded(
      flex: 1,
      child: PaymentCard(
  order: order,
),
    ),
  ],
),

const SizedBox(height: 20),

/// SHIPPING + TOTALS
Row(
  crossAxisAlignment:
      CrossAxisAlignment.start,
  children: [
    Expanded(
      flex: 1,
      child: ShippingCard(
        address: order.shippingAddress,
      ),
    ),

    const SizedBox(width: 20),

    Expanded(
      flex: 1,
      child: TotalsCard(
    order: order,
  ),
    ),
  ],
),

const SizedBox(height: 20),

/// ORDER ITEMS
OrderItemsCard(
  items: order.items,
),

const SizedBox(
  height: 20,
),

/// ORDER TIMELINE
TimelineCard(
  timeline: order.statusHistory,
),

const SizedBox(
  height: 40,
),
              ],
            ),
          ),
        );
      },
    ),
  );
}
}