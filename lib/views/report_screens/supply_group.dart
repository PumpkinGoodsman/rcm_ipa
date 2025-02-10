import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:ACM/models/supply_summary_model.dart';
import 'package:ACM/services/helper/report_services.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../Widgets/reusable_text_widget.dart';

class SupplyGroup extends StatefulWidget {
  const SupplyGroup({super.key, required this.saleForce, required this.title, required this.months, required this.hd});
  final String saleForce;
  final String title;
  final String hd;
  final String months;

  @override
  State<SupplyGroup> createState() => _SupplyGroupState();
}

class _SupplyGroupState extends State<SupplyGroup> {
  ReportServices services = ReportServices();
  final String searchQuery = '';
  final numberFormat = NumberFormat('#,##0.##', 'en_US');
  @override
  void initState() {
    super.initState();
    userName();
    services.supplySummary(widget.saleForce, widget.months, widget.hd.toString());
  }
  String formatDate(DateTime? dateTime) {
    // Define the date format pattern
    DateFormat formatter =
    DateFormat('dd-MM-yyyy'); // Adjust the pattern as needed

    // Return the formatted date or a default message if the date is null
    return dateTime != null ? formatter.format(dateTime) : 'No date available';
  }
  final currentdate = DateTime.timestamp();
  String value = '';

