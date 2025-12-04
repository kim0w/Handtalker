import 'package:flutter/material.dart';
import 'src/navigation/main_navigation.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HandTalk',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainNavigation(),
    );
  }
}
