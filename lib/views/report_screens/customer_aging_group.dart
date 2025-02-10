import 'package:flutter/material.dart';
import 'package:ACM/models/customer_summary_model.dart';
import 'package:ACM/services/helper/report_services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import '../../Widgets/reusable_text_widget.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class CustomerGroup extends StatefulWidget {
  const CustomerGroup({super.key, required this.saleForce, required this.title, required this.months, required this.hd});
  final String saleForce;
  final String title;
  final String hd;
  final String months;

  @override
  State<CustomerGroup> createState() => _CustomerGroupState();
}

class _CustomerGroupState extends State<CustomerGroup> {
  ReportServices services = ReportServices();

  @override
  void initState() {
    super.initState();
    userName();
    services.customerSummary(widget.saleForce,widget.months,widget.hd);
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
  final String searchQuery = '';
  final numberFormat = NumberFormat('#,##0.##', 'en_US');
  Future<void> _generatePdf() async {
    final pdf = pw.Document();
    final data = await services.customerSummary(widget.saleForce, widget.months, widget.hd);

    final entries = data.entries;
    final cityWiseData = <String, List<Entry>>{};
    for (var entry in entries) {
      final city = entry.properties.bezei;
      if (!cityWiseData.containsKey(city)) {
        cityWiseData[city] = [];
      }
      cityWiseData[city]!.add(entry);
    }

    final cityTotals = <String, Map<String, double>>{};
    for (var city in cityWiseData.keys) {
      double totalOpeningBalance = 0.0;
      double totalSaleQuantity = 0.0;
      double totalRetail = 0.0;
      double totalValue = 0.0;
      double totalReceives = 0.0;
      double totalIncentives = 0.0;
      double totalAdjustment = 0.0;
      double totalClosingBalance = 0.0;

      for (var entry in cityWiseData[city]!) {
        totalOpeningBalance += double.parse(entry.properties.opbal);
        totalSaleQuantity += double.parse(entry.properties.qty);
        totalRetail += double.parse(entry.properties.retail);
        totalValue += double.parse(entry.properties.value);
        totalReceives += double.parse(entry.properties.totrec);
        totalIncentives += double.parse(entry.properties.incentives);
        totalAdjustment += double.parse(entry.properties.adjustment);
        totalClosingBalance += double.parse(entry.properties.clbal);
      }

      cityTotals[city] = {
        'openingBalance': totalOpeningBalance,
        'saleQuantity': totalSaleQuantity,
        'retail': totalRetail,
        'value': totalValue,
        'receives': totalReceives,
        'incentives': totalIncentives,
        'adjustment': totalAdjustment,
        'closingBalance': totalClosingBalance,
      };
    }

    final grandTotalOpeningBalance = cityTotals.values.fold(0.0, (sum, totals) => sum + totals['openingBalance']!);
    final grandTotalSaleQuantity = cityTotals.values.fold(0.0, (sum, totals) => sum + totals['saleQuantity']!);
    final grandTotalRetail = cityTotals.values.fold(0.0, (sum, totals) => sum + totals['retail']!);
    final grandTotalValue = cityTotals.values.fold(0.0, (sum, totals) => sum + totals['value']!);
    final grandTotalReceives = cityTotals.values.fold(0.0, (sum, totals) => sum + totals['receives']!);
    final grandTotalIncentives = cityTotals.values.fold(0.0, (sum, totals) => sum + totals['incentives']!);
    final grandTotalAdjustment = cityTotals.values.fold(0.0, (sum, totals) => sum + totals['adjustment']!);
    final grandTotalClosingBalance = cityTotals.values.fold(0.0, (sum, totals) => sum + totals['closingBalance']!);

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
                    '${widget.title} Table',
                    style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 24),
                  pw.Table.fromTextArray(
                    headerDecoration: pw.BoxDecoration(color: PdfColor.fromHex('#dde0d9')),
                    rowDecoration: pw.BoxDecoration(color: PdfColors.white),

                    headerPadding: pw.EdgeInsets.zero,
                    headerStyle: pw.TextStyle(
                      color: PdfColors.black,
                      fontWeight: pw.FontWeight.bold,

                    ),
                    headers: [
                      'Region',
                      'Opening Balance',
                      'Sale Quantity',
                      'Retail',
                      'Value',
                      'Total Receipt',
                      'Incentives',
                      'Adjustment',
                      'Closing Balance',
                    ],
                    columnWidths: {
                      // Assign equal fixed width to all columns
                      0: const pw.FixedColumnWidth(50),
                      1: const pw.FixedColumnWidth(50),
                      2: const pw.FixedColumnWidth(50),
                      3: const pw.FixedColumnWidth(50),
                      4: const pw.FixedColumnWidth(50),
                      5: const pw.FixedColumnWidth(50),
                      6: const pw.FixedColumnWidth(50),
                      7: const pw.FixedColumnWidth(50),
                      8: const pw.FixedColumnWidth(50),
                    },
                    data: [
                      ...cityTotals.entries.map((entry) {
                        final city = entry.key;
                        final totals = entry.value;
                        return [
                          city,
                          numberFormat.format(double.tryParse(totals['openingBalance'].toString()) ?? 0),
                          numberFormat.format(double.tryParse(totals['saleQuantity'].toString()) ?? 0),
                          numberFormat.format(double.tryParse(totals['retail'].toString()) ?? 0),
                          numberFormat.format(double.tryParse(totals['value'].toString()) ?? 0),
                          numberFormat.format(double.tryParse(totals['receives'].toString()) ?? 0),
                          numberFormat.format(double.tryParse(totals['incentives'].toString()) ?? 0),
                          numberFormat.format(double.tryParse(totals['adjustment'].toString()) ?? 0),
                          numberFormat.format(double.tryParse(totals['closingBalance'].toString()) ?? 0),
                        ];
                      }).toList(),
                      [
                        'Grand Total',
                        numberFormat.format(grandTotalOpeningBalance ?? 0),
                        numberFormat.format(grandTotalSaleQuantity ?? 0),
                        numberFormat.format(grandTotalRetail ?? 0),
                        numberFormat.format(grandTotalValue ?? 0),
                        numberFormat.format(grandTotalReceives ?? 0),
                        numberFormat.format(grandTotalIncentives ?? 0),
                        numberFormat.format(grandTotalAdjustment ?? 0),
                        numberFormat.format(grandTotalClosingBalance ?? 0),
                      ],
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
      body: FutureBuilder<CustomerSummaryModel>(
        future: services.customerSummary(widget.saleForce, widget.months, widget.hd),
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

            // Filter and process data as before
            final filteredEntries = entries.where((entry) {
              return entry.properties.bezei.toLowerCase().contains(searchQuery.toLowerCase());
            }).toList();

            final cityWiseData = <String, List<Entry>>{};
            for (var entry in filteredEntries) {
              final city = entry.properties.bezei;
              if (!cityWiseData.containsKey(city)) {
                cityWiseData[city] = [];
              }
              cityWiseData[city]!.add(entry);
            }

            final cityTotals = <String, Map<String, double>>{};
            for (var city in cityWiseData.keys) {
              double totalOpeningBalance = 0.0;
              double totalSaleQuantity = 0.0;
              double totalRetail = 0.0;
              double totalValue = 0.0;
              double totalReceives = 0.0;
              double totalIncentives = 0.0;
              double totalAdjustment = 0.0;
              double totalClosingBalance = 0.0;

              for (var entry in cityWiseData[city]!) {
                try {
                  totalOpeningBalance += double.parse(entry.properties.opbal);
                  totalSaleQuantity += double.parse(entry.properties.qty);
                  totalRetail += double.parse(entry.properties.retail);
                  totalValue += double.parse(entry.properties.value);
                  totalReceives += double.parse(entry.properties.totrec);
                  totalIncentives += double.parse(entry.properties.incentives);
                  totalAdjustment += double.parse(entry.properties.adjustment);
                  totalClosingBalance += double.parse(entry.properties.clbal);
                } catch (e) {
                  print('Error parsing value: $e');
                }
              }

              cityTotals[city] = {
                'openingBalance': totalOpeningBalance,
                'saleQuantity': totalSaleQuantity,
                'retail': totalRetail,
                'value': totalValue,
                'receives': totalReceives,
                'incentives': totalIncentives,
                'adjustment': totalAdjustment,
                'closingBalance': totalClosingBalance,
              };
            }

            double grandTotalOpeningBalance = 0.0;
            double grandTotalSaleQuantity = 0.0;
            double grandTotalRetail = 0.0;
            double grandTotalValue = 0.0;
            double grandTotalReceives = 0.0;
            double grandTotalIncentives = 0.0;
            double grandTotalAdjustment = 0.0;
            double grandTotalClosingBalance = 0.0;

            for (var entry in filteredEntries) {
              try {
                grandTotalOpeningBalance += double.parse(entry.properties.opbal);
                grandTotalSaleQuantity += double.parse(entry.properties.qty);
                grandTotalRetail += double.parse(entry.properties.retail);
                grandTotalValue += double.parse(entry.properties.value);
                grandTotalReceives += double.parse(entry.properties.totrec);
                grandTotalIncentives += double.parse(entry.properties.incentives);
                grandTotalAdjustment += double.parse(entry.properties.adjustment);
                grandTotalClosingBalance += double.parse(entry.properties.clbal);
              } catch (e) {
                print('Error parsing value: $e');
              }
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
                      padding: const EdgeInsets.only(left: 12.0,top: 6, bottom: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ReusableText(text: "${widget.title} Table", size: 14, fw: FontWeight.w500),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(width: 2, color: Colors.black12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ReusableText(text: 'Month ${entries.first.properties.zmon}', size: 16, fw: FontWeight.w500),
                          ReusableText(text: 'Company Code ${entries.first.properties.burks}', size: 16, fw: FontWeight.w500),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Table(
                        columnWidths: {
                          0: FlexColumnWidth(0.2),
                          1: FlexColumnWidth(0.2),
                          2: FlexColumnWidth(0.2),
                          3: FlexColumnWidth(0.2),
                          4: FlexColumnWidth(0.2),
                          5: FlexColumnWidth(0.2),
                          6: FlexColumnWidth(0.3),
                          7: FlexColumnWidth(0.3),
                          8: FlexColumnWidth(0.2),
                        },
                        defaultColumnWidth: FlexColumnWidth(),
                        border: TableBorder.all(
                          color: Colors.black45,
                          style: BorderStyle.solid,
                          width: 1,
                        ),
                        children: [
                          TableRow(
                            decoration: BoxDecoration(color: Colors.grey),
                            children: [
                              buildTableCell('Region', fontSize, FontWeight.bold),
                              buildTableCell('Opening Balance', fontSize, FontWeight.bold),
                              buildTableCell('Sale Quantity', fontSize, FontWeight.bold),
                              buildTableCell('Retail', fontSize, FontWeight.bold),
                              buildTableCell('Value', fontSize, FontWeight.bold),
                              buildTableCell('Total Receipt', fontSize, FontWeight.bold),
                              buildTableCell('Incentives', fontSize, FontWeight.bold),
                              buildTableCell('Adjustment', fontSize, FontWeight.bold),
                              buildTableCell('Closing Balance', fontSize, FontWeight.bold),
                            ],
                          ),
                          ...cityTotals.entries.map((entry) {
                            final city = entry.key;
                            final totals = entry.value;
                            return TableRow(
                              decoration: BoxDecoration(color: Colors.white),
                              children: [
                                buildTableCell(city, fontSize, FontWeight.normal),
                                buildTableCell(
                                  numberFormat.format(double.tryParse(totals['openingBalance']!.toString()) ?? 0),
                                  fontSize,
                                  FontWeight.normal,
                                ),
                                buildTableCell(
                                  numberFormat.format(double.tryParse(totals['saleQuantity']!.toString()) ?? 0),
                                  fontSize,
                                  FontWeight.normal,
                                ),
                                buildTableCell(
                                  numberFormat.format(double.tryParse(totals['retail']!.toString()) ?? 0),
                                  fontSize,
                                  FontWeight.normal,
                                ),
                                buildTableCell(
                                  numberFormat.format(double.tryParse(totals['value']!.toString()) ?? 0),
                                  fontSize,
                                  FontWeight.normal,
                                ),
                                buildTableCell(
                                  numberFormat.format(double.tryParse(totals['receives']!.toString()) ?? 0),
                                  fontSize,
                                  FontWeight.normal,
                                ),
                                buildTableCell(
                                  numberFormat.format(double.tryParse(totals['incentives']!.toString()) ?? 0),
                                  fontSize,
                                  FontWeight.normal,
                                ),
                                buildTableCell(
                                  numberFormat.format(double.tryParse(totals['adjustment']!.toString()) ?? 0),
                                  fontSize,
                                  FontWeight.normal,
                                ),
                                buildTableCell(
                                  numberFormat.format(double.tryParse(totals['closingBalance']!.toString()) ?? 0),
                                  fontSize,
                                  FontWeight.normal,
                                ),

                              ],
                            );
                          }).toList(),
                          TableRow(
                            decoration: BoxDecoration(color: Colors.white),
                            children: [
                              buildTableCell('Grand Total', fontSize, FontWeight.bold),
                              buildTableCell(
                                numberFormat.format(double.tryParse(grandTotalOpeningBalance.toString()) ?? 0),
                                fontSize,
                                FontWeight.bold,
                              ),
                              buildTableCell(
                                numberFormat.format(double.tryParse(grandTotalSaleQuantity.toString()) ?? 0),
                                fontSize,
                                FontWeight.bold,
                              ),
                              buildTableCell(
                                numberFormat.format(double.tryParse(grandTotalRetail.toString()) ?? 0),
                                fontSize,
                                FontWeight.bold,
                              ),
                              buildTableCell(
                                numberFormat.format(double.tryParse(grandTotalValue.toString()) ?? 0),
                                fontSize,
                                FontWeight.bold,
                              ),
                              buildTableCell(
                                numberFormat.format(double.tryParse(grandTotalReceives.toString()) ?? 0),
                                fontSize,
                                FontWeight.bold,
                              ),
                              buildTableCell(
                                numberFormat.format(double.tryParse(grandTotalIncentives.toString()) ?? 0),
                                fontSize,
                                FontWeight.bold,
                              ),
                              buildTableCell(
                                numberFormat.format(double.tryParse(grandTotalAdjustment.toString()) ?? 0),
                                fontSize,
                                FontWeight.bold,
                              ),
                              buildTableCell(
                                numberFormat.format(double.tryParse(grandTotalClosingBalance.toString()) ?? 0),
                                fontSize,
                                FontWeight.bold,
                              ),

                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const ReusableText(
                          text: 'Data Administration',
                          size: 16,
                          fw: FontWeight.w500),
                      const SizedBox(
                        height: 12,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6)),
                        child:  Column(
                          children: [
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                ReusableText(
                                    color: Colors.grey,
                                    text: 'Generated by: $value',
                                    size: 12,
                                    fw: FontWeight.w500),
                                ReusableText(
                                    color: Colors.grey,
                                    text: 'Generated on: ${formatDate(currentdate).toString()}',
                                    size: 12,
                                    fw: FontWeight.w500),
                              ],
                            ),

                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            _generatePdf();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.blue.shade900,
                              borderRadius: const BorderRadius.all(
                                  Radius.circular(8)),
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
                  )
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
          padding: const EdgeInsets.all(2),
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
}
