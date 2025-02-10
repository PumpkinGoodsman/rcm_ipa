import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ListOfItems extends StatelessWidget {
  const ListOfItems({
    super.key, required this.title, required this.date, required this.description, required this.price,
  });

  final String title;
  final String date;
  final String description;
  final String price;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      alignment: Alignment.topLeft,
      height: 134,
      width: double.infinity,
      color: Colors.white,
      child: Column(
        children: [
          Container(
            alignment: Alignment.topLeft,
            child: Text(
             title,
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
              date,
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
              description,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: const Color.fromARGB(221, 37, 37, 37)),
            ),
          ),
          Container(
            alignment: Alignment.bottomRight,
            child: Text(
              price,
              style: GoogleFonts.notoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: const Color.fromARGB(221, 37, 37, 37)),
            ),
          )
        ],
      ),
    );
  }
}
