import 'package:flutter/material.dart';
import 'package:gladskin_backend/models/order_model.dart';

import '../../../models/totals_model.dart';

class TotalsCard extends StatelessWidget {
  final OrderModel order;

  const TotalsCard({
    super.key,
    required this.order,
  });

  Widget _row(
    String title,
    double value, {
    bool bold = false,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 8,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: bold
                    ? FontWeight.w600
                    : FontWeight.w400,
              ),
            ),
          ),
          Text(
            "₹${value.toStringAsFixed(2)}",
            style: TextStyle(
              fontSize: 15,
              fontWeight: bold
                  ? FontWeight.bold
                  : FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.grey.shade200,
        ),
      ),
      child: Padding(
        padding:
            const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.receipt_long,
                ),
                SizedBox(width: 8),
                Text(
                  "Order Totals",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            _row(
              "Subtotal",
              order.subtotal,
            ),

            _row(
              "Shipping",
              order.shipping,
            ),

            _row(
              "Tax",
              order.tax,
            ),

            if (order.couponDiscount > 0)
              _row(
                "Coupon Discount",
                order.couponDiscount,
                color: Colors.green,
              ),

            if (order.walletUsed > 0)
              _row(
                "Wallet Used",
                order.walletUsed,
                color: Colors.green,
              ),

            if (order.codCharge > 0)
              _row(
                "COD Charge",
                order.codCharge,
              ),

            if (order.rewardAmount > 0)
              _row(
                "Reward Amount",
                order.rewardAmount,
                color: Colors.blue,
              ),

            const Padding(
              padding: EdgeInsets.symmetric(
                vertical: 12,
              ),
              child: Divider(),
            ),

            _row(
              "Gross Total",
              order.grossTotal,
            ),

            _row(
              "Discounted Total",
              order.discountedTotal,
            ),

            const Divider(),

            _row(
              "Final Payable",
              order.finalPayable,
              bold: true,
            ),
          ],
        ),
      ),
    );
  }
}