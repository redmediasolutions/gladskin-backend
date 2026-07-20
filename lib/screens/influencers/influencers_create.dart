import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gladskin_backend/models/coupon_model.dart';
import 'package:gladskin_backend/services/firestore_service.dart';
import 'package:go_router/go_router.dart';

class CreateInfluencerScreen
    extends StatefulWidget {
  const CreateInfluencerScreen({
    super.key,
  });

  @override
  State<CreateInfluencerScreen>
      createState() =>
          _CreateInfluencerScreenState();
}

class _CreateInfluencerScreenState
    extends State<
        CreateInfluencerScreen> {
  final _formKey =
      GlobalKey<FormState>();

  final FirebaseFirestore _db =
      FirebaseFirestore.instance;

  final FirestoreService
      _firestoreService =
      FirestoreService();

  /// SEARCH
  final TextEditingController
      _searchController =
      TextEditingController();

  /// BASIC INFO
  final TextEditingController
      _nameController =
      TextEditingController();

  final TextEditingController
      _locationController =
      TextEditingController();

  /// SOCIALS
  final TextEditingController
      _instagramController =
      TextEditingController();

  final TextEditingController
      _youtubeController =
      TextEditingController();

  /// OTHER
  final TextEditingController
      _bioController =
      TextEditingController();

  final TextEditingController
      _commissionController =
      TextEditingController(
    text: "10",
  );

  bool _isLoading = false;

  DocumentSnapshot? _selectedUser;

  Map<String, dynamic>? _selectedUserData;

  /// =========================================
  /// SEARCH USER
  /// =========================================

  Future<void> _searchUser() async {
    try {
      print("🔍 Starting user search...");

      // 1. Get raw input, trim spaces
      String inputPhone = _searchController.text.trim();

      if (inputPhone.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Enter phone number")),
        );
        return;
      }

      // 2. Normalize input: remove spaces, hyphens, or brackets
      inputPhone = inputPhone.replaceAll(RegExp(r'[\s\-()]'), '');

      // 3. Smart country code appending
      String searchPhone;
      if (inputPhone.startsWith('+91')) {
        searchPhone = inputPhone;
      } else if (inputPhone.startsWith('91') && inputPhone.length > 10) {
        // Handles cases where user typed 919876543210 without the '+'
        searchPhone = '+$inputPhone';
      } else {
        // Handles standard 10 digit input like 9876543210
        searchPhone = '+91$inputPhone';
      }

      print("📱 Original input: ${_searchController.text.trim()} -> Formatted search phone: $searchPhone");

      final result = await _db
          .collection('Users')
          .where('phone_number', isEqualTo: searchPhone)
          .limit(1)
          .get();

      print("📄 Documents found: ${result.docs.length}");

      if (result.docs.isEmpty) {
        throw Exception("No user found with number $searchPhone");
      }

      final user = result.docs.first;
      final data = user.data();

      setState(() {
        _selectedUser = user;
        _selectedUserData = data;

        /// PREFILL
        _nameController.text = data['full_name'] ?? '';
        _locationController.text = data['location'] ?? '';
        _instagramController.text = data['influencerData']?['instagramHandle'] ?? '';
        _youtubeController.text = data['influencerData']?['youtubeChannel'] ?? '';
        _bioController.text = data['influencerData']?['bio'] ?? '';
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User found")),
      );
    } catch (e) {
      print("❌ SEARCH USER ERROR: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  /// =========================================
  /// CREATE INFLUENCER
  /// =========================================

  Future<void>
      _createInfluencer() async {
    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    if (_selectedUser == null) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text("Select a user first"),
    ),
  );
  return;
}

if (_selectedUserData?['isInfluencer'] == true) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text("This user is already an influencer."),
    ),
  );
  return;
}

setState(() {
  _isLoading = true;
});

