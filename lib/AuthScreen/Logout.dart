import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:ACM/controller/auth_controller.dart';
import 'Login.dart';

class Logout extends StatefulWidget {
  const Logout({super.key});

  @override
  State<Logout> createState() => _LogoutState();
}

class _LogoutState extends State<Logout> {

   String value = '';

  userName()async{
    final storage = new FlutterSecureStorage();
    String userName = await storage.read(key: 'userName') ?? '';
   setState(() {
     value =  userName;
   });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    userName();
  }

  @override
  Widget build(BuildContext context) {

    final controller = Get.put(AuthController());
    return WillPopScope(
      onWillPop: () async {
        // Returning false to disable the back button
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: Image.asset('assets/logo.jpg', width: 46, height: 46),
            ),
          ],
          backgroundColor: Colors.white,
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
        body: Container(
          margin: EdgeInsets.fromLTRB(25, 30, 0, 20),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.account_circle_outlined,
                    color: Colors.blue.shade900,
                    size: 100,
                  ),
                  Column(
                    children: [
                      Container(
                        margin: EdgeInsets.only(left: 14),
                        child: Text(
                         value,
                          style: TextStyle(fontSize: 25),
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Container(
                        child: Row(
                          children: [
                            Icon(
                              Icons.logout,
                              color: Colors.blue.shade900,
                            ),
                            GestureDetector(
                              onTap: () {
                                controller.logOut();
                                controller.removeData();
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Login(),
                                    ));
                              },
                              child: Text(
                                " Log Off",
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade900),
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  )
                ],
              ),
              Divider()
            ],
          ),
        ),
      ),
    );
  }
}
