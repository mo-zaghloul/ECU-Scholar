class Student {
  final String name;
  final String faculty;
  final String gpa;
  // final String id;
  // final String degree;
  // final String major;
  // final String level;
  // final String totalPassedHours;

  Student({
    required this.name,
    required this.faculty,
    required this.gpa,
    // required this.id,
    // required this.degree,
    // required this.major,
    // required this.level,
    // required this.totalPassedHours,
  });

  // factory Student.fromMap(Map<String, String> map) {
  //   return Student(
  //     name: map['Student Name'] ?? 'N/A',
  //     id: map['Student ID'] ?? 'N/A',
  //     degree: map['Degree'] ?? 'N/A',
  //     faculty: map['Faculty'] ?? 'N/A',
  //     major: map['Major'] ?? 'N/A',
  //     level: map['Level'] ?? 'N/A',
  //     totalPassedHours: map['Total Passed Hours'] ?? 'N/A',
  //     cgpa: map['CGPA'] ?? 'N/A',
  //   );
  // }
  // convert json -> student
  factory Student.fromJson(json) => Student(
        name: json['name'] ?? 'N/A',
        gpa: json['gpa'] ?? 'N/A',
        faculty: json['faculty'] ?? 'N/A',
        // id: json['studentID'],
        // degree: json['studentDegree'],
        // major: json['studentMajor'],
        // level: json['studentLevel'],
        // totalPassedHours: json['studentTotalPassedHours'],
      );
}
