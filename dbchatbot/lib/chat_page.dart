import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
// import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key}); // Constructor for ChatPage widget

  @override
  State<ChatPage> createState() => _ChatPageState(); // Creates state for ChatPage
}

class _ChatPageState extends State<ChatPage> {
  final List<types.Message> messages = []; // Stores chat messages

  // Represents the user sending messages
  final _user = const types.User(
      id: '82091008-a484-4a89-ae75-a22bf8d6f3ac'); 

  // Represents the AI user in the chat
  final _aiUser = const types.User(
    id: 'AI',
    firstName: 'Al Ottaha',
    imageUrl: 'assets/ai_avatar.png',
  );

  // Adds a new message to the chat
  void _addMessage(types.Message message) {
    setState(() {
      messages.insert(0, message); // Inserts the message at the top
    });
  }

  // Handles the event when the user sends a message
  void _handleSendPressed(types.PartialText message) {
    // Creates a text message object
    final textMessage = types.TextMessage(
      author: _user, // Sets the author to the current user
      createdAt: DateTime.now().millisecondsSinceEpoch, // Timestamp for message
      id: const Uuid().v4(), // Generates a unique ID for the message
      text: message.text, // Message content
    );

    _addMessage(textMessage); // Adds the user's message to the chat

    _fetchAIResponse(message.text); // Triggers AI response generation
  }

  // Fetches AI's response based on user input
  Future<void> _fetchAIResponse(String userInput) async {
    try {
      // Fetches data from the 'employees' table in Supabase
      final supabaseResponse = await Supabase.instance.client
          .from('employees')
          .select();
      log('Supabase Response: $supabaseResponse'); // Logs the response

      // Prepares the request body for OpenAI's API
      var requestBody = {
        "model": "gpt-4o", // Specifies the AI model to use
        "messages": [
          {
            "role": "system",
            "content":
                "Your name is Al Ottaha, you only answer about camels, you are a camel expert if asked anything about anything else than camels you say you are unaware of that topic. you randomly act a fool. you only answer what is asked and sound human like"
          },
          {"role": "user", "content": userInput} // User's message
        ]
      };

      // Sends a POST request to OpenAI's API
      var apiResponse = await http.post(
        Uri.parse("https://api.openai.com/v1/chat/completions"),
        headers: {
          // "Authorization": "Bearer ${dotenv.env['OPENAI_API_KEY']}", // API key for authentication
          "Content-Type": "application/json", // Specifies content type
        },
        body: jsonEncode(requestBody), // Converts request body to JSON
      );

      // Checks if the request was successful
      if (apiResponse.statusCode == 200) {
        var jsonResponse = jsonDecode(apiResponse.body); // Decodes the JSON response
        String aiText = jsonResponse['choices'][0]['message']['content']; // Extracts AI's response

        // Creates a message object for the AI's response
        final aiMessage = types.TextMessage(
          author: _aiUser, // Sets the author to the AI user
          createdAt: DateTime.now().millisecondsSinceEpoch, // Timestamp for message
          id: const Uuid().v4(), // Generates a unique ID for the message
          text: aiText, // AI's response text
        );

        _addMessage(aiMessage); // Adds AI's response to the chat
      } else {
        print("API Error: ${apiResponse.body}"); // Logs error if API call fails
      }
    } catch (e) {
      print("Error: $e"); // Catches and prints any exceptions
    }
  }

  @override
  Widget build(BuildContext context) {
    // Builds the chat interface
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0), // Adds padding around the chat
        child: Chat(
          messages: messages, // Passes the list of messages to the chat widget
          onSendPressed: _handleSendPressed, // Callback when user sends a message
          user: _user, // Sets the current user
          showUserNames: true, // Displays usernames in the chat
          showUserAvatars: true, // Displays avatars in the chat
          
          // Builds custom avatar for AI user
          avatarBuilder: (user) {
            if (user.id == 'AI') {
              return CircleAvatar(
                backgroundImage: AssetImage('assets/aiavatar.jpg'), // AI avatar image
                radius: 20,
                foregroundColor:  Colors.white,
              );
            }
            // Default avatar for other users
            return Container(
              color: Colors.red,
            );
          },
        ), // Displays the chat widget
      ),
    );
  }
}

