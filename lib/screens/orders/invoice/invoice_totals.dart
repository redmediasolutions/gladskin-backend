import 'package:flutter/material.dart';
import 'package:gladskin_backend/models/order_model.dart';
import 'package:intl/intl.dart';


class InvoiceTotals extends StatelessWidget {
  final OrderModel order;

  const InvoiceTotals({
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

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Spacer(),

        SizedBox(
          width: 360,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey.shade300,
              ),
              borderRadius:
                  BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _row(
                  "Subtotal",
                  currency.format(order.subtotal),
                ),

                if (order.tax > 0)
                  _row(
                    "GST",
                    currency.format(order.tax),
                  ),

                if (order.couponDiscount > 0)
                  _row(
                    "Coupon Discount",
                    "- ${currency.format(order.couponDiscount)}",
                    valueColor: Colors.green,
                  ),

                if (order.walletUsed > 0)
                  _row(
                    "Wallet Used",
                    "- ${currency.format(order.walletUsed)}",
                    valueColor: Colors.green,
                  ),

                if (order.rewardAmount > 0)
                  _row(
                    "Coupon Discount",
                    "- ${currency.format(order.couponDiscount)}",
                    valueColor: Colors.green,
                  ),
                
                if (order.shipping > 0)
                  _row(
                    "Shipping",
                    currency.format(order.shipping),
                  ),

                if (order.codCharge > 0)
                  _row(
                    "COD Charges",
                    currency.format(order.codCharge),
                  ),

                const Padding(
                  padding:
                      EdgeInsets.symmetric(
                    vertical: 14,
                  ),
                  child: Divider(
                    height: 1,
                  ),
                ),

                _row(
                  "Grand Total",
                  currency.format(
                    order.finalPayable,
                  ),
                  bold: true,
                  fontSize: 18,
                ),

                if (order.paymentStatus
                    .toLowerCase() ==
                    "paid")
                  Padding(
                    padding:
                        const EdgeInsets.only(
                      top: 20,
                    ),
                    child: Container(
                      width: double.infinity,
                      padding:
                          const EdgeInsets.all(
                        12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green
                            .withOpacity(.08),
                        borderRadius:
                            BorderRadius
                                .circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons
                                .check_circle,
                            color:
                                Colors.green,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Payment Received",
                              style: TextStyle(
                                color: Colors
                                    .green,
                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Padding(
                    padding:
                        const EdgeInsets.only(
                      top: 20,
                    ),
                    child: Container(
                      width: double.infinity,
                      padding:
                          const EdgeInsets.all(
                        12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange
                            .withOpacity(.08),
                        borderRadius:
                            BorderRadius
                                .circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.warning,
                            color:
                                Colors.orange,
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Expanded(
                            child: Text(
                              order.paymentStatus,
                              style: const TextStyle(
                                color: Colors
                                    .orange,
                                fontWeight:
                                    FontWeight
                                        .bold,
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
        ),
      ],
    );
  }

  Widget _row(
    String title,
    String value, {
    bool bold = false,
    double fontSize = 15,
    Color? valueColor,
  }) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 6,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: bold
                    ? FontWeight.bold
                    : FontWeight.w500,
                fontSize: fontSize,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: bold
                  ? FontWeight.bold
                  : FontWeight.w600,
              fontSize: fontSize,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}