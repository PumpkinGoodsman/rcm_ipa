import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:ACM/Widgets/Auth/fields.dart';
import 'package:ACM/Widgets/reusable_text_widget.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ACM/services/helper/report_services.dart';

import '../../models/aging_summary_model.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen(
      {super.key, this.title, this.startDate, this.endDate, this.saleOffice, this.hd});

  final String? title;
  final String? hd;
  final String? saleOffice;
  final DateTime? startDate;
  final DateTime? endDate;
  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  ReportServices services = ReportServices();

  List<AgingSummaryModel> agingSummaries = [];
  bool isAgingLoading = true;
  bool isAscending = true;
  int sortColumnIndex = 0;
  final numberFormat = NumberFormat('#,##0.##', 'en_US'); // Define the format
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    Permission.storage.request();
    userName();
    services.reportAgingSummary(widget.saleOffice.toString(),widget.hd.toString());
    fetchAgingSummary();
  }

  Set<int> selectedRows = {}; // Track selected row indices

  // Function to toggle row selection
  void toggleRowSelection(int rowIndex) {
    setState(() {
      if (selectedRows.contains(rowIndex)) {
        selectedRows.remove(rowIndex);
      } else {
        selectedRows.add(rowIndex);
      }
    });
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
    print(screenWidth);
    double defaultFontSize = 7.0;
    double fontSize =
    screenWidth < 500 ? defaultFontSize : defaultFontSize * 1.8;
    final fieldWidth = screenWidth * 0.8;

    print('UserName $value');
    print('Date ${formatDate(currentdate)}');
    print("Selected Row $selectedRows");
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: ReusableText(
            text: "${widget.title.toString()} Report",
            size: 16,
            fw: FontWeight.w500),
        actions: [
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: Image(image: AssetImage('assets/logo.jpg')),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 24),
              Authfields(
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
                label: 'Search',
              ),
              SizedBox(
                child: FutureBuilder<AgingSummaryModel>(
                  future:
                  services.reportAgingSummary(widget.saleOffice.toString(),widget.hd.toString()),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text('An error occurred: ${snapshot.error}'),
                      );
                    } else if (!snapshot.hasData) {
                      return Center(
                        child: Text('No data available'),
                      );
                    } else {
                      final data = snapshot.data!;
                      final agingSummaries =
                          data; // Ensure you are using the correct field

                      if (agingSummaries.entries.isEmpty) {
                        return Center(
                            child: Text('No aging summaries available.'));
                      }

                      final entries = agingSummaries.entries;
                      if (entries.isEmpty) {
                        return Center(child: Text('No entries available.'));
                      }

                      final filteredEntries = entries.where((entry) {
                        final searchLowerCase = searchQuery.toLowerCase();

                        return entry.properties.bezei.toLowerCase().contains(searchLowerCase) ||
                            entry.properties.name1.toLowerCase().contains(searchLowerCase) ||
                            entry.properties.dmbtr.toLowerCase().contains(searchLowerCase);
                      }).toList();


                      if (filteredEntries.isEmpty) {
                        return Center(
                            child: Text('No matching entries found.'));
                      }

                      final balances = filteredEntries.map((e) => double.parse(e.properties.dmbtr)).toList();

                      // Find the highest and lowest balance values
                      final highestBalance = balances.reduce((a, b) => a > b ? a : b);
                      final lowestBalance = balances.reduce((a, b) => a < b ? a : b);

                      // Sort the entries based on the difference between the highest and lowest balance values
                      if (isAscending) {
                        filteredEntries.sort((a, b) {
                          final balanceA = double.parse(a.properties.dmbtr);
                          final balanceB = double.parse(b.properties.dmbtr);
                          return (balanceA - lowestBalance).compareTo(balanceB - lowestBalance);
                        });
                      } else {
                        filteredEntries.sort((a, b) {
                          final balanceA = double.parse(a.properties.dmbtr);
                          final balanceB = double.parse(b.properties.dmbtr);
                          return (balanceB - lowestBalance).compareTo(balanceA - lowestBalance);
                        });
                      }


                      if (filteredEntries.isEmpty) {
                        return Center(child: Text('No matching entries found.'));
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 20,),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                    border: Border.all(width: 2, color: Colors.black12),
                    borderRadius: BorderRadius.circular(6)),

                            child: Padding(
                              padding: const EdgeInsets.only(left: 12.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  ReusableText(text: "${widget.title} Table", size: 14, fw: FontWeight.w500),

                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        isAscending = !isAscending;
                                        });

                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: Container(
                                        height: 46,
                                        width: 46,
                                        decoration: BoxDecoration(
                                            border: Border.all(width: 2, color: Colors.black12),
                                            borderRadius: BorderRadius.circular(6)),
                                        child: const Center(
                                          child: Icon(Icons.sort),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: Table(
                                  columnWidths: {
                                    0: FlexColumnWidth(0.3),
                                    1: FlexColumnWidth(0.3),
                                    2: FlexColumnWidth(0.3),
                                    3: FlexColumnWidth(0.2),
                                    4: FlexColumnWidth(0.2),
                                    5: FlexColumnWidth(0.2),
                                    6: FlexColumnWidth(0.2),
                                    7: FlexColumnWidth(0.2),
                                    8: FlexColumnWidth(0.2),
                                    9: FlexColumnWidth(0.2),
                                  },
                                  defaultColumnWidth: FlexColumnWidth(),
                                  border: TableBorder.all(
                                    color: Colors.black45,
                                    style: BorderStyle.solid,
                                    width: 1,
                                  ),
                                  children: [
                                    TableRow(
                                      decoration:
                                      BoxDecoration(color: Colors.grey),
                                      children: [

                                        buildTableCell('Region', fontSize,
                                            FontWeight.bold, 0),
                                        buildTableCell('Name', fontSize,
                                            FontWeight.bold, 0),
                                        buildTableCell('Balance', fontSize,
                                            FontWeight.bold, 0),
                                        buildTableCell('0-30', fontSize,
                                            FontWeight.bold, 0),
                                        buildTableCell('31-60', fontSize,
                                            FontWeight.bold, 0),
                                        buildTableCell('61-90', fontSize,
                                            FontWeight.bold, 0),
                                        buildTableCell('91-120', fontSize,
                                            FontWeight.bold, 0),
                                        buildTableCell('121-150', fontSize,
                                            FontWeight.bold, 0),
                                        buildTableCell('151-180', fontSize,
                                            FontWeight.bold, 0),
                                        buildTableCell('181 & Above', fontSize,
                                            FontWeight.bold, 0),
                                      ],
                                    ),
                                  ]),
                            ),
                          ),
                          SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(8)
                              ),
                              child: Table(
                                columnWidths: {
                                  0: FlexColumnWidth(0.3),
                                  1: FlexColumnWidth(0.3),
                                  2: FlexColumnWidth(0.3),
                                  3: FlexColumnWidth(0.2),
                                  4: FlexColumnWidth(0.2),
                                  5: FlexColumnWidth(0.2),
                                  6: FlexColumnWidth(0.2),
                                  7: FlexColumnWidth(0.2),
                                  8: FlexColumnWidth(0.2),
                                  9: FlexColumnWidth(0.2),
                                },
                                defaultColumnWidth: FlexColumnWidth(),

                                border: TableBorder.all(
                                  color: Colors.grey,
                                  style: BorderStyle.solid,
                                  width: 1,
                                ),
                                children:
                                List.generate(filteredEntries.length, (index) {
                                  final datas = filteredEntries[index];
                                  final dateform = DateFormat('dd-MM-yy');

                                  bool isSelected = selectedRows.contains(index);

                                  return TableRow(
                                    decoration: BoxDecoration(
                                      color: isSelected ? Colors.blue : Colors.white,
                                    ),
                                    children: [
                                      buildTableCell(datas.properties.bezei.toString(), fontSize, FontWeight.normal, index),
                                      buildTableCell(datas.properties.name1.toString(), fontSize, FontWeight.normal, index),
                                      buildTableCell(numberFormat.format(double.tryParse(datas.properties.dmbtr.toString()) ?? 0.0), fontSize, FontWeight.normal, index),
                                      buildTableCell(numberFormat.format(double.tryParse(datas.properties.age01.toString()) ?? 0.0), fontSize, FontWeight.normal, index),
                                      buildTableCell(numberFormat.format(double.tryParse(datas.properties.age02.toString()) ?? 0.0), fontSize, FontWeight.normal, index),
                                      buildTableCell(numberFormat.format(double.tryParse(datas.properties.age03.toString()) ?? 0.0), fontSize, FontWeight.normal, index),
                                      buildTableCell(numberFormat.format(double.tryParse(datas.properties.age04.toString()) ?? 0.0), fontSize, FontWeight.normal, index),
                                      buildTableCell(numberFormat.format(double.tryParse(datas.properties.age05.toString()) ?? 0.0), fontSize, FontWeight.normal, index),
                                      buildTableCell(numberFormat.format(double.tryParse(datas.properties.age06.toString()) ?? 0.0), fontSize, FontWeight.normal, index),
                                      buildTableCell(numberFormat.format(double.tryParse(datas.properties.age07.toString()) ?? 0.0), fontSize, FontWeight.normal, index),

                                    ],
                                  );
                                }),
                              ),
                            ),
                          ),

                          const SizedBox(
                            height: 24,
                          ),
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
                                        text: 'Generated on: ${formatDate(
                                            currentdate).toString()}',
                                        size: 12,
                                        fw: FontWeight.w500),
                                  ],
                                ),

                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Center(
                            child: GestureDetector(
                              onTap: () {
                                _generatePdf(context);
                                fetchAgingSummary();
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
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTableCell(
      String text, double fontSize, FontWeight fontWeight, int rowIndex) {
    return GestureDetector(
      onTap: () {
        setState(() {
          toggleRowSelection(rowIndex);
        });
      },
      child: Center(
        child: Text(
          text,
          style: TextStyle(fontSize: fontSize, fontWeight: fontWeight),
        ),
      ),
    );
  }
  void fetchAgingSummary() async {
    try {
      print("Fetching Aging Summary...");
      AgingSummaryModel data = await services.reportAgingSummary(widget.saleOffice.toString(),widget.hd.toString());

      print("Data fetched: ${data.entries.first.properties.kunnr}");

      setState(() {
        agingSummariess = [data]; // Storing the fetched data
        isAgingLoading = false;
      });
    } catch (error, stackTrace) {
      print("Error fetching Aging Summary: $error");
      print("Stack trace: $stackTrace");
      setState(() {
        isAgingLoading = false;
      });
      Get.snackbar('Error', error.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  List<AgingSummaryModel> agingSummariess = [];

  Future<void> _generatePdf(BuildContext context) async {
    final pdf = pw.Document(
      version: PdfVersion.pdf_1_4,
      compress: true,
    );

    // Load the custom font
    final fontData = await rootBundle.load("assets/fonts/Roboto-Regular.ttf");
    final ttf = pw.Font.ttf(fontData.buffer.asByteData());

    // Define selectedData if it is not already defined
    List<List<String>> selectedData = agingSummariess.isNotEmpty
        ? agingSummariess
        .expand((entry) => entry.entries.map((e) => [
      e.properties.bezei.toString() ?? '',
      e.properties.name1.toString() ?? '',
      numberFormat.format(double.tryParse(e.properties.dmbtr.toString() ?? '0.0')),
      numberFormat.format(double.tryParse(e.properties.age01.toString() ?? '0.0')),
      numberFormat.format(double.tryParse(e.properties.age02.toString() ?? '0.0')),
      numberFormat.format(double.tryParse(e.properties.age03.toString() ?? '0.0')),
      numberFormat.format(double.tryParse(e.properties.age04.toString() ?? '0.0')),
      numberFormat.format(double.tryParse(e.properties.age05.toString() ?? '0.0')),
      numberFormat.format(double.tryParse(e.properties.age06.toString() ?? '0.0')),
      numberFormat.format(double.tryParse(e.properties.age07.toString() ?? '0.0')),
    ]))
        .toList()
        : [];

    print("Selected Data: $selectedData");
    print("Selected Rows: $selectedRows");
    print('Length of agingSummariess: ${agingSummariess.length}');

    // Check the structure of each item in agingSummariess
    for (int i = 0; i < agingSummariess.length; i++) {
      print('Index $i: ${agingSummariess[i]}');
      print('Entries: ${agingSummariess[i].entries}');
    }

    final validIndices = selectedRows
        .where((index) => index >= 0 && index < (agingSummariess.isNotEmpty ? agingSummariess.first.entries.length : 0))
        .toList();

// Extract data for the selected rows
    List<List<dynamic>> pdfData = validIndices.isNotEmpty
        ? validIndices
        .map((index) {
      // Ensure index is within the bounds of the entries in the single agingSummariess item
      if (agingSummariess.isNotEmpty && index < agingSummariess.first.entries.length) {
        var entry = agingSummariess.first.entries[index];
        return [
          entry.properties.bezei.toString() ?? '',
          entry.properties.name1.toString() ?? '',
          numberFormat.format(double.tryParse(entry.properties.dmbtr.toString() ?? '0.0')),
          numberFormat.format(double.tryParse(entry.properties.age01.toString() ?? '0.0')),
          numberFormat.format(double.tryParse(entry.properties.age02.toString() ?? '0.0')),
          numberFormat.format(double.tryParse(entry.properties.age03.toString() ?? '0.0')),
          numberFormat.format(double.tryParse(entry.properties.age04.toString() ?? '0.0')),
          numberFormat.format(double.tryParse(entry.properties.age05.toString() ?? '0.0')),
          numberFormat.format(double.tryParse(entry.properties.age06.toString() ?? '0.0')),
          numberFormat.format(double.tryParse(entry.properties.age07.toString() ?? '0.0')),

        ];
      }
      return []; // Return an empty list if index is out of bounds
    })
        .toList()
        : selectedData; // Use selectedData if no rows are selected

    print("Selected Rows: $selectedRows");
    print("pdfData after processing: $pdfData");


    print("pdfData after processing: $pdfData");

    pw.Widget createPageContent(List<List<dynamic>> data, String title) {
      return pw.Stack(
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  title,
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 24),
              pw.Container(
                padding: pw.EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: pw.BoxDecoration(
                  color: PdfColors.white,
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Table.fromTextArray(
                  headerDecoration: pw.BoxDecoration(color: PdfColor.fromHex('#dde0d9')),
                  rowDecoration: pw.BoxDecoration(color: PdfColors.white),
                  headers: [
                    'Region',
                    'Name',
                    'Balance',
                    '0-30',
                    '31-60',
                    '61-90',
                    '91-120',
                    '121-150',
                    '151-180',
                    '181 & Above ',
                  ],
                  data: data,
                  headerStyle: pw.TextStyle(
                    color: PdfColors.black,
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 12
                  ),
                  cellStyle: pw.TextStyle(),
                  cellAlignment: pw.Alignment.center,
                  columnWidths: {
                    0: pw.FixedColumnWidth(100),
                    1: pw.FixedColumnWidth(80),
                    2: pw.FixedColumnWidth(80),
                  },
                ),
              ),
              pw.SizedBox(height: 18),
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
    }



    // Paginate the data if necessary
    const int itemsPerPage = 6;
    int totalPages = (pdfData.length / itemsPerPage).ceil();

    for (int pageIndex = 0; pageIndex < totalPages; pageIndex++) {
      List<List<dynamic>> pageData = pdfData.skip(pageIndex * itemsPerPage).take(itemsPerPage).toList();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4.landscape,
          build: (pw.Context context) {
            return createPageContent(pageData, widget.title.toString());
          },
        ),
      );
    }

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
