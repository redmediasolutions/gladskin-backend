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
      print(
        "🔍 Starting user search...",
      );

      final phone =
          _searchController.text
              .trim();

      print(
        "📱 Searching phone: $phone",
      );

      if (phone.isEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              "Enter phone number",
            ),
          ),
        );

        return;
      }

      final result =
          await _db
              .collection('Users')
              .where(
                'phone_number',
                isEqualTo: phone,
              )
              .limit(1)
              .get();

      print(
        "📄 Documents found: ${result.docs.length}",
      );

      if (result.docs.isEmpty) {
        throw Exception(
          "No user found",
        );
      }

      final user =
          result.docs.first;

      final data =
          user.data()
              as Map<String, dynamic>;

      setState(() {
        _selectedUser = user;

        _selectedUserData =
            data;

        /// PREFILL
        _nameController.text =
            data['full_name'] ??
                '';

        _locationController
                .text =
            data['location'] ??
                '';

        _instagramController
                .text =
            data['influencerData']
                    ?[
                    'instagramHandle'] ??
                '';

        _youtubeController
                .text =
            data['influencerData']
                    ?[
                    'youtubeChannel'] ??
                '';

        _bioController.text =
            data['influencerData']
                    ?['bio'] ??
                '';
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "User found",
          ),
        ),
      );
    } catch (e) {
      print(
        "❌ SEARCH USER ERROR: $e",
      );

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content:
              Text(e.toString()),
        ),
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
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Select a user first",
          ),
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

      final phone =
          _selectedUserData?[
                  'phone_number'] ??
              '';

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

      final cleanPhone =
          phone
              .toString()
              .replaceAll(
                RegExp(r'\D'),
                '',
              );

      final phoneLast4 =
          cleanPhone.length >= 4
              ? cleanPhone.substring(
                  cleanPhone.length -
                      4,
                )
              : cleanPhone;

      final timestamp =
          DateTime.now()
              .millisecondsSinceEpoch
              .toString()
              .substring(8);

      /// REFERRAL CODE
      final referralCode =
          "$shortName$phoneLast4$timestamp";

      /// COUPON CODE
      final couponCode =
          "${shortName}10";

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
                            (_selectedUserData![
                                            'full_name'] ??
                                        'U')
                                    .toString()[0]
                                    .toUpperCase(),

                            style:
                                const TextStyle(
                              color:
                                  Colors.white,

                              fontWeight:
                                  FontWeight
                                      .w700,
                            ),
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