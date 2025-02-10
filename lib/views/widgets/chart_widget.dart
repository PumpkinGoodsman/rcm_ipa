import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ACM/Widgets/reusable_text_widget.dart';

class ChartWidget extends StatelessWidget {
  const ChartWidget({
    super.key,
    required this.containerWidth, required this.title, required this.highLow, required this.dcolor, required this.data, this.icon, required this.iconColor, required this.spIconColor, required this.spIcon,
  });

  final double containerWidth;
  final String title;
  final String highLow;
  final String data;
  final Color dcolor;
  final Color iconColor;
  final Color spIconColor;
  final IconData? icon;
  final IconData spIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      width: containerWidth,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(10),),
        border: Border.all(color: Colors.black54),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ReusableText(
              text: title, size: 16, fw: FontWeight.w600),
          SizedBox(height: 6,),
          Text(
            data,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: dcolor,
               fontSize: 16, fontWeight: FontWeight.bold
          ),),

          SizedBox(height: 6,),
          Icon(spIcon, color: spIconColor,size: 18,),
        ],
      ),
    );
  }
}

class ChartFirstWidget extends StatelessWidget {
  const ChartFirstWidget({
    super.key,
    required this.containerWidth, required this.title, required this.highLow, required this.dcolor, required this.data, this.icon, required this.iconColor, required this.spIconColor, required this.spIcon,required this.sTitle,required this.sData,
  });

  final double containerWidth;
  final String title;
  final String sTitle;
  final String highLow;
  final String data;
  final String sData;
  final Color dcolor;
  final Color iconColor;
  final Color spIconColor;
  final IconData? icon;
  final IconData spIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      width: containerWidth,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(10),),
        border: Border.all(color: Colors.black54),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ReusableText(
              text: title, size: 14, fw: FontWeight.w600),
          SizedBox(height: 6,),
          Text(
            data,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: dcolor,
                fontSize: 16, fontWeight: FontWeight.bold
            ),),
          ReusableText(
              text: sTitle, size: 14, fw: FontWeight.w600),
          const SizedBox(height: 6,),
          Text(
            sData,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: dcolor,
                fontSize: 16, fontWeight: FontWeight.bold
            ),),
          SizedBox(height: 6,),
          Icon(spIcon, color: spIconColor,size: 18,),
        ],
      ),
    );
  }
}