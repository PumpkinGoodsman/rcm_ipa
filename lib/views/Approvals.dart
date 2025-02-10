import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ACM/views/Dashboard.dart';
import 'package:ACM/views/tablees/approvalDetail.dart';
import 'package:ACM/views/widgets/pr_tile_widgets.dart';
import '../models/po_list_model.dart';
import '../services/helper/request_services.dart';

class POApprovals extends StatefulWidget {


  const POApprovals({
    Key? key,
  }) : super(key: key);

  @override
  State<POApprovals> createState() => _POApprovalsState();
}

class _POApprovalsState extends State<POApprovals> {
  RequestServices services = RequestServices();

  bool _isRefreshTriggered = false;
  final double _refreshThreshold = 100.0;
  final ScrollController _scrollController = ScrollController();
  Future<void> _refresh() async {

    await Future.delayed(const Duration(seconds: 1));
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

    services.fetchPurchaseOrders();

  }

  @override
  Widget build(BuildContext context) {


    services.fetchPurchaseOrders();

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
            'Purchase Order Approval',
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
            child: FutureBuilder<PurchaseOrderSet>(
              future: services.fetchPurchaseOrders(),
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

                      final numberFormat = NumberFormat('#,##0.00', 'en_US');
                      final amt = '${numberFormat.format(entry.amount)} ${entry.currency}';
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => POApprovalTableScreen(
                                appBarTitle: entry.supplierName,
                                po: entry.po,
                                wid: entry.wiId,
                                currency: entry.currency,
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ListOfItems(
                            title: entry.po,
                            date: dateFormat.format(entry.docDate),
                            description: entry.supplierName,
                            price: amt,
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

