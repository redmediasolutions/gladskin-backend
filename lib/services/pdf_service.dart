import 'package:gladskin_backend/models/order_model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfService {
  static Future<void> downloadInvoice(
    OrderModel order,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),

        build: (context) => [
          _buildHeader(order),

          pw.SizedBox(height: 30),

          _buildCustomerInfo(order),

pw.SizedBox(height: 30),

_buildItemsTable(order),

pw.SizedBox(height: 25),

_buildTotals(order),

pw.SizedBox(height: 40),

          pw.Divider(),

          pw.Center(
            child: pw.Text(
              "Thank you for shopping with GladSkin",
              style: const pw.TextStyle(
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename:
          "Invoice-${order.orderNumber}.pdf",
    );
  }

  static pw.Widget _buildHeader(
    OrderModel order,
  ) {
    return pw.Row(
      crossAxisAlignment:
          pw.CrossAxisAlignment.start,
      mainAxisAlignment:
          pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment:
              pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              "GladSkin",
              style: pw.TextStyle(
                fontSize: 28,
                fontWeight:
                    pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 6),
            pw.Text(
              "TAX INVOICE",
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight:
                    pw.FontWeight.bold,
              ),
            ),
          ],
        ),

        pw.Column(
  crossAxisAlignment: pw.CrossAxisAlignment.end,
  children: [
    _pdfRow(
      "Invoice No: ",
      order.orderNumber.isNotEmpty
          ? order.orderNumber
          : order.wooOrderId.toString(),
    ),
    _pdfRow(
      "Woo Order",
      order.wooOrderId.toString(),
    ),
    _pdfRow(
      "Status",
      order.status,
    ),
    _pdfRow(
      "Payment",
      order.paymentMethod.toUpperCase(),
    ),
  ],
),
      ],
    );
  }

  static pw.Widget _buildCustomerInfo(
    OrderModel order,
  ) {
    return pw.Row(
      crossAxisAlignment:
          pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: _addressCard(
            "Billing Address",
            order.billing,
          ),
        ),

        pw.SizedBox(width: 20),

        pw.Expanded(
          child: _addressCard(
            "Shipping Address",
            order.shippingAddress,
          ),
        ),
      ],
    );
  }

  static pw.Widget _addressCard(
    String title,
    dynamic address,
  ) {
    if (address == null) {
      return pw.Container();
    }

    return pw.Container(
      padding:
          const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(),
      ),
      child: pw.Column(
        crossAxisAlignment:
            pw.CrossAxisAlignment.start,
        children: [
  pw.Text(
    title,
    style: pw.TextStyle(
      fontWeight: pw.FontWeight.bold,
    ),
  ),

  pw.SizedBox(height: 10),

  pw.Text(address.fullName),

  if (address.company.isNotEmpty)
    pw.Text(address.company),

  if (address.address1.isNotEmpty)
    pw.Text(address.address1),

  if (address.address2.isNotEmpty)
    pw.Text(address.address2),

  pw.Text(
    "${address.city}, ${address.state}",
  ),

  pw.Text(address.postcode),

  pw.Text(address.country),

  if (address.phone.isNotEmpty)
    pw.Text(address.phone),

  if (address.email.isNotEmpty)
    pw.Text(address.email),
],
      ),
    );
  }

  static pw.Widget _buildItemsTable(
  OrderModel order,
) {
  return pw.TableHelper.fromTextArray(
    border: pw.TableBorder.all(),
    headerStyle: pw.TextStyle(
      fontWeight: pw.FontWeight.bold,
    ),
    headers: const [
      "Product",
      "SKU",
      "Qty",
      "Price",
      "Total",
    ],
    data: order.items.map((item) {
      return [
        item.name,
        item.quantity.toString(),
        item.salePrice.toStringAsFixed(2),
        item.lineTotal.toStringAsFixed(2),
      ];
    }).toList(),
  );
}

  static pw.Widget _buildTotals(
  OrderModel order,
) {
  return pw.Align(
    alignment: pw.Alignment.centerRight,
    child: pw.Container(
      width: 260,
      child: pw.Column(
        children: [
          _pdfRow(
            "Subtotal",
            order.subtotal.toStringAsFixed(2),
          ),
          _pdfRow(
            "Shipping",
            order.shipping.toStringAsFixed(2),
          ),
          _pdfRow(
            "Tax",
            order.tax.toStringAsFixed(2),
          ),
          _pdfRow(
            "Coupon",
            order.couponDiscount.toStringAsFixed(2),
          ),
          _pdfRow(
            "COD Charge",
            order.codCharge.toStringAsFixed(2),
          ),
          _pdfRow(
            "Wallet Used",
            order.walletUsed.toStringAsFixed(2),
          ),
          pw.Divider(),
          _pdfRow(
            "Grand Total",
            order.finalPayable.toStringAsFixed(2),
            bold: true,
          ),
        ],
      ),
    ),
  );
}

  static pw.Widget _pdfRow(
    String title,
    String value, {
    bool bold = false,
  }) {
    return pw.Padding(
      padding:
          const pw.EdgeInsets.symmetric(
        vertical: 3,
      ),
      child: pw.Row(
        mainAxisAlignment:
            pw.MainAxisAlignment
                .spaceBetween,
        children: [
          pw.Text(title),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontWeight: bold
                  ? pw.FontWeight.bold
                  : pw.FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}