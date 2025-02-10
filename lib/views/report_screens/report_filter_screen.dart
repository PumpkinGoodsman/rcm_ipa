import 'package:ACM/models/filter_request_model.dart';
import 'package:ACM/services/helper/auth_helper.dart';
import 'package:ACM/services/helper/dashBorad_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:googleapis/sourcerepo/v1.dart';
import 'package:intl/intl.dart';
import 'package:ACM/Widgets/reusable_text_widget.dart';
import 'package:ACM/models/company_code_model.dart';
import 'package:ACM/services/helper/report_services.dart';
import 'package:ACM/services/helper/request_services.dart';
import 'package:ACM/views/report_screens/customer_aging_group.dart';
import 'package:ACM/views/report_screens/customer_summary_screen.dart';
import 'package:ACM/views/report_screens/sunmmay_age_group.dart';
import 'package:ACM/views/report_screens/supply_group.dart';
import 'package:ACM/views/report_screens/supply_summary_screen.dart';
import 'package:ACM/views/report_screens/widgets/custom_dropdown.dart';
import 'package:ACM/views/report_screens/widgets/multiple_select.dart';

import '../../models/report_list_model.dart';
import 'aging_summary.dart';

class ReportFilterScreen extends StatefulWidget {
  const ReportFilterScreen({super.key});

  @override
  State<ReportFilterScreen> createState() => _ReportFilterScreenState();
}

class _ReportFilterScreenState extends State<ReportFilterScreen> {
  String? _selectedDropdownValue;
  String? _selectedmonth;
  List<String> _selectedSaleOffices = [];
  List<String> _selectedCC = [];
  List<SaleOfficeModel> saleOffices = [];
  List<CompanyCodeModel> companyCode = [];
  bool isLoading = true;

  ReportServices services = ReportServices();
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
  @override
  void initState() {
    super.initState();
    fetchSaleOffices();
    fetchCompanyCode();
    filterData();
  }



