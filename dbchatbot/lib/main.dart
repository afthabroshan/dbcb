import 'package:dbchatbot/chat_page.dart';
import 'package:dbchatbot/loging.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  // Ensures that Flutter widgets are initialized before running asynchronous operations.
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase with the project's URL and anonymous key.
  await Supabase.initialize(
    url: 'https://zofdiwijmmeltnrrjxux.supabase.co', // Supabase project URL
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpvZmRpd2lqbW1lbHRucnJqeHV4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzk3ODc3NTQsImV4cCI6MjA1NTM2Mzc1NH0.nPvbUsI_GHpoX_dpqvBxv6Xd2_kz_SPxamgHhThmR78', // Supabase anonymous access key
  );

  // Runs the Flutter application
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo', // App title
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple), // Defines the color scheme
        useMaterial3: true, // Enables Material 3 design
      ),
      home:
          const Login(), // Entry point of the application, directs to the Login screen
    );
  }
}
