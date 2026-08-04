import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gladskin_backend/models/order_totals_model.dart';
import 'package:gladskin_backend/models/tracking_model.dart';
import 'package:gladskin_backend/models/user_model.dart';
import 'package:gladskin_backend/screens/orders/invoice/invoice_page.dart';
import 'package:gladskin_backend/screens/orders/invoice/invoice_sheet.dart';
import 'package:gladskin_backend/screens/orders/widgets/user_details_card.dart';
import 'package:intl/intl.dart';

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

  final TextEditingController _trackingController =
    TextEditingController();

final TextEditingController _notesController =
    TextEditingController();

String? _selectedCourier;
bool? _sendComplimentaryGift;

  late Future<OrderModel?> _future;
late Future<UserModel?> _userFuture;
String? _selectedStatus;
bool _updatingStatus = false;

  @override
  void initState() {
    super.initState();

    _future = _service.fetchOrder(
      widget.orderId,
    );

    _userFuture = _future.then((order) {
  if (order == null) return null;

  
  return _service.fetchUser(
    order.uid,
  );
  
});
  }

String normalizeStatus(String? status) {
  final value = (status ?? "").trim().toLowerCase();

  switch (value) {
    case "":
    case "payment_pending":
    case "checkout-draft":
    case "draft":
      return "pending";

    case "payment_failed":
      return "failed";

    case "on_hold":
      return "on-hold";

    case "pending":
    case "processing":
    case "on-hold":
    case "shipped":
    case "completed":
    case "cancelled":
    case "refunded":
    case "failed":
      return value;

    default:
      debugPrint(
        "Unknown order status '$value', defaulting to pending",
      );
      return "pending";
  }
}

Future<void> _updateOrderStatus(OrderModel order) async {
  if (_selectedStatus == null ||
      _selectedStatus == order.status) {
    return;
  }

  setState(() {
    _updatingStatus = true;
  });

  try {
    // Skip WooCommerce for shipped
    if (_selectedStatus != "shipped") {
      await _service.updateWooCommerceOrderStatus(
        wooOrderId: order.wooOrderId,
        status: _selectedStatus!,
      );
    }

    await _service.updateFirestoreOrderStatus(
      orderId: widget.orderId,
      status: _selectedStatus!,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Order status updated successfully."),
      ),
    );

    await _refresh();
  } finally {
    if (mounted) {
      setState(() {
        _updatingStatus = false;
      });
    }
  }
}

Future<void> _refresh() async {
  setState(() {
    _selectedStatus = null;
    _selectedCourier = null;
    _sendComplimentaryGift = null;

    _future = _service.fetchOrder(widget.orderId);

    _userFuture = _future.then((order) {
      if (order == null) return null;

      return _service.fetchUser(order.uid);
    });
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
        const validStatuses = <String>{
  "pending",
  "processing",
  "on-hold",
  "shipped",
  "completed",
  "cancelled",
  "refunded",
  "failed",
};

if (_selectedStatus == null) {
  final normalizedStatus = normalizeStatus(order?.status);

  _selectedStatus = validStatuses.contains(normalizedStatus)
      ? normalizedStatus
      : "pending";
}

        _selectedCourier ??= order?.tracking?.courier;

if (_sendComplimentaryGift == null) {
  _sendComplimentaryGift = order?.giftAdded ?? false;
}

if (_trackingController.text.isEmpty) {
  _trackingController.text =
      order?.tracking?.trackingNumber ?? "";
}

if (_notesController.text.isEmpty) {
  _notesController.text =
      order?.tracking?.notes ?? "";
}

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
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Order ${order.orderNumber}",
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
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
          _formatDate(order.createdAt),
          style: TextStyle(
            color: Colors.grey.shade600,
          ),
        ),
      ],
    ),

    Row(
      children: [
        SizedBox(
  width: 180,
  child: DropdownButtonFormField<String>(
    value: _selectedStatus,
    decoration: const InputDecoration(
      labelText: "Status",
      border: OutlineInputBorder(),
      isDense: true,
    ),
    items: const [
  "pending",
  "processing",
  "on-hold",
  "shipped",
  "completed",
  "cancelled",
  "refunded",
  "failed",
].map((status) {
  return DropdownMenuItem(
    value: status,
    child: Text(status),
  );
}).toList(),
    onChanged: (value) {
      setState(() {
        _selectedStatus = value;
      });
    },
  ),
),

ElevatedButton.icon(
  onPressed: _updatingStatus
      ? null
      : () => _updateOrderStatus(order),
  icon: _updatingStatus
      ? const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        )
      : const Icon(Icons.save),
  label: const Text("Update"),
),

        const SizedBox(width: 12),

        OutlinedButton.icon(
          onPressed: () {
            Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => InvoicePage(
      order: order,
    ),
  ),
);
          },
          icon: const Icon(
            Icons.receipt_long_outlined,
          ),
          label: const Text(
            "Invoice",
          ),
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