  userName() async {
    final storage = new FlutterSecureStorage();
    String userName = await storage.read(key: 'userName') ?? '';
    setState(() {
      value = userName ;
    });
  }
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double defaultFontSize = 7.0;
    double fontSize = screenWidth < 500 ? defaultFontSize : defaultFontSize * 1.8;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: ReusableText(text: '${widget.title} Grouping', size: 16, fw: FontWeight.w500),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Image(image: AssetImage('assets/logo.jpg')),
          ),
        ],
      ),
      body: FutureBuilder<SupplySummaryModel>(
        future: services.supplySummary(widget.saleForce, widget.months, widget.hd.toString()),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('An error occurred: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('No data available'));
          } else {
            final data = snapshot.data!;
            final entries = data.entries;

            if (entries.isEmpty) {
              return Center(child: Text('No entries available.'));
            }

            final filteredEntries = entries.where((entry) {
              return entry.properties.bezei.toLowerCase().contains(searchQuery.toLowerCase());
            }).toList();

            if (filteredEntries.isEmpty) {
              return Center(child: Text('No matching entries found.'));
            }

            // Group entries by city
            final cityWiseData = <String, List<Entry>>{};
            for (var entry in filteredEntries) {
              final city = entry.properties.bezei;
              if (!cityWiseData.containsKey(city)) {
                cityWiseData[city] = [];
              }
              cityWiseData[city]!.add(entry);
            }

            // Calculate totals for each city
            final cityTotals = <String, Map<String, double>>{};
            for (var city in cityWiseData.keys) {
              double totalBalance = 0.0;
              double totalAge01 = 0.0;

              for (var entry in cityWiseData[city]!) {
                try {
                  totalBalance += double.parse(entry.properties.fkimg);
                  totalAge01 += double.parse(entry.properties.kwert);
                } catch (e) {
                  print('Error parsing value: $e');
                }
              }

              cityTotals[city] = {
                'balance': totalBalance,
                'age01': totalAge01,
              };
            }

            double grandTotalBalance = 0.0;
            double grandTotalAge01 = 0.0;

            for (var city in cityTotals.keys) {
              var totals = cityTotals[city]!;
              grandTotalBalance += totals['balance'] ?? 0.0;
              grandTotalAge01 += totals['age01'] ?? 0.0;
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(width: 2, color: Colors.black12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ReusableText(
                            text: "${widget.title} Group Table",
                            size: 14,
                            fw: FontWeight.w500,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Table(
                        columnWidths: {
                          0: FlexColumnWidth(0.4),
                          1: FlexColumnWidth(0.2),
                          2: FlexColumnWidth(0.2),
                        },
                        border: TableBorder.all(
                          color: Colors.grey,
                          style: BorderStyle.solid,
                          width: 1,
                        ),
                        children: [
                          TableRow(
                            decoration: BoxDecoration(color: Colors.grey),
                            children: [
                              buildTableCell('Region', fontSize, FontWeight.bold),
                              buildTableCell('Quantity', fontSize, FontWeight.bold),
                              buildTableCell('Values', fontSize, FontWeight.bold),
                            ],
                          ),
                          ...cityTotals.entries.map((entry) {
                            final city = entry.key;
                            final totals = entry.value;
                            return TableRow(
                              children: [
                                buildTableCell(city, fontSize, FontWeight.normal),
                                buildTableCell(
                                  numberFormat.format(totals['balance']),
                                  fontSize,
                                  FontWeight.normal,
                                ),
                                buildTableCell(
                                  numberFormat.format(totals['age01']),
                                  fontSize,
                                  FontWeight.normal,
                                ),
                              ],
                            );
                          }).toList(),
                          TableRow(
                            children: [
                              buildTableCell('Grand Total', fontSize, FontWeight.bold),
                              buildTableCell(
                                numberFormat.format(grandTotalBalance),
                                fontSize,
                                FontWeight.bold,
                              ),
                              buildTableCell(
                                numberFormat.format(grandTotalAge01),
                                fontSize,
                                FontWeight.bold,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Spacer(), // This pushes the content below it to the bottom
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const ReusableText(
                        text: 'Data Administration',
                        size: 16,
                        fw: FontWeight.w500,
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ReusableText(
                              color: Colors.grey,
                              text: 'Generated by: $value',
                              size: 12,
                              fw: FontWeight.w500,
                            ),
                            ReusableText(
                              color: Colors.grey,
                              text: 'Generated on: ${formatDate(currentdate).toString()}',
                              size: 12,
                              fw: FontWeight.w500,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        generatePDF(cityTotals, grandTotalBalance, grandTotalAge01);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue.shade900,
                          borderRadius: const BorderRadius.all(Radius.circular(8)),
                        ),
                        padding: const EdgeInsets.all(8),
                        alignment: Alignment.center,
                        margin: const EdgeInsets.all(5),
                        height: 42,
                        width: double.infinity,
                        child: const Text(
                          "Generate PDF",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );

          }
        },
      ),
    );
  }

  Widget buildTableCell(String text, double fontSize, FontWeight fontWeight) {
    return TableCell(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Text(
            text,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: fontWeight,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> generatePDF(Map<String, Map<String, double>> cityTotals, double grandTotalBalance, double grandTotalAge01) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (pw.Context context) {
          return pw.Stack(
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    '${widget.title} Group Table',
                    style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 20),
                  pw.Table(

                    border: pw.TableBorder.all(color: PdfColors.grey, width: 1),
                    children: [
                      pw.TableRow(
                        decoration: pw.BoxDecoration(
                           color: PdfColor.fromHex('#dde0d9')
                        ),
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Text('Region', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Text('Quantity', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Text('Value', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          ),
                          // Add remaining headers...
                        ],
                      ),
                      ...cityTotals.entries.map((entry) {
                        final city = entry.key;
                        final totals = entry.value;
                        return pw.TableRow(
                          children: [
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(4),
                              child: pw.Text(city),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(4),
                              child: pw.Text(numberFormat.format(totals['balance'])),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(4),
                              child: pw.Text(numberFormat.format(totals['age01'])),
                            ),
                            // Add remaining cells...
                          ],
                        );
                      }).toList(),
                      pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Text('Grand Total', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Text(numberFormat.format(grandTotalBalance), style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Text(numberFormat.format(grandTotalAge01), style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          ),
                          // Add remaining grand total cells...
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              pw.Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.white,
                    borderRadius: pw.BorderRadius.circular(6),
                    border: pw.Border.all(color: PdfColors.black),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Data Administration',
                        style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.SizedBox(height: 12),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            'Generated by:',
                            style: pw.TextStyle(color: PdfColors.grey, fontSize: 8),
                          ),
                          pw.Text(
                            value, // Replace with actual user if available
                            style: pw.TextStyle(color: PdfColors.black, fontSize: 8),
                          ),
                        ],
                      ),
                      pw.Divider(),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            'Generated on:',
                            style: pw.TextStyle(color: PdfColors.grey, fontSize: 8),
                          ),
                          pw.Text(
                            formatDate(DateTime.now()), // Replace with actual generation date if available
                            style: pw.TextStyle(color: PdfColors.black, fontSize: 8),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
    try {
      Directory? directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory == null) {
        throw Exception('Could not find the directory');
      }

      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      final path = '${directory.path}/report.pdf';
      final file = File(path);

      await file.writeAsBytes(await pdf.save());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF saved to $path')),
      );

      print('PDF saved at $path');

      final result = await OpenFile.open(path);
      if (result.type != ResultType.done) {
        throw Exception('Error opening PDF: ${result.message}');
      }
    } catch (e) {
      print('Error saving PDF: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving PDF: $e')),
      );
    }

  }
}
