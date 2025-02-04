import 'package:flutter/material.dart';

import '../constants/text_styles.dart';

class TasksPage extends StatelessWidget {
  TasksPage({super.key});
  final List<String> tasks = [
    'Buy groceries',
    'Walk the dog',
    'Complete Flutter project',
    'Read a book',
    'Exercise for 30 minutes'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tasks', style: AppTextStyles.headline3),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(tasks[index]),
            leading: Icon(Icons.check_box_outline_blank),
          );
        },
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: TasksPage(),
  ));
}