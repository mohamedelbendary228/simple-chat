import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:simple_chat_app/widgets/chat_messages_list.dart';
import 'package:simple_chat_app/widgets/new_message_form.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat Screen"),
        actions: [
          IconButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
              },
              color: Theme.of(context).colorScheme.primary,
              icon: const Icon(Icons.exit_to_app))
        ],
      ),
      body: Column(
        children: const [
          Expanded(
            child: ChatMessages(),
          ),
          NewMessageTextField(),
        ],
      ),
    );
  }
}
