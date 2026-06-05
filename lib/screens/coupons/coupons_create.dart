import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gladskin_backend/models/coupon_model.dart';
import 'package:gladskin_backend/services/firestore_service.dart';
import 'package:go_router/go_router.dart';

class CreateCouponScreen extends StatefulWidget {
  const CreateCouponScreen({super.key});

  @override
  State<CreateCouponScreen> createState() =>
      _CreateCouponScreenState();
}

class _CreateCouponScreenState
    extends State<CreateCouponScreen> {
  final _formKey = GlobalKey<FormState>();

  final FirestoreService _firestoreService =
      FirestoreService();

  final FirebaseFirestore _db =
      FirebaseFirestore.instance;

  final TextEditingController _codeController =
      TextEditingController();

  final TextEditingController
      _discountController =
      TextEditingController();

  final TextEditingController
      _maxUsageController =
      TextEditingController();

  bool _isActive = true;

  bool _isUnlimitedUsage = false;

  bool _isInfluencerCoupon = false;

  bool _isLoading = false;

  String? _selectedInfluencerId;
  String? _selectedInfluencerName;

  DateTime? _startDate;
  DateTime? _endDate;

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  Future<void> _createCoupon() async {
    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final coupon = CouponModel(
        id: '',

        code: _codeController.text
            .trim()
            .toUpperCase(),

        discount: double.parse(
          _discountController.text,
        ),

        usedCount: 0,

        maxUsage: _isUnlimitedUsage
            ? -1
            : int.parse(
                _maxUsageController.text,
              ),

        isActive: _isActive,

        isInfluencerCoupon:
            _isInfluencerCoupon,

        influencerId:
            _selectedInfluencerId,

        influencerName:
            _selectedInfluencerName,

        startDate: _startDate != null
            ? Timestamp.fromDate(
                _startDate!,
              )
            : null,

        endDate: _endDate != null
            ? Timestamp.fromDate(
                _endDate!,
              )
            : null,

        createdAt: Timestamp.now(),
      );

      await _firestoreService
          .createCoupon(
        coupon: coupon,
      );

      /// LINK COUPON TO USER
      if (_isInfluencerCoupon &&
          _selectedInfluencerId != null) {
        await _db
            .collection('users')
            .doc(
              _selectedInfluencerId,
            )
            .update({
          'isInfluencer': true,
          'influencerCouponCode':
              coupon.code,
        });
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Coupon created successfully",
          ),
        ),
      );

      context.pop();
    } catch (e) {
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

  InputDecoration _inputDecoration(
    String label,
  ) {
    return InputDecoration(
      labelText: label,

      filled: true,

      fillColor:
          const Color(0xFFF8F4F4),

      border:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF8F4F4),

      appBar: AppBar(
        backgroundColor:
            Colors.transparent,

        elevation: 0,

        title: const Text(
          "Create Coupon",
        ),
      ),

      body: Center(
        child: Container(
          width: 700,

          margin:
              const EdgeInsets.all(24),

          padding:
              const EdgeInsets.all(28),

          decoration: BoxDecoration(
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
                  "Coupon Details",

                  style: TextStyle(
                    fontSize: 26,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),

                const SizedBox(
                  height: 8,
                ),

                const Text(
                  "Create and manage promotional coupons.",

                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(
                  height: 32,
                ),

                /// CODE
                TextFormField(
                  controller:
                      _codeController,

                  textCapitalization:
                      TextCapitalization
                          .characters,

                  decoration:
                      _inputDecoration(
                    "Coupon Code",
                  ),

                  validator: (
                    value,
                  ) {
                    if (value == null ||
                        value
                            .trim()
                            .isEmpty) {
                      return "Enter coupon code";
                    }

                    return null;
                  },
                ),

                const SizedBox(
                  height: 20,
                ),

                /// DISCOUNT
                TextFormField(
                  controller:
                      _discountController,

                  keyboardType:
                      TextInputType.number,

                  decoration:
                      _inputDecoration(
                    "Discount %",
                  ),

                  validator: (
                    value,
                  ) {
                    if (value == null ||
                        value
                            .trim()
                            .isEmpty) {
                      return "Enter discount";
                    }

                    return null;
                  },
                ),

                const SizedBox(
                  height: 24,
                ),

                /// UNLIMITED USAGE
                SwitchListTile(
                  value:
                      _isUnlimitedUsage,

                  activeColor:
                      const Color(
                    0xFFB5838D,
                  ),

                  title: const Text(
                    "Unlimited Usage",
                  ),

                  contentPadding:
                      EdgeInsets.zero,

                  onChanged: (
                    value,
                  ) {
                    setState(() {
                      _isUnlimitedUsage =
                          value;
                    });
                  },
                ),

                const SizedBox(
                  height: 16,
                ),

                /// MAX USAGE
                if (!_isUnlimitedUsage)
                  TextFormField(
                    controller:
                        _maxUsageController,

                    keyboardType:
                        TextInputType
                            .number,

                    decoration:
                        _inputDecoration(
                      "Maximum Usage",
                    ),

                    validator: (
                      value,
                    ) {
                      if (_isUnlimitedUsage) {
                        return null;
                      }

                      if (value ==
                              null ||
                          value
                              .trim()
                              .isEmpty) {
                        return "Enter max usage";
                      }

                      return null;
                    },
                  ),

                const SizedBox(
                  height: 24,
                ),

                /// INFLUENCER COUPON
                SwitchListTile(
                  value:
                      _isInfluencerCoupon,

                  activeColor:
                      const Color(
                    0xFFB5838D,
                  ),

                  title: const Text(
                    "Attach Influencer",
                  ),

                  subtitle: const Text(
                    "Link this coupon to an influencer",
                  ),

                  contentPadding:
                      EdgeInsets.zero,

                  onChanged: (
                    value,
                  ) {
                    setState(() {
                      _isInfluencerCoupon =
                          value;

                      if (!value) {
                        _selectedInfluencerId =
                            null;

                        _selectedInfluencerName =
                            null;
                      }
                    });
                  },
                ),

                /// SELECT INFLUENCER
                if (_isInfluencerCoupon) ...[
                  const SizedBox(
                    height: 20,
                  ),

                  StreamBuilder<
                      QuerySnapshot>(
                    stream: _db
                        .collection(
                          'users',
                        )
                        .where(
                          'isInfluencer',
                          isEqualTo: true,
                        )
                        .snapshots(),

                    builder:
                        (
                          context,
                          snapshot,
                        ) {
                      if (!snapshot
                          .hasData) {
                        return const Center(
                          child:
                              CircularProgressIndicator(),
                        );
                      }

                      final docs =
                          snapshot
                              .data!
                              .docs;

                      return DropdownButtonFormField<
                          String>(
                        value:
                            _selectedInfluencerId,

                        decoration:
                            _inputDecoration(
                          "Select Influencer",
                        ),

                        items:
                            docs.map(
                          (
                            doc,
                          ) {
                            final data =
                                doc.data()
                                    as Map<String,
                                        dynamic>;

                            final name =
                                data['full_name'] ??
                                    'Unnamed';

                            final phone =
                                data['phoneNumber'] ??
                                    '';

                            return DropdownMenuItem<
                                String>(
                              value:
                                  doc.id,

                              child:
                                  Text(
                                "$name ($phone)",
                              ),
                            );
                          },
                        ).toList(),

                        onChanged:
                            (
                              value,
                            ) {
                          final selectedDoc =
                              docs.firstWhere(
                            (
                              doc,
                            ) =>
                                doc.id ==
                                value,
                          );

                          final data =
                              selectedDoc
                                      .data()
                                  as Map<String,
                                      dynamic>;

                          setState(
                            () {
                              _selectedInfluencerId =
                                  value;

                              _selectedInfluencerName =
                                  data['full_name'];
                            },
                          );
                        },

                        validator:
                            (
                              value,
                            ) {
                          if (_isInfluencerCoupon &&
                              value ==
                                  null) {
                            return "Select influencer";
                          }

                          return null;
                        },
                      );
                    },
                  ),
                ],

                const SizedBox(
                  height: 24,
                ),

                /// ACTIVE SWITCH
                SwitchListTile(
                  value: _isActive,

                  activeColor:
                      const Color(
                    0xFFB5838D,
                  ),

                  title: const Text(
                    "Active Coupon",
                  ),

                  contentPadding:
                      EdgeInsets.zero,

                  onChanged: (
                    value,
                  ) {
                    setState(() {
                      _isActive =
                          value;
                    });
                  },
                ),

                const SizedBox(
                  height: 24,
                ),

                /// DATES
                Row(
                  children: [
                    Expanded(
                      child:
                          OutlinedButton(
                        onPressed:
                            _pickStartDate,

                        style:
                            OutlinedButton.styleFrom(
                          padding:
                              const EdgeInsets.symmetric(
                            vertical:
                                18,
                          ),
                        ),

                        child: Text(
                          _startDate ==
                                  null
                              ? "Select Start Date"
                              : "${_startDate!.day}/${_startDate!.month}/${_startDate!.year}",
                        ),
                      ),
                    ),

                    const SizedBox(
                      width: 16,
                    ),

                    Expanded(
                      child:
                          OutlinedButton(
                        onPressed:
                            _pickEndDate,

                        style:
                            OutlinedButton.styleFrom(
                          padding:
                              const EdgeInsets.symmetric(
                            vertical:
                                18,
                          ),
                        ),

                        child: Text(
                          _endDate ==
                                  null
                              ? "Select End Date"
                              : "${_endDate!.day}/${_endDate!.month}/${_endDate!.year}",
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 40,
                ),

                /// BUTTON
                SizedBox(
                  height: 56,

                  child:
                      ElevatedButton(
                    onPressed:
                        _isLoading
                            ? null
                            : _createCoupon,

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
                                "Create Coupon",
                              ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}