import 'package:flutter/material.dart';
import 'package:gladskin_backend/models/order_model.dart';
import 'package:gladskin_backend/screens/orders/invoice/invoice_customer.dart';
import 'package:gladskin_backend/screens/orders/invoice/invoice_header.dart';
import 'package:gladskin_backend/screens/orders/invoice/invoice_items.dart';
import 'package:gladskin_backend/screens/orders/invoice/invoice_totals.dart';
import 'package:gladskin_backend/services/pdf_service.dart';

class InvoicePage extends StatelessWidget {
  final OrderModel order;

  const InvoicePage({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: Text(
          "Invoice ${order.orderNumber}",
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: FilledButton.icon(
              icon: const Icon(Icons.download),
              label: const Text("Download PDF"),
              onPressed: () async {
                await PdfService.downloadInvoice(order);
              },
            ),
          ),
        ],
      ),

      body: Scrollbar(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 40,
            vertical: 30,
          ),
          child: Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: 794, // A4 width
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: Colors.grey.shade300,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(48),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    InvoiceHeader(order: order),

                    const SizedBox(height: 32),

                    InvoiceCustomer(order: order),

                    const SizedBox(height: 32),

                    InvoiceItems(order: order),

                    const SizedBox(height: 32),

                    InvoiceTotals(order: order),

                    const SizedBox(height: 60),

                    const Divider(),

                    const SizedBox(height: 20),

                    Center(
                      child: Text(
                        "Thank you for shopping with GladSkin",
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 14,
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
    );
  }
}