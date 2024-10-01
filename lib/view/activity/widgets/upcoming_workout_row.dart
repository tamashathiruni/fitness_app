import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:flutter/material.dart';

class UpcomingWorkoutRow extends StatefulWidget {
  final Map wObj;
  const UpcomingWorkoutRow({Key? key, required this.wObj}) : super(key: key);

  @override
  State<UpcomingWorkoutRow> createState() => _UpcomingWorkoutRowState();
}

class _UpcomingWorkoutRowState extends State<UpcomingWorkoutRow> {
  @override
  Widget build(BuildContext context) {
    bool positive = false;
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: AppColors.whiteColor,
            borderRadius: BorderRadius.circular(15),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)]),
        child: Row(
          children: [
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.wObj["title"].toString(),
                  style: TextStyle(
                      color: AppColors.blackColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500),
                ),
                Text(
                  widget.wObj["time"].toString(),
                  style: TextStyle(
                    color: AppColors.grayColor,
                    fontSize: 10,
                  ),
                ),
              ],
            )),
          ],
        ));
  }
}
