import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ACM/Widgets/reusable_text_widget.dart';
import 'package:ACM/controller/auth_controller.dart';
import 'package:ACM/models/po_table_model.dart';
import 'package:ACM/services/helper/request_services.dart';
import 'package:ACM/views/Approvals.dart';
import 'package:ACM/views/tablees/widgets/button_widget.dart';
import '../../controller/table_controller.dart';

class POApprovalTableScreen extends StatefulWidget {
  final String appBarTitle;
  final String? po;
  final String? wid;
  final String? currency;

  const POApprovalTableScreen(
      {Key? key, required this.appBarTitle, this.po, this.wid, this.currency})
      : super(key: key);

  @override
  State<POApprovalTableScreen> createState() => _POApprovalTableScreenState();
}

class _POApprovalTableScreenState extends State<POApprovalTableScreen> {
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
          icon: Icon(Icons.warning_rounded,color: Colors.red,size: 46,),
          title: const ReusableText(
              text: 'Purchase Order Rejected!',
              size: 20,
              fw: FontWeight.w500),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                ReusableText(
                    text:
                    'Please add your remarks for rejection.',
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
                    hintText: 'Type your remakrs...',
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
              onPressed: ()  async{

                if (commentController.text.isNotEmpty) {
                  setState(() {
                    controllers.rejected = true;
                  });

                  try {
                    // Call the API and wait for the response
                    await services.purchaseOrderApproval(
                        '0002', widget.wid.toString(),commentController.text);
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => POApprovals()));

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
                  Get.snackbar('Fill the Field!', 'Please fill your field to reject!',
                      backgroundColor: Colors.red, colorText: Colors.white);
                }
                  //   Navigator.of(context).pop();
                  //
                  //   WidgetsBinding.instance.addPostFrameCallback((_) {
                  //     // Ensure we use the scaffold's context to request focus
                  //     if (_scaffoldKey.currentContext != null) {
                  //       FocusScope.of(_scaffoldKey.currentContext!).requestFocus(_commentFocusNode);
                  //     }
                  // });
              },
            ),
          ],
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {


    AuthController controller = AuthController();
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double defaultFontSize = 7.0;
    double defaultContSize = 16.0;
    double fontSize =
        screenWidth < 500 ? defaultFontSize : defaultFontSize * 1.8;
    double contSize =
        screenWidth < 500 ? defaultContSize : defaultContSize * 1.3;
    print(widget.wid);

    String currencyLabel = widget.currency == 'USD' ? 'DOLLARS' : 'RUPEES';
    print("Comments ${commentController.text}");
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
            widget.appBarTitle.toString(),
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: const Color.fromARGB(221, 37, 37, 37),
            ),
          ),
          centerTitle: true,
          leading: GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => POApprovals()));
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
                  child: FutureBuilder<PurchaseOrderTable>(
                    future: services.fetchPOTableData(widget.po.toString()),
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

                        if (data.purchaseOrders.isEmpty ||
                            data.purchaseOrders.first.items.isEmpty) {
                          return Center(
                            child: Text('No items available'),
                          );
                        }

                        final purchaseOrder = data.purchaseOrders.first;
                        final item = purchaseOrder.items.first;

                        print('data.po ${item.properties.hsCode}');
                        print('Assignment ${item.properties.kntp}');

                        final dataFormat = DateFormat('dd-MM-yy');
                        final double amount = purchaseOrder.properties.amount;
                        final double netPrice = item.properties.netPrice;
                        final totalNetPrice = data.purchaseOrders.fold<double>(0.0, (sum, request) {
                          return sum + request.items.fold<double>(0.0, (itemSum, item) {
                            return itemSum + item.properties.netPrice;
                          });
                        });


                        print('Totall $totalNetPrice');

                        final String amountInWords =
                            controller.numberToWords(amount.toInt());
                        print(amountInWords);


                        final numberFormat = NumberFormat('#,##0.00', 'en_US');// Define the format
                        final amt = numberFormat.format(amount);
                        final ntp = numberFormat.format(netPrice);
                        final discount = data.purchaseOrders.first.properties.discount1;
                        final amount1 = data.purchaseOrders.first.properties.amount;

                        final ntpresult = amount - discount;

                        final dicount2 = data.purchaseOrders.first.properties.discount2;
                        final gst = data.purchaseOrders.first.properties.gst;
                        final transport = data.purchaseOrders.first.properties.trnasport;

                        final totalResult = ntpresult + gst + transport - dicount2;



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
                                            5.5), // Adjust the width of the second column
                                        2: FlexColumnWidth(
                                            3.5), // Adjust the width of the third column
                                        3: FlexColumnWidth(
                                            4.5), // Adjust the width of the fourth column
                                      },
                                      children: [
                                        TableRow(
                                          children: [
                                            TableCell(
                                              child: Text(
                                                'Purchase Order:',
                                                style: TextStyle(
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                            TableCell(
                                              child: Text(
                                                data.purchaseOrders.first.items
                                                    .first.properties.po,
                                                style: TextStyle(fontSize: 9),
                                              ),
                                            ),
                                            TableCell(
                                              child: Text(
                                                'Order Date:',
                                                style: TextStyle(
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                            TableCell(
                                              child: Text(
                                                dataFormat.format(data
                                                    .purchaseOrders
                                                    .first
                                                    .properties
                                                    .docDate),
                                                style: TextStyle(fontSize: 9),
                                              ),
                                            ),
                                          ],
                                        ),
                                        TableRow(
                                          children: [
                                            TableCell(
                                              child: Text(
                                                'Purchase Org:',
                                                style: TextStyle(
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                            TableCell(
                                              child: Text(
                                                '${data.purchaseOrders.first.properties.purOrg} - ${data.purchaseOrders.first.properties.purOrgName}',
                                                style: TextStyle(fontSize: 9),
                                              ),
                                            ),
                                            TableCell(
                                              child: Text(
                                                'Purchase Group:',
                                                style: TextStyle(
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                            TableCell(
                                              child: Text(
                                                '${data.purchaseOrders.first.properties.purGrp} - ${data.purchaseOrders.first.properties.purGrpName}',
                                                style: TextStyle(fontSize: 9),
                                              ),
                                            ),
                                          ],
                                        ),

                                        TableRow(
                                          children: [
                                            TableCell(
                                              child: Text(
                                                'Currency:',
                                                style: TextStyle(
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                            TableCell(
                                              child: Text(
                                                data.purchaseOrders.first
                                                    .properties.currency,
                                                style: TextStyle(fontSize: 9),
                                              ),
                                            ),
                                            TableCell(
                                              child: Text(
                                                'Amount',
                                                style: TextStyle(
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                            TableCell(
                                              child: Text(
                                                amt.toString(),
                                                style: TextStyle(fontSize: 9),
                                              ),
                                            ),
                                          ],
                                        ),


                                      ],
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    SingleChildScrollView(
                                      scrollDirection: Axis.vertical,
                                      child: Table(
                                          columnWidths: {
                                            0: FlexColumnWidth(0.1),
                                            1: FlexColumnWidth(0.20),
                                            2: FlexColumnWidth(0.20),
                                            3: FlexColumnWidth(0.32),
                                            4: FlexColumnWidth(0.18),
                                            5: FlexColumnWidth(0.18),
                                            6: FlexColumnWidth(0.18),
                                            7: FlexColumnWidth(0.18),
                                            8: FlexColumnWidth(0.18),
                                          },
                                          defaultColumnWidth: FlexColumnWidth(),
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
                                                buildTableCell('Item', fontSize,
                                                    FontWeight.bold),
                                                buildTableCell('Ac.Assign',
                                                    fontSize, FontWeight.bold),
                                                buildTableCell('Mat.No.',
                                                    fontSize, FontWeight.bold),
                                                buildTableCell(
                                                    'Material Description',
                                                    fontSize,
                                                    FontWeight.bold),
                                                buildTableCell('HS Code',
                                                    fontSize, FontWeight.bold),

                                                buildTableCell('UOM', fontSize,
                                                    FontWeight.bold),
                                                buildTableCell('Quantity',
                                                    fontSize, FontWeight.bold),
                                                buildTableCell('Rate', fontSize,
                                                    FontWeight.bold),
                                                buildTableCell('Net Price',
                                                    fontSize, FontWeight.bold),
                                              ],
                                            ),
                                          ]),
                                    ),
                                    SingleChildScrollView(
                                      scrollDirection: Axis.vertical,
                                      child: Table(
                                        columnWidths: {
                                          0: FlexColumnWidth(0.1),
                                          1: FlexColumnWidth(0.20),
                                          2: FlexColumnWidth(0.20),
                                          3: FlexColumnWidth(0.32),
                                          4: FlexColumnWidth(0.18),
                                          5: FlexColumnWidth(0.18),
                                          6: FlexColumnWidth(0.18),
                                          7: FlexColumnWidth(0.18),
                                          8: FlexColumnWidth(0.18),
                                        },
                                        defaultColumnWidth: FlexColumnWidth(),
                                        border: TableBorder.all(
                                          color: Colors.grey,
                                          style: BorderStyle.solid,
                                          width: 1,
                                        ),
                                        children: List.generate(
                                            data.purchaseOrders.first.items
                                                .length, (index) {
                                          final datas = data
                                              .purchaseOrders.first.items[index];
                                          final dateform = DateFormat('dd-mm-yy');
                                          return TableRow(
                                            children: [
                                              buildTableCell(
                                                  int.parse(datas.properties.poItem).toString(),
                                                  fontSize,
                                                  FontWeight.normal),
                                              buildTableCell(
                                                  datas.properties.kntp == 'A'
                                                      ? 'CAPEX'
                                                      : (datas.properties.kntp == 'F' || datas.properties.kntp == 'K')
                                                      ? 'OPEX'
                                                      : 'INVENTORY',
                                                  fontSize,
                                                  FontWeight.normal),
                                              buildTableCell(
                                                  '${datas.properties.material}',
                                                  fontSize,
                                                  FontWeight.normal),
                                              buildTableCell(
                                                  '${datas.properties.materialDesc}',
                                                  fontSize,
                                                  FontWeight.normal),
                                              buildTableCell(
                                                  datas.properties.hsCode
                                                      .toString(),
                                                  fontSize,
                                                  FontWeight.normal),

                                              buildTableCell(datas.properties.uom,
                                                  fontSize, FontWeight.normal),
                                              buildTableCell(
                                                  datas.properties.poQty
                                                      .toString(),
                                                  fontSize,
                                                  FontWeight.normal),
                                              buildTableCell(
                                                  datas.properties.rate
                                                      .toString(),
                                                  fontSize,
                                                  FontWeight.normal),
                                              buildTableCell(numberFormat.format(datas.properties.netPrice),
                                                  fontSize, FontWeight.normal),
                                            ],
                                          );
                                        }),
                                      ),
                                    ),
                                    Container(
                                      height: contSize,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.withOpacity(.5),
                                        border: Border.all(
                                            color: Colors.black26, width: 1),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            ReusableText(
                                                text: 'Gross Price',
                                                size: fontSize,
                                                fw: FontWeight.w500),
                                            ReusableText(
                                                text:
                                                    '${numberFormat.format(data.purchaseOrders.first.properties.amount)}',
                                                size: fontSize,
                                                fw: FontWeight.w500),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Container(
                                      height: contSize,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.black26, width: 1),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            ReusableText(
                                                text: 'Discount',
                                                size: fontSize,
                                                fw: FontWeight.w500),
                                            ReusableText(
                                                text: '${numberFormat.format(data.purchaseOrders.first.properties.discount1)}',
                                                // '${data.purchaseOrders.first.properties.currency}   ${data.purchaseOrders.first.items.first.properties.netPrice}',
                                                size: fontSize,
                                                fw: FontWeight.w500),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Container(
                                      height: contSize,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.withOpacity(.5),
                                        border: Border.all(
                                            color: Colors.black26, width: 1),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            ReusableText(
                                                text: 'Net Price',
                                                size: fontSize,
                                                fw: FontWeight.w500),
                                            ReusableText(
                                                text:
                                                    '${numberFormat.format(ntpresult)}',
                                                size: fontSize,
                                                fw: FontWeight.w500),
                                          ],
                                        ),
                                      ),
                                    ),

                                    Container(
                                      height: contSize,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.black26, width: 1),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6.0),
                                        child: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          children: [
                                            ReusableText(
                                                text: 'GST',
                                                size: fontSize,
                                                fw: FontWeight.w500),
                                            ReusableText(
                                                text: '${numberFormat.format(data.purchaseOrders.first.properties.gst)}',
                                                // '${data.purchaseOrders.first.properties.currency}   ${data.purchaseOrders.first.items.first.properties.netPrice}',
                                                size: fontSize,
                                                fw: FontWeight.w500),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Container(
                                      height: contSize,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.black26, width: 1),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6.0),
                                        child: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          children: [
                                            ReusableText(
                                                text: 'Transport Charges',
                                                size: fontSize,
                                                fw: FontWeight.w500),
                                            ReusableText(
                                                text: '${numberFormat.format(data.purchaseOrders.first.properties.trnasport)}',
                                                // '${data.purchaseOrders.first.properties.currency}   ${data.purchaseOrders.first.items.first.properties.netPrice}',
                                                size: fontSize,
                                                fw: FontWeight.w500),
                                          ],
                                        ),
                                      ),
                                    ),

                                    Container(
                                      height: contSize,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.black26, width: 1),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6.0),
                                        child: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          children: [
                                            ReusableText(
                                                text: 'Discount',
                                                size: fontSize,
                                                fw: FontWeight.w500),
                                            ReusableText(
                                                text: '${numberFormat.format(data.purchaseOrders.first.properties.discount2)}',
                                                // '${data.purchaseOrders.first.properties.currency}   ${data.purchaseOrders.first.items.first.properties.netPrice}',
                                                size: fontSize,
                                                fw: FontWeight.w500),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Container(
                                      height: contSize,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.withOpacity(.5),
                                        border: Border.all(
                                            color: Colors.black26, width: 1),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            ReusableText(
                                                text: 'Total',
                                                size: fontSize,
                                                fw: FontWeight.w500),
                                            ReusableText(
                                                text:
                                                    '${data.purchaseOrders.first.properties.currency}   ${numberFormat.format(totalResult)}',
                                                size: fontSize,
                                                fw: FontWeight.w500),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Container(
                                      height: contSize,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.black26, width: 1),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6.0),
                                        child: Row(
                                          children: [
                                            ReusableText(
                                                text: 'Amount in words :',
                                                size: fontSize,
                                                fw: FontWeight.w500),
                                            Expanded(
                                              child: ReusableText(
                                                  text:
                                                      ' ${amountInWords.toUpperCase()} $currencyLabel.',
                                                  size: fontSize,
                                                  fw: FontWeight.w500),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Container(
                                      height: contSize,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.withOpacity(.5),
                                        border: Border.all(
                                            color: Colors.black26, width: 1),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6.0),
                                        child: ReusableText(
                                            text: 'Terms and Conditions',
                                            size: fontSize,
                                            fw: FontWeight.w500),
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
                        onTap: () async{

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
                            await services.purchaseOrderApproval(
                                '0001', widget.wid.toString(), commentController.text);
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => POApprovals()));

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
