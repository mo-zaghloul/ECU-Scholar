import 'package:flutter/material.dart';

class Schedule {
  final String courseName;
  final String location;
  final String startTime;
  final String endTime;
  final String classType;
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
  
  static Color getTileColor(String classType) {
    switch (classType.toLowerCase()) {
      case 'tut':
        return Color(0xFFFF0000); // Red
      case 'lec':
        return Color(0xFF00FF00); // Green
      case 'lab':
        return Color(0xFF0000FF); // Blue
      default:
        return Color(0xFF000000); // Default color (black)
    }
  }

  // Static method to parse a string into a Schedule object
  static Schedule parseSchedule(String input) {
    final regex = RegExp(r'([A-Za-z0-9]+)\[([A-Za-z\s]+) - (\w+) -(\d{2}:\d{2}) - (\d{2}:\d{2}) - (\w+)\]');
    final match = regex.firstMatch(input);

    if (match != null) {
      final courseName = match.group(1) ?? '';
      final lecturerName = match.group(2)?.trim() ?? '';
      final classType = match.group(3) ?? '';
      final startTime = match.group(4) ?? '';
      final endTime = match.group(5) ?? '';
      final location = match.group(6) ?? '';

      final schedule = Schedule(
        courseName: courseName,
        location: location,
        startTime: startTime,
        endTime: endTime,
        classType: classType,
        lecturerName: lecturerName,
        tileColor: getTileColor(classType),
      );

      return schedule;
    } else {
      // Log error or return null if the format is wrong
      debugPrint("Error: Invalid input format.");
      throw FormatException('Invalid schedule format');
    }
  }
}
/*
void main() {
  String scheduleString = "Schedule today: HUM013[Sara yehia - tut -21:30 - 22:30 - A202]";

  final schedule = Schedule.parseSchedule(scheduleString);
  if (schedule != null) {
    print('Course: ${course.courseName}');
    print('Lecturer: ${course.lecturerName}');
    print('Class Type: ${course.classType}');
    print('Start Time: ${course.startTime}');
    print('End Time: ${course.endTime}');
    print('Location: ${course.location}');
    print('Tile Color: ${course.tileColor}');
  } else {
    print("Failed to parse the course.");
  }
}
  // convert scedule -> json
  Map<String, dynamic> toJson() => {
        'courseName': courseName,
        'location': location,
        'startTime': startTime,
        'endTime': endTime,
        'classType': classType,
        'lecturerName': lecturerName,
      };

  // convert json -> schedule
  factory Schedule.fromJson(Map<String, dynamic> json) => Schedule(
        courseName: json['courseName'],
        location: json['location'],
        startTime: json['startTime'],
        endTime: json['endTime'],
        classType: json['classType'],
        lecturerName: json['lecturerName'],
      );
}
*/