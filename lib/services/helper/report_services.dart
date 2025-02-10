import 'dart:convert';
import 'package:ACM/constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:ACM/models/company_code_model.dart';
import 'package:ACM/models/customer_summary_model.dart';
import 'package:ACM/models/supply_summary_model.dart';
import 'package:xml/xml.dart';



import '../../models/aging_summary_model.dart';
import '../../models/report_list_model.dart';

class ReportServices{


  Future<SaleOfficeModel> reportListData() async {
    const String apiUsername = 'mobile';
    const String apiPassword = 'pakistan@123\$';
    final storage = new FlutterSecureStorage();
    String token = await storage.read(key: 'csrfToken') ?? '';
    String userName = await storage.read(key: 'userName') ?? '';
    print('User Name $userName');

    print('Token $token');
    final String basicAuth = 'Basic ' + base64Encode(utf8.encode('$apiUsername:$apiPassword'));

    var headers = {
      'Content-Type': 'application/xml',
      'Authorization': basicAuth,
    };

    var response = await http.get(
      Uri.parse("$basUrl/Sale_Office?\$filter=USER_ID%20eq%20%27$userName%27"),
      headers: headers,
    );

    print("Report List Data ${response.body}");
    print(response.statusCode);

    if (response.statusCode == 200) {
      final document = XmlDocument.parse(response.body);
      return SaleOfficeModel.fromXml(document);
    } else {
      throw Exception('Failed to load sale offices');
    }
  }

  Future<CompanyCodeModel> companyCode() async {
    const String apiUsername = 'mobile';
    const String apiPassword = 'pakistan@123\$';
    final storage = new FlutterSecureStorage();
    String token = await storage.read(key: 'csrfToken') ?? '';
    String userName = await storage.read(key: 'userName') ?? '';

    print('Token $token');
    final String basicAuth = 'Basic ' + base64Encode(utf8.encode('$apiUsername:$apiPassword'));

    var headers = {
      'Content-Type': 'application/xml',
      'Authorization': basicAuth,
    };

    var response = await http.get(
      Uri.parse("$basUrl/Company_CodeSet?\$filter=USER_ID%20eq%20%27$userName%27"),
      headers: headers,
    );

    print("Report List Data ${response.body}");
    print(response.statusCode);

    if (response.statusCode == 200) {
      final document = XmlDocument.parse(response.body);
      return CompanyCodeModel.fromXml(document);
    } else {
      throw Exception('Failed to load sale offices');
    }
  }


  Future<AgingSummaryModel> reportAgingSummary(String value,String hd) async {
    const String apiUsername = 'mobile';
    const String apiPassword = 'pakistan@123\$';
    final storage = new FlutterSecureStorage();
    String token = await storage.read(key: 'csrfToken') ?? '';
    String userName = await storage.read(key: 'userName') ?? '';

    print('Token $token');
    final String basicAuth = 'Basic ' + base64Encode(utf8.encode('$apiUsername:$apiPassword'));

    var headers = {
      'Content-Type': 'application/xml',
      'Authorization': basicAuth,
    };

    var response = await http.get(
      Uri.parse("$basUrl/Aging_Summary?\$filter=USER_ID%20eq%20%27$userName%27%20and%20S_VKBUR%20eq%20%27$value%27%20and%20BUKRS%20eq%20%27$hd%27"),
      headers: headers,
    );

    print("Report Summary Aging ${response.body}");
    print("Report Summary Aging Value $value");
    print("Report Summary Company Code $hd");
    print(response.statusCode);

    if (response.statusCode == 200) {
      final document = XmlDocument.parse(response.body);
      final rootElement = document.rootElement; // Get the root element
      return AgingSummaryModel.fromXml(rootElement);
    } else {
      throw Exception('Failed to load sale offices');
    }
  }


  Future<SupplySummaryModel> supplySummary(String value, String month,String hd) async {
    const String apiUsername = 'mobile';
    const String apiPassword = 'pakistan@123\$';
    final storage = new FlutterSecureStorage();
    String token = await storage.read(key: 'csrfToken') ?? '';
    String userName = await storage.read(key: 'userName') ?? '';

    print('Token $token');
    final String basicAuth = 'Basic ' + base64Encode(utf8.encode('$apiUsername:$apiPassword'));

    var headers = {
      'Content-Type': 'application/xml',
      'Authorization': basicAuth,
    };

    // Properly format and encode query parameters
    final String baseUrl = "http://paldev.volta.com.pk:8100/sap/opu/odata/sap/ZXPL_MOBILE_API_SRV/SUPPLY_SUMMARY";
    final String filter = "\$filter=USER_ID eq 'ZBASIT' AND S_VKBUR eq '1000,1200' and ZMON eq 'AUG'";
    final String encodedFilter = Uri.encodeQueryComponent(filter);
    final String url = "$baseUrl?$encodedFilter";

    var response = await http.get(
      Uri.parse('$basUrl/SUPPLY_SUMMARY?\$filter=USER_ID%20eq%20%27$userName%27%20and%20S_VKBUR%20eq%20%27$value%27%20and%20ZMON%20eq%20%27$month%27%20and%20BUKRS%20eq%20%27$hd%27'),
      headers: headers,
    );

    print("Supply Summary Aging ${response.body}");
    print("Supply Summary Aging Value $value");
    print(response.statusCode);

    if (response.statusCode == 200) {
      final document = XmlDocument.parse(response.body);
      final rootElement = document.rootElement;
      return SupplySummaryModel.fromXml(rootElement);
    } else {
      print("Error: ${response.body}");
      throw Exception('Failed to load supply summary');
    }
  }

  Future<CustomerSummaryModel> customerSummary(String value, String month,String hd) async {
    const String apiUsername = 'mobile';
    const String apiPassword = 'pakistan@123\$';
    final storage = new FlutterSecureStorage();
    String token = await storage.read(key: 'csrfToken') ?? '';
    String userName = await storage.read(key: 'userName') ?? '';

    print('Token $token');
    final String basicAuth = 'Basic ' + base64Encode(utf8.encode('$apiUsername:$apiPassword'));

    var headers = {
      'Content-Type': 'application/xml',
      'Authorization': basicAuth,
    };

    // Properly format and encode query parameters
    final String baseUrl = "http://paldev.volta.com.pk:8100/sap/opu/odata/sap/ZXPL_MOBILE_API_SRV/SUPPLY_SUMMARY";
    final String filter = "\$filter=USER_ID eq 'ZBASIT' AND S_VKBUR eq '1000,1200' and ZMON eq 'AUG'";
    final String encodedFilter = Uri.encodeQueryComponent(filter);
    final String url = "$baseUrl?$encodedFilter";

    var response = await http.get(
      Uri.parse('$basUrl/CUSTOMER_SUMMARY?\$filter=USER_ID%20eq%20%27$userName%27%20and%20S_VKBUR%20eq%20%27$value%27%20and%20ZMON%20eq%20%27$month%27%20and%20BUKRS%20eq%20%27$hd%27'),
      headers: headers,
    );

    print("Customer Summary Aging ${response.body}");
    print("Customer Summary Aging Value $value");
    print(response.statusCode);

    if (response.statusCode == 200) {
      final document = XmlDocument.parse(response.body);
      final rootElement = document.rootElement;
      return CustomerSummaryModel.fromXml(rootElement);
    } else {
      print("Error: ${response.body}");
      throw Exception('Failed to load supply summary');
    }
  }

}