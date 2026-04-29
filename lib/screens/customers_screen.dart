import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:html' as html;

import '../components/primary_scaffold.dart';
import '../models/customer.dart';
import '../services/firestore_service.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final FirestoreService _firestore = FirestoreService();
  final TextEditingController _searchController = TextEditingController();

  final List<Customer> _customers = [];
  QueryDocumentSnapshot? _lastDoc;

  bool _isLoading = false;
  bool _hasMore = true;

  static const int _pageSize = 20;

  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  // ===================== DATA =====================

  Future<void> _loadCustomers({bool reset = false}) async {
    if (_isLoading || (!_hasMore && !reset)) return;

    if (reset) {
      _customers.clear();
      _lastDoc = null;
      _hasMore = true;
    }

    setState(() => _isLoading = true);

    final docs = await _firestore.fetchUsersPage(
      lastDoc: _lastDoc,
      limit: _pageSize,
      searchText: _searchController.text.trim(),
      startDate: _startDate,
      endDate: _endDate,
    );

    if (docs.isNotEmpty) {
      _lastDoc = docs.last;
      _customers.addAll(docs.map(Customer.fromFirestore));
    } else {
      _hasMore = false;
    }

    setState(() => _isLoading = false);
  }

  // ===================== DATE PICKERS =====================

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        _endDate = null;
      });
    }
  }

  Future<void> _pickEndDate() async {
    if (_startDate == null) return;
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate!,
      firstDate: _startDate!,
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _endDate = picked);
  }

  // ===================== EXPORT =====================

  void _openExportDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ExportCustomersDialog(firestore: _firestore),
    );
  }

  // ===================== CART =====================

  void _openCustomerCart(Customer customer) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => CustomerCartSheet(
        customerAuthUid: customer.authUid,
        customerName: customer.name,
      ),
    );
  }

  // ===================== UI =====================

  @override
  Widget build(BuildContext context) {
    return PrimaryScaffold(
      title: 'Customers',
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _searchBox(),
                  _dateButton(
                    label: _startDate == null
                        ? 'Start Date'
                        : _formatDate(_startDate!),
                    onTap: _pickStartDate,
                  ),
                  _dateButton(
                    label: _endDate == null
                        ? 'End Date'
                        : _formatDate(_endDate!),
                    onTap: _pickEndDate,
                    enabled: _startDate != null,
                  ),
                  ElevatedButton(
                    onPressed: () => _loadCustomers(reset: true),
                    child: const Text('Apply Filter'),
                  ),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.download),
                    label: const Text('Export'),
                    onPressed: _openExportDialog,
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                  color: Colors.white,
                ),
                child: Column(
                  children: [
                    _tableHeader(),
                    const Divider(height: 1),

                    if (_customers.isEmpty && !_isLoading)
                      const Padding(
                        padding: EdgeInsets.all(24),
                        child: Text('No customers found'),
                      ),

                    ..._customers.map(_customerRow),

                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      ),

                    if (_hasMore && !_isLoading && _customers.isNotEmpty)
                      TextButton(
                        onPressed: _loadCustomers,
                        child: const Text('Load More'),
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

  // ===================== UI HELPERS =====================

  Widget _searchBox() {
    return SizedBox(
      width: 260,
      height: 40,
      child: TextField(
        controller: _searchController,
        textInputAction: TextInputAction.search,
        decoration: const InputDecoration(
          hintText: 'Search by phone...',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(),
          isDense: true,
        ),
        onSubmitted: (_) => _loadCustomers(reset: true),
      ),
    );
  }

  Widget _dateButton({
    required String label,
    required VoidCallback onTap,
    bool enabled = true,
  }) {
    return SizedBox(
      height: 40,
      child: OutlinedButton(
        onPressed: enabled ? onTap : null,
        child: Text(label),
      ),
    );
  }

  String _formatDate(DateTime d) => '${d.day}/${d.month}/${d.year}';

  Widget _tableHeader() {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      color: Colors.grey.shade100,
      child: const Row(
        children: [
          Expanded(flex: 2, child: Text('Customer', style: TextStyle(fontWeight: FontWeight.w600))),
          Expanded(flex: 3, child: Text('Email', style: TextStyle(fontWeight: FontWeight.w600))),
          Expanded(flex: 2, child: Text('Phone', style: TextStyle(fontWeight: FontWeight.w600))),
          Expanded(flex: 2, child: Text('Joined', style: TextStyle(fontWeight: FontWeight.w600))),
          Expanded(flex: 1, child: Text('Type', style: TextStyle(fontWeight: FontWeight.w600))),
          Expanded(flex: 1, child: Text('Role', style: TextStyle(fontWeight: FontWeight.w600))),
          Expanded(flex: 1, child: Text('Actions', style: TextStyle(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  Widget _customerRow(Customer c) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(c.name)),
          Expanded(flex: 3, child: Text(c.email)),
          Expanded(flex: 2, child: Text(c.phone)),
          Expanded(flex: 2, child: Text(_formatDate(c.createdAt))),
          Expanded(flex: 1, child: Text(c.isAnonymous ? 'Guest' : 'User')),
          Expanded(flex: 1, child: Text(c.isAdmin ? 'Admin' : 'User')),
          Expanded(
            flex: 1,
            child: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'cart') _openCustomerCart(c);
                if (value == 'rewards') {
                  context.go(
                    '/customers/${c.id}/rewards?name=${Uri.encodeComponent(c.name)}',
                  );
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'cart', child: Text('View Cart')),
                PopupMenuItem(value: 'rewards', child: Text('View Rewards')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ===================== EXPORT DIALOG =====================

class _ExportCustomersDialog extends StatefulWidget {
  final FirestoreService firestore;
  const _ExportCustomersDialog({required this.firestore});

  @override
  State<_ExportCustomersDialog> createState() => _ExportCustomersDialogState();
}

class _ExportCustomersDialogState extends State<_ExportCustomersDialog> {
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isExporting = false;

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() { _startDate = picked; _endDate = null; });
  }

  Future<void> _pickEndDate() async {
    if (_startDate == null) return;
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate!,
      firstDate: _startDate!,
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _endDate = picked);
  }

  Future<void> _export() async {
    if (_startDate == null || _endDate == null) return;
    setState(() => _isExporting = true);

    final docs = await widget.firestore.fetchUsersPage(
      limit: 1000,
      startDate: _startDate,
      endDate: _endDate,
    );

    final customers = docs.map(Customer.fromFirestore).toList();

    final rows = <List<String>>[
      ['ID', 'Auth UID', 'Name', 'Email', 'Phone', 'Joined Date', 'User Type', 'Role', 'Profile Complete'],
    ];
    for (final c in customers) rows.add(c.toCsvRow());

    final csvData =  CsvCodec().encode(rows);

    if (kIsWeb) {
      final bytes = utf8.encode(csvData);
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.AnchorElement(href: url)
        ..setAttribute('download', 'gladskin_customers.csv')
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/gladskin_customers.csv');
      await file.writeAsString(csvData);
      await Share.shareXFiles([XFile(file.path)], text: 'Gladskin Customers Export');
    }

    if (context.mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Export Customers'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _pickStartDate,
              child: Text(_startDate == null ? 'Select Start Date' : '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _startDate != null ? _pickEndDate : null,
              child: Text(_endDate == null ? 'Select End Date' : '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isExporting ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: (_startDate != null && _endDate != null && !_isExporting) ? _export : null,
          child: _isExporting
              ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Export'),
        ),
      ],
    );
  }
}

// ===================== CART SHEET =====================

class CustomerCartSheet extends StatelessWidget {
  final String customerAuthUid;
  final String customerName;

  const CustomerCartSheet({
    super.key,
    required this.customerAuthUid,
    required this.customerName,
  });

  @override
  Widget build(BuildContext context) {
    if (customerAuthUid.isEmpty) {
      return const Center(child: Text('Invalid customer UID'));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('carts')
          .doc(customerAuthUid)
          .collection('items')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Padding(
            padding: EdgeInsets.all(32),
            child: Text('Cart is empty'),
          ));
        }

        final items = snapshot.data!.docs;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                '$customerName\'s Cart',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ...items.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return _cartItemTile(context, customerAuthUid, doc.id, data);
            }),
          ],
        );
      },
    );
  }

  Widget _cartItemTile(
    BuildContext context,
    String customerId,
    String docId,
    Map<String, dynamic> data,
  ) {
    final qtyController =
        TextEditingController(text: data['quantity']?.toString() ?? '1');

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: data['image'] != null && data['image'].toString().isNotEmpty
            ? Image.network(data['image'], width: 50, height: 50, fit: BoxFit.cover)
            : const Icon(Icons.medical_services_outlined),
        title: Text(
          data['name'] ?? 'Unknown product',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (data['contents'] != null) Text(data['contents']),
            const SizedBox(height: 4),
            Text(
              'MRP ₹${data['mrp']}  •  Sale ₹${data['salePrice']}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        trailing: SizedBox(
          width: 160,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: qtyController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Qty', isDense: true),
                  onSubmitted: (value) async {
                    final qty = int.tryParse(value);
                    if (qty == null || qty <= 0) return;
                    await FirebaseFirestore.instance
                        .collection('carts')
                        .doc(customerId)
                        .collection('items')
                        .doc(docId)
                        .update({'quantity': qty, 'updatedAt': FieldValue.serverTimestamp()});
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () async {
                  await FirebaseFirestore.instance
                      .collection('carts')
                      .doc(customerId)
                      .collection('items')
                      .doc(docId)
                      .delete();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}