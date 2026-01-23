import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class InvoicePage extends StatelessWidget {
  const InvoicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => generateInvoice(),
          child: const Text('Generate & Print Invoice'),
        ),
      ),
    );
  }

  Future<void> generateInvoice() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
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
                          'Business 08',
                          style: pw.TextStyle(
                            fontSize: 24,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text('123456',
                            style: const pw.TextStyle(fontSize: 12)),
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
                        pw.Text('#INV-20260118-ZUV1'),
                        pw.Text('January 18th, 2026'),
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
                pw.Text('Habibur Rahman',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text('Dhaka'),
                pw.Text('01913165240'),

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
                    // Item
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('product 001',
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold)),
                              pw.Text('no color',
                                  style: const pw.TextStyle(
                                      fontSize: 10, color: PdfColors.grey)),
                            ],
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child:
                              pw.Text('123.00', textAlign: pw.TextAlign.right),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('1', textAlign: pw.TextAlign.right),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child:
                              pw.Text('123.00', textAlign: pw.TextAlign.right),
                        ),
                      ],
                    ),
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
                                  style:
                                      const pw.TextStyle(color: PdfColors.grey)),
                            ),
                            pw.SizedBox(width: 20),
                            pw.Text('123.00'),
                          ],
                        ),
                        pw.SizedBox(height: 5),
                        pw.Row(
                          children: [
                            pw.SizedBox(
                              width: 100,
                              child: pw.Text('Delivery Charge',
                                  style:
                                      const pw.TextStyle(color: PdfColors.grey)),
                            ),
                            pw.SizedBox(width: 20),
                            pw.Text('99.97'),
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
                                pw.Text('222.97',
                                    style: pw.TextStyle(
                                        fontWeight: pw.FontWeight.bold)),
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
                    style:
                        const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    // Save or share the PDF
    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save());
  }
}
