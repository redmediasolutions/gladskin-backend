import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gladskin_backend/models/influencer_model.dart';
import 'package:gladskin_backend/services/firestore_service.dart';
import 'package:go_router/go_router.dart';

class Influencerscreens extends StatelessWidget {
  const Influencerscreens({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F4F4),

      body: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            /// HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      "Influencers",

                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    SizedBox(height: 4),

                    Text(
                      "Manage influencer accounts and coupon tracking",

                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),

                ElevatedButton.icon(
                  onPressed: () {
                    context.push('/influencers/create');
                  },

                  icon: const Icon(Icons.person_add_alt_1),

                  label: const Text("Add Influencer"),

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB5838D),

                    foregroundColor: Colors.white,

                    padding: const EdgeInsets.symmetric(
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

                  borderRadius: BorderRadius.circular(18),

                  border: Border.all(color: Colors.grey.shade200),
                ),

                child: Column(
                  children: [
                    /// HEADER
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 18,
                      ),

                      decoration: BoxDecoration(
                        color: const Color(0xFFFDFBFB),

                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(18),
                          topRight: Radius.circular(18),
                        ),

                        border: Border(
                          bottom: BorderSide(color: Colors.grey.shade200),
                        ),
                      ),

                      child: const Row(
                        children: [
                          Expanded(
                            flex: 2,

                            child: Text(
                              "Influencer",

                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),

                          Expanded(
                            flex: 2,

                            child: Text(
                              "Phone",

                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),

                          Expanded(
                            flex: 2,

                            child: Text(
                              "Coupon Code",

                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),

                          Expanded(
                            child: Text(
                              "Status",

                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),

                          SizedBox(width: 60),
                        ],
                      ),
                    ),

                    /// DATA
                    Expanded(
                      child: StreamBuilder<List<InfluencerModel>>(
                        stream: firestoreService.getInfluencers(),

                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          final influencers = snapshot.data ?? [];

                          if (influencers.isEmpty) {
                            return const Center(
                              child: Text("No influencers found"),
                            );
                          }

                          return ListView.separated(
                            itemCount: influencers.length,

                            separatorBuilder: (_, __) =>
                                Divider(height: 1, color: Colors.grey.shade200),

                            itemBuilder: (context, index) {
                              final influencer = influencers[index];

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 18,
                                ),

                                child: Row(
                                  children: [
                                    /// NAME
                                    Expanded(
                                      flex: 2,

                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 18,

                                            backgroundColor: const Color(
                                              0xFFF6ECEE,
                                            ),

                                            child: Text(
                                              influencer.fullName.isNotEmpty
                                                  ? influencer.fullName[0]
                                                        .toUpperCase()
                                                  : "?",

                                              style: const TextStyle(
                                                color: Color(0xFFB5838D),

                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),

                                          const SizedBox(width: 12),

                                          Expanded(
                                            child: Text(
                                              influencer.fullName,

                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    /// PHONE
                                    Expanded(
                                      flex: 2,

                                      child: Text(influencer.phoneNumber),
                                    ),

                                    /// COUPON
                                    Expanded(
                                      flex: 2,

                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),

                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF6ECEE),

                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),
                                        ),

                                        child: Text(
                                          influencer.couponCode,

                                          textAlign: TextAlign.center,

                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,

                                            color: Color(0xFFB5838D),
                                          ),
                                        ),
                                      ),
                                    ),

                                    /// STATUS
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),

                                        decoration: BoxDecoration(
                                          color: Colors.green.shade50,

                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),

                                        child: const Text(
                                          "Active",

                                          textAlign: TextAlign.center,

                                          style: TextStyle(
                                            fontSize: 12,

                                            fontWeight: FontWeight.w600,

                                            color: Colors.green,
                                          ),
                                        ),
                                      ),
                                    ),

                                    /// ACTIONS
                                    PopupMenuButton<String>(
                                      onSelected: (value) async {
                                        final referralCode =
                                            influencer.referralCode ??
                                            '';

                                        final referralLink =
                                            "https://go.gladskin.in/referral/$referralCode";

                                        if (value == 'copy_referral') {
                                          await Clipboard.setData(
                                            ClipboardData(text: referralLink),
                                          );

                                          if (!context.mounted) {
                                            return;
                                          }

                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                "Referral link copied",
                                              ),
                                            ),
                                          );
                                        }
                                      },

                                      itemBuilder: (context) => [
                                        const PopupMenuItem(
                                          value: 'copy_referral',

                                          child: Row(
                                            children: [
                                              Icon(Icons.copy, size: 18),

                                              SizedBox(width: 10),

                                              Text("Copy Referral Link"),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
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
