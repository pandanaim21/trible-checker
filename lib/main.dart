import 'package:flutter/material.dart';
import '../pages/user_page.dart';
import '../pages/home_page.dart';
import '../db/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final user = await DatabaseHelper().getUser();
  final initialRoute = user!.isNotEmpty ? '/home' : '/';
  runApp(MyApp(initialRoute));
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp(this.initialRoute, {super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: initialRoute,
      routes: {
        '/': (context) => const UserPage(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}
