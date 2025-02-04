import 'package:ecu_scholar/constants/text_styles.dart';
import 'package:ecu_scholar/models/content_model.dart';
import 'package:flutter/material.dart';

class ContentTile extends StatelessWidget {
  final Content content;

  const ContentTile({super.key, required this.content});
  @override
  Widget build(BuildContext context) {
    return Container(
        child: ListTile(
      title: Text(
        content.courseName,
        style: AppTextStyles.subtitle1bold,
      ),
      subtitle: Text(
        content.major +
            ' · ' +
            content.sectionGroup +
            ' · ' +
            content.classType,
        style: AppTextStyles.subtitle1
            .copyWith(color: const Color.fromARGB(255, 107, 107, 107))),
        leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(content.coverImage)),
      ),
    );
  }
}
