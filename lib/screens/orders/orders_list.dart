import 'package:flutter/material.dart';
import 'package:gladskin_backend/screens/orders/widgets/order_card.dart';
import 'package:go_router/go_router.dart';

import '../../models/order_model.dart';
import '../../services/order_service.dart';
import 'widgets/order_status_chip.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrdersList extends StatefulWidget {
  const OrdersList({super.key});

  @override
  State<OrdersList> createState() =>
      _OrdersListState();
}

class _OrdersListState
    extends State<OrdersList> {
  final OrderService _orderService =
      OrderService();

  List<OrderModel> _orders = [];

bool _isLoading = false;
bool _hasMore = true;

QueryDocumentSnapshot? _lastDocument;

final ScrollController _scrollController =
    ScrollController();

  final TextEditingController
      _searchController =
      TextEditingController();

  String _status = "all";

  @override
void initState() {
  super.initState();

  _loadOrders(refresh: true);

  _scrollController.addListener(() {
  if (!_scrollController.hasClients) return;

  final position = _scrollController.position;

  // Load next page when 70% of the current list is reached
  if (position.pixels >= position.maxScrollExtent * 0.7 &&
      !_isLoading &&
      _hasMore) {
    _loadOrders();
  }
});
}

Widget _statusChip(
  String value,
  String label,
) {
  final selected = _status == value;

  return ChoiceChip(
    label: Text(label),
    selected: selected,
    showCheckmark: false,

    selectedColor: Theme.of(context).primaryColor,

    labelStyle: TextStyle(
      color: selected ? Colors.white : Colors.black87,
      fontWeight:
          selected ? FontWeight.w600 : FontWeight.normal,
    ),

    onSelected: (_) async {
  setState(() {
    _status = value;
  });

  await _loadOrders(refresh: true);
},
  );
}

  Future<void> _loadOrders({
  bool refresh = false,
}) async {

  if (refresh) {
    _orders.clear();
    _lastDocument = null;
    _hasMore = true;
  }

  if (_isLoading || !_hasMore) return;

  _isLoading = true;

  if (mounted) {
    setState(() {});
  }

  try {
    final result = await _orderService.fetchOrders(
      lastDoc: _lastDocument,
      limit: 25,
      status: _status,
      searchText: _searchController.text.trim(),
    );

    if (!mounted) return;

    setState(() {
      final Map<String, OrderModel> map = {
        for (final o in _orders)
          (o.wooOrderId > 0
              ? "woo_${o.wooOrderId}"
              : o.orderNumber): o,
      };

      for (final order in result.orders) {
        final key = order.wooOrderId > 0
            ? "woo_${order.wooOrderId}"
            : order.orderNumber;

        map[key] = order;
      }

      _orders = map.values.toList()
        ..sort((a, b) {
          final aTime =
              a.createdAt?.millisecondsSinceEpoch ?? 0;
          final bTime =
              b.createdAt?.millisecondsSinceEpoch ?? 0;

          return bTime.compareTo(aTime);
        });

      _lastDocument = result.lastDocument;
      _hasMore = result.hasMore;
    });
  } finally {
    _isLoading = false;

    if (mounted) {
      setState(() {});
    }
  }
}
  Future<void> _refresh() async {
  await _loadOrders(refresh: true);
}

  @override
void dispose() {
  _scrollController.dispose();
  _searchController.dispose();
  super.dispose();
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF8F4F4),

      body: Padding(
        padding:
            const EdgeInsets.all(24),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            /// HEADER
            Row(
              mainAxisAlignment:
                  MainAxisAlignment
                      .spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(
                      "Orders",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight:
                            FontWeight
                                .w700,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Manage customer orders",
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),

                ElevatedButton.icon(
                  onPressed: _refresh,
                  icon: const Icon(
                    Icons.refresh,
                  ),
                  label:
                      const Text("Refresh"),
                ),
              ],
            ),

            const SizedBox(height: 24),

            /// SEARCH + FILTER
/// SEARCH + STATUS FILTER
Container(
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
  ),
  child: Column(
    children: [
      TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: "Search order, customer or phone",
          prefixIcon: const Icon(Icons.search),

          suffixIcon: _searchController.text.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: "Clear Search",
                  onPressed: () {
                    _searchController.clear();

                    FocusScope.of(context).unfocus();

                    _loadOrders(refresh: true);

                    setState(() {});
                  },
                ),

          filled: true,
          fillColor: Colors.grey.shade50,

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),

        onChanged: (_) {
          setState(() {});
        },

        onSubmitted: (_) {
          _loadOrders(refresh: true);
        },
      ),

      const SizedBox(height: 16),

      Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          _statusChip("all", "All"),
          _statusChip("pending", "Pending"),
          _statusChip("processing", "Processing"),
          _statusChip("shipped", "Shipped"),
          _statusChip("delivered", "Delivered"),
          _statusChip("cancelled", "Cancelled"),
          _statusChip("completed", "Completed"),
          _statusChip("failed", "Failed"),
        ],
      ),
    ],
  ),
),
            const SizedBox(height: 24),

            /// TABLE
            Expanded(
  child: _isLoading && _orders.isEmpty
      ? const Center(
          child: CircularProgressIndicator(),
        )
      : ListView.builder(
          controller: _scrollController,
          itemCount: _orders.length +
              (_hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == _orders.length) {
  if (!_isLoading) {
    return const SizedBox.shrink();
  }

  return const Padding(
    padding: EdgeInsets.symmetric(vertical: 20),
    child: Center(
      child: SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
        ),
      ),
    ),
  );
}

            return OrderCard(
              order: _orders[index],
            );
          },
        ),
)
          ],
        ),
      ),
    );
  }
}