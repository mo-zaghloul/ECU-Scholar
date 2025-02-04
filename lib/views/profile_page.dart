import 'package:ecu_scholar/utils/academic_advisor_tile.dart';
import 'package:ecu_scholar/utils/profile_tile.dart';
import 'package:ecu_scholar/view_models/student_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/text_styles.dart';
import '../models/student_model.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}
  /*
  final Student _student = Student(
    name: 'John Doe',
    id: '1234567890',
    degree: 'BSc in Computer Science',
    faculty: 'Faculty of Science',
    major: 'Computer Science',
    cgpa: '3.81',
    level: 'Level 2',
    totalPassedHours: '37.00',
  );
  */
  class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    fetchStudentData();
  }

  Future<void> fetchStudentData() async {
    await Provider.of<StudentViewModel>(context, listen: false).fetchStudentData();
  }

  @override
  Widget build(BuildContext context) {
    var student = Provider.of<StudentViewModel>(context).studentData;
    student = Student(
    name: 'Mohamed Zaghloul',
    id: '192300513',
    degree: 'B.Sc',
    faculty: 'Faculty of Engineering and Technology', 
    major: 'Software Engineering and Information Technology',
    cgpa: '3.81',
    level: 'Level 2',
    totalPassedHours: '55.00',
  );
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile', style: AppTextStyles.headline3),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            CircleAvatar(
              radius: 55,
              child: Text(student.name[0], style: TextStyle(fontSize: 70),),
              // backgroundImage: AssetImage('assets/images/studentpersona.png'),
              backgroundColor: const Color.fromARGB(244, 206, 20, 7),
            ),
            Text(
              student.name,
              style: AppTextStyles.headline3.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(student.id, style: AppTextStyles.headline3),

            // Academic Details
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20.0, bottom: 2.0),
                  child: Text('Academic Details',
                      style: AppTextStyles.headline3.copyWith(
                        fontWeight: FontWeight.bold,
                      )),
                ),
              ],
            ),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ProfileTile(
                      icon: Icons.school,
                      title: 'Degree',
                      body: student.degree),
                  ProfileTile(
                      icon: Icons.business,
                      title: 'Faculty',
                      body: student.faculty),
                  ProfileTile(
                      icon: Icons.category,
                      title: 'Major',
                      body: student.major),
                ],
              ),
            ),
            // Academic Information
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20.0, bottom: 2.0),
                  child: Text('Advisor Information',
                      style: AppTextStyles.headline3.copyWith(
                        fontWeight: FontWeight.bold,
                      )),
                ),
              ],
            ),
            AcademicAdvisorTile(
              icon: Icons.person,
              title: 'Academic Advisor',
              name: 'Ahmed Ali',
              email: ' ahmedali@ecu.edu.eg',
            ),

            // Academic Performance
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20.0, bottom: 2.0),
                  child: Text('Academic Performance',
                      style: AppTextStyles.headline3.copyWith(
                        fontWeight: FontWeight.bold,
                      )),
                ),
              ],
            ),
            /*
            Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('CGPA:', style: AppTextStyles.subtitle1bold),
                  Text(student.cgpa, style: AppTextStyles.bodyText1),
                ],
              ),
            ),
            */
            // Level
            Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Level:', style: AppTextStyles.subtitle1bold),
                  Text(student.level, style: AppTextStyles.bodyText1),
                ],
              ),
            ),
            // Total Passed Credits
            Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total Passed CH:', style: AppTextStyles.subtitle1bold),
                  Text(student.totalPassedHours,
                      style: AppTextStyles.bodyText1),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
