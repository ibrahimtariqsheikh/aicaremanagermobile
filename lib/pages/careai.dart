import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:aicaremanagermob/controller/socket_handler.dart';
import 'package:aicaremanagermob/models/chat_message.dart';
import 'package:aicaremanagermob/widgets/chat_bubble.dart';
import 'dart:async';

class CareAiPage extends StatefulWidget {
  static const routeName = '/care-ai';
  final String id;
  final String? email;
  
  const CareAiPage({
    super.key, 
    required this.id,
    required this.email,
  });

  @override
  State<CareAiPage> createState() => _CareAiPageState();
}

class _CareAiPageState extends State<CareAiPage> {
  late SocketHandler socketHandler;
  bool isFetchingResponse = false;
  final List<ChatMessage> messages = [];
  Timer? _typingTimer;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    socketHandler = SocketHandler(
      serverUrl: 'http://192.168.0.148:9000',
    );
    socketHandler.subscribeToMessages(onMessageReceived);
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    socketHandler.disconnect();
    super.dispose();
  }

  void onMessageReceived(String message) {
    _typingTimer?.cancel();
    setState(() {
      isFetchingResponse = false;
      messages.insert(
        0,
        ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: message,
          createdAt: DateTime.now(),
          senderId: 'careai',
          senderName: 'Care AI',
          senderAvatar: 'assets/images/careai.png',
        ),
      );
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final message = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: _messageController.text,
      createdAt: DateTime.now(),
      senderId: widget.id,
      senderName: widget.email,
    );

    setState(() {
      isFetchingResponse = true;
      messages.insert(0, message);
      _messageController.clear();
    });
    
    _scrollToBottom();
    
    // Start a timer to stop typing indicators after 30 seconds
    _typingTimer = Timer(const Duration(seconds: 30), () {
      if (mounted && isFetchingResponse) {
        setState(() {
          isFetchingResponse = false;
        });
      }
    });
    
    socketHandler.sendMessage(message.text);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Care AI',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.none,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(LucideIcons.settings),
              onPressed: () {
                // Settings action
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                reverse: true,
                padding: const EdgeInsets.symmetric(vertical: 16),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  return ChatBubble(
                    message: message.text,
                    isMe: message.senderId == widget.id,
                    avatarUrl: message.senderAvatar,
                    timestamp: message.createdAt,
                  );
                },
              ),
            ),
            if (isFetchingResponse)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    Text(
                      'Care AI is typing...',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.cardColor,
                border: Border(
                  top: BorderSide(
                    color: theme.dividerColor.withValues(alpha: 0.1),
                    width: 0.5,
                  ),
                ),
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFE9E9EB),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _messageController,
                                decoration: InputDecoration(
                                  hintText: 'Type a message...',
                                  hintStyle: TextStyle(
                                    fontWeight: FontWeight.w100,
                                    color: Colors.black.withValues(alpha: 0.5),
                                    fontSize: 16,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                ),
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w100,
                                ),
                                maxLines: null,
                                textCapitalization: TextCapitalization.sentences,
                              ),
                            ),
                            ValueListenableBuilder<TextEditingValue>(
                              valueListenable: _messageController,
                              builder: (context, value, child) {
                                return IconButton(
                                  icon: Icon(
                                    LucideIcons.send,
                                    color: value.text.trim().isEmpty
                                        ? Colors.black.withValues(alpha: 0.3)
                                        : const Color(0xFF007AFF),
                                    size: 20,
                                  ),
                                  onPressed: value.text.trim().isEmpty
                                      ? null
                                      : _sendMessage,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}