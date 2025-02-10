import 'dart:convert';
import 'package:ACM/constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import '../../models/filter_request_model.dart';
import '../../models/update_password_model.dart';
import '../../views/Dashboard.dart';

class AuthHelper {

  bool isLoading = false;
  Future<void> updatePassword(UpdatePassModel model) async {
    const String apiUsername = 'mobile';
    const String apiPassword = 'pakistan@123\$';
    // const String apiUsername = 'ABAPDEV';
    // const String apiPassword =
    //     'pakistan';
    final storage = new FlutterSecureStorage();
    String sessionID = await storage.read(key: 'SessionPAD_ID') ?? '';
    String token = await storage.read(key: 'csrfToken') ?? '';
    String userName = await storage.read(key: 'userName') ?? '';

    String user1 = 'mobile';
    String pass1 = 'pakistan@123\$';

    String newPass = model.newPassword;
    String cfmPass = model.confPassword;
    print('Token $token');
    print('Session $sessionID');
    final String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$apiUsername:$apiPassword'));

    isLoading = true;

    var headers = {
      'Content-Type': 'application/xml',
      'Authorization': basicAuth,
      'x-csrf-token': token,
      'Cookie': 'SAP_SESSIONID_PAP_800=$sessionID;'
    };

    var body = '''
  <?xml version="1.0" encoding="utf-8"?>
  <entry xml:base="http://paldev.volta.com.pk:8100/sap/opu/odata/sap/ZXPL_MOBILE_API_SRV/" xmlns="http://www.w3.org/2005/Atom" xmlns:m="http://schemas.microsoft.com/ado/2007/08/dataservices/metadata" xmlns:d="http://schemas.microsoft.com/ado/2007/08/dataservices">
    <id>http:</id>
    <title type="text">LoginSet(ImPassword='',ImUserName='')</title>
    <updated>2024-06-08T05:26:35Z</updated>
    <category term="ZXPL_MOBILE_API_SRV.Login_call" scheme="http://schemas.microsoft.com/ado/2007/08/dataservices/scheme"/>
    <link href="LoginSet(ImPassword='',ImUserName='')" rel="self" title="Login_call"/>
    <content type="application/xml">
      <m:properties>
        <d:Username>$userName</d:Username>
        <d:NewPassword>$newPass</d:NewPassword>
        <d:ConfPassword>$cfmPass</d:ConfPassword>
        <d:Status/>
      </m:properties>
    </content>
  </entry>''';

   var response = await http.put(
       Uri.parse(
           "$basUrl/LoginSet(ImUserName='${user1}',ImPassword='${pass1}')"),
     headers: headers,
     body: body,

   );

    print(body);
    print(response.body);
    print(response.statusCode);
    print("tOKEN ${response.headers['x-csrf-token']}");
    isLoading = false;
    if (response.statusCode == 204) {

      print("tOKEN ${response.headers['x-csrf-token']}");
      Get.offAll(()=>Dashboard(),
        transition: Transition.rightToLeft,
        duration: Duration(seconds: 2)
      );

    }
    else {
      isLoading = false;
      print(response.reasonPhrase);
    }

  }


  Future<Auth?> filtersRequest() async {
    final storage = new FlutterSecureStorage();
    String sessionID = await storage.read(key: 'SessionPAD_ID') ?? '';
    String userName = await storage.read(key: 'userName') ?? '';

    const String apiUsername = 'mobile';
    const String apiPassword = 'pakistan@123\$';
    final String basicAuth = 'Basic ' + base64Encode(utf8.encode('$apiUsername:$apiPassword'));

    var headers = {
      'Content-Type': 'application/xml',
      'Authorization': basicAuth,
      'Cookie': 'SAP_SESSIONID_PAP_800=$sessionID;'
    };

    final response = await http.get(
      Uri.parse('$basUrl/AuthSet?\$filter=Username%20eq%20%27$userName%27'),
      headers: headers,
    );

    print('Filter code ${response.statusCode}');
    print("Filter body ${response.body}");

    if (response.statusCode == 200) {
      try {
        final document = XmlDocument.parse(response.body);
        final entries = document.findAllElements('entry');

        if (entries.isNotEmpty) {
          final entry = entries.first;
          final content = entry.findElements('content').first;
          final properties = content.findElements('m:properties').first;
          print(properties);

          return Auth.fromXml(properties);
        } else {
          throw Exception('No entry elements found in the response');
        }
      } catch (e) {
        throw Exception('Failed to parse auth data: $e');
      }
    } else {
      throw Exception('Failed to load auth data, status code: ${response.statusCode}');
    }
  }
}

