import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:simple_chat_app/widgets/message_bubble.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final fireStoreInstance = FirebaseFirestore.instance;
    final authenticatedUser = FirebaseAuth.instance.currentUser;
    final chatStream = fireStoreInstance
        .collection("chats")
        .orderBy("createdAt", descending: true)
        .snapshots();

    return StreamBuilder(
      stream: chatStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox();
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text("No messages found"),
          );
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text("Something went wrong..."),
          );
        }
        final chatDocs = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 20, right: 14, left: 14),
          reverse: true,
          itemCount: chatDocs.length,
          itemBuilder: (context, index) {
            final message = chatDocs[index].data();
            final nextMessage =
                index + 1 < chatDocs.length ? chatDocs[index + 1].data() : null;

            final currentMessageUserId = message["userId"];
            final nextMessageUserId =
                nextMessage != null ? nextMessage["userId"] : null;

            final nextUserIsSame = nextMessageUserId == currentMessageUserId;

            if (nextUserIsSame) {
              return MessageBubble.next(
                  message: message["text"],
                  isMe: authenticatedUser!.uid == currentMessageUserId);
            } else {
              return MessageBubble.first(
                userImage: message["userImage"],
                username: message["username"],
                message: message["text"],
                isMe: authenticatedUser!.uid == currentMessageUserId,
              );
            }
          },
        );
      },
    );
  }
}
