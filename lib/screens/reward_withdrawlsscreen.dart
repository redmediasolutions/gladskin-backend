import 'package:flutter/material.dart';
import 'package:gladskin_backend/models/reward_withdrawal.dart';
import 'package:gladskin_backend/services/firestore_service.dart';

class RewardWithdrawalsPage extends StatefulWidget {
  const RewardWithdrawalsPage({
    super.key,
  });

  @override
  State<RewardWithdrawalsPage> createState() =>
      _RewardWithdrawalsPageState();
}

class _RewardWithdrawalsPageState
    extends State<RewardWithdrawalsPage> {

  final FirestoreService _firestore =
      FirestoreService();

  late Future<List<RewardWithdrawal>>
      _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<RewardWithdrawal>>
      _load() async {
    return _firestore
        .fetchRewardWithdrawals();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _load();
    });
  }

  String _formatDate(
    DateTime? date,
  ) {
    if (date == null) return "-";

    return "${date.day}/${date.month}/${date.year}";
  }

  Future<void> _approve(
    String id,
  ) async {

    await _firestore
        .approveRewardWithdrawal(id);

    _refresh();
  }

  Future<void> _reject(
    String id,
  ) async {

    await _firestore
        .rejectRewardWithdrawal(id);

    _refresh();
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
                      "Reward Withdrawals",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),

                    SizedBox(height: 4),

                    Text(
                      "Manage payout requests",
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
                  label: const Text(
                    "Refresh",
                  ),
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(
                      0xFFB5838D,
                    ),
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

            Expanded(
              child: Container(
                decoration:
                    BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(
                          18),
                  border: Border.all(
                    color: Colors
                        .grey
                        .shade200,
                  ),
                ),

                child: Column(
                  children: [

                    Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 18,
                      ),
                      decoration:
                          BoxDecoration(
                        color:
                            const Color(
                          0xFFFDFBFB,
                        ),
                        borderRadius:
                            const BorderRadius.only(
                          topLeft:
                              Radius.circular(
                                  18),
                          topRight:
                              Radius.circular(
                                  18),
                        ),
                        border:
                            Border(
                          bottom:
                              BorderSide(
                            color: Colors
                                .grey
                                .shade200,
                          ),
                        ),
                      ),

                      child:
                          const Row(
                        children: [

                          Expanded(
                            flex: 2,
                            child: Text(
                              "Customer",
                              style:
                                  TextStyle(
                                fontWeight:
                                    FontWeight.w600,
                              ),
                            ),
                          ),

                          Expanded(
                            flex: 2,
                            child: Text(
                              "UPI ID",
                              style:
                                  TextStyle(
                                fontWeight:
                                    FontWeight.w600,
                              ),
                            ),
                          ),

                          Expanded(
                            child: Text(
                              "Amount",
                              style:
                                  TextStyle(
                                fontWeight:
                                    FontWeight.w600,
                              ),
                            ),
                          ),

                          Expanded(
                            child: Text(
                              "Date",
                              style:
                                  TextStyle(
                                fontWeight:
                                    FontWeight.w600,
                              ),
                            ),
                          ),

                          Expanded(
                            child: Text(
                              "Status",
                              style:
                                  TextStyle(
                                fontWeight:
                                    FontWeight.w600,
                              ),
                            ),
                          ),

                          SizedBox(
                            width: 60,
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: FutureBuilder<
                          List<
                              RewardWithdrawal>>(
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

                          final withdrawals =
                              snapshot.data ??
                                  [];

                          if (withdrawals
                              .isEmpty) {

                            return const Center(
                              child: Text(
                                "No withdrawal requests",
                              ),
                            );
                          }

                          return RefreshIndicator(
                            onRefresh:
                                _refresh,

                            child:
                                ListView.separated(

                              itemCount:
                                  withdrawals
                                      .length,

                              separatorBuilder:
                                  (_, __) =>
                                      Divider(
                                height:
                                    1,
                                color: Colors
                                    .grey
                                    .shade200,
                              ),

                              itemBuilder:
                                  (
                                    context,
                                    index,
                                  ) {

                                final withdrawal =
                                    withdrawals[
                                        index];

                                final status =
                                    withdrawal
                                        .status;

                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(
                                    horizontal:
                                        20,
                                    vertical:
                                        18,
                                  ),

                                  child:
                                      Row(
                                    children: [

                                      Expanded(
                                        flex: 2,
                                        child:
                                          Column(
  crossAxisAlignment:
      CrossAxisAlignment.start,
  children: [

    Text(
      withdrawal.customerName.isNotEmpty
          ? withdrawal.customerName
          : 'Unknown Customer',
      style: const TextStyle(
        fontWeight: FontWeight.w600,
      ),
    ),

    Text(
      withdrawal.phoneNumber.isNotEmpty
          ? withdrawal.phoneNumber
          : withdrawal.uid,
      style: TextStyle(
        fontSize: 12,
        color: Colors.grey.shade600,
      ),
    ),
  ],
),
                                      ),

                                      Expanded(
                                        flex: 2,
                                        child:
                                            SelectableText(
                                          withdrawal
                                              .upiId,
                                        ),
                                      ),

                                      Expanded(
                                        child:
                                            Text(
                                          "₹${withdrawal.amount.toStringAsFixed(2)}",
                                        ),
                                      ),

                                      Expanded(
                                        child:
                                            Text(
                                          _formatDate(
                                            withdrawal
                                                .createdAt,
                                          ),
                                        ),
                                      ),

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
                                            color: status ==
                                                    'pending'
                                                ? Colors.orange.shade50
                                                : status ==
                                                        'approved'
                                                    ? Colors.green.shade50
                                                    : Colors.red.shade50,

                                            borderRadius:
                                                BorderRadius.circular(
                                                    20),
                                          ),

                                          child:
                                              Text(
                                            status.toUpperCase(),

                                            textAlign:
                                                TextAlign.center,

                                            style:
                                                TextStyle(
                                              fontSize:
                                                  12,
                                              fontWeight:
                                                  FontWeight.w600,
                                              color: status ==
                                                      'pending'
                                                  ? Colors.orange
                                                  : status ==
                                                          'approved'
                                                      ? Colors.green
                                                      : Colors.red,
                                            ),
                                          ),
                                        ),
                                      ),

                                      PopupMenuButton<
                                          String>(
                                        onSelected:
                                            (
                                              value,
                                            ) async {

                                          if (value ==
                                              'approve') {

                                            await _approve(
                                              withdrawal
                                                  .id,
                                            );
                                          }

                                          if (value ==
                                              'reject') {

                                            await _reject(
                                              withdrawal
                                                  .id,
                                            );
                                          }
                                        },

                                        itemBuilder:
                                            (_) =>
                                                [

                                          if (status ==
                                              'pending')
                                            const PopupMenuItem(
                                              value:
                                                  'approve',
                                              child:
                                                  Text(
                                                'Approve',
                                              ),
                                            ),

                                          if (status ==
                                              'pending')
                                            const PopupMenuItem(
                                              value:
                                                  'reject',
                                              child:
                                                  Text(
                                                'Reject',
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