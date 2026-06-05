import 'package:flutter/material.dart';
import 'package:gladskin_backend/models/coupon_model.dart';
import 'package:gladskin_backend/services/firestore_service.dart';
import 'package:go_router/go_router.dart';

class CouponsList extends StatefulWidget {
  const CouponsList({super.key});

  @override
  State<CouponsList> createState() =>
      _CouponsListState();
}

class _CouponsListState
    extends State<CouponsList> {
  final FirestoreService _firestoreService =
      FirestoreService();

  late Future<List<CouponModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = _firestoreService.fetchCoupons();
  }

  Future<void> _refresh() async {
    setState(() {
      _future =
          _firestoreService.fetchCoupons();
    });
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "-";

    return "${date.day}/${date.month}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F4F4),

      body: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            /// HEADER
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,

              children: [
                const Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    Text(
                      "Coupons",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),

                    SizedBox(height: 4),

                    Text(
                      "Manage discount coupons",
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),

                ElevatedButton.icon(
                   onPressed: () async {

    await context.push('/coupons/create');

    _refresh();

  },

                  icon: const Icon(Icons.add),

                  label:
                      const Text("Create Coupon"),

                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFFB5838D),

                    foregroundColor:
                        Colors.white,

                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 16,
                    ),
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
                      BorderRadius.circular(18),

                  border: Border.all(
                    color: Colors.grey.shade200,
                  ),
                ),

                child: Column(
                  children: [
                    /// TABLE HEADER
                    Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 18,
                      ),

                      decoration: BoxDecoration(
                        color:
                            const Color(0xFFFDFBFB),

                        borderRadius:
                            const BorderRadius.only(
                          topLeft:
                              Radius.circular(18),
                          topRight:
                              Radius.circular(18),
                        ),

                        border: Border(
                          bottom: BorderSide(
                            color:
                                Colors.grey.shade200,
                          ),
                        ),
                      ),

                      child: const Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              "Code",
                              style: TextStyle(
                                fontWeight:
                                    FontWeight.w600,
                              ),
                            ),
                          ),

                          Expanded(
                            flex: 2,
                            child: Text(
                              "Discount",
                              style: TextStyle(
                                fontWeight:
                                    FontWeight.w600,
                              ),
                            ),
                          ),

                          Expanded(
                            flex: 2,
                            child: Text(
                              "Usage",
                              style: TextStyle(
                                fontWeight:
                                    FontWeight.w600,
                              ),
                            ),
                          ),

                          Expanded(
                            flex: 2,
                            child: Text(
                              "Expiry",
                              style: TextStyle(
                                fontWeight:
                                    FontWeight.w600,
                              ),
                            ),
                          ),

                          Expanded(
                            child: Text(
                              "Status",
                              style: TextStyle(
                                fontWeight:
                                    FontWeight.w600,
                              ),
                            ),
                          ),

                          SizedBox(width: 60),
                        ],
                      ),
                    ),

                    /// DATA
                    Expanded(
                      child:
                          FutureBuilder<
                              List<CouponModel>>(
                        future: _future,

                        builder:
                            (context, snapshot) {
                          if (snapshot
                                  .connectionState ==
                              ConnectionState
                                  .waiting) {
                            return const Center(
                              child:
                                  CircularProgressIndicator(),
                            );
                          }

                          if (snapshot.hasError) {
                            return Center(
                              child: Text(
                                snapshot.error
                                    .toString(),
                              ),
                            );
                          }

                          final coupons =
                              snapshot.data ?? [];

                          if (coupons.isEmpty) {
                            return const Center(
                              child: Text(
                                "No coupons found",
                              ),
                            );
                          }

                          return RefreshIndicator(
                            onRefresh: _refresh,

                            child:
                                ListView.separated(
                              itemCount:
                                  coupons.length,

                              separatorBuilder:
                                  (_, __) => Divider(
                                        height: 1,
                                        color: Colors
                                            .grey
                                            .shade200,
                                      ),

                              itemBuilder:
                                  (context, index) {
                                final coupon =
                                    coupons[
                                        index];

                                return Padding(
                                  padding:
                                      const EdgeInsets
                                          .symmetric(
                                    horizontal:
                                        20,
                                    vertical:
                                        18,
                                  ),

                                  child: Row(
                                    children: [
                                      /// CODE
                                      Expanded(
                                        flex: 2,

                                        child:
                                            SelectableText(
                                          coupon.code,

                                          style:
                                              const TextStyle(
                                            fontWeight:
                                                FontWeight.w600,
                                          ),
                                        ),
                                      ),

                                      /// DISCOUNT
                                      Expanded(
                                        flex: 2,

                                        child: Text(
                                          "${coupon.discount.toStringAsFixed(0)}%",
                                        ),
                                      ),

                                      /// USAGE
                                      Expanded(
                                        flex: 2,

                                        child: Text(
                                          "${coupon.usedCount} / ${coupon.maxUsage}",
                                        ),
                                      ),

                                      /// EXPIRY
                                      Expanded(
                                        flex: 2,

                                        child: Text(
                                          _formatDate(
                                            coupon
                                                .endDate
                                                ?.toDate(),
                                          ),
                                        ),
                                      ),

                                      /// STATUS
                                      Expanded(
                                        child:
                                            Container(
                                          padding:
                                              const EdgeInsets.symmetric(
                                            horizontal:
                                                10,
                                            vertical:
                                                6,
                                          ),

                                          decoration:
                                              BoxDecoration(
                                            color: coupon
                                                    .isActive
                                                ? Colors
                                                    .green
                                                    .shade50
                                                : Colors
                                                    .red
                                                    .shade50,

                                            borderRadius:
                                                BorderRadius.circular(
                                              20,
                                            ),
                                          ),

                                          child:
                                              Text(
                                            coupon
                                                    .isActive
                                                ? "Active"
                                                : "Inactive",

                                            textAlign:
                                                TextAlign.center,

                                            style:
                                                TextStyle(
                                              fontSize:
                                                  12,

                                              fontWeight:
                                                  FontWeight.w600,

                                              color: coupon
                                                      .isActive
                                                  ? Colors.green
                                                  : Colors.red,
                                            ),
                                          ),
                                        ),
                                      ),

                                      /// ACTIONS
                                      PopupMenuButton<
                                          String>(
                                        onSelected:
                                            (
                                              value,
                                            ) async {
                                          if (value ==
                                              'delete') {
                                            await _firestoreService
                                                .deleteCoupon(
                                              coupon.id,
                                            );

                                            _refresh();
                                          }
                                        },

                                        itemBuilder:
                                            (
                                              context,
                                            ) => [
                                              const PopupMenuItem(
                                                value:
                                                    'edit',

                                                child:
                                                    Text(
                                                  "Edit",
                                                ),
                                              ),

                                              const PopupMenuItem(
                                                value:
                                                    'delete',

                                                child:
                                                    Text(
                                                  "Delete",
                                                ),
                                              ),
                                            ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          );
                        },
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