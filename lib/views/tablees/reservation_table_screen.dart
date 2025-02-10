import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ACM/services/helper/request_services.dart';
import 'package:ACM/views/tablees/widgets/button_widget.dart';
import '../../Widgets/reusable_text_widget.dart';
import '../../controller/table_controller.dart';
import '../../models/reservation_table_model.dart';
import '../reservation_approval.dart';

class ReservationTableScreen extends StatefulWidget {
  final String appBarTitle;
  final String? wid;

  const ReservationTableScreen({Key? key, required this.appBarTitle, this.wid})
      : super(key: key);

  @override
  State<ReservationTableScreen> createState() => _ReservationTableScreenState();
}

class _ReservationTableScreenState extends State<ReservationTableScreen> {
  RequestServices services = RequestServices();
  TextEditingController commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final controllers = Get.put(TableController());
  Future<void> _showMyDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          icon: Icon(
            Icons.warning_rounded,
            color: Colors.red,
            size: 46,
          ),
          title: const ReusableText(
              text: 'Reservation Rejected!', size: 20, fw: FontWeight.w500),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                ReusableText(
                    text: 'Please add your remarks for rejection.',
                    size: 14,
                    fw: FontWeight.w400),
                TextFormField(
                  controller: commentController,
                  focusNode: _commentFocusNode,
                  maxLines: 2,
                  decoration: InputDecoration(
                    enabledBorder:
                        OutlineInputBorder(borderSide: BorderSide(width: 1)),
                    focusedBorder: OutlineInputBorder(),
                    hintText: 'Type your remarks...',
                  ),
                  onChanged: (text) {
                    // Handle text changes if needed
                    print('Comment text: $text');
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child:
                  ReusableText(text: 'Cancel', size: 16, fw: FontWeight.bold),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: ReusableText(
                text: 'Remarks',
                size: 16,
                fw: FontWeight.bold,
                color: Colors.red,
              ),
              onPressed: () async {
                if (commentController.text.isNotEmpty) {
                  setState(() {
                    controllers.rejected = true;
                  });

                  try {
                    // Call the API and wait for the response
                    await services.reservationApproval(
                        '0002', widget.wid.toString(), commentController.text);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ReservationApprovals()),
                    );

                    // If the API call was successful, navigate back
                  } catch (e) {
                    // Handle any errors that occur during the API call
                    print('API call failed: $e');
                  } finally {
                    // Update the state regardless of success or failure

                    setState(() {
                      controllers.rejected = false;
                    });
                  }
                } else {
                  Get.snackbar(
                      'Fill the Field!', 'Please fill your field to reject!',
                      backgroundColor: Colors.red, colorText: Colors.white);
                }
                // setState(() {
                //   Navigator.of(context).pop();
                //   WidgetsBinding.instance.addPostFrameCallback((_) {
                //     // Ensure we use the scaffold's context to request focus
                //     if (_scaffoldKey.currentContext != null) {
                //       FocusScope.of(_scaffoldKey.currentContext!)
                //           .requestFocus(_commentFocusNode);
                //     }
                //   });
                // });
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    services.fetchReservationTableData(widget.appBarTitle.toString());
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double defaultFontSize = 7.0;
    double fontSize =
        screenWidth < 500 ? defaultFontSize : defaultFontSize * 1.8;
    double screenHeight = MediaQuery.of(context).size.height;

    return WillPopScope(
      onWillPop: () async {
        // Returning false to disable the back button
        return false;
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Color.fromARGB(255, 241, 240, 240),
        appBar: AppBar(
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: Image.asset('assets/logo.jpg', width: 46, height: 46),
            ),
          ],
          backgroundColor: Colors.white,
          title: Text(
            int.parse(widget.appBarTitle).toString(),
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: const Color.fromARGB(221, 37, 37, 37),
            ),
          ),
          centerTitle: true,
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(
              Icons.navigate_before,
              color: Colors.blue.shade900,
              size: 35,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Column(
              children: [
                SizedBox(
                  height: screenHeight * 0.77,
                  child: FutureBuilder<ReservationTable>(
                    future: services.fetchReservationTableData(
                        widget.appBarTitle.toString()),
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

                        if (data.reservations.isEmpty ||
                            data.reservations.first.items.isEmpty) {
                          return Center(
                            child: Text('No items available'),
                          );
                        }
                        print(
                            'data.po ${data.reservations.first.items.last.properties.material}');
                        // print('data.po ${data.items.first.po}');
                        final dataformat = DateFormat('dd-mm-yy');
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    Table(
                                      columnWidths: {
                                        0: FlexColumnWidth(
                                            3.5), // Adjust the width of the first column
                                        1: FlexColumnWidth(
                                            4.5), // Adjust the width of the fourth column
                                      },
                                      children: [
                                        TableRow(
                                          children: [
                                            TableCell(
                                              child: Text(
                                                'Movement Type:',
                                                style: TextStyle(
                                                    fontSize: 9,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                            TableCell(
                                              child: Text(
                                                data.reservations.first
                                                    .properties.movementType,
                                                style: TextStyle(fontSize: 9),
                                              ),
                                            ),
                                          ],
                                        ),
                                        TableRow(
                                          children: [
                                            TableCell(
                                              child: Text(
                                                'Cost Center:',
                                                style: TextStyle(
                                                    fontSize: 9,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                            TableCell(
                                              child: Text(
                                                data.reservations.first
                                                    .properties.costCenter,
                                                style: TextStyle(fontSize: 9),
                                              ),
                                            ),
                                          ],
                                        ),
                                        TableRow(
                                          children: [
                                            TableCell(
                                              child: Text(
                                                'Plant',
                                                style: TextStyle(
                                                    fontSize: 9,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                            TableCell(
                                              child: Text(
                                                '${data.reservations.first.items.first.properties.plantLocation}',
                                                style: TextStyle(fontSize: 9),
                                              ),
                                            ),
                                          ],
                                        ),
                                        TableRow(
                                          children: [
                                            TableCell(
                                              child: Text(
                                                'SLoc',
                                                style: TextStyle(
                                                    fontSize: 9,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                            TableCell(
                                              child: Text(
                                                '${data.reservations.first.properties.recLocation} ${data.reservations.first.items.first.properties.location}',
                                                style: TextStyle(fontSize: 9),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(top: 20),
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.vertical,
                                        child: Table(
                                            columnWidths: {
                                              0: FlexColumnWidth(0.1),
                                              1: FlexColumnWidth(0.2),
                                              2: FlexColumnWidth(0.4),
                                              3: FlexColumnWidth(0.2),
                                              4: FlexColumnWidth(0.12),
                                              5: FlexColumnWidth(0.18),
                                              6: FlexColumnWidth(0.20),
                                              7: FlexColumnWidth(0.4),
                                            },
                                            defaultColumnWidth:
                                                FlexColumnWidth(),
                                            border: TableBorder.all(
                                              color: Colors.black45,
                                              style: BorderStyle.solid,
                                              width: 1,
                                            ),
                                            children: [
                                              TableRow(
                                                decoration: BoxDecoration(
                                                  color: Colors.grey
                                                ),
                                                children: [
                                                  buildTableCell(
                                                      'Item',
                                                      fontSize,
                                                      FontWeight.bold),
                                                  buildTableCell(
                                                      'Material',
                                                      fontSize,
                                                      FontWeight.bold),
                                                  buildTableCell(
                                                      'Material Description',
                                                      fontSize,
                                                      FontWeight.bold),
                                                  buildTableCell(
                                                      'Quantity',
                                                      fontSize,
                                                      FontWeight.bold),
                                                  buildTableCell(
                                                      'BUN',
                                                      fontSize,
                                                      FontWeight.bold),
                                                  buildTableCell(
                                                      'Rate',
                                                      fontSize,
                                                      FontWeight.bold),
                                                  buildTableCell(
                                                      'C.Stock',
                                                      fontSize,
                                                      FontWeight.bold),
                                                  buildTableCell(
                                                      'Text',
                                                      fontSize,
                                                      FontWeight.bold),
                                                ],
                                              ),
                                            ]),
                                      ),
                                    ),
                                    SingleChildScrollView(
                                      scrollDirection: Axis.vertical,
                                      child: Table(
                                        columnWidths: {
                                          0: FlexColumnWidth(0.1),
                                          1: FlexColumnWidth(0.2),
                                          2: FlexColumnWidth(0.4),
                                          3: FlexColumnWidth(0.2),
                                          4: FlexColumnWidth(0.12),
                                          5: FlexColumnWidth(0.18),
                                          6: FlexColumnWidth(0.20),
                                          7: FlexColumnWidth(0.4),
                                        },
                                        defaultColumnWidth: FlexColumnWidth(),
                                        border: TableBorder.all(
                                          color: Colors.grey,
                                          style: BorderStyle.solid,
                                          width: 1,
                                        ),
                                        children: List.generate(
                                            data.reservations.first.items
                                                .length, (index) {
                                          final datas = data
                                              .reservations.first.items[index];
                                          final dateform =
                                              DateFormat('dd-mm-yy');
                                          return TableRow(
                                            decoration: BoxDecoration(),
                                            children: [
                                              buildTableCell(
                                                  int.parse(
                                                          datas.properties.item)
                                                      .toString(),
                                                  fontSize,
                                                  FontWeight.normal),
                                              Text(
                                                '${datas.properties.material}',
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: fontSize,
                                                ),
                                              ),Text(
                                                '${datas.properties.materialDesc}',
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: fontSize,
                                                ),
                                              ),

                                              buildTableCell(
                                                  datas.properties.qty
                                                      .toString(),
                                                  fontSize,
                                                  FontWeight.normal),
                                              buildTableCell(
                                                  datas.properties.bun,
                                                  fontSize,
                                                  FontWeight.normal),
                                              buildTableCell(
                                                  datas.properties.lpPrice
                                                      .toString(),
                                                  fontSize,
                                                  FontWeight.normal),
                                              buildTableCell(
                                                  datas.properties.cStock
                                                      .toString(),
                                                  fontSize,
                                                  FontWeight.normal),
                                          Text(
                                          '${datas.properties.text}',
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                          fontWeight: FontWeight.normal,
                                          fontSize: fontSize,
                                          ),
                                          ),
                                            ],
                                          );
                                        }),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: RejectButton(
                        screenWidth: screenWidth,
                        text: 'Reject',
                        onTap: () async {
                          // Schedule the focus request for the next frame
                          _showMyDialog(context);
                        },
                        boxColor: Colors.red.shade100,
                        iconColor: Colors.red.shade700,
                        icon: Icons.cancel,
                        textColor: Colors.red.shade700,
                      ),
                    ),
                    Expanded(
                      child: ApprovalButton(
                        screenWidth: screenWidth,
                        text: 'Approval',
                        onTap: () async {
                          setState(() {
                            controllers.approval = true;
                          });

                          try {
                            // Call the API and wait for the response
                            await services.reservationApproval('0001',
                                widget.wid.toString(), commentController.text);
                            Navigator.pop(context);

                            // If the API call was successful, navigate back
                          } catch (e) {
                            // Handle any errors that occur during the API call
                            print('API call failed: $e');
                          } finally {
                            // Update the state regardless of success or failure

                            setState(() {
                              controllers.approval = false;
                            });
                          }
                        },
                        boxColor: Colors.green.shade100,
                        iconColor: const Color.fromARGB(255, 4, 139, 8),
                        icon: Icons.task_alt_outlined,
                        textColor: Color.fromARGB(255, 4, 139, 8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget buildTableCell(String text, double fontSize, FontWeight fontWeight) {
  return TableCell(
    child: Center(
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
        ),
      ),
    ),
  );
}
