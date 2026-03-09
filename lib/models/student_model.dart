class Student {
  final String id;
  final String name;
  final String faculty;
  final String major;
  final String year;
  final double totalPassedCH;
  final String courseRegStatus;
  final String? avatarUrl;

  Student({
    required this.id,
    required this.name,
    required this.faculty,
    required this.major,
    required this.year,
    required this.totalPassedCH,
    required this.courseRegStatus,
    this.avatarUrl,
  });

  /// Create from API response
  factory Student.fromJson(Map<String, dynamic> json) => Student(
        id: json['student_id']?.toString() ?? 'N/A',
        name: json['full_name'] ?? 'N/A',
        faculty: json['faculty'] ?? 'N/A',
        major: json['major'] ?? 'N/A',
        year: json['year']?.toString() ?? 'N/A',
        totalPassedCH: (json['total_passed_ch'] ?? 0).toDouble(),
        courseRegStatus: json['course_reg_status'] ?? 'N/A',
        avatarUrl: json['avatar_url'],
      );

  /// Empty student for default state
  factory Student.empty() => Student(
        id: '',
        name: '',
        faculty: '',
        major: '',
        year: '',
        totalPassedCH: 0,
        courseRegStatus: '',
      );

  /// Legacy getter for backwards compatibility
  String get gpa => 'N/A'; // GPA comes from grades endpoint now
}
