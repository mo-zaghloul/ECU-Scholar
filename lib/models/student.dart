import 'package:flutter/material.dart';

class Student {
  final String studentName;
  final String studentID;
  final String studentDegree;
  final String studentFaculty;
  final String studentMajor;
  final String studentCGPA;
  final String studentLevel;
  final String studentTotalPassedHours;

  Student({
    required this.studentName,
    required this.studentID,
    required this.studentDegree,
    required this.studentFaculty,
    required this.studentMajor,
    required this.studentCGPA,
    required this.studentLevel,
    required this.studentTotalPassedHours,
  });

  // convert student -> json
  Map<String, dynamic> toJson() => {
        'studentName': studentName,
        'studentID': studentID,
        'studentDegree': studentDegree,
        'studentFaculty': studentFaculty,
        'studentMajor': studentMajor,
        'studentCGPA': studentCGPA,
        'studentLevel': studentLevel,
        'studentTotalPassedHours': studentTotalPassedHours,
      };
  // convert json -> student
  factory Student.fromJson(Map<String, dynamic> json) => Student(
        studentName: json['studentName'],
        studentID: json['studentID'],
        studentDegree: json['studentDegree'],
        studentFaculty: json['studentFaculty'],
        studentMajor: json['studentMajor'],
        studentCGPA: json['studentCGPA'],
        studentLevel: json['studentLevel'],
        studentTotalPassedHours: json['studentTotalPassedHours'],
      );
}
