import 'package:flutter/material.dart';

class PrimaryScaffold extends StatelessWidget {
  final String title;
  final Widget body;

  const PrimaryScaffold({
    super.key,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            // Gladskin logo/brand text
            const Text(
              'Gladskin',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 20,
                color: Color(0xFFB5838D),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 1,
              height: 20,
              color: Colors.grey.shade300,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.grey.shade200,
      ),
      backgroundColor: const Color(0xFFF8F4F4),
      body: body,
    );
  }
}