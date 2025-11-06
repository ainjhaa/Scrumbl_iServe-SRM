import 'package:demo_app/wrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'screens/auth/welcome_page.dart';
import 'screens/home_page.dart';
import 'screens/auth/login_page.dart';
import 'screens/auth/signup_page.dart';
import 'screens/auth/forgot_password_page.dart';
//import 'screens/auth/twofa_page.dart';
//import 'screens/profile_page.dart';
//import 'screens/notification_page.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const iServeSRM());
}

class iServeSRM extends StatelessWidget {
  const iServeSRM({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Rakan Muda App',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      initialRoute: '/welcome',
      routes: {
        '/welcome': (_) => const WelcomePage(),
        '/login': (_) => const LoginPage(),
        '/forgot': (_) => const ForgotPasswordPage(),
        '/signup': (_) => const SignUpPage(),
        '/home': (_) => const HomePage(),
        /*'/profile': (_) => const ProfilePage(),
        '/notification': (_) => const NotificationPage(),*/
      },
    );
  }
}
