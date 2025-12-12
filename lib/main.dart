// App entry point: initialize Firebase and setup theme & routes.
import 'package:chat_app/screens/auth_screen.dart';
import 'package:chat_app/screens/chat_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // replace with your generated file
import 'screens/splash_screen.dart';
import 'utils/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        primaryColor: AppColors.primary,
        appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 1),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      routes: {
        '/auth': (ctx) => const AuthScreen(),
        '/chats': (ctx) => const ChatListScreen(),
      },
    );
  }
}
