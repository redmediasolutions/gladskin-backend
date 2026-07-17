import 'package:flutter/material.dart';
import 'package:gladskin_backend/models/user_model.dart';

class UserDetailsCard extends StatelessWidget {
  final UserModel? user;

  const UserDetailsCard({
    super.key,
    required this.user,
  });

  Widget row(
    String label,
    String? value,
  ) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 6,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value?.isNotEmpty == true
                  ? value!
                  : "-",
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const SizedBox();
    }

    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              "Customer Account",
              style: TextStyle(
                fontWeight:
                    FontWeight.bold,
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 20),

            row(
              "UID",
              user!.uid,
            ),

            row(
              "Referral Code",
              user!.referralCode,
            ),

            row(
              "Referred By",
              user!.referredBy,
            ),

            row(
              "Referrer Phone",
              user!.referredByPhone,
            ),

            row(
              "Wallet Balance",
              "₹${user!.walletBalance}",
            ),

            row(
              "Reward Points",
              "${user!.rewardPoints}",
            ),
          ],
        ),
      ),
    );
  }
}