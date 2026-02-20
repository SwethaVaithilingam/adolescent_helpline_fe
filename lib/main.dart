import 'package:adolescent_helpline/features/presentation/screens/questionnaire_screen.dart';
import 'package:adolescent_helpline/features/presentation/screens/dass21_screen.dart';
import 'package:adolescent_helpline/features/presentation/screens/home_screen.dart';
import 'package:adolescent_helpline/features/presentation/screens/login_screen.dart';
import 'package:adolescent_helpline/features/presentation/screens/profile_screen.dart';
import 'package:adolescent_helpline/features/presentation/screens/signup_screen.dart';
import 'package:adolescent_helpline/features/presentation/screens/phq9_screen.dart';
import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
// import 'features/home/home_page.dart';
// import 'features/forms/pages/form_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Purple Form App',
      debugShowCheckedModeBanner: false,

      // Global purple theme
      theme: AppTheme.lightTheme,

      // Initial screen
      initialRoute: '/login',

      // App routes
      routes: {
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/home': (context) => const HomePage(),
        '/questionnaire': (context) => const QuestionnairePage(),
        '/profile':(context) => const ProfilePage(),
        '/dass21':(context) => const Dass21Page(),
        '/phq9':(context) => const Phq9Page()
      },
    );
  }
}
