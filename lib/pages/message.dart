import 'package:flutter/cupertino.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';

class Client {
  final String id;
  final String name;
  final String lastMessage;
  final String time;
  final bool isOnline;

  Client({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.time,
    this.isOnline = false,
  });
}

class MessagePage extends StatefulWidget {
  const MessagePage({super.key});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  final List<Client> _clients = [
    Client(
      id: '1',
      name: 'John Doe',
      lastMessage: 'Hello, how are you?',
      time: '10:30 AM',
      isOnline: true,
    ),
    Client(
      id: '2',
      name: 'Jane Smith',
      lastMessage: 'Can we meet tomorrow?',
      time: '9:45 AM',
      isOnline: true,
    ),
    Client(
      id: '3',
      name: 'Mike Johnson',
      lastMessage: 'Thanks for your help!',
      time: 'Yesterday',
      isOnline: false,
    ),
    Client(
      id: '4',
      name: 'Sarah Wilson',
      lastMessage: 'The project is going well',
      time: 'Yesterday',
      isOnline: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Messages'),
        backgroundColor: CupertinoColors.systemBackground,
      ),
      child: SafeArea(
        child: ListView.builder(
          itemCount: _clients.length,
          itemBuilder: (context, index) {
            final client = _clients[index];
            return CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => ChatPage(client: client),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: CupertinoColors.systemBackground,
                  border: Border(
                    bottom: BorderSide(
                      color: CupertinoColors.systemGrey5,
                      width: 0.5,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: CupertinoColors.systemGrey5,
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: Center(
                            child: Text(
                              client.name[0],
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: CupertinoColors.systemGrey,
                              ),
                            ),
                          ),
                        ),
                        if (client.isOnline)
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: CupertinoColors.activeGreen,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: CupertinoColors.systemBackground,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                client.name,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: CupertinoColors.black,
                                ),
                              ),
                              Text(
                                client.time,
                                style: const TextStyle(
                                  color: CupertinoColors.systemGrey,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            client.lastMessage,
                            style: const TextStyle(
                              color: CupertinoColors.systemGrey,
                              fontSize: 15,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class ChatPage extends StatefulWidget {
  final Client client;

  const ChatPage({super.key, required this.client});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  WebSocketChannel? _channel;
  final List<ChatMessage> _messages = [];
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _connectWebSocket();
    // Add some dummy messages for UI testing
    _messages.addAll([
      ChatMessage(
        text: 'Hello! How can I help you today?',
        isMe: false,
        time: '10:30 AM',
      ),
      ChatMessage(
        text: 'I need some assistance with my project',
        isMe: true,
        time: '10:31 AM',
      ),
    ]);
  }

  void _connectWebSocket() {
    try {
      _channel = IOWebSocketChannel.connect(
        Uri.parse('ws://192.168.2.106:3001/ws'),
      );

      _channel!.stream.listen(
        (message) {
          setState(() {
            _messages.add(ChatMessage(
              text: message,
              isMe: false,
              time: _getCurrentTime(),
            ));
          });
          _scrollToBottom();
        },
        onError: (error) {
          //    print('WebSocket Error: $error');
        },
        onDone: () {
          //    print('WebSocket Connection Closed');
        },
      );
    } catch (e) {
      //    print('Failed to connect to WebSocket: $e');
    }
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour}:${now.minute.toString().padLeft(2, '0')}';
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() {
    if (_messageController.text.isNotEmpty && _channel != null) {
      final message = _messageController.text;
      _channel!.sink.add(message);
      setState(() {
        _messages.add(ChatMessage(
          text: message,
          isMe: true,
          time: _getCurrentTime(),
        ));
      });
      _messageController.clear();
      _scrollToBottom();
    }
  }

  @override
  void dispose() {
    _channel?.sink.close();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: CupertinoNavigationBar(
        middle: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey5,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Center(
                child: Text(
                  widget.client.name[0],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.client.name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (widget.client.isOnline)
                  const Text(
                    'Online',
                    style: TextStyle(
                      fontSize: 12,
                      color: CupertinoColors.activeGreen,
                    ),
                  ),
              ],
            ),
          ],
        ),
        backgroundColor: CupertinoColors.systemBackground,
      ),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return Align(
                    alignment: message.isMe
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.75,
                      ),
                      child: Column(
                        crossAxisAlignment: message.isMe
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: message.isMe
                                  ? CupertinoColors.activeBlue
                                  : CupertinoColors.systemBackground,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: CupertinoColors.systemGrey.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              message.text,
                              style: TextStyle(
                                color: message.isMe
                                    ? CupertinoColors.white
                                    : CupertinoColors.black,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            message.time,
                            style: const TextStyle(
                              color: CupertinoColors.systemGrey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: CupertinoColors.systemBackground,
                border: Border(
                  top: BorderSide(
                    color: CupertinoColors.systemGrey5,
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemGrey6,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: CupertinoTextField(
                        controller: _messageController,
                        placeholder: 'Type a message...',
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: null,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CupertinoButton(
                    padding: const EdgeInsets.all(8),
                    onPressed: _sendMessage,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: CupertinoColors.activeBlue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        CupertinoIcons.arrow_up,
                        color: CupertinoColors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isMe;
  final String time;

  ChatMessage({
    required this.text,
    required this.isMe,
    required this.time,
  });
}