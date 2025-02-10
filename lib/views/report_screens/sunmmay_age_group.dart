import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:ACM/services/helper/report_services.dart';
import 'package:open_file/open_file.dart';
import '../../Widgets/reusable_text_widget.dart';
import '../../models/aging_summary_model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class SummaryAginGroup extends StatefulWidget {
  const SummaryAginGroup(
      {super.key,
      required this.saleForce,
      required this.title,
      required this.hd});
  final String saleForce;
  final String hd;
  final String title;

  @override
  State<SummaryAginGroup> createState() => _SummaryAginGroupState();
}

class _SummaryAginGroupState extends State<SummaryAginGroup> {
  ReportServices services = ReportServices();

  @override
  void initState() {
    super.initState();
    userName();
    services.reportAgingSummary(widget.saleForce, widget.hd);
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
  final numberFormat = NumberFormat('#,##0.##', 'en_US');

  userName() async {
    final storage = new FlutterSecureStorage();
    String userName = await storage.read(key: 'userName') ?? '';
    setState(() {
      value = userName;
    });
  }

  Future<void> _generatePdf() async {
    final pdf = pw.Document();

    final data = await services.reportAgingSummary(widget.saleForce, widget.hd);
    final entries = data.entries;

    if (entries.isEmpty) {
      print('No entries available.');
      return;
    }

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
      double totalBalance = 0.0;
      double totalAge01 = 0.0;
      double totalAge02 = 0.0;
      double totalAge03 = 0.0;
      double totalAge04 = 0.0;
      double totalAge05 = 0.0;
      double totalAge06 = 0.0;
      double totalAge07 = 0.0;

      for (var entry in cityWiseData[city]!) {
        try {
          totalBalance += double.parse(entry.properties.dmbtr);
          totalAge01 += double.parse(entry.properties.age01);
          totalAge02 += double.parse(entry.properties.age02);
          totalAge03 += double.parse(entry.properties.age03);
          totalAge04 += double.parse(entry.properties.age04);
          totalAge05 += double.parse(entry.properties.age05);
          totalAge06 += double.parse(entry.properties.age06);
          totalAge07 += double.parse(entry.properties.age07);
        } catch (e) {
          print('Error parsing value: $e');
        }
      }

      cityTotals[city] = {
        'balance': totalBalance,
        'age01': totalAge01,
        'age02': totalAge02,
        'age03': totalAge03,
        'age04': totalAge04,
        'age05': totalAge05,
        'age06': totalAge06,
        'age07': totalAge07,
      };
    }

    double grandTotalBalance = 0.0;
    double grandTotalAge01 = 0.0;
    double grandTotalAge02 = 0.0;
    double grandTotalAge03 = 0.0;
    double grandTotalAge04 = 0.0;
    double grandTotalAge05 = 0.0;
    double grandTotalAge06 = 0.0;
    double grandTotalAge07 = 0.0;

    for (var entry in entries) {
      try {
        grandTotalBalance += double.parse(entry.properties.dmbtr);
        grandTotalAge01 += double.parse(entry.properties.age01);
        grandTotalAge02 += double.parse(entry.properties.age02);
        grandTotalAge03 += double.parse(entry.properties.age03);
        grandTotalAge04 += double.parse(entry.properties.age04);
        grandTotalAge05 += double.parse(entry.properties.age05);
        grandTotalAge06 += double.parse(entry.properties.age06);
        grandTotalAge07 += double.parse(entry.properties.age07);
      } catch (e) {
        print('Error parsing value: $e');
      }
    }

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
                    style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 20),
                  pw.Table.fromTextArray(
                    headerDecoration: pw.BoxDecoration(color: PdfColor.fromHex('#dde0d9')),
                    rowDecoration: pw.BoxDecoration(color: PdfColors.white),
                    headers: [
                      'Region',
                      'Balance',
                      '0-30',
                      '31-60',
                      '61-90',
                      '91-120',
                      '121-150',
                      '151-180',
                      '181 & Above'
                    ],
                    data: [
                      ...cityTotals.entries.map((entry) {
                        return [
                          entry.key,
                          numberFormat.format(entry.value['balance'] ?? 0.0),
                          numberFormat.format(entry.value['age01'] ?? 0.0),
                          numberFormat.format(entry.value['age02'] ?? 0.0),
                          numberFormat.format(entry.value['age03'] ?? 0.0),
                          numberFormat.format(entry.value['age04'] ?? 0.0),
                          numberFormat.format(entry.value['age05'] ?? 0.0),
                          numberFormat.format(entry.value['age06'] ?? 0.0),
                          numberFormat.format(entry.value['age07'] ?? 0.0),
                        ];
                      }).toList(),
                      [
                        'Grand Total',
                        numberFormat.format(grandTotalBalance),
                        numberFormat.format(grandTotalAge01),
                        numberFormat.format(grandTotalAge02),
                        numberFormat.format(grandTotalAge03),
                        numberFormat.format(grandTotalAge04),
                        numberFormat.format(grandTotalAge05),
                        numberFormat.format(grandTotalAge06),
                        numberFormat.format(grandTotalAge07),
                      ],
                    ],
                    columnWidths: {
                      0: const pw.FixedColumnWidth(100), // Fixed width for the first column (Region)
                      for (int i = 1; i <= 8; i++) i: const pw.FixedColumnWidth(60), // Equal width for all other columns
                    },
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
    double fontSize =
        screenWidth < 500 ? defaultFontSize : defaultFontSize * 1.8;
    final fieldWidth = screenWidth * 0.8;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: ReusableText(
            text: '${widget.title} Grouping', size: 16, fw: FontWeight.w500),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Image(image: AssetImage('assets/logo.jpg')),
          ),
        ],
      ),
      body: FutureBuilder<AgingSummaryModel>(
        future: services.reportAgingSummary(
            widget.saleForce.toString(), widget.hd.toString()),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('An error occurred: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('No data available'));
          } else {
            final data = snapshot.data!;
            final agingSummaries =
                data; // Ensure you are using the correct field

            if (agingSummaries.entries.isEmpty) {
              return Center(child: Text('No aging summaries available.'));
            }

            final entries = agingSummaries.entries;
            if (entries.isEmpty) {
              return Center(child: Text('No entries available.'));
            }

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
              double totalBalance = 0.0;
              double totalAge01 = 0.0;
              double totalAge02 = 0.0;
              double totalAge03 = 0.0;
              double totalAge04 = 0.0;
              double totalAge05 = 0.0;
              double totalAge06 = 0.0;
              double totalAge07 = 0.0;

              for (var entry in cityWiseData[city]!) {
                try {
                  totalBalance += double.parse(entry.properties.dmbtr);
                  totalAge01 += double.parse(entry.properties.age01);
                  totalAge02 += double.parse(entry.properties.age02);
                  totalAge03 += double.parse(entry.properties.age03);
                  totalAge04 += double.parse(entry.properties.age04);
                  totalAge05 += double.parse(entry.properties.age05);
                  totalAge06 += double.parse(entry.properties.age06);
                  totalAge07 += double.parse(entry.properties.age07);
                } catch (e) {
                  print('Error parsing value: $e');
                }
              }

              cityTotals[city] = {
                'balance': totalBalance,
                'age01': totalAge01,
                'age02': totalAge02,
                'age03': totalAge03,
                'age04': totalAge04,
                'age05': totalAge05,
                'age06': totalAge06,
                'age07': totalAge07,
              };
            }

            double grandTotalBalance = 0.0;
            double grandTotalAge01 = 0.0;
            double grandTotalAge02 = 0.0;
            double grandTotalAge03 = 0.0;
            double grandTotalAge04 = 0.0;
            double grandTotalAge05 = 0.0;
            double grandTotalAge06 = 0.0;
            double grandTotalAge07 = 0.0;

            for (var entry in entries) {
              try {
                grandTotalBalance += double.parse(entry.properties.dmbtr);
                grandTotalAge01 += double.parse(entry.properties.age01);
                grandTotalAge02 += double.parse(entry.properties.age02);
                grandTotalAge03 += double.parse(entry.properties.age03);
                grandTotalAge04 += double.parse(entry.properties.age04);
                grandTotalAge05 += double.parse(entry.properties.age05);
                grandTotalAge06 += double.parse(entry.properties.age06);
                grandTotalAge07 += double.parse(entry.properties.age07);
              } catch (e) {
                print('Error parsing value: $e');
              }
            }

            final numberFormat = NumberFormat('#,##0.##', 'en_US');

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ReusableText(
                              text: "${widget.title} Group Table",
                              size: 14,
                              fw: FontWeight.w500),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Table(
                        columnWidths: {
                          0: FlexColumnWidth(0.3),
                          1: FlexColumnWidth(0.3),
                          2: FlexColumnWidth(0.2),
                          3: FlexColumnWidth(0.2),
                          4: FlexColumnWidth(0.2),
                          5: FlexColumnWidth(0.2),
                          6: FlexColumnWidth(0.2),
                          7: FlexColumnWidth(0.2),
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
                              buildTableCell(
                                  'Region', fontSize, FontWeight.bold),
                              buildTableCell(
                                  'Balance', fontSize, FontWeight.bold),
                              buildTableCell('0-30', fontSize, FontWeight.bold),
                              buildTableCell(
                                  '31-60', fontSize, FontWeight.bold),
                              buildTableCell(
                                  '61-90', fontSize, FontWeight.bold),
                              buildTableCell(
                                  '91-120', fontSize, FontWeight.bold),
                              buildTableCell(
                                  '121-150', fontSize, FontWeight.bold),
                              buildTableCell(
                                  '151-180', fontSize, FontWeight.bold),
                              buildTableCell(
                                  '181 & Above', fontSize, FontWeight.bold),
                            ],
                          ),
                          ...cityTotals.entries.map((entry) {
                            return TableRow(
                              decoration: BoxDecoration(color: Colors.white),
                              children: [
                                buildTableCell(
                                  entry.key,
                                  fontSize,
                                  FontWeight.normal,
                                ),
                                buildTableCell(
                                  numberFormat
                                      .format(entry.value['balance'] ?? 0.0),
                                  fontSize,
                                  FontWeight.normal,
                                ),
                                buildTableCell(
                                  numberFormat
                                      .format(entry.value['age01'] ?? 0.0),
                                  fontSize,
                                  FontWeight.normal,
                                ),
                                buildTableCell(
                                  numberFormat
                                      .format(entry.value['age02'] ?? 0.0),
                                  fontSize,
                                  FontWeight.normal,
                                ),
                                buildTableCell(
                                  numberFormat
                                      .format(entry.value['age03'] ?? 0.0),
                                  fontSize,
                                  FontWeight.normal,
                                ),
                                buildTableCell(
                                  numberFormat
                                      .format(entry.value['age04'] ?? 0.0),
                                  fontSize,
                                  FontWeight.normal,
                                ),
                                buildTableCell(
                                  numberFormat
                                      .format(entry.value['age05'] ?? 0.0),
                                  fontSize,
                                  FontWeight.normal,
                                ),
                                buildTableCell(
                                  numberFormat
                                      .format(entry.value['age06'] ?? 0.0),
                                  fontSize,
                                  FontWeight.normal,
                                ),
                                buildTableCell(
                                  numberFormat
                                      .format(entry.value['age07'] ?? 0.0),
                                  fontSize,
                                  FontWeight.normal,
                                ),
                              ],
                            );
                          }).toList(),
                          TableRow(
                            decoration: BoxDecoration(color: Colors.white),
                            children: [
                              buildTableCell(
                                  'Grand Total', fontSize, FontWeight.bold),
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
                              buildTableCell(
                                numberFormat.format(grandTotalAge02),
                                fontSize,
                                FontWeight.bold,
                              ),
                              buildTableCell(
                                numberFormat.format(grandTotalAge03),
                                fontSize,
                                FontWeight.bold,
                              ),
                              buildTableCell(
                                numberFormat.format(grandTotalAge04),
                                fontSize,
                                FontWeight.bold,
                              ),
                              buildTableCell(
                                numberFormat.format(grandTotalAge05),
                                fontSize,
                                FontWeight.bold,
                              ),
                              buildTableCell(
                                numberFormat.format(grandTotalAge06),
                                fontSize,
                                FontWeight.bold,
                              ),
                              buildTableCell(
                                numberFormat.format(grandTotalAge07),
                                fontSize,
                                FontWeight.bold,
                              ),
                            ],
                          )
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
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ReusableText(
                                    color: Colors.grey,
                                    text: 'Generated by: $value',
                                    size: 12,
                                    fw: FontWeight.w500),
                                ReusableText(
                                    color: Colors.grey,
                                    text:
                                    'Generated on: ${formatDate(currentdate).toString()}',
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
                              borderRadius:
                              const BorderRadius.all(Radius.circular(8)),
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
