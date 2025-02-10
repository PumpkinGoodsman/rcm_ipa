import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'tablees/return_gatepass_table_screen.dart';  // Import the ReturnableGatePassTable class

class ReturnGatePass extends StatefulWidget {
  const ReturnGatePass({Key? key}) : super(key: key);

  @override
  _ReturnGatePassState createState() => _ReturnGatePassState();
}

class _ReturnGatePassState extends State<ReturnGatePass> {
  // Static data entries for Return Gate Pass
  final List<Map<String, dynamic>> staticEntries = [
    {
      'docDate': DateTime(2022, 12, 01),
      'supplierName': 'Supplier A',
      'valuationPrice': 1500.00,
      'priceUnit': 'USD',
      'pr': 'PR12345',
      'wiId': 'WI12345',
    },
    {
      'docDate': DateTime(2022, 11, 15),
      'supplierName': 'Supplier B',
      'valuationPrice': 2300.00,
      'priceUnit': 'EUR',
      'pr': 'PR12346',
      'wiId': 'WI12346',
    },
    {
      'docDate': DateTime(2022, 10, 10),
      'supplierName': 'Supplier C',
      'valuationPrice': 3200.00,
      'priceUnit': 'GBP',
      'pr': 'PR12347',
      'wiId': 'WI12347',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd');
    final numberFormat = NumberFormat('#,##0.00', 'en_US'); // Define the new format

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 241, 240, 240),
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: Image.asset('assets/logo.jpg', width: 46, height: 46),
          ),
        ],
        backgroundColor: Colors.white,
        title: const Text(
          'Return Gate Pass',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: Color.fromARGB(221, 37, 37, 37),
          ),
        ),
        centerTitle: true,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context); // Go back to the previous screen
          },
          child: Icon(
            Icons.navigate_before,
            color: Colors.blue.shade900,
            size: 35,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Placeholder for refresh action
          await Future.delayed(const Duration(seconds: 2));
        },
        child: Container(
          margin: const EdgeInsets.all(17),
          child: ListView.builder(
            itemCount: staticEntries.length,
            itemBuilder: (context, index) {
              final entry = staticEntries[index];

              return GestureDetector(
                onTap: () {
                  // Navigate to the ReturnableGatePassTable page on tap
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ReturnableGatePassTable(),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Card(
                    color: Colors.white,
                    // Remove shadow by setting elevation to 0
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      // Remove border radius
                      borderRadius: BorderRadius.zero,
                    ),
                    child: ListTile(
                      title: Text(
                        entry['pr'],
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Date: ${dateFormat.format(entry['docDate'])}',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey.shade600),
                          ),
                          Text(
                            'Supplier: ${entry['supplierName']}',
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey.shade800),
                          ),
                          Text(
                            'Price: ${numberFormat.format(entry['valuationPrice'])} ${entry['priceUnit']}',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        color: const Color.fromARGB(255, 255, 255, 255),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
