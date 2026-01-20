import 'package:ecu_scholar/services/auth_service/auth_service.dart';
import 'package:ecu_scholar/services/onboarding_service/onboarding_service.dart';
import 'package:ecu_scholar/view_models/auth_viewmodel.dart';
import 'package:ecu_scholar/view_models/onboarding_viewmodel.dart';
import 'package:ecu_scholar/view_models/student_viewmodel.dart';
import 'package:ecu_scholar/views/auth_page.dart';
import 'package:ecu_scholar/views/onboarding_page.dart';
import 'package:ecu_scholar/themes/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ecu_scholar/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'view_models/schedule_list_viewmodel.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: '.env');
  
  // Initialize services
  await AuthService.instance.initialize();
  await OnboardingService.instance.initialize();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>(create: (context) => ThemeProvider()),
        ChangeNotifierProvider<AuthViewModel>(create: (context) => AuthViewModel()),
        ChangeNotifierProvider<OnboardingViewModel>(create: (context) => OnboardingViewModel()),
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
    // Determine initial screen based on onboarding status
    final bool isOnboardingComplete = OnboardingService.instance.isOnboardingComplete;
    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // Localization
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
      ],
      home: isOnboardingComplete ? const AuthPage() : const OnboardingPage(),
      theme: Provider.of<ThemeProvider>(context).themeData,
    );
  }
}