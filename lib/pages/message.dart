import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'chat_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class User {
  final String id;
  final String firstname;
  final String lastname;
  final DateTime lastMessageTime;

  User({
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.lastMessageTime,
  });
}

class MessageData {
  final String username;
  final String message;
  final DateTime createdAt;
  final String senderID;
  final String recieverID;
  final String urlAvatar;

  MessageData({
    required this.username,
    required this.message,
    required this.createdAt,
    required this.senderID,
    required this.recieverID,
    required this.urlAvatar,
  });
}

class MessagesPage extends StatelessWidget {
  MessagesPage({Key? key}) : super(key: key);

  // Dummy data
  final List<User> dummyUsers = [
    User(
      id: '1',
      firstname: 'John',
      lastname: 'Doe',
      lastMessageTime: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    User(
      id: '2',
      firstname: 'Jane',
      lastname: 'Smith',
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    User(
      id: '3',
      firstname: 'Mike',
      lastname: 'Johnson',
      lastMessageTime: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  // Dummy message previews
  final List<String> messagePreviews = [
    "Hey, how's the project coming along?",
    "Don't forget about our meeting tomorrow at 2 PM",
    "Thanks for your help with the documentation!",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CupertinoColors.systemBackground,
      appBar: AppBar(
        backgroundColor: CupertinoColors.systemBackground,
        title: Text(
          'Messages',
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: dummyUsers.length,
        itemBuilder: (context, index) {
          final user = dummyUsers[index];
          return _MessageTitle(
            messageData: MessageData(
              username: '${user.firstname} ${user.lastname}',
              message: messagePreviews[index],
              createdAt: user.lastMessageTime,
              senderID: 'current_user',
              recieverID: user.id,
              urlAvatar: 'https://i.pravatar.cc/150?img=${index + 1}',
            ),
          );
        },
      ),
    );
  }
}

class _MessageTitle extends StatelessWidget {
  const _MessageTitle({
    Key? key,
    required this.messageData,
  }) : super(key: key);

  final MessageData messageData;

  @override
  Widget build(BuildContext context) {
    final DateFormat formatter = DateFormat('h:mm a');
    final String formattedTime =
        formatter.format(messageData.createdAt.toLocal());
    return InkWell(
      onTap: () {
        Navigator.of(context).push(ChatScreen.route(messageData));
      },
      child: Container(
        height: 100,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey,
              width: 0.2,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(messageData.urlAvatar),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        messageData.username,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          letterSpacing: 0.2,
                          wordSpacing: 1.5,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                      child: Text(
                        messageData.message,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      formattedTime,
                      style: const TextStyle(
                        fontSize: 11,
                        letterSpacing: -0.2,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
