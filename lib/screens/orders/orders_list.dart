import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/order_model.dart';
import '../../services/order_service.dart';
import 'widgets/order_status_chip.dart';

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

  late Future<List<OrderModel>> _future;

  final TextEditingController
      _searchController =
      TextEditingController();

  String _status = "all";

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  void _loadOrders() {
    _future = _orderService.fetchOrders(
      status: _status,
      searchText:
          _searchController.text.trim(),
    );
  }

  Future<void> _refresh() async {
    setState(() {
      _loadOrders();
    });
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
                  borderRadius:
                      BorderRadius.circular(
                    18,
                  ),
                ),
                child: FutureBuilder<
                    List<OrderModel>>(
                  future: _future,
                  builder: (
                    context,
                    snapshot,
                  ) {
                    if (snapshot
                            .connectionState ==
                        ConnectionState
                            .waiting) {
                      return const Center(
                        child:
                            CircularProgressIndicator(),
                      );
                    }

                    if (snapshot
                        .hasError) {
                      return Center(
                        child: Text(
                          snapshot.error
                              .toString(),
                        ),
                      );
                    }

                    final orders =
                        snapshot.data ??
                            [];

                    if (orders.isEmpty) {
                      return const Center(
                        child: Text(
                          "No Orders Found",
                        ),
                      );
                    }

                    return SingleChildScrollView(
                      child: DataTable(
                        headingRowColor:
                            WidgetStateProperty.all(
                          const Color(
                            0xFFF8F4F4,
                          ),
                        ),
                        columns: const [
                          DataColumn(
                            label:
                                Text("Order"),
                          ),
                          DataColumn(
                            label: Text(
                                "Customer"),
                          ),
                          DataColumn(
                            label:
                                Text("Total"),
                          ),
                          DataColumn(
                            label: Text(
                                "Status"),
                          ),
                          DataColumn(
                            label:
                                Text("Date"),
                          ),
                          DataColumn(
                            label:
                                Text(""),
                          ),
                        ],
                        rows: orders.map((
                          order,
                        ) {
                          return DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  order
                                      .orderNumber,
                                ),
                              ),

                              DataCell(
  Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        order.customer.name,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 2),
      Text(
        order.customer.phone?.isNotEmpty == true
            ? order.customer.phone!
            : "-",
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade600,
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
                                  status:
                                      order
                                          .status,
                                ),
                              ),

                              DataCell(
                                Text(
                                  order.createdAt ==
                                          null
                                      ? "-"
                                      : order
                                          .createdAt!
                                          .toDate()
                                          .toString()
                                          .split(
                                              " ")
                                          .first,
                                ),
                              ),

                              DataCell(
                                PopupMenuButton<
                                    String>(
                                  onSelected:
                                      (
                                        value,
                                      ) {
                                        if (value ==
                                            "view") {
                                          context.go(
                                            "/orders/${order.id}",
                                          );
                                        }
                                      },
                                  itemBuilder:
                                      (
                                        context,
                                      ) =>
                                          const [
                                    PopupMenuItem(
                                      value:
                                          "view",
                                      child: Text(
                                        "View",
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}