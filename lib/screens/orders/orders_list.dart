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
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 300 &&
        !_isLoading &&
        _hasMore) {
      _loadOrders();
    }
  });
}

  Future<void> _loadOrders({
  bool refresh = false,
}) async {
  if (_isLoading) return;

  setState(() {
    _isLoading = true;
  });

  if (refresh) {
    _orders.clear();
    _lastDocument = null;
    _hasMore = true;
  }

  final result = await _orderService.fetchOrders(
    lastDoc: _lastDocument,
    limit: 20,
    status: _status,
    searchText: _searchController.text.trim(),
  );

  if (mounted) {
    setState(() {
      _orders.addAll(result.orders);

      _lastDocument = result.lastDocument;

      _hasMore = result.hasMore;

      _isLoading = false;
    });
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
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller:
                        _searchController,
                    decoration:
                        InputDecoration(
                      hintText:
                          "Search order, customer or phone",
                      prefixIcon:
                          const Icon(
                        Icons.search,
                      ),
                      filled: true,
                      fillColor:
                          Colors.white,
                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(
                          12,
                        ),
                        borderSide:
                            BorderSide.none,
                      ),
                    ),
                    onSubmitted: (_) {
                      setState(() {
                        _loadOrders();
                      });
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
                        _loadOrders();
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
        : Scrollbar(
            controller: _scrollController,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: _scrollController,
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
),
          ],
        ),
      ),
    );
  }
}