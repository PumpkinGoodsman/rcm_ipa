import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../tablees/approvalDetail.dart';

class Supplier extends StatelessWidget {
  final String appBarTitle;

  const Supplier({Key? key, required this.appBarTitle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 241, 240, 240),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          appBarTitle,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: const Color.fromARGB(221, 37, 37, 37),
          ),
        ),
        centerTitle: true,
        leading: Row(
          children: [
            // Icon(
            //   Icons.account_circle_outlined,
            //   color: Colors.blue.shade900,
            //   size: 40,
            // ),
            SizedBox(width: 10),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Icon(
             Icons.navigate_before,
                color: Colors.blue.shade900,
                size: 35,
              ),
            ),
          ],
        ),
      ),
      body: Container(
        margin: EdgeInsets.all(17),
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => POApprovalTableScreen(
                      appBarTitle: "TUV SUB Middle East",
                    ),
                  ),
                );
              },
              child: Container(
                padding: EdgeInsets.all(10),
                alignment: Alignment.topLeft,
                height: 130,
                width: double.infinity,
                color: Colors.white,
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "TUV SUB Middle East",
                        style: GoogleFonts.notoSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: const Color.fromARGB(221, 37, 37, 37)),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.all(3),
                      alignment: Alignment.topLeft,
                      child: Text(
                        "12/11/22",
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: const Color.fromARGB(221, 37, 37, 37)),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.all(3),
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Supper Invoice ID 3 - Melad Kaskas",
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: const Color.fromARGB(221, 37, 37, 37)),
                      ),
                    ),
                    Container(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        "7000 AED",
                        style: GoogleFonts.notoSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: const Color.fromARGB(221, 37, 37, 37)),
                      ),
                    )
                  ],
                ),
              ),
            ),
            ////////////////////////////////////////////////////////////////////////////////////////////
            SizedBox(
              height: 15,
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => POApprovalTableScreen(
                      appBarTitle: "Bin Diari & Partners Contr.& Gen. Miant",
                    ),
                  ),
                );
              },
              child: Container(
                padding: EdgeInsets.all(10),
                alignment: Alignment.topLeft,
                height: 130,
                width: double.infinity,
                color: Colors.white,
                child: Column(
                  children: [
                    Text(
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      "Bin Diari & Partners Contr.& Gen. Miant",
                      style: GoogleFonts.notoSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: const Color.fromARGB(221, 37, 37, 37)),
                    ),
                    Container(
                      margin: EdgeInsets.all(3),
                      alignment: Alignment.topLeft,
                      child: Text(
                        "02/11/24",
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: const Color.fromARGB(221, 37, 37, 37)),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.all(3),
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Supper Invoice ID 6 - Support User",
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: const Color.fromARGB(221, 37, 37, 37)),
                      ),
                    ),
                    Container(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        "4000 AED",
                        style: GoogleFonts.notoSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: const Color.fromARGB(221, 37, 37, 37)),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
