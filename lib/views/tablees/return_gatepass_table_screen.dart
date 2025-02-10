import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReturnableGatePassTable extends StatefulWidget {
  const ReturnableGatePassTable({Key? key}) : super(key: key);

  @override
  _ReturnableGatePassTableState createState() => _ReturnableGatePassTableState();
}

class _ReturnableGatePassTableState extends State<ReturnableGatePassTable> {
  bool isApproved = false; // To track approval state
  TextEditingController rejectionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double fontSize = screenWidth < 500 ? 8.0 : 12.0; // Slightly smaller font size for compactness

    final NumberFormat numberFormat = NumberFormat('#,##0.00', 'en_US'); // Format for numbers

    // Dummy Data
    final List<Map<String, dynamic>> items = [
      {
        'item': '001',
        'acAssign': 'CAPEX',
        'matNo': 'MAT123',
        'matDesc': 'Material 1',
        'quantity': 100,
        'uom': 'KG',
        'priceUnit': 50.0,
        'valuationPrice': 5000.0,
        'cStock': 200,
      },
      {
        'item': '002',
        'acAssign': 'OPEX',
        'matNo': 'MAT124',
        'matDesc': 'Material 2',
        'quantity': 150,
        'uom': 'L',
        'priceUnit': 30.0,
        'valuationPrice': 4500.0,
        'cStock': 100,
      },
    ];

    final double totalValue = items.fold<double>(
      0.0,
      (sum, item) => sum + item['valuationPrice'],
    );

    final String amountInWords = 'Five Thousand Four Hundred DOLLARS'; // Dummy amount in words

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Returnable Gate Pass Table',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: Color.fromARGB(221, 37, 37, 37),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Column(
            children: [
              // Your table layout and other widgets here
              Table(
                columnWidths: const {
                  0: FlexColumnWidth(5),
                  1: FlexColumnWidth(5),
                  2: FlexColumnWidth(4),
                  3: FlexColumnWidth(5),
                },
                children: [
                  TableRow(
                    children: [
                      buildTableCell('Purchase Org:', fontSize, FontWeight.bold),
                      buildTableCell('ABC Org', fontSize, FontWeight.normal),
                      buildTableCell('Currency:', fontSize, FontWeight.bold),
                      buildTableCell('USD', fontSize, FontWeight.normal),
                    ],
                  ),
                  TableRow(
                    children: [
                      buildTableCell('Order Date:', fontSize, FontWeight.bold),
                      buildTableCell('20-01-2025', fontSize, FontWeight.normal),
                      buildTableCell('Amount:', fontSize, FontWeight.bold),
                      buildTableCell(numberFormat.format(totalValue), fontSize, FontWeight.normal),
                    ],
                  ),
                  TableRow(
                    children: [
                      buildTableCell('Header Text:', fontSize, FontWeight.bold),
                      buildTableCell('Dummy Header', fontSize, FontWeight.normal),
                      buildTableCell('', fontSize, FontWeight.bold),
                      buildTableCell('', fontSize, FontWeight.normal),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Table(
                columnWidths: const {
                  0: FlexColumnWidth(0.6),
                  1: FlexColumnWidth(0.7),
                  2: FlexColumnWidth(0.7),
                  3: FlexColumnWidth(0.9),
                  4: FlexColumnWidth(0.7),
                  5: FlexColumnWidth(0.6),
                  6: FlexColumnWidth(0.7),
                  7: FlexColumnWidth(1),
                  8: FlexColumnWidth(0.7),
                },
                defaultColumnWidth: const FlexColumnWidth(),
                border: TableBorder.all(
                  color: Colors.black45,
                  style: BorderStyle.solid,
                  width: 1,
                ),
                children: [
                  TableRow(
                    decoration: const BoxDecoration(color: Colors.grey),
                    children: [
                      buildTableCell('Item', fontSize, FontWeight.bold),
                      buildTableCell('Ac.Assign', fontSize, FontWeight.bold),
                      buildTableCell('Mat.No.', fontSize, FontWeight.bold),
                      buildTableCell('Material Description', fontSize, FontWeight.bold),
                      buildTableCell('Quantity', fontSize, FontWeight.bold),
                      buildTableCell('UOM', fontSize, FontWeight.bold),
                      buildTableCell('Price Unit', fontSize, FontWeight.bold),
                      buildTableCell('Valuation Price', fontSize, FontWeight.bold),
                      buildTableCell('C.Stock', fontSize, FontWeight.bold),
                    ],
                  ),
                  ...items.map((item) {
                    return TableRow(
                      children: [
                        buildTableCell(item['item'], fontSize, FontWeight.normal),
                        buildTableCell(item['acAssign'], fontSize, FontWeight.normal),
                        buildTableCell(item['matNo'], fontSize, FontWeight.normal),
                        buildTableCell(item['matDesc'], fontSize, FontWeight.normal),
                        buildTableCell(item['quantity'].toString(), fontSize, FontWeight.normal),
                        buildTableCell(item['uom'], fontSize, FontWeight.normal),
                        buildTableCell(numberFormat.format(item['priceUnit']), fontSize, FontWeight.normal),
                        buildTableCell(numberFormat.format(item['valuationPrice']), fontSize, FontWeight.normal),
                        buildTableCell(item['cStock'].toString(), fontSize, FontWeight.normal),
                      ],
                    );
                  }).toList(),
                ],
              ),
              Container(
                height: 10.0,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(.5),
                  border: Border.all(color: Colors.black26, width: 1),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total',
                        style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        numberFormat.format(totalValue),
                        style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                height: 40.0,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black26, width: 1),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Row(
                    children: [
                      Text(
                        'Amount in words: ',
                        style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w500),
                      ),
                      Expanded(
                        child: Text(
                          ' $amountInWords',
                          style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Approval Button
            Expanded(
              child: Container(
                height: 75, // Increased height
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isApproved = true; // Change the state to approved
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(221, 167, 232, 169),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: EdgeInsets.zero, // Remove internal padding
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, color: const Color.fromARGB(255, 86, 205, 2), size: 30), // Larger icon
                      const SizedBox(height: 8),
                      Text(
                        isApproved ? 'Approved' : 'Approval',
                        style: TextStyle(color: const Color.fromARGB(255, 86, 205, 2), fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Rejection Button
            Expanded(
              child: Container(
                height: 75, // Increased height
                child: ElevatedButton(
                  onPressed: () {
                    _showRejectionDialog(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(177, 247, 154, 190),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: EdgeInsets.zero, // Remove internal padding
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cancel, color: const Color.fromARGB(255, 176, 47, 47), size: 30), // Larger icon
                      const SizedBox(height: 8),
                      Text(
                        'Reject',
                        style: TextStyle(color: const Color.fromARGB(255, 176, 47, 47), fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Dialog box to show rejection prompt
  Future<void> _showRejectionDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Reason for Rejection'),
          content: TextField(
            controller: rejectionController,
            decoration: InputDecoration(hintText: 'Enter your reason here'),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Handle rejection remarks submission here
                Navigator.pop(context); // Close the dialog
                // You can also add logic to save the rejection reason
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      content: Text('Rejection Reason: ${rejectionController.text}'),
                    );
                  },
                );
              },
              child: Text('Add Remarks'),
            ),
          ],
        );
      },
    );
  }

  Widget buildTableCell(String text, double fontSize, FontWeight fontWeight) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.all(6.0), // Reduced padding
        child: Center(
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
