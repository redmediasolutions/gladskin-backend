import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../models/status_history_model.dart';

class TimelineCard extends StatelessWidget {
  final List<StatusHistoryModel>
      timeline;

  const TimelineCard({
    super.key,
    required this.timeline,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(
          16,
        ),
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
                  Icons.history,
                ),
                SizedBox(width: 8),
                Text(
                  "Order Timeline",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 20,
            ),

            if (timeline.isEmpty)
              const Padding(
                padding:
                    EdgeInsets.symmetric(
                  vertical: 20,
                ),
                child: Center(
                  child: Text(
                    "No timeline available",
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics:
                    const NeverScrollableScrollPhysics(),
                itemCount:
                    timeline.length,
                separatorBuilder:
                    (_, __) =>
                        const Divider(
                  height: 28,
                ),
                itemBuilder:
                    (
                  context,
                  index,
                ) {
                  final item =
                      timeline[index];

                  return Row(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration:
                                const BoxDecoration(
                              color: Color(
                                0xFFF6ECEE,
                              ),
                              shape:
                                  BoxShape.circle,
                            ),
                            child: Icon(
                              _iconForStatus(
                                item.status,
                              ),
                              size: 18,
                              color:
                                  const Color(
                                0xFFB5838D,
                              ),
                            ),
                          ),

                          if (index !=
                              timeline.length -
                                  1)
                            Container(
                              width: 2,
                              height: 50,
                              color: Colors
                                  .grey
                                  .shade300,
                            ),
                        ],
                      ),

                      const SizedBox(
                        width: 16,
                      ),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Text(
                              item.status
                                  .replaceAll(
                                      "_",
                                      " ")
                                  .toUpperCase(),
                              style:
                                  const TextStyle(
                                fontWeight:
                                    FontWeight
                                        .bold,
                                fontSize:
                                    15,
                              ),
                            ),

                            if (item
                                .description
                                .isNotEmpty)
                              Padding(
                                padding:
                                    const EdgeInsets.only(
                                  top: 4,
                                ),
                                child: Text(
                                  item
                                      .description,
                                  style:
                                      TextStyle(
                                    color: Colors
                                        .grey
                                        .shade700,
                                  ),
                                ),
                              ),

                            const SizedBox(
                              height: 6,
                            ),

                            Row(
                              children: [
                                Text(
                                  item
                                      .performedBy,
                                  style:
                                      TextStyle(
                                    fontSize:
                                        12,
                                    color: Colors
                                        .grey
                                        .shade600,
                                  ),
                                ),

                                const Spacer(),

                                Text(
                                  _formatDate(
                                    item
                                        .createdAt,
                                  ),
                                  style:
                                      TextStyle(
                                    fontSize:
                                        12,
                                    color: Colors
                                        .grey
                                        .shade600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  IconData _iconForStatus(
    String status,
  ) {
    switch (status
        .toLowerCase()) {
      case 'pending':
        return Icons.schedule;

      case 'processing':
        return Icons.sync;

      case 'packed':
        return Icons.inventory_2;

      case 'shipped':
        return Icons.local_shipping;

      case 'out_for_delivery':
        return Icons.delivery_dining;

      case 'delivered':
        return Icons.check_circle;

      case 'cancelled':
        return Icons.cancel;

      case 'refunded':
        return Icons.currency_exchange;

      default:
        return Icons.history;
    }
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
}