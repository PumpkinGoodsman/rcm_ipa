import 'dart:convert';
import 'package:ACM/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import '../../models/dashboard_data_model.dart';
import '../../models/pal_acm_model.dart';

class DashboardAuth {
  List<ApprovalRequest> approvalRequests = [];

  Future<void> getDashboardData() async {
    const String apiUsername = 'mobile';
    const String apiPassword = 'pakistan@123\$';
    final storage = new FlutterSecureStorage();
    String userId = await storage.read(key: 'sapUserId') ?? '';
    String userName = await storage.read(key: 'userName') ?? '';
    final String basicAuth = 'Basic ' + base64Encode(utf8.encode('$apiUsername:$apiPassword'));

    var headers = {
      'Content-Type': 'application/xml',
      'Authorization': basicAuth,
      //'Cookie': 'SAP_SESSIONID_PAD_300=$sessionID;'
    };
    var response = await http.get(
      Uri.parse('$basUrl/Approval_RequestSet?\$filter=UserId%20eq%20%27$userId%27'),
      headers: headers,
    );

    print("Dashboard Data ${response.statusCode}");
   // print(response.body);

    if (response.statusCode == 200) {
      final document = XmlDocument.parse(response.body);
      final entries = document.findAllElements('entry');
      approvalRequests = entries.map((entry) {
        final content = entry.findElements('content').first;
        final properties = content.findElements('m:properties').first;
        return ApprovalRequest.fromXml(properties);
      }).toList();

      approvalRequests.forEach((request) {
       // print('WiId: ${request.wiId}, UserId: ${request.userId}, TypeId: ${request.typeId}, InstId: ${request.instId}');
       // print('Content Length for TypeId ${request.typeId}: ${request.getContentLength()}');
      });
    } else {
      print(response.reasonPhrase);
    }
  }

  Future<SalesProdData> getPalAcmData(BuildContext context) async {
    const String apiUsername = 'mobile';
    const String apiPassword = 'pakistan@123\$';
    final storage = new FlutterSecureStorage();
    String userName = await storage.read(key: 'userName') ?? '';
    final String basicAuth = 'Basic ' + base64Encode(utf8.encode('$apiUsername:$apiPassword'));

    var headers = {
      'Content-Type': 'application/xml',
      'Authorization': basicAuth,
    };
    var response = await http.get(
      Uri.parse('$basUrl/Sales_Prod_Data?\$filter=USER_ID%20eq%20%27$userName%27'),
      headers: headers,
    );
    print("Dashboard PAL ACM Data ${response.statusCode}");

    if (response.statusCode == 200) {
      final document = XmlDocument.parse(response.body);
      return SalesProdData.fromXml(document);
    } else {
      throw Exception('Failed to load data');
    }
  }


}
