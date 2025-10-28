import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:dku_bears_kitchen/screens/login_screen.dart';
import 'firebase_options.dart'; // flutterfire configure 자동 생성 파일

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(BearsKitchenApp());
}

class BearsKitchenApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Bear's Kitchen",
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