try {
      final userId =
          _selectedUser!.id;

      final fullName =
          _nameController.text
              .trim();

      final location =
          _locationController
              .text
              .trim();

      /// =========================================
      /// GENERATE REFERRAL CODE
      /// =========================================

      final cleanName =
          fullName
              .replaceAll(
                RegExp(
                  r'[^A-Za-z]',
                ),
                '',
              )
              .toUpperCase();

      final shortName =
          cleanName.length >= 4
              ? cleanName.substring(
                  0,
                  4,
                )
              : cleanName;

      /// REFERRAL CODE
      /// =========================================
/// GENERATE UNIQUE COUPON / REFERRAL CODE
/// =========================================


String baseCode = "${shortName}10";
String uniqueCode = baseCode;

int counter = 2;

while (true) {
  final userExists = await _db
      .collection("Users")
      .where("referralCode", isEqualTo: uniqueCode)
      .limit(1)
      .get();

  final couponExists = await _db
      .collection("Coupons")
      .where("code", isEqualTo: uniqueCode)
      .limit(1)
      .get();

  if (userExists.docs.isEmpty &&
      couponExists.docs.isEmpty) {
    break;
  }

  uniqueCode = "$baseCode$counter";
  counter++;
}

final couponCode = uniqueCode;

/// Referral code is the same as coupon code
final referralCode = uniqueCode;

      print(
        "🎯 Referral Code: $referralCode",
      );

      print(
        "🏷 Coupon Code: $couponCode",
      );

      /// =========================================
      /// UPDATE USER
      /// =========================================

      final userUpdateData = {
        'full_name':
            fullName,

        'location':
            location,

        'isInfluencer':
            true,

        'referralCode':
            referralCode,

        'influencerCouponCode':
            couponCode,

        'influencerData': {
          'name':
              fullName,

          'location':
              location,

          'instagramHandle':
              _instagramController
                  .text
                  .trim(),

          'youtubeChannel':
              _youtubeController
                  .text
                  .trim(),

          'bio':
              _bioController.text
                  .trim(),

          'couponCode':
              couponCode,

          'referralCode':
              referralCode,

          'commissionPercentage':
              double.parse(
            _commissionController
                .text,
          ),

          'totalOrders': 0,

          'totalRevenue': 0,

          'totalCommissionEarned':
              0,

          'totalCustomersReferred':
              0,

          'totalCouponUses':
              0,

          'status': 'active',

          'joinedAt':
              Timestamp.now(),

          'updatedAt':
              Timestamp.now(),
        },
      };

      await _db
          .collection('Users')
          .doc(userId)
          .update(
            userUpdateData,
          );

      print(
        "✅ User updated successfully",
      );

      /// =========================================
      /// CREATE COUPON
      /// =========================================

      final coupon = CouponModel(
        id: '',

        code: couponCode,

        discount: 10,

        usedCount: 0,

        maxUsage: -1,

        isActive: true,

        isInfluencerCoupon:
            true,

        influencerId:
            userId,

        influencerName:
            fullName,

        startDate: null,

        endDate: null,

        createdAt:
            Timestamp.now(),
      );

      await _firestoreService
          .createCoupon(
        coupon: coupon,
      );

      print(
        "✅ Coupon created successfully",
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Influencer created successfully",
          ),
        ),
      );

      context.pop();
    } catch (e) {
      print(
        "❌ CREATE INFLUENCER ERROR: $e",
      );

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content:
              Text(e.toString()),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// =========================================
  /// INPUT DECORATION
  /// =========================================

  InputDecoration
      _inputDecoration(
    String label,
  ) {
    return InputDecoration(
      labelText: label,

      filled: true,

      fillColor:
          const Color(
        0xFFF8F4F4,
      ),

      border:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(
          14,
        ),

        borderSide:
            BorderSide.none,
      ),
    );
  }

  /// =========================================
  /// UI
  /// =========================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          const Color(
        0xFFF8F4F4,
      ),

      appBar: AppBar(
        backgroundColor:
            Colors.transparent,

        elevation: 0,

        title: const Text(
          "Create Influencer",
        ),
      ),

      body: Center(
        child: Container(
          width: 700,

          margin:
              const EdgeInsets.all(
            24,
          ),

          padding:
              const EdgeInsets.all(
            28,
          ),

          decoration:
              BoxDecoration(
            color: Colors.white,

            borderRadius:
                BorderRadius.circular(
              24,
            ),
          ),

          child: Form(
            key: _formKey,

            child: ListView(
              children: [
                const Text(
                  "Influencer Onboarding",

                  style: TextStyle(
                    fontSize: 26,

                    fontWeight:
                        FontWeight
                            .w700,
                  ),
                ),

                const SizedBox(
                  height: 8,
                ),

                const Text(
                  "Convert an existing customer into an influencer.",

                  style: TextStyle(
                    color:
                        Colors.grey,
                  ),
                ),

                const SizedBox(
                  height: 32,
                ),

                /// SEARCH
                Row(
                  children: [
                    Expanded(
                      child:
                          TextFormField(
                        controller:
                            _searchController,

                        keyboardType:
                            TextInputType
                                .phone,

                        decoration:
                            _inputDecoration(
                          "Search by Phone Number",
                        ),
                      ),
                    ),

                    const SizedBox(
                      width: 12,
                    ),

                    SizedBox(
                      height: 58,

                      child:
                          ElevatedButton(
                        onPressed:
                            _searchUser,

                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(
                            0xFFB5838D,
                          ),

                          foregroundColor:
                              Colors.white,
                        ),

                        child:
                            const Text(
                          "Find User",
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 24,
                ),

                /// USER CARD
                if (_selectedUserData !=
                    null)
                  Container(
                    padding:
                        const EdgeInsets.all(
                      18,
                    ),

                    decoration:
                        BoxDecoration(
                      color:
                          const Color(
                        0xFFF8F4F4,
                      ),

                      borderRadius:
                          BorderRadius.circular(
                        16,
                      ),
                    ),

                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 26,

                          backgroundColor:
                              const Color(
                            0xFFB5838D,
                          ),

                          child: Text(
  (() {
    final name = (_selectedUserData?['full_name'] ?? '')
        .toString()
        .trim();

    return name.isEmpty
        ? 'U'
        : name.characters.first.toUpperCase();
  })(),
),
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
                                _selectedUserData![
                                        'full_name'] ??
                                    '',

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
                                height: 4,
                              ),

                              Text(
                                _selectedUserData![
                                        'phone_number'] ??
                                    '',

                                style:
                                    const TextStyle(
                                  color:
                                      Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                if (_selectedUserData !=
                    null) ...[
                  const SizedBox(
                    height: 28,
                  ),

                  TextFormField(
                    controller:
                        _nameController,

                    decoration:
                        _inputDecoration(
                      "Influencer Name",
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  TextFormField(
                    controller:
                        _locationController,

                    decoration:
                        _inputDecoration(
                      "Location",
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  TextFormField(
                    controller:
                        _instagramController,

                    decoration:
                        _inputDecoration(
                      "Instagram Handle",
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  TextFormField(
                    controller:
                        _youtubeController,

                    decoration:
                        _inputDecoration(
                      "YouTube Channel",
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  TextFormField(
                    controller:
                        _bioController,

                    maxLines: 4,

                    decoration:
                        _inputDecoration(
                      "Bio",
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  TextFormField(
                    controller:
                        _commissionController,

                    keyboardType:
                        TextInputType
                            .number,

                    decoration:
                        _inputDecoration(
                      "Commission %",
                    ),
                  ),

                  const SizedBox(
                    height: 40,
                  ),

                  SizedBox(
                    height: 56,

                    child:
                        ElevatedButton(
                      onPressed:
                          _isLoading
                              ? null
                              : _createInfluencer,

                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(
                          0xFFB5838D,
                        ),

                        foregroundColor:
                            Colors.white,
                      ),

                      child:
                          _isLoading
                              ? const CircularProgressIndicator(
                                  color:
                                      Colors.white,
                                )
                              : const Text(
                                  "Create Influencer",
                                ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}