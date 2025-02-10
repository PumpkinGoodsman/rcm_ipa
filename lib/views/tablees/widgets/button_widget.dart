import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ACM/controller/table_controller.dart';

import '../../../services/helper/request_services.dart';

class ApprovalButton extends StatelessWidget {
  const ApprovalButton({
    super.key,
    required this.screenWidth, required this.text, required this.onTap, required this.boxColor,required this.textColor, required this.iconColor, required this.icon,
  });

  final double screenWidth;
  final String text;
  final void  Function() onTap;
  final Color boxColor;
  final Color iconColor;
  final Color textColor;
  final IconData icon;

  @override
  Widget build(BuildContext context) {

    final controller = Get.put(TableController());
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: boxColor,
          borderRadius:
          BorderRadius.all(Radius.circular(8)),
        ),
        padding: EdgeInsets.all(8),
        alignment: Alignment.center,
        margin: EdgeInsets.all(5),
        height: 75,
        width: screenWidth,
        child: controller.isApproval ? Padding(
          padding: const EdgeInsets.all(4.0),
          child: Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              )),
        ): Column(
          children: [
            Icon(
              icon,
              color: iconColor,
            ),
            Text(
              text,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class RejectButton extends StatelessWidget {
  const RejectButton({
    super.key,
    required this.screenWidth, required this.text, required this.onTap, required this.boxColor,required this.textColor, required this.iconColor, required this.icon,
  });

  final double screenWidth;
  final String text;
  final void  Function() onTap;
  final Color boxColor;
  final Color iconColor;
  final Color textColor;
  final IconData icon;

  @override
  Widget build(BuildContext context) {

    final controller = Get.put(TableController());
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: boxColor,
          borderRadius:
          BorderRadius.all(Radius.circular(8)),
        ),
        padding: EdgeInsets.all(8),
        alignment: Alignment.center,
        margin: EdgeInsets.all(5),
        height: 75,
        width: screenWidth,
        child:controller.isRejected ? Padding(
          padding: const EdgeInsets.all(4.0),
          child: Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              )),
        ) : Column(
          children: [
            Icon(
              icon,
              color: iconColor,
            ),
             Text(
              text,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

