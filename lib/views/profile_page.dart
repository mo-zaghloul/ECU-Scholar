import 'package:ecu_scholar/view_models/auth_viewmodel.dart';
import 'package:ecu_scholar/view_models/student_viewmodel.dart';
import 'package:ecu_scholar/views/auth_page.dart';
import 'package:ecu_scholar/widgets/shimmer_loading.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/text_styles.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  ProfilePageState createState() => ProfilePageState();
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
  class ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    fetchStudentData();
  }

  Future<void> fetchStudentData() async {
    await Provider.of<StudentViewModel>(context, listen: false).fetchStudentData();
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              await context.read<AuthViewModel>().logout(); // Clear auth state
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const AuthPage()),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile', style: AppTextStyles.headline3),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      body: Consumer<StudentViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const ProfileShimmer();
          }
          
          final student = viewModel.studentData;
          return RefreshIndicator(
            onRefresh: fetchStudentData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  CircleAvatar(
                    radius: 55,
                    backgroundColor: const Color.fromARGB(244, 206, 20, 7),
                    child: Text(
                      student.name.isNotEmpty ? student.name[0] : '?',
                      style: const TextStyle(fontSize: 70),
                    ),
                  ),
                  Text(
                    student.name,
                    style: AppTextStyles.headline3.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(student.faculty, style: AppTextStyles.bodyText1),

                  // Academic Performance Section
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0, bottom: 2.0),
                        child: Text(
                          'Academic Performance',
                          style: AppTextStyles.headline3.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Student ID Display
                  Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Student ID:', style: AppTextStyles.subtitle1bold),
                        Text(student.id, style: AppTextStyles.bodyText1),
                      ],
                    ),
                  ),
                  // GPA Display
                  Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('GPA:', style: AppTextStyles.subtitle1bold),
                        Text(student.gpa, style: AppTextStyles.bodyText1),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
