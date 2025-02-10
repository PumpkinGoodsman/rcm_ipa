import 'dart:convert';

import 'package:ACM/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:http/http.dart'as http;
import 'package:ACM/controller/table_controller.dart';
import 'package:ACM/models/po_table_model.dart';
import 'package:ACM/models/pr_list_model.dart';
import 'package:xml/xml.dart';
import 'package:xml/xml.dart' as xml;
import '../../models/po_list_model.dart';
import '../../models/pr_table_model.dart';
import '../../models/reservation_list_model.dart';
import '../../models/reservation_table_model.dart';
class RequestServices {


  final controller =  Get.put(TableController());
  Future<PurchaseOrderSet> fetchPurchaseOrders() async {
    const String apiUsername = 'mobile';
    const String apiPassword = 'pakistan@123\$';
    final storage = new FlutterSecureStorage();
    String sessionID = await storage.read(key: 'SessionPAD_ID') ?? '';
    String userId = await storage.read(key: 'sapUserId') ?? '';
    print('SapUser id $userId');
    final String basicAuth = 'Basic ' + base64Encode(utf8.encode('$apiUsername:$apiPassword'));

    var headers = {
      'Content-Type': 'application/xml',
      'Authorization': basicAuth,
      'Cookie': 'SAP_SESSIONID_PAP_800=$sessionID;'
    };

    final response = await http.get(
      Uri.parse('$basUrl/PurchaseOrderSet?\$filter=USER_ID%20eq%20%27$userId%27'),
      headers: headers,
    );

    print(response.statusCode);
    print(response.body);

    if (response.statusCode == 200) {
      final document = XmlDocument.parse(response.body);
      return PurchaseOrderSet.fromXml(document.rootElement);
    } else {
      throw Exception('Failed to load purchase orders');
    }
  }

