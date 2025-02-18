import 'package:dbchatbot/chat_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
    await Supabase.initialize(
    url: 'https://zofdiwijmmeltnrrjxux.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpvZmRpd2lqbW1lbHRucnJqeHV4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzk3ODc3NTQsImV4cCI6MjA1NTM2Mzc1NH0.nPvbUsI_GHpoX_dpqvBxv6Xd2_kz_SPxamgHhThmR78',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ChatPage(), //this is the entry point for the program
    );
  }
}
