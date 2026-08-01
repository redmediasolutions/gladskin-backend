import 'package:flutter/material.dart';
import 'package:gladskin_backend/models/order_item_model.dart';
import 'package:gladskin_backend/models/order_model.dart';
import 'package:intl/intl.dart';


class InvoiceItems extends StatelessWidget {
  final OrderModel order;

  const InvoiceItems({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 2,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Items",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 16),

        Table(
          border: TableBorder.all(
            color: Colors.grey.shade300,
            width: .8,
          ),
          columnWidths: const {
            0: FlexColumnWidth(4),
            1: FlexColumnWidth(1.5),
            2: FlexColumnWidth(1.5),
            3: FlexColumnWidth(1.8),
          },
          children: [
            TableRow(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
              ),
              children: [
                _header("Product"),
                _header("Qty"),
                _header("Price"),
                _header("Total"),
              ],
            ),

            ...order.items.map(
              (item) => _itemRow(
                item,
                currency,
              ),
            ),
          ],
        ),
      ],
    );
  }

  TableRow _itemRow(
    OrderItemModel item,
    NumberFormat currency,
  ) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              if ((item.image ?? "").isNotEmpty)
                ClipRRect(
                  borderRadius:
                      BorderRadius.circular(8),
                  child: Image.network(
                    item.image!,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (_, __, ___) =>
                            _placeholder(),
                  ),
                )
              else
                _placeholder(),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        _cell("${item.quantity}"),

        _cell(
          currency.format(item.salePrice),
        ),

        _cell(
          currency.format(item.lineSubtotal),
        ),
      ],
    );
  }

  Widget _header(String text) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _cell(String text) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius:
            BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.image_outlined,
        size: 22,
      ),
    );
  }
}