  Future<PurchaseOrderTable> fetchPOTableData(String po) async {
    const String apiUsername = 'mobile';
    const String apiPassword = 'pakistan@123\$';

    final storage = new FlutterSecureStorage();
    String sessionID = await storage.read(key: 'SessionPAD_ID') ?? '';

    final String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$apiUsername:$apiPassword'));

    var headers = {
      'Content-Type': 'application/xml',
      'Authorization': basicAuth,
      'Cookie': 'SAP_SESSIONID_PAP_800=$sessionID;'
    };

    try {
      final response = await http.get(
        Uri.parse(
            '$basUrl/PurchaseOrderSet?\$expand=PoNav&\$filter=PO%20eq%20%27$po%27'),
        headers: headers,
      );

      print('Table ${response.statusCode}');
      print(response.body);

      if (response.statusCode == 200) {
        final document = response.body;
        return PurchaseOrderTable.fromXml(document);
      } else {
        throw Exception('Failed to load purchase orders. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching data: $e');
      throw Exception('Failed to load purchase orders: $e');
    }
  }

  Future<PurchaseRequestSet> fetchPurchaseRequest() async {
    const String apiUsername = 'mobile';
    const String apiPassword = 'pakistan@123\$';
    final storage = new FlutterSecureStorage();
    String sessionID = await storage.read(key: 'SessionPAD_ID') ?? '';
    String userId = await storage.read(key: 'sapUserId') ?? '';
    print('Id $userId');

    final String basicAuth = 'Basic ' + base64Encode(utf8.encode('$apiUsername:$apiPassword'));

    var headers = {
      'Content-Type': 'application/xml',
      'Authorization': basicAuth,
      'Cookie': 'SAP_SESSIONID_PAP_800=$sessionID;'
    };

    final response = await http.get(
      Uri.parse('$basUrl/Purchase_RequestSet?\$filter=USER_ID%20eq%20%27$userId%27 '),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final document = XmlDocument.parse(response.body);
      return PurchaseRequestSet.fromXml(document.rootElement);
    } else {
      throw Exception('Failed to load purchase orders');
    }
  }
  Future<PurchaseRequestTable> fetchPRTableData(String pr) async {
    const String apiUsername = 'mobile';
    const String apiPassword = 'pakistan@123\$';

    final storage = new FlutterSecureStorage();
    String sessionID = await storage.read(key: 'SessionPAD_ID') ?? '';

    final String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$apiUsername:$apiPassword'));

    var headers = {
      'Content-Type': 'application/xml',
      'Authorization': basicAuth,
      'Cookie': 'SAP_SESSIONID_PAP_800=$sessionID;'
    };

    try {
      final response = await http.get(
        Uri.parse(
            '$basUrl/Purchase_RequestSet?\$expand=PURtoItem&\$filter=PR%20eq%20%27$pr%27'),
        headers: headers,
      );

      print('Table ${response.statusCode}');
      print(response.body);

      if (response.statusCode == 200) {
        final document = response.body;
        return PurchaseRequestTable.fromXml(document);
      } else {
        throw Exception('Failed to load purchase orders. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching data: $e');
      throw Exception('Failed to load purchase orders: $e');
    }
  }

  Future<ReservationSet> fetchReservationRequest() async {
    const String apiUsername = 'mobile';
    const String apiPassword = 'pakistan@123\$';

    final storage = new FlutterSecureStorage();
    String sessionID = await storage.read(key: 'SessionPAD_ID') ?? '';
    String userId = await storage.read(key: 'sapUserId') ?? '';


    final String basicAuth = 'Basic ' + base64Encode(utf8.encode('$apiUsername:$apiPassword'));

    var headers = {
      'Content-Type': 'application/xml',
      'Authorization': basicAuth,
      'Cookie': 'SAP_SESSIONID_PAP_800=$sessionID;'
    };

    final response = await http.get(
      Uri.parse('$basUrl/ReservationSet?\$filter=USER_ID%20eq%20%27$userId%27'),
      headers: headers,
    );

    print(response.statusCode);
    print("Reservation List Body ${response.body}");

    if (response.statusCode == 200) {
      final document = xml.XmlDocument.parse(response.body);
      return ReservationSet.fromXml(document);
    } else {
      throw Exception('Failed to load purchase orders');
    }
  }

  Future<ReservationTable> fetchReservationTableData(String resNo) async {
    const String apiUsername = 'mobile';
    const String apiPassword = 'pakistan@123\$';

    final storage = new FlutterSecureStorage();
    String sessionID = await storage.read(key: 'SessionPAD_ID') ?? '';

    final String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$apiUsername:$apiPassword'));

    var headers = {
      'Content-Type': 'application/xml',
      'Authorization': basicAuth,
      'Cookie': 'SAP_SESSIONID_PAP_800=$sessionID;'
    };

    try {
      final response = await http.get(
        Uri.parse(
            '$basUrl/ReservationSet?\$expand=RESTOITEMNAV&\$filter=RESNO%20eq%20%27$resNo%27'),
        headers: headers,
      );

      print('Table ${response.statusCode}');
      print(response.body);

      if (response.statusCode == 200) {
        final document = response.body;
        return ReservationTable.fromXml(document);
      } else {
        throw Exception('Failed to load purchase orders. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching data: $e');
      throw Exception('Failed to load purchase orders: $e');
    }
  }

  // RESERVATION APPROVAL

  Future<void> purchaseOrderApproval(String equ,String wid,String remarks) async {
    const String apiUsername = 'mobile';
    const String apiPassword = 'pakistan@123\$';
    final storage = new FlutterSecureStorage();
    String token = await storage.read(key: 'csrfToken') ?? '';
    String userId = await storage.read(key: 'sapUserId') ?? '';

    if(equ == '0001'){
      controller.approval = true;

    }else{
      controller.rejected = true;
    }
    print('Token $token');
    final String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$apiUsername:$apiPassword'));


    var headers = {
      'Content-Type': 'application/xml',
      'Authorization': basicAuth,
      'x-csrf-token': token,
    };
    var response = await http.get(
      Uri.parse(
          "$basUrl/PurchaseOrderSet?\$filter=USER_ID eq '$userId' and WI_ID eq '>$wid' and DEC_KEY eq '$equ'and Remarks eq '$remarks'"),
      headers: headers,

    );


    print(controller.isApproval);
    print(response.body);
    print(response.statusCode);
    if(equ == '0001'){
      controller.approval = false;

    }else{
      controller.rejected = false;
    }

    if (response.statusCode == 200) {

      if(equ == '0001'){
        Get.snackbar('Successfully Approval',"Your Purchase Order successfully approval!",
        backgroundColor: Colors.green,
        colorText: Colors.white
        );
        print('Successfully Approval');
      }else{
        Get.snackbar('Purchase Order Rejected',"Your Purchase Order rejected!",
            backgroundColor: Colors.red,
            colorText: Colors.white
        );
        print('Successfully Rejected');
      }
    }
    else {
      if(equ == '0001'){
        controller.approval = false;

      }else{
        controller.rejected = false;
      }
      print(response.reasonPhrase);
    }

  }

  Future<void> purchaseRequestApproval(String equ,String wid,String remarks) async {
    const String apiUsername = 'mobile';
    const String apiPassword = 'pakistan@123\$';
    final storage = new FlutterSecureStorage();
    String token = await storage.read(key: 'csrfToken') ?? '';
    String userId = await storage.read(key: 'sapUserId') ?? '';

    if(equ == '0001'){
      controller.approval = true;

    }else{
      controller.rejected = true;
    }
    print('Token $token');
    final String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$apiUsername:$apiPassword'));


    var headers = {
      'Content-Type': 'application/xml',
      'Authorization': basicAuth,
      'x-csrf-token': token,
    };
    var response = await http.get(
      Uri.parse(
          "$basUrl/Purchase_RequestSet?\$filter=USER_ID eq '$userId' and WI_ID eq '>$wid' and DEC_KEY eq '$equ'and Remarks eq '$remarks'"),
      headers: headers,

    );


    print(response.body);
    print(response.statusCode);
    if(equ == '0001'){
      controller.approval = false;

    }else{
      controller.rejected = false;

    }

    if (response.statusCode == 200) {
      if(equ == '0001'){
        Get.snackbar('Successfully Approval',"Your Purchase Request successfully approval!",
        backgroundColor: Colors.green,
        colorText: Colors.white
        );
        print('Successfully Approval');
      }else{
        Get.snackbar('Purchase Request Rejected',"Your Purchase Request rejected!",
            backgroundColor: Colors.red,
            colorText: Colors.white
        );
        print('Successfully Rejected');
      }
    }
    else {
      if(equ == '0001'){
        controller.approval = false;

      }else{
        controller.rejected = false;

      }
      print(response.reasonPhrase);
    }

  }


  Future<void> reservationApproval(String equ,String wid,String remarks) async {
    const String apiUsername = 'mobile';
    const String apiPassword = 'pakistan@123\$';
    final storage = new FlutterSecureStorage();
    String token = await storage.read(key: 'csrfToken') ?? '';
    String userId = await storage.read(key: 'sapUserId') ?? '';

    if(equ == '0001'){
      controller.approval = true;

    }else{
      controller.rejected = true;
    }
    print('Token $token');
    final String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$apiUsername:$apiPassword'));


    var headers = {
      'Content-Type': 'application/xml',
      'Authorization': basicAuth,
      'x-csrf-token': token,
    };
    var response = await http.get(
      Uri.parse(
          "$basUrl/ReservationSet?\$filter=USER_ID eq '$userId' and WI_ID eq '>$wid' and DEC_KEY eq '$equ'and Remarks eq '$remarks'"),
      headers: headers,

    );

    print(response.body);
    print(response.statusCode);

    if(equ == '0001'){
      controller.approval = false;

    }else{
      controller.rejected = false;
    }
    if (response.statusCode == 200) {

      if(equ == '0001'){
        Get.snackbar('Successfully Approval',"Your reservation successfully approval!",
        backgroundColor: Colors.green,
        colorText: Colors.white
        );
        print('Successfully Approval');
      }else{
        Get.snackbar('Reservation Rejected',"Your reservation rejected!",
            backgroundColor: Colors.red,
            colorText: Colors.white
        );
        print('Successfully Rejected');
      }

    }
    else {

      if(equ == '0001'){
        controller.approval = false;

      }else{
        controller.rejected = false;
      }
      print(response.reasonPhrase);
    }

  }



}