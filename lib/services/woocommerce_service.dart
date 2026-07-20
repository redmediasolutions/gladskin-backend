import 'dart:convert';

import 'package:gladskin_backend/services/config.dart';
import 'package:http/http.dart' as http;


class WooCommerceService {
  final String _auth = "Basic ${base64Encode(
    utf8.encode(
      "${Config.consumerKey}:${Config.consumerSecret}",
    ),
  )}";

  Future<void> updateOrderStatus({
    required int orderId,
    required String status,
  }) async {
    final url =
        "${Config.baseUrl}${Config.apiPath}wc/v3/orders/$orderId";

    final response = await http.put(
      Uri.parse(url),
      headers: {
        "Authorization": _auth,
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "status": status,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }
  }
}