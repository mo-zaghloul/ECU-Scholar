class Student {
  final String name;
  final String id;
  final String degree;
  final String faculty;
  final String major;
  final String cgpa;
  final String level;
  final String totalPassedHours;

  Student({
    required this.name,
    required this.id,
    required this.degree,
    required this.faculty,
    required this.major,
    required this.cgpa,
    required this.level,
    required this.totalPassedHours,
  });

  factory Student.fromMap(Map<String, String> map) {
    return Student(
      name: map['Student Name'] ?? 'N/A',
      id: map['Student ID'] ?? 'N/A',
      degree: map['Degree'] ?? 'N/A',
      faculty: map['Faculty'] ?? 'N/A',
      major: map['Major'] ?? 'N/A',
      level: map['Level'] ?? 'N/A',
      totalPassedHours: map['Total Passed Hours'] ?? 'N/A',
      cgpa: map['CGPA'] ?? 'N/A',
    );
  }
  // convert json -> student
  factory Student.fromJson(json) => Student(
        name: json['studentName'],
        id: json['studentID'],
        degree: json['studentDegree'],
        faculty: json['studentFaculty'],
        major: json['studentMajor'],
        cgpa: json['studentCGPA'],
        level: json['studentLevel'],
        totalPassedHours: json['studentTotalPassedHours'],
      );
}