  void fetchSaleOffices() async {
    try {
      print("Fetching data...");
      SaleOfficeModel data = await services.reportListData();

      if (data.entries.isNotEmpty) {
        print("Data fetched: ${data.entries.first.vkbur}");
      } else {
        print("No data fetched.");
      }

      setState(() {
        saleOffices = [data];
        isLoading = false;
      });
    } catch (error, stackTrace) {
      print("Error fetching data: $error");
      print("Stack trace: $stackTrace");
      setState(() {
        isLoading = false;
      });
      Get.snackbar('Error', error.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void fetchCompanyCode() async {
    try {
      print("Fetching data...");
      CompanyCodeModel data = await services.companyCode();

      if (data.entries.isNotEmpty) {
        print("Data fetched: ${data.entries.first.burks}");
      } else {
        print("No data fetched.");
      }

      setState(() {
        companyCode = [data];
        isLoading = false;
      });
    } catch (error, stackTrace) {
      print("Error fetching data: $error");
      print("Stack trace: $stackTrace");
      setState(() {
        isLoading = false;
      });
      Get.snackbar('Error', error.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double defaultFontSize = 7.0;
    double fontSize = screenWidth < 500 ? defaultFontSize : defaultFontSize * 1.8;

    List<String> getReportItems() {
      List<String> items = [];

      // Check if auth is not null before accessing its properties
      if (auth != null) {
        if (auth!.rep1 == 'X') {
          items.add('Sales Summary');
        }
        if (auth!.rep2 == 'X') {
          items.add('Customer Summary');
        }
        if (auth!.rep3 == 'X') {
          items.add('Aging');
        }
        if (auth!.rep4 == 'X') {
          items.add('Current Report');
        }

      } else {
        // Handle the null case, e.g., log an error, show a message, etc.
        print('auth is null, cannot fetch report items.');
      }

      return items;
    }

    List<String> getMonthsList() {
      final now = DateTime.now();
      final formatter = DateFormat('MMM');

      List<String> months = [];
      for (int i = 3; i >= 0; i--) {
        final monthDate = DateTime(now.year, now.month - i, 1);
        months.add(formatter.format(monthDate).toUpperCase());
      }

      return months;
    }

    List<String> months = getMonthsList();

    List<String> saleOfficeItems = saleOffices
        .expand((office) => office.entries.map((entry) => entry.vkbur))
        .toSet()
        .toList();

    List<String> company = companyCode
        .expand((office) => office.entries.map((entry) => entry.burks))
        .toSet()
        .toList();

    String getDropdownText(String value) {
      switch (value) {
        case 'Customer Summary':
          return 'Customer Group';
        case 'Aging':
          return 'Aging Group';
        case 'Sales Summary':
          return 'Sales Group';

        default:
          return '';
      }
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: ReusableText(text: 'Reports', size: 16, fw: FontWeight.w500),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Image(image: AssetImage('assets/logo.jpg')),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 24),
              CustomDropdown(
                items: getReportItems(),
                value: _selectedDropdownValue,
                hintText: 'Select reports type',
                onChanged: (value) {
                  setState(() {
                    _selectedDropdownValue = value;
                  });
                },
              ),

              SizedBox(height: 12),
              _selectedDropdownValue == 'Sales Summary' || _selectedDropdownValue == 'Customer Summary'?
              CustomDropdown(
                items: months,
                value: _selectedmonth,
                hintText: 'Select your month',
                onChanged: (value) {
                  setState(() {
                    _selectedmonth = value;
                    print("Selected month: $_selectedmonth");
                  });
                },
              ) : SizedBox.shrink(),
              SizedBox(height: 12),
              _selectedDropdownValue != null ? isLoading
                  ? Center(child: CircularProgressIndicator())
                  : MultiSelectDropdown(
                items: saleOfficeItems,
                selectedItems: _selectedSaleOffices,
                hintText: 'Select Sale Office',
                onChanged: (selectedItems) {
                  setState(() {
                    _selectedSaleOffices = selectedItems.map((item) => item.split(' - ')[0]).toList();
                  });
                  print("Selected Sale Offices: ${_selectedSaleOffices.join(',')}");
                },
              ) : SizedBox.shrink(),

              SizedBox(height: 12),
              _selectedDropdownValue != null ? isLoading
                  ? Center(child: CircularProgressIndicator())
                  : MultiSelectDropdown(
                items: company,
                selectedItems: _selectedCC,
                hintText: 'Select Company Code',
                onChanged: (List<String> cc) {
                  setState(() {
                    _selectedCC = cc.map((item) => item.split(' - ')[0]).toList();
                  });
                  print("Selected Company Code: ${_selectedCC.join(',')}");
                },
              ) : SizedBox.shrink(),
              SizedBox(height: 24),
              Center(
                child: GestureDetector(
                  onTap: () {
                    if (_selectedDropdownValue != null) {
                      if(_selectedDropdownValue == 'Aging'){
                        Get.to(() => ReportScreen(
                          title: _selectedDropdownValue.toString(),
                          saleOffice: _selectedSaleOffices.join(',').toString(),
                          hd: _selectedCC.join(',').toString(),
                        ));
                      }else if(_selectedDropdownValue == 'Sales Summary'){
                        Get.to(() => SupplySummaryScreen(
                          hd: _selectedCC.join(',').toString(),
                          title: _selectedDropdownValue.toString(),
                          saleOffice: _selectedSaleOffices.join(',').toString(),
                          month: _selectedmonth,
                        ));
                      }else if(_selectedDropdownValue == 'Customer Summary'){
                        Get.to(() => CustomerSummaryScreen(
                          hd: _selectedCC.join(',').toString(),
                          title: _selectedDropdownValue.toString(),
                          saleOffice: _selectedSaleOffices.join(',').toString(),
                          month: _selectedmonth,
                        ));
                      }
                      else {
                        Get.snackbar('Execution Failed!', 'Please select a valid report type!',
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                      }
                    } else {
                      Get.snackbar('Execution Failed!', 'Please select a valid report type!',
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue.shade900,
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    padding: EdgeInsets.all(8),
                    alignment: Alignment.center,
                    margin: EdgeInsets.all(5),
                    height: 42,
                    width: double.infinity,
                    child: Text(
                      "Execute",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),SizedBox(height: 24),
              _selectedDropdownValue != null
              ?
              Center(
                child: GestureDetector(
                  onTap: () {
                    if (_selectedDropdownValue != null) {
                      if(_selectedDropdownValue == 'Aging'){
                        Get.to(() => SummaryAginGroup(
                          hd:_selectedCC.join(',').toString(),
                          title: _selectedDropdownValue.toString(),
                          saleForce: _selectedSaleOffices.join(',').toString(),
                        ));
                      }else if(_selectedDropdownValue == 'Customer Summary'){
                        Get.to(() => CustomerGroup(
                          hd: _selectedCC.join(',').toString(),
                          title: _selectedDropdownValue.toString(),
                          saleForce: _selectedSaleOffices.join(',').toString(),
                          months: _selectedmonth.toString(),
                        ));
                      }else if(_selectedDropdownValue == 'Sales Summary'){
                        Get.to(() => SupplyGroup(
                          hd: _selectedCC.join(',').toString(),
                          title: _selectedDropdownValue.toString(),
                          saleForce: _selectedSaleOffices.join(',').toString(),
                          months: _selectedmonth.toString(),
                        ));
                      }
                    } else {
                      Get.snackbar('Execution Failed!', 'Please select a valid report type!',
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue.shade900,
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    padding: EdgeInsets.all(8),
                    alignment: Alignment.center,
                    margin: EdgeInsets.all(5),
                    height: 42,
                    width: double.infinity,
                    child:  Text(
                      getDropdownText(_selectedDropdownValue.toString()),
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ) ,
                  ),
                ),
              ) : SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}
