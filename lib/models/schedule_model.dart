import 'package:flutter/material.dart';

class Schedule {
  final String courseName;
  final String location;
  final String startTime;
  final String endTime;
  final String classType; // section from API
  final String lecturerName;
  final Color tileColor;

  Schedule({
    required this.courseName,
    required this.location,
    required this.startTime,
    required this.endTime,
    required this.classType,
    required this.lecturerName,
    this.tileColor = Colors.red, // default color 
  });

  /// Factory constructor to create Schedule from backend API JSON response
  factory Schedule.fromJson(Map<String, dynamic> json) {
    final section = json['section'] ?? '';
    return Schedule(
      courseName: json['course'] ?? '',
      lecturerName: json['instructor'] ?? '',
      classType: section,
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      location: json['location'] ?? '',
      tileColor: getTileColor(section),
    );
  }

  static Color getTileColor(String classType) {
    final type = classType.toLowerCase();
    if (type.contains('group')) {
      return const Color(0xFF0000FF); // Blue for group/lab sessions
    } else if (type.startsWith('b') || type.startsWith('a')) {
      return const Color(0xFFFF0000); // Red for section tutorials
    }
    switch (type) {
      case 'tut':
        return const Color(0xFFFF0000); // Red
      case 'lec':
        return const Color(0xFF00FF00); // Green
      case 'lab':
        return const Color(0xFF0000FF); // Blue
      default:
        return const Color(0xFF9C27B0); // Purple for other types
    }
  }
}