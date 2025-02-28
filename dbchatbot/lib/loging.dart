import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dbchatbot/chat_page.dart'; // Importing chat page for navigation after successful login

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  // Form key for validating user input
  final _formKey = GlobalKey<FormState>();
  // Controllers for capturing user input
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  // Function to handle user login
  Future<void> _login() async {
    final username = _usernameController.text.trim(); // Trim username input
    final password = _passwordController.text;

    // Query Supabase database to check for matching credentials
    final response = await Supabase.instance.client
        .from('user_credentials')
        .select('access_data')
        .eq('username', username)
        .eq('password', password)
        .maybeSingle(); // Fetch a single matching record if exists

    if (response != null) {
      final accessData = response['access_data'];
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login successful, access data: $accessData')),
      );
      // Navigate to chat page with username and access data
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                ChatPage(username: username, accessData: accessData)),
      );
    } else {
      // Show error message if credentials are incorrect
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid username or password')),
      );
    }
  }

  @override
  void dispose() {
    // Dispose controllers to free up resources
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Input field for username
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your username';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              // Input field for password
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32.0),
              // Login button
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await _login();
                  }
                },
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
