import 'package:ecu_scholar/services/auth_service/auth_service.dart';
import 'package:ecu_scholar/view_models/auth_viewmodel.dart';
import 'package:ecu_scholar/view_models/student_viewmodel.dart';
import 'package:ecu_scholar/views/auth_page.dart';
import 'package:ecu_scholar/themes/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'view_models/schedule_list_viewmodel.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables (for base URL, etc.)
  await dotenv.load(fileName: '.env');
  
  // Initialize auth service
  await AuthService.instance.initialize();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>(create: (context) => ThemeProvider()),
        ChangeNotifierProvider<AuthViewModel>(create: (context) => AuthViewModel()),
        ChangeNotifierProvider<ScheduleListViewModel>(create: (context) => ScheduleListViewModel()),
        ChangeNotifierProvider<StudentViewModel>(create: (context) => StudentViewModel()),
        // Add more providers here as needed
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AuthPage(),
      theme: Provider.of<ThemeProvider>(context).themeData,
    );
  }
}