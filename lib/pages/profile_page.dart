import 'package:ecu_scholar/models/student.dart';
import 'package:ecu_scholar/utils/academic_advisor_tile.dart';
import 'package:ecu_scholar/utils/profile_tile.dart';
import 'package:flutter/material.dart';

import '../constants/text_styles.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});
  final Student _student = Student(
    studentName: 'John Doe',
    studentID: '1234567890',
    studentDegree: 'BSc in Computer Science',
    studentFaculty: 'Faculty of Science',
    studentMajor: 'Computer Science',
    studentCGPA: '3.81',
    studentLevel: 'Level 2',
    studentTotalPassedHours: '37.00',
  );
  @override
  Widget build(BuildContext context) {
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
              radius: 50,
              backgroundImage: AssetImage('assets/studentpersona.png'),
              backgroundColor: Colors.grey,
            ),
            Text(
              _student.studentName,
              style: AppTextStyles.headline2,
            ),
            Text(_student.studentID, style: AppTextStyles.subtitle2),

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
                      body: _student.studentDegree),
                  ProfileTile(
                      icon: Icons.business,
                      title: 'Faculty',
                      body: _student.studentFaculty),
                  ProfileTile(
                      icon: Icons.category,
                      title: 'Major',
                      body: _student.studentMajor),
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
            Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('CGPA:', style: AppTextStyles.subtitle1bold),
                  Text(_student.studentCGPA, style: AppTextStyles.bodyText1),
                ],
              ),
            ),
            // Level
            Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Level:', style: AppTextStyles.subtitle1bold),
                  Text(_student.studentLevel, style: AppTextStyles.bodyText1),
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
                  Text(_student.studentTotalPassedHours,
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
