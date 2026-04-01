import 'package:flutter/material.dart';
import '../utils/time_utils.dart';

class Schedule {
  final String courseCode;
  final String courseName;
  final String location;
  final String startTime;
  final String endTime;
  final String classType;
  final String section;
  final String lecturerName;
  final int dayOfWeek;
  final Color tileColor;

  Schedule({
    required this.courseCode,
    required this.courseName,
    required this.location,
    required this.startTime,
    required this.endTime,
    required this.classType,
    required this.section,
    required this.lecturerName,
    required this.dayOfWeek,
    this.tileColor = Colors.red,
  });

  /// Factory constructor to create Schedule from backend API JSON response
  factory Schedule.fromJson(Map<String, dynamic> json) {
    final classType = json['class_type'] ?? '';
    final section = json['section'] ?? '';
    return Schedule(
      courseCode: json['course_code'] ?? '',
      courseName: json['course_name'] ?? '',
      lecturerName: json['instructor'] ?? '',
      classType: classType,
      section: section,
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      location: json['location'] ?? '',
      dayOfWeek: json['day_of_week'] ?? 0,
      tileColor: getTileColor(classType, section),
    );
  }

  static Color getTileColor(String classType, String section) {
    final type = classType.toLowerCase();
    final sec = section.toLowerCase();
    
    // Check section for group/lab patterns
    if (sec.contains('group') || sec.contains('lab')) {
      return const Color(0xFF2196F3); // Blue for group/lab sessions
    }
    
    switch (type) {
      case 'tut':
        return const Color(0xFFE53935); // Red for tutorials
      case 'lec':
        return const Color(0xFF43A047); // Green for lectures
      case 'lab':
        return const Color(0xFF2196F3); // Blue for labs
      default:
        return const Color(0xFFB71C1C); // Dark red for other types
    }
  }

  /// Compare start times for sorting (earlier time = higher priority)
  int compareStartTime(Schedule other) {
    return compareTimeStrings(startTime, other.startTime);
  }
}

/// Represents a day's schedule with all classes
class DaySchedule {
  final int dayOfWeek;
  final String dayName;
  final DateTime date;
  final List<Schedule> classes;

  DaySchedule({
    required this.dayOfWeek,
    required this.dayName,
    required this.date,
    required this.classes,
  });

  bool get isEmpty => classes.isEmpty;

  /// Get day name from day number (1 = Saturday in Egyptian calendar)
  static String getDayName(int dayOfWeek) {
    const days = [
      '', // 0 - not used
      'Saturday',
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
    ];
    return dayOfWeek >= 1 && dayOfWeek <= 7 ? days[dayOfWeek] : '';
  }

  /// Create from API response
  factory DaySchedule.fromJson(Map<String, dynamic> json, DateTime date) {
    final classList = (json['classes'] as List<dynamic>?) ?? [];
    return DaySchedule(
      dayOfWeek: json['day'] ?? 0,
      dayName: json['day_name'] ?? '',
      date: date,
      classes: classList
          .map((item) => Schedule.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}