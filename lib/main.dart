import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/result_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Boulder AI',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/result': (context) {
          final Map<String, dynamic> result =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>;
          return ResultScreen(processedResult: result);
        },
      },
    );
  }
}
