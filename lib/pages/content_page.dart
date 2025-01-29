import 'package:ecu_scholar/utils/content_tile.dart';
import 'package:flutter/material.dart';
import '../constants/text_styles.dart';
import '../models/content.dart';

class ContentPage extends StatelessWidget {
  ContentPage({super.key});
  final List<Content> coursesContent = [
    Content(courseName: 'Data Structures and Algorithms', major: 'Engineering', sectionGroup: 'G2-2', classType: 'Lec', coverImage: 'assets/images/coverImages/blue_cover_image.png'),
    Content(courseName: 'Operating Systems', major: 'Computer Science', sectionGroup: 'G2-2', classType: 'Lab', coverImage: 'assets/images/coverImages/green_cover_image.png'),
    Content(courseName: 'Software Engineering', major: 'Engineering', sectionGroup: 'G2-2', classType: 'Lec', coverImage: 'assets/images/coverImages/yellow_cover_image.png')
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Content', style: AppTextStyles.headline3),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Content',
                        style: AppTextStyles.headline2,
                      ),
                    ],
                  ),
                ),
            Expanded(
              child: ListView.builder(
                itemCount: coursesContent.length,
                itemBuilder: (context, index) {
                  return ContentTile(content: coursesContent[index]);
                },
              ),
            ),
          ],
        ),
      );
  }
}
