import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bear\'s Kitchen',
      home: Scaffold(
        appBar: AppBar(title: const Text('Firebase 연결 완료!')),
        body: const Center(child: Text('연결 성공 🎉')),
      ),
    );
  }
}
