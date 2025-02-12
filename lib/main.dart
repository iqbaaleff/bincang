import 'package:bincang/firebase_options.dart';
import 'package:bincang/screens/home_page.dart';
import 'package:bincang/screens/login_page.dart';
import 'package:bincang/services/auth/auth_gate.dart';
import 'package:bincang/services/database/database_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(ChangeNotifierProvider(
    create: (context) => DatabaseProvider(),
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bincang',
      theme: ThemeData(
        fontFamily: 'Coolvetica',
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {'/': (context) => const AuthGate()},
    );
  }
}
