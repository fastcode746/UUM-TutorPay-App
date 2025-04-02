import 'package:fee_app/config/theme.dart';
import 'package:fee_app/screens/student/dashboard_screen.dart';
import 'package:fee_app/screens/tutor/dashboard_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'screens/OnBoarding/onboarding_screen.dart';
import 'services/helper_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isUserLoggedIn = false;
  bool userType = false;

  @override
  void initState() {
    getUserLoggedInStatus();
    getUserTypefromSF();
    super.initState();
  }

  Future<void> getUserLoggedInStatus() async {
    await HelperFunctions.getUserLoggedInStatus().then((value) {
      if (value != null) {
        setState(() {
          isUserLoggedIn = value;
        });
      }
    });
  }

  Future<void> getUserTypefromSF() async {
    await HelperFunctions.getUserType().then((value) {
      if (value != null) {
        setState(() {
          userType = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tutor App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        pageTransitionsTheme: PageTransitionsTheme(
          builders: {TargetPlatform.android: CupertinoPageTransitionsBuilder()},
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors().appNavyColor),
      ),
      home:
          isUserLoggedIn
              ? userType
                  ? StudentDashboardScreen()
                  : TutorDashboardScreen()
              : OnBoardingScreen(),
    );
  }
}
