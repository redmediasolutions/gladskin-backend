import 'package:flutter/material.dart';

import '../../../models/order_item_model.dart';

class OrderItemsCard extends StatelessWidget {
  final List<OrderItemModel> items;

  const OrderItemsCard({
    super.key,
    required this.items,
  });

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
                  Icons.shopping_bag_outlined,
                ),
                SizedBox(width: 8),
                Text(
                  "Order Items",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            if (items.isEmpty)
              const Center(
                child: Padding(
                  padding:
                      EdgeInsets.all(24),
                  child: Text(
                    "No items found",
                  ),
                ),
              )
            else
              Column(
                children: items
                    .map(
                      (item) => Container(
                        margin:
                            const EdgeInsets.only(
                          bottom: 16,
                        ),
                        padding:
                            const EdgeInsets.all(
                          16,
                        ),
                        decoration:
                            BoxDecoration(
                          color:
                              const Color(
                            0xFFF8F4F4,
                          ),
                          borderRadius:
                              BorderRadius.circular(
                            12,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            /// IMAGE
                            ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(
                                10,
                              ),
                              child: item.image
                                      .isNotEmpty
                                  ? Image.network(
                                      item.image,
                                      width: 70,
                                      height: 70,
                                      fit: BoxFit
                                          .cover,
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        return _placeholderImage();
                                      },
                                    )
                                  : _placeholderImage(),
                            ),

                            const SizedBox(
                              width: 16,
                            ),

                            /// DETAILS
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  Text(
                                    item.name,
                                    style:
                                        const TextStyle(
                                      fontSize:
                                          16,
                                      fontWeight:
                                          FontWeight
                                              .w600,
                                    ),
                                  ),

                                  const SizedBox(
                                    height: 6,
                                  ),

                                  Text(
                                    "SKU: ${item.sku}",
                                    style:
                                        const TextStyle(
                                      color:
                                          Colors
                                              .grey,
                                    ),
                                  ),

                                  const SizedBox(
                                    height: 4,
                                  ),

                                  Text(
                                    "Quantity: ${item.quantity}",
                                  ),
                                ],
                              ),
                            ),

                            /// PRICE
                            Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .end,
                              children: [
                                Text(
                                  "₹${item.price.toStringAsFixed(2)}",
                                  style:
                                      const TextStyle(
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                    fontSize:
                                        16,
                                  ),
                                ),

                                const SizedBox(
                                  height: 6,
                                ),

                                Text(
                                  "₹${item.total.toStringAsFixed(2)}",
                                  style:
                                      const TextStyle(
                                    color:
                                        Colors
                                            .grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderImage() {
    return Container(
      width: 70,
      height: 70,
      color: Colors.grey.shade200,
      child: const Icon(
        Icons.image_outlined,
        color: Colors.grey,
      ),
    );
  }
}