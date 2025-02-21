import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:shimmer/shimmer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
// import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChatPage extends StatefulWidget {
  final String username;
  final String accessData;

  const ChatPage({Key? key, required this.username, required this.accessData})
      : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<types.Message> messages = [];
  bool isLoading = false; // Stores chat messages

  // Use the passed username as the user identifier
  late final types.User _user = types.User(
    id: widget.username,
    firstName: widget.username,
  );

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
      // Add a temporary "I'm thinking..." message
      final loadingMessage = types.TextMessage(
        author: _aiUser,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: const Uuid().v4(),
        text: "I'm thinking...",
        metadata: {"isLoading": true}, // Placeholder text
      );

      _addMessage(loadingMessage);
      // setState(() {
      //   isLoading = true;
      // });
      // Fetches data from the 'employees' table in Supabase
      final supabaseResponse =
          await Supabase.instance.client.from('employees').select();
      log('Supabase Response: $supabaseResponse'); // Logs the response
      final apiResponse = await http.post(
        Uri.parse(
            'http://localhost:8000/query'), // Ensure this URL matches your FastAPI endpoint  'http://192.168.1.39:8000/query', "http://127.0.0.1:8000/query"
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'query': userInput}),
      );
      // Prepares the request body for OpenAI's API
      // var requestBody = {
      //   "model": "gpt-4o", // Specifies the AI model to use
      //   "messages": [
      //     {
      //       "role": "system",
      //       "content":
      //           "Your name is Al Ottaha, you only answer about camels, you are a camel expert if asked anything about anything else than camels you say you are unaware of that topic. you randomly act a fool. you only answer what is asked and sound human like"
      //     },
      //     {"role": "user", "content": userInput} // User's message
      //   ]
      // };

      // Sends a POST request to OpenAI's API
      // var apiResponse = await http.post(
      //   Uri.parse("https://api.openai.com/v1/chat/completions"),
      //   headers: {
      //     // "Authorization": "Bearer ${dotenv.env['OPENAI_API_KEY']}", // API key for authentication
      //     "Content-Type": "application/json", // Specifies content type
      //   },
      //   body: jsonEncode(requestBody), // Converts request body to JSON
      // );

      // Checks if the request was successful
      if (apiResponse.statusCode == 200) {
        var jsonResponse =
            jsonDecode(apiResponse.body); // Decodes the JSON response
        String aiText = jsonResponse['output'];
        log('Query Result: $aiText');
        // String aiText = jsonResponse['choices'][0]['message']
        //     ['content']; // Extracts AI's response

        // Creates a message object for the AI's response
        final aiMessage = types.TextMessage(
          author: _aiUser, // Sets the author to the AI user
          createdAt:
              DateTime.now().millisecondsSinceEpoch, // Timestamp for message
          id: const Uuid().v4(), // Generates a unique ID for the message
          text: aiText, // AI's response text
        );
        setState(() {
          messages.remove(loadingMessage);
        });
        _addMessage(aiMessage); // Adds AI's response to the chat
      } else {
        String error_message =
            "There seems some error: ${apiResponse.statusCode}";
        final aiMessage = types.TextMessage(
          author: _aiUser, // Sets the author to the AI user
          createdAt:
              DateTime.now().millisecondsSinceEpoch, // Timestamp for message
          id: const Uuid().v4(), // Generates a unique ID for the message
          text: error_message, // AI's response text
        );
        _addMessage(aiMessage); // Adds AI's response to the chat
        log("API Error: ${apiResponse.body}"); // Logs error if API call fails
      }
    } catch (e) {
      print("Error: $e"); // Catches and prints any exceptions
    }
  }

  @override
  Widget build(BuildContext context) {
    // Builds the chat interface
    return Scaffold(
        appBar: AppBar(
          title: Text('Welcome, ${widget.username}'),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(child: Text('Access: ${widget.accessData}')),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Expanded(
                child: Chat(
                  messages: messages,
                  onSendPressed: _handleSendPressed,
                  user: _user,
                  showUserNames: true,
                  showUserAvatars: true,
                  customMessageBuilder: _customBubbleBuilder,
                  avatarBuilder: (user) {
                    if (user.id == 'AI') {
                      return CircleAvatar(
                        backgroundImage: AssetImage('assets/aiavatar.jpg'),
                        radius: 20,
                        foregroundColor: Colors.white,
                      );
                    }
                    return Container(color: Colors.red);
                  },
                ),
              ),
              // if (isLoading) // Show shimmer only if loading
              //   Padding(
              //     padding: const EdgeInsets.all(8.0),
              //     child: Row(
              //       mainAxisAlignment: MainAxisAlignment.center,
              //       children: [
              //         Shimmer.fromColors(
              //           baseColor: Colors.grey[300]!,
              //           highlightColor: Colors.grey[100]!,
              //           child: Row(
              //             children: [
              //               Container(
              //                 height: 14,
              //                 width: 14,
              //                 decoration: BoxDecoration(
              //                   color: Colors.grey[300],
              //                   shape: BoxShape.circle,
              //                 ),
              //               ),
              //               SizedBox(width: 10),
              //               Text(
              //                 "Al ottaha isthinking hard...",
              //                 style: TextStyle(
              //                   fontSize: 14,
              //                   color: Colors.grey[300],
              //                 ),
              //               ),
              //             ],
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
            ],
          ),
        ));
  }
}

Widget _customBubbleBuilder(
  types.CustomMessage message, {
  required int messageWidth,
}) {
  if (message.author.id == 'AI' &&
      message.metadata?['text'] == "I'm thinking...") {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          "I'm thinking...",
          style: TextStyle(color: Colors.black54),
        ),
      ),
    );
  }
  return Container(); // Return empty container for non-shimmer messages
}
