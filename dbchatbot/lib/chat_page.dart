import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<types.Message> messages = [];
  final _user = const types.User(
      id: '82091008-a484-4a89-ae75-a22bf8d6f3ac'); //the id is hardcoded for now, use user id from db
  final _aiUser = const types.User(
    id: 'AI',
    firstName: 'Al Ottaha',
    imageUrl: 'assets/ai_avatar.png',
  );

  void _addMessage(types.Message message) {
    setState(() {
      messages.insert(0, message);
    });
  }

  void _handleSendPressed(types.PartialText message) {
    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: message.text,
    );

    _addMessage(textMessage);

    _fetchAIResponse(message.text);
  }

  Future<void> _fetchAIResponse(String userInput) async {
    try {
      var requestBody = {
        "model": "gpt-4o",
        "messages": [
          {
            "role": "system",
            "content":
                "Your name is Al Ottaha, you only answer about camels, you are a camel expert if asked anything about anything else than camels you say you are unaware of that topic. you randomly act a fool. you only answer what is asked and sound human like"
          },
          {"role": "user", "content": userInput}
        ]
      };

      var response = await http.post(
        Uri.parse("https://api.openai.com/v1/chat/completions"),
        headers: {
          "Authorization": "Bearer $Apikey",
          "Content-Type": "application/json",
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        String aiText = jsonResponse['choices'][0]['message']['content'];

        final aiMessage = types.TextMessage(
          author: _aiUser,
          createdAt: DateTime.now().millisecondsSinceEpoch,
          id: const Uuid().v4(),
          text: aiText,
        );

        _addMessage(aiMessage);
      } else {
        print("API Error: ${response.body}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Chat(
          messages: messages,
          onSendPressed: _handleSendPressed,
          user: _user,
          showUserNames: true,
          showUserAvatars: true,
          avatarBuilder: (user) {
            if (user.id == 'AI') {
              return CircleAvatar(
                backgroundImage: AssetImage('assets/aiavatar.jpg'),
                radius: 20,
              );
            }
            return Container(
              color: Colors.red,
            );
          },
        ), //this is the point where the chat widget is called
      ),
    );
  }
}
