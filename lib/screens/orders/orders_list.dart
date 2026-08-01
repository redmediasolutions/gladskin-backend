import 'package:flutter/material.dart';
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


static const int _pageSize = 20;
int _currentPage = 1;
bool _hasNextPage = false;
bool _hasPreviousPage = false;

/// Cursor for each page.
/// page 1 = null
final List<QueryDocumentSnapshot?> _pageCursors = [null];


  final TextEditingController
      _searchController =
      TextEditingController();

  String _status = "all";

@override
void initState() {
  super.initState();
  _loadPage(1);
}

Future<void> _loadPage(int page) async {
  setState(() => _isLoading = true);

  final result = await _orderService.fetchOrders(
    lastDoc: _pageCursors[page - 1],
    limit: _pageSize,
    status: _status,
    searchText: _searchController.text.trim(),
  );

  if (!mounted) return;

  setState(() {
    _orders = result.orders;

    _currentPage = page;

    _hasNextPage = result.hasMore;

    _hasPreviousPage = page > 1;

    if (result.hasMore &&
        _pageCursors.length == page) {
      _pageCursors.add(result.lastDocument);
    }

    _isLoading = false;
  });
}



Future<void> _refresh() async {
  _pageCursors
    ..clear()
    ..add(null);

  await _loadPage(1);
}
  @override
void dispose() {
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
            Row(
              children: [
                Expanded(
                  child: TextField(
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
                  
                                _pageCursors
  ..clear()
  ..add(null);

_loadPage(1);
                  
                                setState(() {});
                              },
                            ),
                  
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  
                    onChanged: (_) {
                      setState(() {});
                    },
                  
                    onSubmitted: (_) {
                      _pageCursors
  ..clear()
  ..add(null);

_loadPage(1);
                    },
                  ),
                ),

                const SizedBox(width: 16),

                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(
                      12,
                    ),
                  ),
                  child: DropdownButton(
                    underline:
                        const SizedBox(),
                    value: _status,
                    items: const [
                      DropdownMenuItem(
                        value: "all",
                        child: Text("All"),
                      ),
                      DropdownMenuItem(
                        value: "pending",
                        child:
                            Text("Pending"),
                      ),
                      DropdownMenuItem(
                        value:
                            "processing",
                        child: Text(
                          "Processing",
                        ),
                      ),
                      DropdownMenuItem(
                        value:
                            "shipped",
                        child:
                            Text("Shipped"),
                      ),
                      DropdownMenuItem(
                        value:
                            "delivered",
                        child: Text(
                          "Delivered",
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _status =
                            value.toString();
                        _pageCursors
  ..clear()
  ..add(null);

_loadPage(1);
                      });
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            /// TABLE
            Expanded(
  child: Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
    ),
    child: _isLoading && _orders.isEmpty
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : SingleChildScrollView(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor:
                  WidgetStateProperty.all(
                const Color(0xFFF8F4F4),
              ),
              columns: const [
                DataColumn(label: Text("Order")),
                DataColumn(label: Text("Customer")),
                DataColumn(label: Text("Total")),
                DataColumn(label: Text("Status")),
                DataColumn(label: Text("Date")),
                DataColumn(label: Text("")),
              ],
              rows: _orders.map((order) {
                return DataRow(
                  cells: [
                    DataCell(
                      Text(order.orderNumber),
                    ),
        
                    DataCell(
                      Column(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.customer.name,
                            style: const TextStyle(
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            order.customer.phone.isNotEmpty
                                ? order.customer.phone
                                : "-",
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
        
                    DataCell(
                      Text(
                        "₹${order.finalPayable.toStringAsFixed(2)}",
                      ),
                    ),
        
                    DataCell(
                      OrderStatusChip(
                        status: order.status,
                      ),
                    ),
        
                    DataCell(
                      Text(
                        order.createdAt == null
                            ? "-"
                            : order.createdAt!
                                .toDate()
                                .toString()
                                .split(" ")
                                .first,
                      ),
                    ),
        
                    DataCell(
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == "view") {
                            context.go(
                              "/orders/${order.id}",
                            );
                          }
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(
                            value: "view",
                            child: Text("View"),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
            
          ),
        ),
  ),
),

Padding(
  padding: const EdgeInsets.all(16),
  child: Row(
    children: [
      Text(
        "Showing ${((_currentPage - 1) * _pageSize) + 1}"
        " - ${((_currentPage - 1) * _pageSize) + _orders.length}",
      ),

      const Spacer(),

      OutlinedButton.icon(
        onPressed: _hasPreviousPage
            ? () => _loadPage(_currentPage - 1)
            : null,
        icon: const Icon(Icons.chevron_left),
        label: const Text("Previous"),
      ),

      const SizedBox(width: 16),

      Text(
        "Page $_currentPage",
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),

      const SizedBox(width: 16),

      ElevatedButton.icon(
        onPressed: _hasNextPage
            ? () => _loadPage(_currentPage + 1)
            : null,
        icon: const Icon(Icons.chevron_right),
        label: const Text("Next"),
      ),
    ],
  ),
),
          ],
        ),
      ),
    );
  }
}