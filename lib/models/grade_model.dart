import 'package:flutter/material.dart';

/// Model for a single course grade
class Grade {
  final String academicYear;
  final String semester;
  final String courseCode;
  final String courseName;
  final double creditHours;
  final String gradeLetter;
  final double gradePoints;

  Grade({
    required this.academicYear,
    required this.semester,
    required this.courseCode,
    required this.courseName,
    required this.creditHours,
    required this.gradeLetter,
    required this.gradePoints,
  });

  factory Grade.fromJson(Map<String, dynamic> json) => Grade(
        academicYear: json['academic_year']?.toString() ?? '',
        semester: json['semester']?.toString() ?? '',
        courseCode: json['course_code']?.toString() ?? '',
        courseName: json['course_name']?.toString() ?? '',
        creditHours: (json['credit_hours'] ?? 0).toDouble(),
        gradeLetter: json['grade_letter']?.toString() ?? '',
        gradePoints: (json['grade_points'] ?? 0).toDouble(),
      );

  /// Get color for grade letter
  Color get gradeColor {
    switch (gradeLetter.toUpperCase()) {
      case 'A+':
      case 'A':
        return const Color(0xFF34C759); // Green
      case 'A-':
        return const Color(0xFF30D158);
      case 'B+':
        return const Color(0xFF32ADE6); // Blue
      case 'B':
        return const Color(0xFF007AFF);
      case 'B-':
        return const Color(0xFF5856D6);
      case 'C+':
        return const Color(0xFFFFCC00); // Yellow
      case 'C':
        return const Color(0xFFFF9500); // Orange
      case 'C-':
        return const Color(0xFFFF9F0A);
      case 'D+':
      case 'D':
        return const Color(0xFFFF6B6B); // Light red
      case 'F':
        return const Color(0xFFCE1407); // Red
      default:
        return const Color(0xFF8E8E93); // Gray
    }
  }
}

/// Model for semester GPA
class SemesterGpa {
  final String academicYear;
  final String semester;
  final double gpa;
  final double credits;

  SemesterGpa({
    required this.academicYear,
    required this.semester,
    required this.gpa,
    required this.credits,
  });

  factory SemesterGpa.fromJson(Map<String, dynamic> json) => SemesterGpa(
        academicYear: json['academic_year']?.toString() ?? '',
        semester: json['semester']?.toString() ?? '',
        gpa: (json['gpa'] ?? 0).toDouble(),
        credits: (json['credits'] ?? 0).toDouble(),
      );
}

/// Model for GPA summary response
class GpaSummary {
  final double cumulativeGpa;
  final double totalCredits;
  final List<SemesterGpa> bySemester;

  GpaSummary({
    required this.cumulativeGpa,
    required this.totalCredits,
    required this.bySemester,
  });

  factory GpaSummary.fromJson(Map<String, dynamic> json) => GpaSummary(
        cumulativeGpa: (json['cumulative_gpa'] ?? 0).toDouble(),
        totalCredits: (json['total_credits'] ?? 0).toDouble(),
        bySemester: (json['by_semester'] as List<dynamic>?)
                ?.map((e) => SemesterGpa.fromJson(e))
                .toList() ??
            [],
      );

  factory GpaSummary.empty() => GpaSummary(
        cumulativeGpa: 0,
        totalCredits: 0,
        bySemester: [],
      );
}

/// Model for academic year with semesters
class AcademicYearSemesters {
  final String academicYear;
  final List<String> semesters;

  AcademicYearSemesters({
    required this.academicYear,
    required this.semesters,
  });
}

/// Helper to parse semesters list from API
List<AcademicYearSemesters> parseSemestersList(List<dynamic> data) {
  final Map<String, List<String>> grouped = {};
  
  for (final item in data) {
    final year = item['academic_year']?.toString() ?? '';
    final semester = item['semester']?.toString() ?? '';
    if (year.isNotEmpty) {
      grouped.putIfAbsent(year, () => []);
      if (semester.isNotEmpty && !grouped[year]!.contains(semester)) {
        grouped[year]!.add(semester);
      }
    }
  }
  
  // Sort years descending (newest first)
  final sortedYears = grouped.keys.toList()
    ..sort((a, b) => b.compareTo(a));
  
  return sortedYears.map((year) => AcademicYearSemesters(
    academicYear: year,
    semesters: grouped[year]!,
  )).toList();
}
