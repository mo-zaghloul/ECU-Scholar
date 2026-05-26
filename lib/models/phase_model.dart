// lib/models/phase_model.dart
class PhaseData {
  final String semester;
  final String academicYear;
  final bool isExamPhase;

  const PhaseData({
    required this.semester,
    required this.academicYear,
    required this.isExamPhase,
  });

  factory PhaseData.fromJson(Map<String, dynamic> json) => PhaseData(
    semester:     json['semester']?.toString() ?? '',
    academicYear: json['academic_year']?.toString() ?? '',
    isExamPhase:  json['exams'] as bool? ?? false,
  );
}