import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ACM/Widgets/reusable_text_widget.dart';
import '../Approvals.dart';
import '../pr_approval_lsit_screen.dart';
import '../report_screens/report_filter_screen.dart';
import '../reservation_approval.dart';

class drawyerItems extends StatelessWidget {
  const drawyerItems({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: 12,
          ),

          GestureDetector(
            onTap: (){
              Get.to(()=> POApprovals());
            },
            child: Container(
              height: 40,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade300
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Row(
                  children: [
                    Icon(Icons.fact_check_outlined, color: Colors.blue.shade900,),
                    SizedBox(width: 24,),
                    ReusableText(
                      text: 'Purchase Order',
                      size: 16,
                      fw: FontWeight.w500,
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 6,),
          GestureDetector(
            onTap: (){
              Get.to(()=> PRApprovals());
            },
            child: Container(
              height: 40,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade300
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Row(
                  children: [
                    Icon(Icons.beenhere_outlined, color: Colors.blue.shade900,),
                    SizedBox(width: 24,),
                    ReusableText(
                      text: 'Purchase Request',
                      size: 16,
                      fw: FontWeight.w500,
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 6,),
          GestureDetector(
            onTap: (){
              Get.to(()=> ReservationApprovals());
            },
            child: Container(
              height: 40,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade300
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Row(
                  children: [
                    Icon(Icons.flaky_outlined, color: Colors.blue.shade900,),
                    SizedBox(width: 24,),
                    ReusableText(
                      text: '(MIR) Reservation',
                      size: 16,
                      fw: FontWeight.w500,
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 6,),
          GestureDetector(
            onTap: (){
              Get.to(()=> ReportFilterScreen());
            },
            child: Container(
              height: 40,
              width: double.infinity,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.shade300
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Row(
                  children: [
                    Icon(CupertinoIcons.chart_bar_square_fill, color: Colors.blue.shade900,),
                    SizedBox(width: 24,),
                    ReusableText(
                      text: 'Report',
                      size: 16,
                      fw: FontWeight.w500,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
