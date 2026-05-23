import 'package:flutter/material.dart';

/// Represents a single exam during the exam phase
class Exam {
  final String courseCode;
  final String courseName;
  final DateTime startDateTime;  // Combined date + time (24h format from API)
  final DateTime endDateTime;    // Combined date + time (24h format from API)
  final String? location;
  final String? seat;
  final String examType; // 'Final', 'Midterm', 'Quiz'

  Exam({
    required this.courseCode,
    required this.courseName,
    required this.startDateTime,
    required this.endDateTime,
    required this.examType,
    this.seat,
    this.location,
  });

  /// Factory constructor to create Exam from backend API JSON response
  /// API provides: date (ISO), start_time (HH:MM 24h), end_time (HH:MM 24h)
  factory Exam.fromJson(Map<String, dynamic> json) {
    // Parse the date
    final dateStr = json['date'];
    final DateTime examDate = dateStr is String
        ? DateTime.parse(dateStr)
        : dateStr as DateTime;
    
    // Parse start and end times (24-hour format)
    final startTimeStr = (json['start_time'] ?? '00:00') as String;
    final endTimeStr = (json['end_time'] ?? '00:00') as String;
    
    final startTimeParts = startTimeStr.split(':');
    final endTimeParts = endTimeStr.split(':');
    
    final startHour = int.tryParse(startTimeParts[0]) ?? 0;
    final startMinute = int.tryParse(startTimeParts[1]) ?? 0;
    final endHour = int.tryParse(endTimeParts[0]) ?? 0;
    final endMinute = int.tryParse(endTimeParts[1]) ?? 0;
    
    // Construct DateTime objects
    final startDateTime = DateTime(
      examDate.year,
      examDate.month,
      examDate.day,
      startHour,
      startMinute,
    );
    final endDateTime = DateTime(
      examDate.year,
      examDate.month,
      examDate.day,
      endHour,
      endMinute,
    );
    
    return Exam(
      courseCode: json['course_code'] ?? '',
      courseName: json['course_name'] ?? '',
      startDateTime: startDateTime,
      endDateTime: endDateTime,
      // Normalize empty strings to null
      location: (json['location'] as String?)?.isEmpty == true ? null : json['location'],
      seat: (json['seat'] as String?)?.isEmpty == true ? null : json['seat'],
      examType: json['exam_type'] ?? 'Final',
    );
  }

  /// Convert to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'course_code': courseCode,
      'course_name': courseName,
      'start_time': '${startDateTime.hour.toString().padLeft(2, '0')}:${startDateTime.minute.toString().padLeft(2, '0')}',
      'end_time': '${endDateTime.hour.toString().padLeft(2, '0')}:${endDateTime.minute.toString().padLeft(2, '0')}',
      'date': startDateTime.toIso8601String(),
      'location': location,
      'seat': seat,
      'exam_type': examType,
    };
  }

  /// Check if exam is today
  bool get isToday {
    final now = DateTime.now();
    return startDateTime.year == now.year &&
        startDateTime.month == now.month &&
        startDateTime.day == now.day;
  }

  /// Check if exam is in the future
  bool get isFuture {
    final now = DateTime.now();
    return startDateTime.isAfter(now);
  }

  /// Calculate days remaining until exam
  int get daysRemaining {
    final now = DateTime.now();
    final difference = startDateTime.difference(now);
    return difference.inDays;
  }

  /// Get time range as string (e.g., "09:00 — 11:00")
  String get timeRange {
    final startStr = '${startDateTime.hour.toString().padLeft(2, '0')}:${startDateTime.minute.toString().padLeft(2, '0')}';
    final endStr = '${endDateTime.hour.toString().padLeft(2, '0')}:${endDateTime.minute.toString().padLeft(2, '0')}';
    return '$startStr — $endStr';
  }

  /// Get time range as string (e.g., "09:00 — 11:00")
  String get startTimeRange {
    final startStr = '${startDateTime.hour.toString().padLeft(2, '0')}:${startDateTime.minute.toString().padLeft(2, '0')}';
    return '$startStr';
  }

  /// Get formatted location info
  /// Both location and seat are null → "TBA"
  /// Both location and seat are present → "location · Seat seat"
  String getLocationDisplay() {
    if (location == null || seat == null) {
      return 'TBA';
    }
    return '$location · Seat $seat';
  }

  /// Get exam badge color based on type
  Color get badgeColor {
    switch (examType.toLowerCase()) {
      case 'final':
        return const Color(0xFF3d1010); // Dark red for Final
      case 'midterm':
        return const Color(0xFF2d3d1d); // Dark green for Midterm
      case 'quiz':
        return const Color(0xFF1d2d3d); // Dark blue for Quiz
      default:
        return const Color(0xFF3d1010);
    }
  }

  /// Get exam badge text color
  Color get badgeTextColor {
    switch (examType.toLowerCase()) {
      case 'final':
        return const Color(0xFFe87070); // Light red
      case 'midterm':
        return const Color(0xFF70e870); // Light green
      case 'quiz':
        return const Color(0xFF7090e8); // Light blue
      default:
        return const Color(0xFFe87070);
    }
  }
}

/// Represents the overall exam phase information
class ExamPhase {
  final bool isExamPhase;
  final String semester;
  final String academicYear;
  final List<Exam> exams;

  ExamPhase({
    required this.isExamPhase,
    required this.semester,
    required this.academicYear,
    required this.exams,
  });

  /// Factory constructor to create ExamPhase from backend API JSON response
  factory ExamPhase.fromJson(Map<String, dynamic> json) {
    final examsList = <Exam>[];
    
    // Handle exams data - could be bool or list
    final examsData = json['exams'];
    if (examsData is List) {
      examsList.addAll(
        examsData
            .map((e) => Exam.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    }

    return ExamPhase(
      isExamPhase: json['exams'] is bool ? json['exams'] as bool : false,
      semester: json['semester'] ?? '',
      academicYear: json['academic_year'] ?? '',
      exams: examsList,
    );
  }

  /// Convert to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'exams': isExamPhase,
      'semester': semester,
      'academic_year': academicYear,
      'exams_list': exams.map((e) => e.toJson()).toList(),
    };
  }

  /// Get today's exam (if any)
  Exam? get todayExam {
    try {
      return exams.firstWhere((e) => e.isToday);
    } catch (e) {
      return null;
    }
  }

  /// Get upcoming exams (excluding today's exam)
  List<Exam> get upcomingExams {
    return exams
        .where((e) => !e.isToday && e.isFuture)
        .toList()
      ..sort((a, b) => a.startDateTime.compareTo(b.startDateTime));
  }

  /// Get all exams sorted by date
  List<Exam> get sortedExams {
    return List<Exam>.from(exams)..sort((a, b) => a.startDateTime.compareTo(b.startDateTime));
  }
}
