import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../components/primary_scaffold.dart';
import '../models/reward_transaction.dart';
import '../services/rewards_service.dart';

class CustomerRewardsScreen extends StatelessWidget {
  final String userId;
  final String customerName;

  CustomerRewardsScreen({
    super.key,
    required this.userId,
    required this.customerName,
  });

  final RewardsService _rewardsService = RewardsService();

  // ===================== ADJUST DIALOG =====================

  void _openAdjustDialog(BuildContext context) {
    final amountController = TextEditingController();
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        String status = 'credited';
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Adjust Points'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: status,
                    items: const [
                      DropdownMenuItem(value: 'credited', child: Text('Credited')),
                      DropdownMenuItem(value: 'debited', child: Text('Debited')),
                      DropdownMenuItem(value: 'pending', child: Text('Pending')),
                    ],
                    onChanged: (val) => setState(() => status = val!),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Amount'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: reasonController,
                    decoration: const InputDecoration(labelText: 'Reason'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final amount = double.tryParse(amountController.text.trim()) ?? 0;
                    if (amount <= 0 || reasonController.text.isEmpty) return;

                    final String type = status == 'debited' ? 'debit' : 'credit';

                    await _rewardsService.adjustPoints(
                      userId: userId,
                      amount: amount.toInt(),
                      type: type,
                      status: status,
                      reason: reasonController.text.trim(),
                    );

                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ===================== REDEEM DIALOG =====================

  void _openRedeemDialog(BuildContext context) {
    final amountController = TextEditingController();
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Redeem Points for Cash'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Redeem Amount'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(labelText: 'Reason'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final amount = double.tryParse(amountController.text.trim()) ?? 0;
              if (amount <= 0 || reasonController.text.isEmpty) return;

              await _rewardsService.adjustPoints(
                userId: userId,
                amount: amount.toInt(),
                type: 'debit',
                status: 'debited',
                reason: 'Redeemed: ${reasonController.text.trim()}',
              );

              Navigator.of(dialogContext).pop();
            },
            child: const Text('Redeem', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ===================== BUILD =====================

  @override
  Widget build(BuildContext context) {
    return PrimaryScaffold(
      title: '$customerName - Wallet',
      body: Container(
        color: const Color(0xFFF8F4F4),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _balanceCard(),
            const SizedBox(height: 24),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Wallet Transactions',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => _openAdjustDialog(context),
                  icon: const Icon(Icons.tune),
                  label: const Text('Adjust Points'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB5838D),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => _openRedeemDialog(context),
                  icon: const Icon(Icons.money_off),
                  label: const Text('Redeem for Cash'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(child: _transactionsList()),
          ],
        ),
      ),
    );
  }

  // ===================== BALANCE CARD =====================

  Widget _balanceCard() {
    return StreamBuilder<List<RewardTransaction>>(
      stream: _rewardsService.streamRewardTransactions(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(height: 120, child: Center(child: CircularProgressIndicator()));
        }

        double available = 0;
        double pending = 0;

        for (final tx in snapshot.data ?? []) {
          final amt = tx.amount;
          if (tx.status == 'pending') {
            pending += amt;
          } else if (tx.status == 'credited') {
            available += amt;
          } else if (tx.status == 'debited' || tx.type == 'debit') {
            available -= amt;
          }
        }

        if (available < 0) available = 0;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [Color(0xFF6D3B47), Color(0xFFB5838D)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.account_balance_wallet, color: Colors.white, size: 40),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Available Balance',
                          style: TextStyle(color: Colors.white70, fontSize: 16)),
                      const SizedBox(height: 6),
                      Text(
                        '₹${available.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (pending > 0) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lock_clock, color: Colors.white70, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Pending Rewards: ₹${pending.toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  // ===================== TRANSACTIONS LIST =====================

  Widget _transactionsList() {
    return StreamBuilder<List<RewardTransaction>>(
      stream: _rewardsService.streamRewardTransactions(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading transactions'));
        }

        final transactions = snapshot.data ?? [];
        if (transactions.isEmpty) {
          return const Center(child: Text('No wallet transactions yet'));
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: transactions.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final tx = transactions[index];

            final isCredit = tx.type == 'credit';
            final isPending = tx.status == 'pending';
            final isReversed = tx.status == 'reversed';

            Color bgColor;
            Color iconColor;
            IconData icon;
            String title;

            if (isPending) {
              bgColor = Colors.orange.shade100;
              iconColor = Colors.orange;
              icon = Icons.lock_clock;
              title = 'Pending Reward';
            } else if (isReversed) {
              bgColor = Colors.red.shade100;
              iconColor = Colors.red;
              icon = Icons.undo;
              title = 'Reward Reversed';
            } else if (isCredit) {
              bgColor = Colors.green.shade100;
              iconColor = Colors.green;
              icon = Icons.arrow_downward;
              title = 'Wallet Credit';
            } else {
              bgColor = Colors.red.shade100;
              iconColor = Colors.red;
              icon = Icons.arrow_upward;
              title = 'Wallet Debit';
            }

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: bgColor,
                    child: Icon(icon, color: iconColor),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 14)),
                        if (tx.wooOrderId != null &&
                            tx.wooOrderId!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: SelectableText(
                              'Order #${tx.wooOrderId}',
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w800),
                            ),
                          ),
                        if (tx.reason.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(tx.reason,
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.black87)),
                          ),
                        if (tx.createdAt != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              DateFormat('dd MMM yyyy, hh:mm a')
                                  .format(tx.createdAt!),
                              style: const TextStyle(
                                  fontSize: 11, color: Colors.grey),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Text(
                    isReversed || !isCredit
                        ? '-₹${tx.amount.toStringAsFixed(2)}'
                        : '+₹${tx.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isPending
                          ? Colors.orange
                          : isReversed
                              ? Colors.red
                              : isCredit
                                  ? Colors.green
                                  : Colors.red,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}