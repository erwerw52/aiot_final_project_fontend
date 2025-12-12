import 'package:aiot_final_project_fontend/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aiot_final_project_fontend/pages/launch_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Travel Planner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF667EEA),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      initialRoute: '/launch',
      routes: {
        '/launch': (context) => LaunchPage(
          modelUrl:
              'https://github.com/duixcom/Duix-Mobile/releases/download/v2.0.1/Lily.zip',
          modelName: 'Lily',
          onCompleted: () {
            Navigator.of(context).pushReplacementNamed('/home');
          },
        ),
        '/home': (context) => const HomePage(),
      },
    );
  }
}
