import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../data/chat_repository.dart';

class ChatPage extends StatefulWidget {
  final String matchId;

  const ChatPage({super.key, required this.matchId});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final repo = ChatRepository();
  final controller = TextEditingController();
  final scrollController = ScrollController();

  String get myUid => FirebaseAuth.instance.currentUser!.uid;

  @override
  void dispose() {
    controller.dispose();
    scrollController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = controller.text.trim();
    if (text.isEmpty) return;

    await repo.sendMessage(widget.matchId, text);
    controller.clear();

    // listeyi en alta kaydır
    await Future.delayed(const Duration(milliseconds: 100));
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chat")),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: repo.watchMessages(widget.matchId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (scrollController.hasClients) {
                    scrollController.jumpTo(
                      scrollController.position.maxScrollExtent,
                    );
                  }
                });

                return ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(12),
                  itemCount: docs.length,
                  itemBuilder: (context, i) {
                    final data = docs[i].data();
                    final text = (data['text'] ?? '').toString();
                    final senderId = (data['senderId'] ?? '').toString();
                    final isMe = senderId == myUid;

                    return Align(
                      alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 12,
                        ),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75,
                        ),
                        decoration: BoxDecoration(
                          color: isMe
                              ? Colors.purple.shade200
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          text,
                          style: const TextStyle(fontSize: 15),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // INPUT BAR
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: const InputDecoration(
                        hintText: "Mesaj yaz...",
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _send,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
