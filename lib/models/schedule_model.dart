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