import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:ACM/services/helper/auth_helper.dart';
import 'package:ACM/services/helper/dashBorad_auth.dart';
import '../../Widgets/reusable_text_widget.dart';
import '../../models/dashboard_data_model.dart';
import '../../models/filter_request_model.dart';
import '../Approvals.dart';
import '../pr_approval_lsit_screen.dart';
import '../reservation_approval.dart';
import '../widgets/chart_widget.dart';
import '../widgets/drawyer_widget.dart';
import '../return_gatepass_lsit_screen.dart'; 
import 'package:ACM/views/report_screens/report_filter_screen.dart';


class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ApprovalRequest> approvalRequests = [];
  List<String> displayData = [];

  Auth? auth;
  DashboardAuth auths = DashboardAuth();

  void filterData() async {
    try {
      Auth? fetchedAuth = await AuthHelper().filtersRequest();
      setState(() {
        auth = fetchedAuth;
      });
    } catch (e) {
      // Handle errors here
      print('Error fetching auth data: $e');
    }
  }

  void fetchData() async {
    await auths.getDashboardData();
    setState(() {
      approvalRequests = auths.approvalRequests;

      displayData = approvalRequests
          .map((request) => 
              'WiId: ${request.wiId}, UserId: ${request.userId}, TypeId: ${request.typeId}, InstId: ${request.instId}, Content Length: ${request.getContentLength()}')
          .toList();
      print(displayData);
    });
  }

  final ScrollController _scrollController = ScrollController(); 
  bool _isRefreshTriggered = false;
  final double _refreshThreshold = 100.0; // Adjust this threshold as needed

  Future<void> _refresh() async {
    fetchData();
    auths.getDashboardData();
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      _isRefreshTriggered = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.hasClients) {
        if (_scrollController.offset < -_refreshThreshold &&
            !_isRefreshTriggered) {
          _isRefreshTriggered = true;
          _refresh();
        }
      }
    });
    auths.getDashboardData();
    fetchData();
    filterData();
    auths.getPalAcmData(context);
  }

  @override
  Widget build(BuildContext context) {
    int pR = 0;
    for (var request in approvalRequests) {
      if (request.typeId == 'BUS2105') {
        pR++;
      }
    }

    int pO = 0;
    for (var request in approvalRequests) {
      if (request.typeId == 'BUS2012') {
        pO++;
      }
    }

    int res = 0;
    for (var request in approvalRequests) {
      if (request.typeId == 'ZBUS2093') {
        res++;
      }
    }

    setState(() {
      pO;
      pR;
      res;
    });

    final widthSize = MediaQuery.of(context).size.width;
    final containerWidth = widthSize * 0.45;

    auths.getDashboardData();
    print('PAL Data');
    print('PR Data $pR');
    auths.getPalAcmData(context);
    return WillPopScope(
      onWillPop: () async {
        // Returning false to disable the back button
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: const Color.fromARGB(255, 241, 240, 240),
          centerTitle: true,
          title:
              const ReusableText(text: 'Home', size: 16, fw: FontWeight.w500),
          actions: [
             IconButton(
                        onPressed: () {
                          _refresh();
                        },
                        icon: Icon(Icons.refresh_outlined))

          ],
        ),
        drawer: const Drawer(
          backgroundColor: Colors.white,
          child: SingleChildScrollView(
            child: drawyerItems(),
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 241, 240, 240),
        body: NotificationListener<ScrollNotification>(
          onNotification: (scrollNotification) {
            if (scrollNotification is ScrollUpdateNotification) {
              if (scrollNotification.metrics.pixels < -_refreshThreshold &&
                  !_isRefreshTriggered) {
                _isRefreshTriggered = true;
                _refresh();
              }
            }
            return false;
          },
          child: RefreshIndicator(
            onRefresh: () async {
              await _refresh();
            },
            child: SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 8,
                    ),
                    FutureBuilder(
                        future: auths.getPalAcmData(context),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          } else if (!snapshot.hasData) {
                            return Center(
                              child: Text('No data available'),
                            );
                          } else if (snapshot.hasError) {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          } else {
                            final data = snapshot.data;

                            final numberFormat =
                                NumberFormat('#,##0.00', 'en_US');

                            return Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                auth == null
                                    ? const SizedBox.shrink()
                                    : auth!.salesPal == 'X' ||
                                            auth!.salesAcm == 'X'
                                        ? Container(
                                            margin: EdgeInsets.only(
                                                bottom: 12, top: 6),
                                            child: const ReusableText(
                                                text: 'Sale Criterial',
                                                size: 24,
                                                fw: FontWeight.bold))
                                        : SizedBox.shrink(),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    auth == null
                                        ? const SizedBox.shrink()
                                        : auth!.salesPal == 'X'
                                            ? Expanded(
                                                child: Container(
                                                  child: ChartFirstWidget(
                                                    containerWidth:
                                                        containerWidth,
                                                    title: 'PAL Sales Qty',
                                                    dcolor: Colors.green,
                                                    data:
                                                        "${numberFormat.format(data!.entries.first.salePalQty)} ",
                                                    // icon: CupertinoIcons
                                                    //     .arrowtriangle_up_fill,
                                                    sTitle: 'PAL Retail Value',
                                                    sData: '${numberFormat.format(data.entries.first.salePal)} ',
                                                    highLow: '+',
                                                    iconColor: Colors.green,
                                                    spIcon:
                                                        Icons.line_axis_sharp,
                                                    spIconColor: Colors.green,
                                                  ),
                                                  margin: EdgeInsets.only(
                                                      right: 10),
                                                ),
                                              )
                                            : SizedBox.shrink(),
                                    auth == null
                                        ? const SizedBox.shrink()
                                        : auth!.salesAcm == 'X'
                                            ? Expanded(
                                                child: Container(

                                                  margin:
                                                      EdgeInsets.only(right: 6),
                                                  child: ChartFirstWidget(
                                                    containerWidth:
                                                        containerWidth,
                                                    title: 'ACM Sales Qty',
                                                    dcolor: Colors.red,
                                                    data:
                                                        "${numberFormat.format(data!.entries.first.saleAcmQty)}",
                                                    sTitle: 'ACM Retail Value',
                                                    sData: ' ${numberFormat.format(data.entries.first.saleAcm)}',
                                                    // icon: CupertinoIcons
                                                    //     .arrowtriangle_down_fill,
                                                    highLow: '+',
                                                    iconColor: Colors.red,
                                                    spIconColor: Colors.red,
                                                    spIcon: CupertinoIcons
                                                        .chart_bar_alt_fill,
                                                  ),
                                                ),
                                              )
                                            : SizedBox.shrink(),
                                  ],
                                ),
                                auth == null
                                    ? const SizedBox.shrink()
                                    : auth!.prodPal == 'X' ||
                                            auth!.prodAcm == 'X'
                                        ? Container(
                                            child: ReusableText(
                                                text: 'Production Criterial',
                                                size: 24,
                                                fw: FontWeight.bold),
                                            margin: EdgeInsets.only(
                                                bottom: 12, top: 16),
                                          )
                                        : SizedBox.shrink(),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    auth == null
                                        ? const SizedBox.shrink()
                                        : auth!.prodPal == 'X'
                                            ? Expanded(
                                                child: GestureDetector(
                                                  onTap: () {
                                                    // Navigate to ReportFilterScreen
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) => const ReportFilterScreen(),
                                                      ),
                                                    );
                                                  },
                                                  child: Container(
                                                    margin: EdgeInsets.only(right: 10),
                                                    child: ChartWidget(
                                                      containerWidth: containerWidth,
                                                      title: 'PAL Productions',
                                                      dcolor: Colors.green,
                                                      data: numberFormat.format(data!.entries.first.prodPal),
                                                      highLow: '-',
                                                      iconColor: Colors.green,
                                                      spIcon: Icons.line_axis_sharp,
                                                      spIconColor: Colors.green,
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : SizedBox.shrink(),
                                    auth == null
                                        ? const SizedBox.shrink()
                                        : auth!.prodAcm == 'X'
                                            ? Expanded(
                                                child: GestureDetector(
                                                  onTap: () {
                                                    // Navigate to ReportFilterScreen
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) => const ReportFilterScreen(),
                                                      ),
                                                    );
                                                  },
                                                  child: Container(
                                                    margin: EdgeInsets.only(right: 6),
                                                    child: ChartWidget(
                                                      containerWidth: containerWidth,
                                                      title: 'ACM Productions',
                                                      dcolor: Colors.red,
                                                      data: numberFormat.format(data!.entries.first.prodAcm),
                                                      highLow: '-',
                                                      iconColor: Colors.red,
                                                      spIconColor: Colors.red,
                                                      spIcon: CupertinoIcons.chart_bar_alt_fill,
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : SizedBox.shrink(),
                                  ],
                                ),

                              ],
                            );
                          }
                        }),
                    SizedBox(
                      height: 12,
                    ),
                    Row(
                      children: [
                        auth == null
                            ? const SizedBox.shrink()
                            : auth!.pr == 'X'
                                ? GestureDetector(
                                    onTap: () async {
                                      Get.to(() =>  PRApprovals());
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(18),
                                      height: 180,
                                      width: containerWidth,
                                      decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20)),
                                        color: Colors.white,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              "PR Approval Request",
                                              style: GoogleFonts.notoSans(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w800,
                                                  color: const Color.fromARGB(
                                                      221, 37, 37, 37)),
                                            ),
                                          ),
                                          Row(children: [
                                            Container(
                                              alignment: Alignment.topLeft,
                                              child: Icon(
                                                Icons.beenhere_outlined,
                                                color: Colors.blue.shade900,
                                                size: 40,
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            Text(
                                              pR.toString(),
                                              style:
                                                  const TextStyle(fontSize: 25),
                                            ),
                                          ]),
                                          Container(
                                              alignment: Alignment.topLeft,
                                              child: const Text(
                                                "Open tasks",
                                                style: TextStyle(fontSize: 12),
                                              ))
                                        ],
                                      ),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                        const SizedBox(
                          width: 10,
                        ),
                        auth == null
                            ? const SizedBox.shrink()
                            : auth!.po == 'X'
                                ? GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const POApprovals(),
                                          ));
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(18),
                                      height: 180,
                                      width: containerWidth,
                                      decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20)),
                                        color: Colors.white,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              "PO Approval Request",
                                              style: GoogleFonts.notoSans(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w800,
                                                  color: const Color.fromARGB(
                                                      221, 37, 37, 37)),
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              Container(
                                                alignment: Alignment.topLeft,
                                                child: Icon(
                                                  Icons.fact_check_outlined,
                                                  color: Colors.blue.shade900,
                                                  size: 42,
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                pO.toString(),
                                                style: const TextStyle(
                                                    fontSize: 25),
                                              ),
                                            ],
                                          ),
                                          Container(
                                              alignment: Alignment.topLeft,
                                              child: const Text(
                                                "Open tasks",
                                                style: TextStyle(fontSize: 12),
                                              ))
                                        ],
                                      ),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    auth == null
                        ? const SizedBox.shrink()
                        : auth!.res == 'X'
                            ? GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const ReservationApprovals(),
                                      ));
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(18),
                                  height: 180,
                                  width: containerWidth,
                                  decoration: const BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20)),
                                    color: Colors.white,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "(MIR)Reservation Approval Request",
                                          style: GoogleFonts.notoSans(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w800,
                                              color: const Color.fromARGB(
                                                  221, 37, 37, 37)),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Container(
                                            alignment: Alignment.topLeft,
                                            child: Icon(
                                              Icons.flaky_outlined,
                                              color: Colors.blue.shade900,
                                              size: 42,
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            res.toString(),
                                            style:
                                                const TextStyle(fontSize: 25),
                                          ),
                                        ],
                                      ),
                                      Container(
                                          alignment: Alignment.topLeft,
                                          child: const Text(
                                            "Open tasks",
                                            style: TextStyle(fontSize: 12),
                                          ))
                                    ],
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Existing containers/buttons...

                                SizedBox(height: 40),

                                // The new "Returnable Gate Pass" container
                                GestureDetector(
                                  onTap: () {
                                    // Navigate to the ReturnGatePass screen when tapped
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => ReturnGatePass()),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(18),
                                    height: 180, // Adjust height as needed
                                    width: containerWidth,
                                    decoration: const BoxDecoration(
                                      borderRadius: BorderRadius.all(Radius.circular(20)),
                                      color: Colors.white,
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Title for the container
                                        Expanded(
                                          child: Text(
                                            "Returnable Gate Pass",
                                            style: GoogleFonts.notoSans(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w800,
                                              color: const Color.fromARGB(221, 37, 37, 37),
                                            ),
                                          ),
                                        ),
                                        // Placeholder for an icon button and text
                                        Row(
                                          children: [
                                            IconButton(
                                              onPressed: () {
                                                // Placeholder for icon action
                                                print('Icon Button tapped');
                                              },
                                              icon: Icon(
                                                Icons.exit_to_app, // You can change this to any other icon if needed
                                                color: Colors.blue.shade900,
                                                size: 42,
                                              ),
                                            ),
                                            const SizedBox(width: 5),
                                            Text(
                                              "Open tasks", // Placeholder text
                                              style: TextStyle(fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // Spacer between sections
                              ],
                            ),


                    const SizedBox(
                      height: 40,
                    ),
                    Center(
                      child: Image.asset(
                        "assets/sap.png",
                        height: 50,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
