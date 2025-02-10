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
import 'package:ACM/models/supply_summary_model.dart';
import 'package:ACM/services/helper/report_services.dart';

class SupplySummaryScreen extends StatefulWidget {
  const SupplySummaryScreen(
      {super.key,
      this.title,
      this.startDate,
      this.endDate,
      this.saleOffice,
      this.month,
      this.hd});

  final String? title;
  final String? hd;
  final String? saleOffice;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? month;
  @override
  State<SupplySummaryScreen> createState() => _SupplySummaryScreenState();
}

class _SupplySummaryScreenState extends State<SupplySummaryScreen> {
  ReportServices services = ReportServices();

  List<SupplySummaryModel> agingSummaries = [];
  bool isAgingLoading = true;
  bool isAscending = true;
  int sortColumnIndex = 0;

  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    Permission.storage.request();
    userName();
    services.supplySummary(widget.saleOffice.toString(),
        widget.month.toString(), widget.hd.toString());
    fetchSalesSummary();
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
      value = userName;
    });
  }
  final numberFormat = NumberFormat('#,##0.##', 'en_US');
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
                child: FutureBuilder<SupplySummaryModel>(
                  future: services.supplySummary(widget.saleOffice.toString(),
                      widget.month.toString(), widget.hd.toString()),
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

                        return entry.properties.fkimg
                                .toLowerCase()
                                .contains(searchLowerCase) ||
                            entry.properties.zmvgr3
                                .toLowerCase()
                                .contains(searchLowerCase) ||
                            entry.properties.zmvgr2
                                .toLowerCase()
                                .contains(searchLowerCase) ||
                            entry.properties.zmvgr4
                                .toLowerCase()
                                .contains(searchLowerCase) ||
                            entry.properties.kwert
                                .toLowerCase()
                                .contains(searchLowerCase) ||
                            entry.properties.bezei
                                .toLowerCase()
                                .contains(searchLowerCase);
                      }).toList();

                      if (filteredEntries.isEmpty) {
                        return Center(
                            child: Text('No matching entries found.'));
                      }

                      final balances = filteredEntries
                          .map((e) => double.parse(e.properties.kwert))
                          .toList();

                      // Find the highest and lowest balance values
                      final highestBalance =
                          balances.reduce((a, b) => a > b ? a : b);
                      final lowestBalance =
                          balances.reduce((a, b) => a < b ? a : b);

                      // Sort the entries based on the difference between the highest and lowest balance values
                      if (isAscending) {
                        filteredEntries.sort((a, b) {
                          final balanceA = double.parse(a.properties.kwert);
                          final balanceB = double.parse(b.properties.kwert);
                          return (balanceA - lowestBalance)
                              .compareTo(balanceB - lowestBalance);
                        });
                      } else {
                        filteredEntries.sort((a, b) {
                          final balanceA = double.parse(a.properties.kwert);
                          final balanceB = double.parse(b.properties.kwert);
                          return (balanceB - lowestBalance)
                              .compareTo(balanceA - lowestBalance);
                        });
                      }

                      print('Category ${data.entries.first.properties.zmvgr3}');

                      if (filteredEntries.isEmpty) {
                        return Center(
                            child: Text('No matching entries found.'));
                      }
                      final numberFormat = NumberFormat('#,##0.##', 'en_US');
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 20,
                          ),
                          Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                border:
                                    Border.all(width: 2, color: Colors.black12),
                                borderRadius: BorderRadius.circular(6)),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 12.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  ReusableText(
                                      text: "${widget.title} Table",
                                      size: 14,
                                      fw: FontWeight.w500),
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
                                            border: Border.all(
                                                width: 2,
                                                color: Colors.black12),
                                            borderRadius:
                                                BorderRadius.circular(6)),
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
                          SizedBox(
                            height: 12,
                          ),
                          Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                border:
                                    Border.all(width: 2, color: Colors.black12),
                                borderRadius: BorderRadius.circular(6)),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  ReusableText(
                                      text:
                                          'Month:  ${entries.first.properties.zmon}',
                                      size: 16,
                                      fw: FontWeight.w500),
                                  ReusableText(
                                      text:
                                          'Company Code:  ${entries.first.properties.burks}',
                                      size: 16,
                                      fw: FontWeight.w500),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 12,
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
                                    3: FlexColumnWidth(0.3),
                                    4: FlexColumnWidth(0.3),
                                    5: FlexColumnWidth(0.3),
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
                                        buildTableCell('Category', fontSize,
                                            FontWeight.bold, 0),
                                        buildTableCell('Type', fontSize,
                                            FontWeight.bold, 0),
                                        buildTableCell('Container', fontSize,
                                            FontWeight.bold, 0),
                                        buildTableCell('Sales Qty', fontSize,
                                            FontWeight.bold, 0),
                                        buildTableCell('Detail Value', fontSize,
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
                                  borderRadius: BorderRadius.circular(8)),
                              child: Table(
                                columnWidths: {
                                  0: FlexColumnWidth(0.3),
                                  1: FlexColumnWidth(0.3),
                                  2: FlexColumnWidth(0.3),
                                  3: FlexColumnWidth(0.3),
                                  4: FlexColumnWidth(0.3),
                                  5: FlexColumnWidth(0.3),
                                },
                                defaultColumnWidth: FlexColumnWidth(),
                                border: TableBorder.all(
                                  color: Colors.grey,
                                  style: BorderStyle.solid,
                                  width: 1,
                                ),
                                children: List.generate(filteredEntries.length,
                                    (index) {
                                  final datas = filteredEntries[index];
                                  final dateform = DateFormat('dd-MM-yy');

                                  bool isSelected =
                                      selectedRows.contains(index);

                                  return TableRow(
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Colors.blue
                                          : Colors.white,
                                    ),
                                    children: [
                                      buildTableCell(datas.properties.bezei,
                                          fontSize, FontWeight.normal, index),
                                      buildTableCell(
                                        datas.properties.zmvgr3
                                            .toString(),
                                        fontSize,
                                        FontWeight.normal,
                                        index,
                                      ),
                                      buildTableCell(
                                        datas.properties.zmvgr2
                                            .toString(),
                                        fontSize,
                                        FontWeight.normal,
                                        index,
                                      ),
                                      buildTableCell(
                                        datas.properties.zmvgr4
                                            .toString(),
                                        fontSize,
                                        FontWeight.normal,
                                        index,
                                      ),
                                      buildTableCell(
                                        numberFormat.format(double.tryParse(
                                                datas.properties.fkimg
                                                    .toString()) ??
                                            0.0),
                                        fontSize,
                                        FontWeight.normal,
                                        index,
                                      ),
                                      buildTableCell(
                                        numberFormat.format(double.tryParse(
                                                datas.properties.kwert
                                                    .toString()) ??
                                            0.0),
                                        fontSize,
                                        FontWeight.normal,
                                        index,
                                      ),
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
                                        text:
                                            'Generated on: ${formatDate(currentdate).toString()}',
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
                                fetchSalesSummary();
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
      child: Container(
        padding: EdgeInsets.all(8.0),
        child: Text(
          text,
          style: TextStyle(fontSize: fontSize, fontWeight: fontWeight),
        ),
      ),
    );
  }

  List<SupplySummaryModel> supplySummariess = [];

  void fetchSalesSummary() async {
    try {
      print("Fetching Aging Summary...");
      SupplySummaryModel data = await services.supplySummary(
          widget.saleOffice.toString(),
          widget.month.toString(),
          widget.hd.toString());

      print("Data fetched: ${data.entries.first.properties.burks}");

      setState(() {
        supplySummariess = [data]; // Storing the fetched data
        isAgingLoading = false;
      });
    } catch (error, stackTrace) {
      print("Error fetching Aging Summary: $error");
      print("Stack trace: $stackTrace");
      setState(() {
        isAgingLoading = false;
      });
      Get.snackbar(
        'Error',
        error.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _generatePdf(BuildContext context) async {
    final pdf = pw.Document(
      version: PdfVersion.pdf_1_4,
      compress: true,
    );

    // Load the custom font
    final fontData = await rootBundle.load("assets/fonts/Roboto-Regular.ttf");
    final ttf = pw.Font.ttf(fontData.buffer.asByteData());

    // Define selectedData if it is not already defined
    List<List<String>> selectedData = supplySummariess.isNotEmpty
        ? supplySummariess
            .expand((entry) => entry.entries.map((e) => [
      e.properties.bezei.toString() ?? '',
      e.properties.zmvgr3.toString() ?? '',
      e.properties.zmvgr2.toString() ?? '',
      e.properties.zmvgr4.toString() ?? '',
      numberFormat.format(double.tryParse(e.properties.fkimg.toString()) ?? 0.0),
      numberFormat.format(double.tryParse(e.properties.kwert.toString()) ?? 0.0),

    ]))
            .toList()
        : [];

    print("Selected Data: $selectedData");
    print("Selected Rows: $selectedRows");
    print('Length of agingSummariess: ${supplySummariess.length}');

    // Check the structure of each item in agingSummariess
    for (int i = 0; i < supplySummariess.length; i++) {
      print('Index $i: ${supplySummariess[i]}');
      print('Entries: ${supplySummariess[i].entries}');
    }

    final validIndices = selectedRows
        .where((index) =>
            index >= 0 &&
            index <
                (supplySummariess.isNotEmpty
                    ? supplySummariess.first.entries.length
                    : 0))
        .toList();

// Extract data for the selected rows
    List<List<dynamic>> pdfData = validIndices.isNotEmpty
        ? validIndices.map((index) {
            // Ensure index is within the bounds of the entries in the single agingSummariess item
            if (supplySummariess.isNotEmpty &&
                index < supplySummariess.first.entries.length) {
              var entry = supplySummariess.first.entries[index];
              return [
                entry.properties.bezei.toString() ?? '',
                entry.properties.zmvgr3.toString() ?? '',
                entry.properties.zmvgr2.toString() ?? '',
                entry.properties.zmvgr4.toString() ?? '',
                numberFormat.format(double.tryParse(entry.properties.fkimg.toString()) ?? 0.0),
                numberFormat.format(double.tryParse(entry.properties.kwert.toString()) ?? 0.0),

              ];
            }
            return []; // Return an empty list if index is out of bounds
          }).toList()
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
                    fontSize: 20,
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
                  headerDecoration:
                      pw.BoxDecoration(color: PdfColor.fromHex('#dde0d9')),
                  rowDecoration: pw.BoxDecoration(color: PdfColors.white),
                  headers: [
                    'Region',
                    'Category',
                    'Type',
                    'Container',
                    'Sales Quantity',
                    'Detail Value',
                  ],
                  data: data,
                  headerStyle: pw.TextStyle(
                    color: PdfColors.black,
                    fontWeight: pw.FontWeight.bold,
                  ),
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
              padding:
                  const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
                    style: pw.TextStyle(
                        fontSize: 12, fontWeight: pw.FontWeight.bold),
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
                        style:
                            pw.TextStyle(color: PdfColors.black, fontSize: 8),
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
                        formatDate(DateTime
                            .now()), // Replace with actual generation date if available
                        style:
                            pw.TextStyle(color: PdfColors.black, fontSize: 8),
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
    const int itemsPerPage = 8;
    int totalPages = (pdfData.length / itemsPerPage).ceil();

    for (int pageIndex = 0; pageIndex < totalPages; pageIndex++) {
      List<List<dynamic>> pageData =
          pdfData.skip(pageIndex * itemsPerPage).take(itemsPerPage).toList();

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
