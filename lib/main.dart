import 'package:cattle_detection/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); // Initialize Firebase
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cattle Detection',
      theme: ThemeData.light().copyWith(
          floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: Colors.black,
      )),
      initialRoute: HomeScreen.id,
      routes: {
        HomeScreen.id: (context) => HomeScreen(),
      },
    );
  }
}
