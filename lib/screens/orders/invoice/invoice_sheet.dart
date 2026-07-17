import 'package:flutter/material.dart';
import 'package:gladskin_backend/models/order_model.dart';

import 'invoice_customer.dart';
import 'invoice_header.dart';
import 'invoice_items.dart';
import 'invoice_totals.dart';

class InvoiceSheet extends StatelessWidget {
  final OrderModel order;

  const InvoiceSheet({
    super.key,
    required this.order,
  });

  static Future<void> show(
    BuildContext context,
    OrderModel order,
  ) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => InvoiceSheet(
        order: order,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: .92,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(28),
          ),
        ),
        child: Column(
          children: [
            /// Drag Handle
            Padding(
              padding: const EdgeInsets.only(
                top: 12,
                bottom: 8,
              ),
              child: Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius:
                      BorderRadius.circular(100),
                ),
              ),
            ),

            /// Header
            Padding(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 24,
              ),
              child: Row(
                children: [
                  const Text(
                    "Invoice",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const Spacer(),

                  FilledButton.icon(
                    onPressed: () {
                      // TODO
                      // PdfService.downloadInvoice(order);
                    },
                    icon: const Icon(
                      Icons.download,
                    ),
                    label: const Text(
                      "Download",
                    ),
                  ),

                  const SizedBox(width: 12),

                  IconButton(
                    onPressed: () {
                      Navigator.pop(
                        context,
                      );
                    },
                    icon: const Icon(
                      Icons.close,
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 24),

            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.all(24),
                child: Center(
                  child: ConstrainedBox(
                    constraints:
                        const BoxConstraints(
                      maxWidth: 850,
                    ),
                    child: Container(
                      decoration:
                          BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(
                          16,
                        ),
                        border: Border.all(
                          color: Colors
                              .grey.shade300,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors
                                .black12,
                            blurRadius: 10,
                            offset:
                                const Offset(
                              0,
                              4,
                            ),
                          ),
                        ],
                      ),
                      padding:
                          const EdgeInsets.all(
                        32,
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          InvoiceHeader(
                            order: order,
                          ),

                          const SizedBox(
                            height: 32,
                          ),

                          InvoiceCustomer(
                            order: order,
                          ),

                          const SizedBox(
                            height: 32,
                          ),

                          InvoiceItems(
                            order: order,
                          ),

                          const SizedBox(
                            height: 32,
                          ),

                          InvoiceTotals(
                            order: order,
                          ),

                          const SizedBox(
                            height: 40,
                          ),

                          Center(
                            child: Text(
                              "Thank you for shopping with GladSkin",
                              style: TextStyle(
                                color: Colors
                                    .grey.shade600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            Container(
              padding:
                  const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border(
                  top: BorderSide(
                    color:
                        Colors.grey.shade300,
                  ),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(
                            context,
                          );
                        },
                        icon: const Icon(
                          Icons.close,
                        ),
                        label: const Text(
                          "Close",
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      flex: 2,
                      child:
                          FilledButton.icon(
                        onPressed: () {
                          // TODO
                          // PdfService.downloadInvoice(order);
                        },
                        icon: const Icon(
                          Icons.download,
                        ),
                        label: const Text(
                          "Download Invoice",
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}