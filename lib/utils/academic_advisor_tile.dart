import 'package:ecu_scholar/constants/text_styles.dart';
import 'package:ecu_scholar/themes/light_mode.dart';
import 'package:flutter/material.dart';
import '../models/schedule.dart';

class AcademicAdvisorTile extends StatelessWidget {
  final String title, name, email;
  final IconData icon;
  const AcademicAdvisorTile(
      {super.key,
      required this.icon,
      required this.title,
      required this.name,
      required this.email});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 6),
      child: Container(
        padding: const EdgeInsets.only(right: 12, top: 0, bottom: 6),
        decoration: BoxDecoration(
          color: lightMode.primaryColorLight,
          borderRadius: BorderRadius.circular(18),
        ),
        height: 90,
        child: Row(
          children: [
            // icon
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                icon,
                size: 40,
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 2.0),
                  child: Text(
                    title,
                    style: AppTextStyles.subtitle1bold,
                  ),
                ),
                // name
                Text(
                  'Eng. ' + name,
                  style: AppTextStyles.bodyText2,
                ),
                // email
                Text(
                  '' + email,
                  style: AppTextStyles.bodyText2,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
