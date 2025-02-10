import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ACM/controller/table_controller.dart';
import 'package:ACM/services/helper/request_services.dart';
import 'package:ACM/views/pr_approval_lsit_screen.dart';
import 'package:ACM/views/tablees/widgets/button_widget.dart';
import '../../Widgets/reusable_text_widget.dart';
import '../../controller/auth_controller.dart';
import '../../models/pr_table_model.dart';

class PRApprovalDetails extends StatefulWidget {
  final String appBarTitle;
  final String? pr;
  final String? wid;
  final String? currency;

  const PRApprovalDetails(
      {Key? key, required this.appBarTitle, this.pr, this.wid, this.currency})
      : super(key: key);

  @override
  State<PRApprovalDetails> createState() => _PRApprovalDetailsState();
}

class _PRApprovalDetailsState extends State<PRApprovalDetails> {
  RequestServices services = RequestServices();
  TextEditingController commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final controllers = Get.put(TableController());
  Future<void> _showMyDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button to close
      builder: (BuildContext context) {
        return AlertDialog(
          icon: const Icon(Icons.warning_rounded,color: Colors.red,size: 46,),
          title: const ReusableText(
              text: 'Purchase Request Rejected!',
              size: 20,
              fw: FontWeight.w500),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[

                const ReusableText(
                    text:
                    'Please add your remarks for rejection.',
                    size: 14,
                    fw: FontWeight.w400),
                const SizedBox(height: 6,),
                TextFormField(
                  controller: commentController,
                  focusNode: _commentFocusNode,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    enabledBorder:
                    OutlineInputBorder(borderSide: BorderSide(width: 1)),
                    focusedBorder: OutlineInputBorder(),
                    hintText: 'Type your remarks...',
                  ),
                  onChanged: (text) {
                    // Handle text changes if needed
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[

            TextButton(
              child:
              const ReusableText(text: 'Cancel', size: 16, fw: FontWeight.bold),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const ReusableText(
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
                    await services.purchaseRequestApproval(
                        '0002', widget.wid.toString(), commentController.text);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) =>  const PRApprovals()),
                    );

                  } catch (e) {
                  } finally {

                    setState(() {
                      controllers.rejected = false;
                    });
                  }
                } else {
                  Get.snackbar('Fill the Field!', 'Please fill your field to reject!',
                  backgroundColor: Colors.red, colorText: Colors.white);
                }



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

    services.fetchPRTableData(widget.pr.toString());
  }

  @override
  Widget build(BuildContext context) {
    AuthController controller = AuthController();
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double defaultFontSize = 7.0;
    double fontSize =
        screenWidth < 500 ? defaultFontSize : defaultFontSize * 1.8;

    bool isLoading = false;

    String currencyLabel = widget.currency == 'USD' ? 'DOLLARS' : 'RUPEES';
    return WillPopScope(
      onWillPop: () async {
        // Returning false to disable the back button
        return false;
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: const Color.fromARGB(255, 241, 240, 240),
        appBar: AppBar(
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: Image.asset('assets/logo.jpg', width: 46, height: 46),
            ),
          ],
          backgroundColor: Colors.white,
          title: Text(
            widget.pr.toString(),
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Color.fromARGB(221, 37, 37, 37),
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
                  child: FutureBuilder<PurchaseRequestTable>(
                    future: services.fetchPRTableData(widget.pr.toString()),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text('An error occurred: ${snapshot.error}'),
                        );
                      } else if (!snapshot.hasData) {
                        return const Center(
                          child: Text('No data available'),
                        );
                      } else {
                        final data = snapshot.data!;

                        if (data.purchaseRequests.isEmpty ||
                            data.purchaseRequests.first.items.isEmpty) {
                          return const Center(
                            child: Text('No items available'),
                          );
                        }
                        // print('data.po ${data.items.first.po}');
                        final dataformat = DateFormat('dd-mm-yyyy');
                        double defaultContSize = 16.0;
                        double contSize = screenWidth < 500
                            ? defaultContSize
                            : defaultContSize * 1.3;

                        final double amount = data.purchaseRequests.first.properties.valuationPrice;
// Assuming 'data' is your object containing purchaseRequests
                        final totalValue = data.purchaseRequests
                            .fold<double>(0.0, (sum, request) {
                          return sum + request.items.fold<double>(0.0, (itemSum, item) {
                            return itemSum + item.properties.valuationPrice;
                          });
                        });


                        final String amountInWords =
                            controller.numberToWords(data.purchaseRequests.first.properties.valuationPrice.toInt());

                        final numberFormat = NumberFormat('#,##0.00', 'en_US');// Define the format
                        final amt = numberFormat.format(amount);
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    Table(
                                      columnWidths: const {
                                        0: FlexColumnWidth(
                                            4.5), // Adjust the width of the first column
                                        1: FlexColumnWidth(
                                            4.5), // Adjust the width of the second column
                                        2: FlexColumnWidth(
                                            3.5), // Adjust the width of the third column
                                        3: FlexColumnWidth(
                                            4.5), // Adjust the width of the fourth column
                                      },
                                      children: [

                                        TableRow(
                                          children: [
                                            const TableCell(
                                              child: Text(
                                                'Purchase Org:',
                                                style: TextStyle(
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                            TableCell(
                                              child: Text(
                                                data.purchaseRequests.first
                                                    .properties.purOrg,
                                                style: const TextStyle(fontSize: 9),
                                              ),
                                            ),
                                            const TableCell(
                                              child: Text(
                                                'Purchase Group:',
                                                style: TextStyle(
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                            TableCell(
                                              child: Text(
                                                data.purchaseRequests.first
                                                    .properties.purGrp,
                                                style: const TextStyle(fontSize: 9),
                                              ),
                                            ),
                                          ],
                                        ),
                                        TableRow(
                                          children: [

                                            const TableCell(
                                              child: Text(
                                                'Order Date:',
                                                style: TextStyle(
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                            TableCell(
                                              child: Text(
                                                data
                                                    .purchaseRequests
                                                    .first
                                                    .properties
                                                    .docDate.toString(),
                                                style: const TextStyle(fontSize: 9),
                                              ),
                                            ),
                                            const TableCell(
                                              child: Text(
                                                '',
                                                style: TextStyle(
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                            const TableCell(
                                              child: Text(
                                                '',
                                                style: TextStyle(fontSize: 9),
                                              ),
                                            ),
                                          ],
                                        ),


                                        TableRow(
                                          children: [
                                            const TableCell(
                                              child: Text(
                                                'Currency:',
                                                style: TextStyle(
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                            TableCell(
                                              child: Text(
                                                widget.currency.toString(),
                                                style: const TextStyle(fontSize: 9),
                                              ),
                                            ),
                                            const TableCell(
                                              child: Text(
                                                'Amount',
                                                style: TextStyle(
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                            TableCell(
                                              child: Text(
                                                amt,
                                                style: const TextStyle(fontSize: 9),
                                              ),
                                            ),
                                          ],
                                        ), TableRow(
                                          children: [
                                            const TableCell(
                                              child: Text(
                                                'Header Text:',
                                                style: TextStyle(
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                            TableCell(
                                              child: Text(
                                                data.purchaseRequests.first.properties.htext,
                                                style: const TextStyle(fontSize: 9),
                                              ),
                                            ),
                                            const TableCell(
                                              child: Text(
                                                '',
                                                style: TextStyle(
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                            TableCell(
                                              child: Text(
                                                '',
                                                style: const TextStyle(fontSize: 9),
                                              ),
                                            ),
                                          ],
                                        ),

                                      ],
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(top: 20),
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.vertical,
                                        child: Table(
                                            columnWidths: const {
                                              0: FlexColumnWidth(0.3),
                                              1: FlexColumnWidth(0.4),
                                              2: FlexColumnWidth(0.4),
                                              3: FlexColumnWidth(0.5),
                                              4: FlexColumnWidth(0.4),
                                              5: FlexColumnWidth(0.3),
                                              6: FlexColumnWidth(0.4),
                                              7: FlexColumnWidth(0.6),
                                              8: FlexColumnWidth(0.4),
                                            },
                                            defaultColumnWidth: const FlexColumnWidth(),
                                            border: TableBorder.all(
                                              color: Colors.black45,
                                              style: BorderStyle.solid,
                                              width: 1,
                                            ),
                                            children: [
                                              TableRow(
                                                decoration: const BoxDecoration(
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
                                                  buildTableCell('Quantity',
                                                      fontSize, FontWeight.bold),

                                                  buildTableCell('UOM', fontSize,
                                                      FontWeight.bold),
                                                  buildTableCell('Price Unit',
                                                      fontSize, FontWeight.bold),
                                                  buildTableCell(
                                                      'Valuation Price',
                                                      fontSize,
                                                      FontWeight.bold),
                                                  buildTableCell('C.Stock',
                                                      fontSize, FontWeight.bold),
                                                ],
                                              ),
                                            ]),
                                      ),
                                    ),
                                    SingleChildScrollView(
                                      scrollDirection: Axis.vertical,
                                      child: Table(
                                        columnWidths: const {
                                          0: FlexColumnWidth(0.3),
                                          1: FlexColumnWidth(0.4),
                                          2: FlexColumnWidth(0.4),
                                          3: FlexColumnWidth(0.5),
                                          4: FlexColumnWidth(0.4),
                                          5: FlexColumnWidth(0.3),
                                          6: FlexColumnWidth(0.4),
                                          7: FlexColumnWidth(0.6),
                                          8: FlexColumnWidth(0.4),
                                        },
                                        defaultColumnWidth: const FlexColumnWidth(),
                                        border: TableBorder.all(
                                          color: Colors.grey,
                                          style: BorderStyle.solid,
                                          width: 1,
                                        ),
                                        children: List.generate(
                                            data.purchaseRequests.first.items
                                                .length, (index) {
                                          final datas = data.purchaseRequests
                                              .first.items[index];
                                          final dateform = DateFormat('dd-mm-yy');
                                          return TableRow(
                                            children: [
                                              buildTableCell(
                                                  int.parse(datas.properties.prItem).toString(),
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
                                                  datas.properties.prQty
                                                      .toString(),
                                                  fontSize,
                                                  FontWeight.normal),

                                              buildTableCell(datas.properties.uom,
                                                  fontSize, FontWeight.normal),
                                              buildTableCell(
                                                  datas.properties.priceUnit,
                                                  fontSize,
                                                  FontWeight.normal),
                                              buildTableCell(numberFormat.format(datas.properties.valuationPrice),
                                                  fontSize, FontWeight.normal),
                                              buildTableCell(
                                                  datas.properties.stock
                                                      .toString(),
                                                  fontSize,
                                                  FontWeight.normal),
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
                                                text: 'Total',
                                                size: fontSize,
                                                fw: FontWeight.w500),
                                            ReusableText(
                                                text: numberFormat.format(totalValue),
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
                          _showMyDialog(context);
                          /*if (commentController.text.isNotEmpty) {
                            setState(() {
                              controllers.rejected = true;
                            });

                            try {
                              await services.purchaseRequestApproval(
                                  '0002', widget.wid.toString());
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const PRApprovals()),
                              );

                            } catch (e) {
                              print('API call failed: $e');
                            } finally {

                              setState(() {
                                controllers.rejected = false;
                              });
                            }
                          } else {
                            _showMyDialog(context);
                          }*/
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
                            await services.purchaseRequestApproval(
                                '0001', widget.wid.toString(), commentController.text);
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) =>  const PRApprovals()),
                            );

                            // If the API call was successful, navigate back
                          } catch (e) {
                            // Handle any errors that occur during the API call
                          } finally {
                            // Update the state regardless of success or failure

                            setState(() {
                              controllers.rejected = false;
                            });
                          }
                          //Get.back();
                        },
                        boxColor: Colors.green.shade100,
                        iconColor: const Color.fromARGB(255, 4, 139, 8),
                        icon: Icons.task_alt_outlined,
                        textColor: const Color.fromARGB(255, 4, 139, 8),
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
