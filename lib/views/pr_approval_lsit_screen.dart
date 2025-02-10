import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ACM/views/tablees/pr_table_screen.dart';
import 'package:ACM/views/widgets/pr_tile_widgets.dart';
import '../models/pr_list_model.dart';
import '../services/helper/request_services.dart';
import 'Dashboard.dart';

class PRApprovals extends StatefulWidget {

  const PRApprovals({
    Key? key,
  }) : super(key: key);

  @override
  State<PRApprovals> createState() => _PRApprovalsState();
}

class _PRApprovalsState extends State<PRApprovals> {
  RequestServices services = RequestServices(); // Note: Use instance, not new

  bool _isRefreshTriggered = false;
  final double _refreshThreshold = 100.0;
  final ScrollController _scrollController = ScrollController();
  Future<void> _refresh() async {

    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _isRefreshTriggered = false;
    });
  }
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.hasClients) {
        if (_scrollController.offset < -_refreshThreshold && !_isRefreshTriggered) {
          _isRefreshTriggered = true;
          _refresh();
        }
      }
    });

    services.fetchPurchaseRequest();

  }

  @override
  Widget build(BuildContext context) {
    services.fetchPurchaseRequest();
    return WillPopScope(
      onWillPop: () async {
        // Returning false to disable the back button
        return false;
      },
      child: Scaffold(
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
            'Purchase Request Approval',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Color.fromARGB(221, 37, 37, 37),
            ),
          ),
          centerTitle: true,
          leading: GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const Dashboard()),
              );
            },
            child: Icon(
              Icons.navigate_before,
              color: Colors.blue.shade900,
              size: 35,
            ),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: _refresh,
          child: Container(
            margin: const EdgeInsets.all(17),
            child: FutureBuilder<PurchaseRequestSet>(
              future: services.fetchPurchaseRequest(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('An error occurred: ${snapshot.error}'),
                  );
                } else if (!snapshot.hasData || snapshot.data!.entries.isEmpty) {
                  return const Center(
                    child: Text('No data available'),
                  );
                } else {
                  final data = snapshot.data!;
                  return ListView.builder(
                    itemCount: data.entries.length,
                    itemBuilder: (context, index) {
                      final entry = data.entries[index];
                      final dateFormat = DateFormat('yyyy-MM-dd');

                      final numberFormat = NumberFormat('#,##0.00', 'en_US'); // Define the new format
                   //   final amt = '${numberFormat.format(entry.valuationPrice)} ${entry.priceUnit}';
      
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PRApprovalDetails(
                                appBarTitle: entry.supplierName,
                                pr: entry.pr,
                                wid: entry.wiId,
                                currency: entry.priceUnit,
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ListOfItems(
                            title: entry.pr,
                            date: dateFormat.format(entry.docDate),
                            description: entry.supplierName,
                            price: '${numberFormat.format(entry.valuationPrice)} ${entry.priceUnit}',
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}