FutureBuilder<UserModel?>(
  future: _userFuture,
  builder: (context, snapshot) {

    if (snapshot.connectionState ==
        ConnectionState.waiting) {
      return const CircularProgressIndicator();
    }

    if (snapshot.hasError) {
      return Text(snapshot.error.toString());
    }

    if (!snapshot.hasData) {
      return const Text("No user found");
    }

    return UserDetailsCard(
      user: snapshot.data,
    );
  },
),
const SizedBox(height: 20),

const SizedBox(height: 20),

Card(
  child: Padding(
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          "Fulfillment",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 20),

        DropdownButtonFormField<String>(
          value: _selectedCourier,
          decoration: const InputDecoration(
            labelText: "Courier",
          ),
          items: const [
            "Delhivery",
            "Blue Dart",
            "DTDC",
            "XpressBees",
            "Ekart",
            "Speed Post",
          ].map((e) {
            return DropdownMenuItem(
              value: e,
              child: Text(e),
            );
          }).toList(),
          onChanged: (v) {
            setState(() {
              _selectedCourier = v;
            });
          },
        ),

        const SizedBox(height: 16),

        TextField(
          controller: _trackingController,
          decoration: const InputDecoration(
            labelText: "Tracking Number",
          ),
        ),

        const SizedBox(height: 16),

        TextField(
          controller: _notesController,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: "Notes",
          ),
        ),

        const SizedBox(height: 24),

CheckboxListTile(
  value: _sendComplimentaryGift,
  onChanged: (value) {
    setState(() {
      _sendComplimentaryGift = value ?? false;
    });
  },
  contentPadding: EdgeInsets.zero,
  controlAffinity: ListTileControlAffinity.leading,
  title: const Text(
    "Send Complimentary Gift",
    style: TextStyle(
      fontWeight: FontWeight.w600,
    ),
  ),
  subtitle: const Text(
    "Customer will receive a complimentary gift with this shipment.",
  ),
),

        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton.icon(
            onPressed: () async {
           // Update status if changed
if (_selectedStatus != order.status) {
  // Skip WooCommerce for shipped
  if (_selectedStatus != "shipped") {
    await _service.updateWooCommerceOrderStatus(
      wooOrderId: order.wooOrderId,
      status: _selectedStatus!,
    );
  }

  // Always update Firestore
  await _service.updateFirestoreOrderStatus(
    orderId: widget.orderId,
    status: _selectedStatus!,
  );
}

await _service.updateTrackingInfo(
  orderId: widget.orderId,
  tracking: TrackingInfo(
    courier: _selectedCourier ?? "",
    trackingNumber: _trackingController.text.trim(),
    notes: _notesController.text.trim(),
  ),
);

await FirebaseFirestore.instance
    .collection("Orders")
    .doc(widget.orderId)
    .update({
  "giftAdded": _sendComplimentaryGift,
});

await _refresh();
            },
            icon: const Icon(Icons.local_shipping),
            label: const Text("Save"),
          ),
        ),
      ],
    ),
  ),
),


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

