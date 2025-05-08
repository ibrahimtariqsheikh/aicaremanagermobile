import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'message.dart';

class ChatScreen extends StatefulWidget {
  static Route route(MessageData data) => MaterialPageRoute(
        builder: (context) => ChatScreen(
          messageData: data,
        ),
      );

  const ChatScreen({
    Key? key,
    required this.messageData,
  }) : super(key: key);

  final MessageData messageData;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _textController = TextEditingController();
  final List<MessageData> _messages = [];

  @override
  void initState() {
    super.initState();
    // Add a dummy message for testing
    _messages.add(MessageData(
      username: widget.messageData.username,
      message: "Hello! How can I help you?",
      createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      senderID: widget.messageData.recieverID,
      recieverID: "current_user",
      urlAvatar: widget.messageData.urlAvatar,
    ));
  }

  void _sendMessage() {
    if (_textController.text.trim().isNotEmpty) {
      setState(() {
        _messages.insert(
          0,
          MessageData(
            username: "You",
            message: _textController.text,
            createdAt: DateTime.now(),
            senderID: "current_user",
            recieverID: widget.messageData.recieverID,
            urlAvatar: widget.messageData.urlAvatar,
          ),
        );
      });
      _textController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: _AppBarTitle(
          messageData: widget.messageData,
        ),
        backgroundColor: CupertinoColors.systemBackground,
        border: null,
      ),
      backgroundColor: CupertinoColors.systemBackground,
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                reverse: true,
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final DateFormat formatter = DateFormat('h:mm a');
                  final String formattedTime =
                      formatter.format(message.createdAt.toLocal());
                  return message.senderID == "current_user"
                      ? _MessageOwnTile(
                          message: message.message,
                          messageDate: formattedTime,
                        )
                      : _MessageTile(
                          message: message.message,
                          messageDate: formattedTime,
                        );
                },
              ),
            ),
            _ActionBar(
              textController: _textController,
              onSendMessage: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageTile extends StatelessWidget {
  const _MessageTile({
    Key? key,
    required this.message,
    required this.messageDate,
  }) : super(key: key);

  final String message;
  final String messageDate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey6,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
                child: Text(
                  message,
                  style: const TextStyle(
                    fontSize: 16,
                    color: CupertinoColors.black,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4.0, left: 8.0),
              child: Text(
                messageDate,
                style: const TextStyle(
                  color: CupertinoColors.systemGrey,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _MessageOwnTile extends StatelessWidget {
  const _MessageOwnTile({
    Key? key,
    required this.message,
    required this.messageDate,
  }) : super(key: key);

  final String message;
  final String messageDate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Align(
        alignment: Alignment.centerRight,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              decoration: BoxDecoration(
                color: CupertinoColors.activeBlue,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
                child: Text(
                  message,
                  style: const TextStyle(
                    fontSize: 16,
                    color: CupertinoColors.white,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4.0, right: 8.0),
              child: Text(
                messageDate,
                style: const TextStyle(
                  color: CupertinoColors.systemGrey,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _AppBarTitle extends StatelessWidget {
  const _AppBarTitle({
    Key? key,
    required this.messageData,
  }) : super(key: key);

  final MessageData messageData;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundImage: NetworkImage(messageData.urlAvatar),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                messageData.username,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Online now',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: CupertinoColors.systemGreen,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({
    Key? key,
    required this.textController,
    required this.onSendMessage,
  }) : super(key: key);

  final TextEditingController textController;
  final VoidCallback onSendMessage;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: CupertinoColors.systemGrey5,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        bottom: true,
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey6,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 12),
                      Expanded(
                        child: CupertinoTextField(
                          controller: textController,
                          style: const TextStyle(fontSize: 16),
                          placeholder: 'Message',
                          decoration: null,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                      CupertinoButton(
                        padding: const EdgeInsets.all(8),
                        onPressed: onSendMessage,
                        child: const Icon(
                          CupertinoIcons.arrow_up_circle_fill,
                          color: CupertinoColors.activeBlue,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
