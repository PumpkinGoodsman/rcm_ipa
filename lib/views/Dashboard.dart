
import 'package:flutter/material.dart';
import '../AuthScreen/Logout.dart';
import 'HomeScreens/home_screen.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: Image.asset('assets/logo.jpg', width: 46, height: 46),
            ),
          ],
          title: Text(
            "My Launchpad",
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: const Color.fromARGB(221, 37, 37, 37)),
          ),
          centerTitle: true,
          leading: GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Logout(),
                  ));
            },
            child: Icon(
              Icons.account_circle_outlined,
              color: Colors.blue.shade900,
              size: 40,
            ),
          ),
          backgroundColor: Colors.white,
        ),
        body: HomeScreen(),
      ),
    );
  }
}








