import 'package:ecu_scholar/constants/text_styles.dart';
import 'package:flutter/material.dart';

class ContentPage extends StatelessWidget {
  final List<Map<String, String>> mockContent = [
    {'title': 'Introduction to Flutter', 'subtitle': 'Learn the basics of Flutter'},
    {'title': 'State Management', 'subtitle': 'Understanding state management in Flutter'},
    {'title': 'Networking', 'subtitle': 'Fetch data from the internet'},
    {'title': 'Database', 'subtitle': 'Persist data locally'},
    {'title': 'Animations', 'subtitle': 'Add animations to your app'},
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
      body: ListView.builder(
        itemCount: mockContent.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(mockContent[index]['title']!),
            subtitle: Text(mockContent[index]['subtitle']!),
          );
        },
      ),
    );
  }
}