import 'package:ecu_scholar/constants/text_styles.dart';
import 'package:flutter/material.dart';
import '../models/schedule.dart';

class ScheduleTile extends StatelessWidget {
  final Schedule schedule;

  const ScheduleTile({super.key, required this.schedule});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 12, top: 6, bottom: 6),
      child: Container(
        padding: const EdgeInsets.only(left: 12, right: 12, top: 0, bottom: 6),
        decoration: BoxDecoration(
          color: schedule.tileColor,
          borderRadius: BorderRadius.circular(18),
        ),
        height: 70,
        child: Row(
          children: [
            // time
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    schedule.startTime,
                    style: AppTextStyles.subtitle1,
                  ),
                  Text(
                    schedule.endTime,
                    style: AppTextStyles.subtitle1,
                  ),
                ],
              ),
            ),
            // course details
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Text(
                    schedule.courseName,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.subtitle1.copyWith(fontWeight: FontWeight.bold),
                    ),
                  Text(
                    schedule.lecturerName,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.subtitle1,
                  ),
                ],
              ),
            ),
            // location
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(schedule.location, style: AppTextStyles.subtitle1),
                Text(schedule.classType, style: AppTextStyles.subtitle1),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
