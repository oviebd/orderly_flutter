import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../orders/domain/entities/order.dart';

class InvoicePage extends StatefulWidget {
  final Order order;
  final String? businessName;
  final String? businessPhone;

  const InvoicePage({
    super.key,
    required this.order,
    this.businessName,
    this.businessPhone,
  });

  @override
  State<InvoicePage> createState() => _InvoicePageState();
}

class _InvoicePageState extends State<InvoicePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice Preview'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Back',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_alt),
            onPressed: _saveInvoice,
            tooltip: 'Save to Local Storage',
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareInvoice,
            tooltip: 'Share Invoice',
          ),
        ],
      ),
      body: PdfPreview(
        build: (format) => _generatePdfBytes(format),
        allowPrinting: true,
        allowSharing: false, // Using our own share button in AppBar
        canChangePageFormat: false,
        canDebug: false,
      ),
    );
  }

  Future<void> _shareInvoice() async {
    try {
      final bytes = await _generatePdfBytes(PdfPageFormat.a4);
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/invoice_${widget.order.id}.pdf');
      await file.writeAsBytes(bytes);

      final box = context.findRenderObject() as RenderBox?;
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Invoice for Order #${widget.order.id.substring(widget.order.id.length - 4).toUpperCase()}',
        sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to share: $e')),
        );
      }
    }
  }

  Future<void> _saveInvoice() async {
    try {
      final bytes = await _generatePdfBytes(PdfPageFormat.a4);
      final output = await getApplicationDocumentsDirectory();
      final file = File("${output.path}/invoice_${widget.order.id}.pdf");
      await file.writeAsBytes(bytes);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invoice saved to app documents: ${file.path.split('/').last}'),
            action: SnackBarAction(
              label: 'OK',
              onPressed: () {},
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e')),
        );
      }
    }
  }

  Future<Uint8List> _generatePdfBytes(PdfPageFormat format) async {
    final pdf = pw.Document();
    final order = widget.order;

    // Calculate subtotal from products
    final subtotal = order.products.fold(
        0.0, (sum, item) => sum + (item.price * item.quantity));

    // Format invoice details
    final invoiceId = order.id.substring(order.id.length - 4).toUpperCase();
    final dateStr = DateFormat('yyyyMMdd').format(order.orderDate);
    final invoiceNumber = '#INV-$dateStr-$invoiceId';
    final invoiceDate = DateFormat('MMMM dd, yyyy').format(order.orderDate);

    pdf.addPage(
      pw.Page(
        pageFormat: format,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(40),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          widget.businessName ?? 'Your Business',
                          style: pw.TextStyle(
                            fontSize: 24,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        if (widget.businessPhone != null)
                          pw.Text(
                            widget.businessPhone!,
                            style: const pw.TextStyle(fontSize: 12),
                          ),
                      ],
                    ),
                    pw.Text(
                      'INVOICE',
                      style: pw.TextStyle(
                        fontSize: 32,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.grey400,
                      ),
                    ),
                  ],
                ),

                pw.SizedBox(height: 10),

                // Invoice details
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(invoiceNumber),
                        pw.Text(invoiceDate),
                      ],
                    ),
                  ],
                ),

                pw.SizedBox(height: 40),

                // Bill To
                pw.Text(
                  'BILL TO',
                  style: pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey600,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  order.customerName ?? 'Walk-in Customer',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                if (order.address.isNotEmpty) pw.Text(order.address),
                if (order.customerPhone != null &&
                    order.customerPhone!.isNotEmpty)
                  pw.Text(order.customerPhone!),

                pw.SizedBox(height: 40),

                // Items Table
                pw.Table(
                  border: pw.TableBorder(
                    horizontalInside: pw.BorderSide(color: PdfColors.grey300),
                    bottom: pw.BorderSide(color: PdfColors.grey300),
                  ),
                  children: [
                    // Header
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(
                          bottom: pw.BorderSide(color: PdfColors.grey300),
                        ),
                      ),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            'ITEM DESCRIPTION',
                            style: pw.TextStyle(
                              fontSize: 10,
                              color: PdfColors.grey600,
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            'PRICE',
                            style: pw.TextStyle(
                                fontSize: 10, color: PdfColors.grey600),
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            'QTY',
                            style: pw.TextStyle(
                                fontSize: 10, color: PdfColors.grey600),
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            'TOTAL',
                            style: pw.TextStyle(
                                fontSize: 10, color: PdfColors.grey600),
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                    // Product items
                    ...order.products.map((item) {
                      final itemTotal = item.price * item.quantity;
                      return pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  item.name,
                                  style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                                if (item.code.isNotEmpty)
                                  pw.Text(
                                    item.code,
                                    style: const pw.TextStyle(
                                      fontSize: 10,
                                      color: PdfColors.grey,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              'BDT ${item.price.toStringAsFixed(2)}',
                              textAlign: pw.TextAlign.right,
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              '${item.quantity}',
                              textAlign: pw.TextAlign.right,
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              'BDT ${itemTotal.toStringAsFixed(2)}',
                              textAlign: pw.TextAlign.right,
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ],
                ),

                pw.SizedBox(height: 40),

                // Totals
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Row(
                          children: [
                            pw.SizedBox(
                              width: 100,
                              child: pw.Text('Subtotal',
                                  style: const pw.TextStyle(
                                      color: PdfColors.grey)),
                            ),
                            pw.SizedBox(width: 20),
                            pw.Text('BDT ${subtotal.toStringAsFixed(2)}'),
                          ],
                        ),
                        pw.SizedBox(height: 5),
                        pw.Row(
                          children: [
                            pw.SizedBox(
                              width: 100,
                              child: pw.Text('Delivery Charge',
                                  style: const pw.TextStyle(
                                      color: PdfColors.grey)),
                            ),
                            pw.SizedBox(width: 20),
                            pw.Text(
                                'BDT ${order.deliveryCharge.toStringAsFixed(2)}'),
                          ],
                        ),
                        pw.SizedBox(height: 10),
                        pw.Container(
                          decoration: const pw.BoxDecoration(
                            border: pw.Border(top: pw.BorderSide(width: 2)),
                          ),
                          child: pw.Padding(
                            padding: const pw.EdgeInsets.only(top: 10),
                            child: pw.Row(
                              children: [
                                pw.SizedBox(
                                  width: 100,
                                  child: pw.Text('Total',
                                      style: pw.TextStyle(
                                          fontWeight: pw.FontWeight.bold)),
                                ),
                                pw.SizedBox(width: 20),
                                pw.Text(
                                  'BDT ${order.totalAmount.toStringAsFixed(2)}',
                                  style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                pw.Spacer(),

                // Footer
                pw.Center(
                  child: pw.Text(
                    'Powered by Orderfy',
                    style: const pw.TextStyle(
                        fontSize: 10, color: PdfColors.grey),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }
}
