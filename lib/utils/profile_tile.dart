import 'package:ecu_scholar/constants/text_styles.dart';
import 'package:flutter/material.dart';
import '../models/schedule_model.dart';

class ProfileTile extends StatelessWidget {
  final String title, body;
  final IconData icon;
  const ProfileTile(
      {super.key, required this.icon, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 6, right: 6, top: 6, bottom: 6),
      child: Container(
        padding: const EdgeInsets.only(left: 12, right: 12, top: 0, bottom: 6),
        decoration: BoxDecoration(
            color: Color.fromARGB(255, 209, 197, 197),
          borderRadius: BorderRadius.circular(18),
        ),
        height: 70,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // icon
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Icon(icon),
                ),
                Text(
                  title,
                  style: AppTextStyles.subtitle1bold,
                ),
              ],
            ),
            // body
            Text(
              body,
              style: AppTextStyles.bodyText1,
            ),
          ],
        ),
      ),
    );
  }
}
