import 'package:ecu_scholar/services/auth_service/auth_service.dart';
import 'package:ecu_scholar/services/onboarding_service/onboarding_service.dart';
import 'package:ecu_scholar/services/notification_service/remote_notification_service.dart';
import 'package:ecu_scholar/view_models/auth_viewmodel.dart';
import 'package:ecu_scholar/view_models/grades_viewmodel.dart';
import 'package:ecu_scholar/view_models/onboarding_viewmodel.dart';
import 'package:ecu_scholar/view_models/student_viewmodel.dart';
import 'package:ecu_scholar/views/auth_page.dart';
import 'package:ecu_scholar/views/onboarding_page.dart';
import 'package:ecu_scholar/themes/theme_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ecu_scholar/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:ecu_scholar/services/sentry_service/error_handler.dart';
import 'view_models/schedule_list_viewmodel.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize notification service
  await RemoteNotificationService.instance.initialize();
  
  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Load environment variables
  await dotenv.load(fileName: '.env');
  
  // Initialize services
  await AuthService.instance.initialize();
  await OnboardingService.instance.initialize();
  
  // Initialize Sentry
  final sentryDsn = dotenv.env['SENTRY_DSN'];
  
  await SentryFlutter.init(
    (options) {
      options.dsn = sentryDsn;
      options.tracesSampleRate = 0.01;
    },
    appRunner: () {
      // Setup global error handlers
      ErrorHandler.setupGlobalErrorHandlers();
      
      runApp(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<ThemeProvider>(create: (context) => ThemeProvider()),
            ChangeNotifierProvider<AuthViewModel>(create: (context) => AuthViewModel()),
            ChangeNotifierProvider<OnboardingViewModel>(create: (context) => OnboardingViewModel()),
            ChangeNotifierProvider<ScheduleListViewModel>(create: (context) => ScheduleListViewModel()),
            ChangeNotifierProvider<StudentViewModel>(create: (context) => StudentViewModel()),
            ChangeNotifierProvider<GradesViewModel>(create: (context) => GradesViewModel()),
          ],
          child: const MyApp(),
        ),
      );
    },
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Load cached student data from SharedPreferences on app startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudentViewModel>().loadCachedStudentData();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    // Update theme when system brightness changes
    final brightness = View.of(context).platformDispatcher.platformBrightness;
    context.read<ThemeProvider>().updateFromSystem(brightness);
  }

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