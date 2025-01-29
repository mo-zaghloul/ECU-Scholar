
class Content {
  final String courseName;
  final String major;
  final String sectionGroup;
  final String classType;
  final String coverImage;

  Content({
    required this.courseName,
    required this.major,
    required this.sectionGroup,
    required this.classType,
    required this.coverImage, 
  });

  // convert content -> json
  Map<String, dynamic> toJson() => {
        'courseName': courseName,
        'major': major,
        'sectionGroup': sectionGroup,
        'classType': classType,
        'coverImage': coverImage,
      };
}