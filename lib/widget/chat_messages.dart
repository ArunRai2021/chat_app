import 'package:chat_app/widget/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context) {
    final authenticatedUser = FirebaseAuth.instance.currentUser;
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("chat")
          .orderBy("createdAt", descending: true)
          .snapshots(),
      builder: (context, chatSnapshots) {
        if (chatSnapshots.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!chatSnapshots.hasData || chatSnapshots.data!.docs.isEmpty) {
          return Center(child: Text("No Message Found"));
        }
        if (chatSnapshots.hasError) {
          return Center(child: Text("Something went wrong"));
        }
        final loadedMessages = chatSnapshots.data!.docs;
        return ListView.builder(
          padding: EdgeInsets.only(bottom: 40, left: 13, right: 13),
          reverse: true,
          itemCount: loadedMessages.length,
          itemBuilder: (BuildContext context, int index) {
            final chatMessage = loadedMessages[index].data();
            final nextChatMessage = index + 1 < loadedMessages.length
                ? loadedMessages[index + 1].data()
                : null;
            final currentMessagesUserName = chatMessage["username"];
            final nextMessageUsername = nextChatMessage != null
                ? nextChatMessage["username"]
                : null;
            final currentMessageUserId = chatMessage["userId"];
            final nextMessageUserId = nextChatMessage != null
                ? nextChatMessage["userId"]
                : null;
            final nextUserIsSame = nextMessageUserId == currentMessageUserId;
            if (nextUserIsSame) {
              return MessageBubble.first(
                message: chatMessage["text"],
                isMe: authenticatedUser?.uid == currentMessageUserId,
              );
            } else {
              return MessageBubble.first(
                userImage: chatMessage["userImage"],
                message: chatMessage["text"],
                username: chatMessage["username"],
                isMe: authenticatedUser?.uid == currentMessageUserId,
              );
            }
          },
        );
      },
    );
  }
}
