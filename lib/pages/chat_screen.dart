import 'package:aicaremanagermob/configs/app_theme.dart';
import 'package:aicaremanagermob/providers/conversation_provider.dart';
import 'package:aicaremanagermob/utils/toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:aicaremanagermob/models/message.dart';
import 'package:aicaremanagermob/models/message_data.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aicaremanagermob/providers/schedule_provider.dart';
import 'package:aicaremanagermob/models/schedule.dart';
import 'package:aicaremanagermob/services/socket_service.dart';
import 'package:aicaremanagermob/providers/auth_provider.dart';
import 'package:aicaremanagermob/configs/app_api_config.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:aicaremanagermob/widgets/typing_indicator.dart';

class ChatScreen extends ConsumerStatefulWidget {
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
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen>
    with SingleTickerProviderStateMixin {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isTyping = false;
  Timer? _typingTimer;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  static const int _messagesPerPage = 20;
  bool _isDisposed = false;
  AnimationController? _typingAnimationController;

  @override
  void initState() {
    super.initState();
    _initializeAnimationController();
    _setupSocketListeners();
    _setupScrollListener();
    Future(() => _initializeChat());
  }

  void _initializeAnimationController() {
    _typingAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    _textController.dispose();
    _typingTimer?.cancel();
    _scrollController.dispose();
    _typingAnimationController?.dispose();
    final socketService = ref.read(socketServiceProvider);
    socketService.dispose();
    super.dispose();
  }

  void _safeSetState(VoidCallback fn) {
    if (!_isDisposed && mounted) {
      setState(fn);
    }
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent * 0.8) {
        _loadMoreMessages();
      }
    });
  }

  Future<void> _loadMoreMessages() async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final conversationNotifier = ref.read(conversationProvider.notifier);
      await conversationNotifier.loadMoreMessages(
        conversationId: ref.read(conversationProvider).conversation?.id ?? '',
        page: _currentPage + 1,
        limit: _messagesPerPage,
      );

      if (mounted) {
        setState(() {
          _currentPage++;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
        _showToast('Error loading more messages', isError: true);
      }
    }
  }

  void _setupSocketListeners() {
    final socketService = ref.read(socketServiceProvider);
    final authState = ref.read(authProvider);

    print('🔌 [Chat] Setting up socket listeners');
    print('🔌 [Chat] User ID: ${authState.user.id}');
    print('🔌 [Chat] Receiver ID: ${widget.messageData.receiverID}');

    // Connect to socket
    socketService.connect(authState.user.id);

    // Join the conversation room
    socketService.joinRoom(widget.messageData.receiverID);

    // Listen to the message stream for both messages and typing events
    socketService.messageStream.listen((data) {
      if (_isDisposed || !mounted) {
        print('❌ [Chat] Component disposed or not mounted');
        return;
      }

      try {
        print('📨 [Chat] Received event from stream');
        print('📨 [Chat] Event data: $data');

        // Handle typing events
        if (data is Map && data['type'] == 'typing') {
          print('📝 [Chat] Processing typing event');
          final typingData = data['data'];
          final userId = data['userId'];
          final currentConversationId =
              ref.read(conversationProvider).conversation?.id;

          print('📝 [Chat] Typing data: $typingData');
          print('📝 [Chat] User ID: $userId');
          print('📝 [Chat] Current conversation ID: $currentConversationId');

          // Check if this is for the current conversation
          if (typingData['conversationId'] != currentConversationId) {
            print('❌ [Chat] Conversation ID mismatch');
            return;
          }

          // Check if this is from the current user
          if (userId == authState.user.id) {
            print('❌ [Chat] Typing event from current user');
            return;
          }

          // Update typing status
          print('✅ [Chat] Setting typing status to: ${typingData['isTyping']}');
          _updateTypingStatus(typingData['isTyping'] == true);
          return;
        }

        // Handle regular messages
        if (data == null) return;

        // Get the message data whether it's in an array or direct object
        final messageData = data is List ? data[0] : data;

        // Get current user ID from auth provider
        final currentUserId = ref.read(authProvider).user.id;
        final senderId = messageData['senderId'] ?? '';

        print('📨 [Chat] Received message from sender: $senderId');
        print('📨 [Chat] Current user ID: $currentUserId');

        // Strictly check if message is from current user
        if (senderId == currentUserId) {
          print('📨 [Chat] Skipping own message - sender matches current user');
          return;
        }

        // Additional check for conversation ID
        final conversationId = messageData['conversationId'] ?? '';
        final currentConversationId =
            ref.read(conversationProvider).conversation?.id;

        if (conversationId != currentConversationId) {
          print('📨 [Chat] Skipping message - conversation ID mismatch');
          return;
        }

        final message = Message(
          id: messageData['id'] ??
              DateTime.now().millisecondsSinceEpoch.toString(),
          content: messageData['content'] ?? '',
          senderId: senderId,
          conversationId: conversationId,
          sentAt: messageData['sentAt'] != null
              ? DateTime.parse(messageData['sentAt'])
              : DateTime.now(),
          updatedAt: messageData['updatedAt'] != null
              ? DateTime.parse(messageData['updatedAt'])
              : DateTime.now(),
          createdAt: messageData['createdAt'] != null
              ? DateTime.parse(messageData['createdAt'])
              : DateTime.now(),
          agencyId: messageData['agencyId'] ?? '',
        );

        // Get current conversation state
        final currentState = ref.read(conversationProvider);
        final conversationNotifier = ref.read(conversationProvider.notifier);

        // Check if conversation exists and message already exists in conversation
        if (currentState.conversation != null) {
          print('📨 [Chat] Checking for duplicate message');
          print('📨 [Chat] Message ID: ${message.id}');
          print(
              '📨 [Chat] Current messages count: ${currentState.conversation!.messages.length}');

          // More thorough duplicate check
          final exists = currentState.conversation!.messages.any((m) {
            final isDuplicate = m.id == message.id ||
                (m.content == message.content &&
                    m.senderId == message.senderId &&
                    m.createdAt.difference(message.createdAt).inSeconds.abs() <
                        2);
            if (isDuplicate) {
              print('📨 [Chat] Found duplicate message: ${m.id}');
            }
            return isDuplicate;
          });

          if (!exists) {
            print('📨 [Chat] Adding new message to conversation');
            _safeSetState(() {
              final updatedMessages = [
                message,
                ...currentState.conversation!.messages
              ];
              conversationNotifier.updateConversation(
                currentState.conversation!.copyWith(
                  messages: updatedMessages,
                ),
              );
            });

            // Scroll to the new message
            if (!_isDisposed && mounted) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_scrollController.hasClients) {
                  _scrollController.animateTo(
                    0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
                }
              });
            }
          } else {
            print('📨 [Chat] Skipping duplicate message');
          }
        }
      } catch (e) {
        if (!_isDisposed && mounted) {
          _showToast('Error processing event: ${e.toString()}', isError: true);
        }
      }
    });
  }

  void _updateTypingStatus(bool isTyping) {
    if (_isDisposed || !mounted) return;

    setState(() {
      _isTyping = isTyping;
      if (isTyping) {
        _typingAnimationController?.repeat(reverse: true);
      } else {
        _typingAnimationController?.stop();
      }
    });
  }

  Future<void> _initializeChat() async {
    if (!mounted) return;

    showToast(
        'senderId: ${widget.messageData.senderID}\n receiverId: ${widget.messageData.receiverID}');

    try {
      final conversationNotifier = ref.read(conversationProvider.notifier);
      await conversationNotifier.getOrCreateConversation(
        senderId: widget.messageData.senderID,
        receiverId: widget.messageData.receiverID,
      );
    } catch (e) {
      if (!mounted) return;
      _showToast('Error initializing chat: ${e.toString()}', isError: true);
    }
  }

  Future<void> _sendMessage() async {
    if (_textController.text.trim().isNotEmpty) {
      try {
        final socketService = ref.read(socketServiceProvider);
        final authState = ref.read(authProvider);
        final conversationState = ref.read(conversationProvider);
        final conversationNotifier = ref.read(conversationProvider.notifier);

        final message = Message(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          content: _textController.text,
          createdAt: DateTime.now(),
          senderId: authState.user.id,
          conversationId: conversationState.conversation?.id ?? '',
          sentAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        if (!mounted) return;

        if (conversationState.conversation != null) {
          final updatedMessages = [
            message,
            ...conversationState.conversation!.messages
          ];
          setState(() {
            conversationNotifier.updateConversation(
              conversationState.conversation!.copyWith(
                messages: updatedMessages,
              ),
            );
          });
        }

        await socketService.sendMessage(
          content: _textController.text,
          roomId: conversationState.conversation?.id ?? '',
          senderId: authState.user.id,
        );

        const String agencyId = AppApiConfig.currentTestingAgencyId;
        await conversationNotifier.sendMessage(
            message, agencyId, authState.user.id);

        if (!mounted) return;
        _textController.clear();
      } catch (e) {
        if (!mounted) return;
        if (e.toString().contains('Failed to save message')) {
          _showToast('Error sending message', isError: true);
        }
      }
    }
  }

  void _handleTyping(String text) {
    print('📝 [Chat] Handling typing event');
    print('📝 [Chat] Text length: ${text.length}');

    final socketService = ref.read(socketServiceProvider);
    final authState = ref.read(authProvider);
    final conversationState = ref.read(conversationProvider);

    // Cancel existing timer
    _typingTimer?.cancel();

    // Set typing status
    print('📝 [Chat] Sending typing status: true');
    socketService.sendTypingStatus(
      conversationId: conversationState.conversation?.id ?? '',
      userId: authState.user.id,
      isTyping: true,
    );

    // Set timer to clear typing status
    _typingTimer = Timer(const Duration(seconds: 2), () {
      print('📝 [Chat] Sending typing status: false');
      socketService.sendTypingStatus(
        conversationId: conversationState.conversation?.id ?? '',
        userId: authState.user.id,
        isTyping: false,
      );
    });
  }

  void _showToast(String message, {bool isError = false}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: isError ? Colors.red : Colors.black87,
      textColor: Colors.white,
    );
  }

  String _formatScheduleType(String scheduleType) {
    return scheduleType
        .toLowerCase()
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final conversationState = ref.watch(conversationProvider);
    final scheduleState = ref.watch(scheduleNotifierProvider);

    // Get all upcoming schedules for this client
    final now = DateTime.now();
    final clientId = widget.messageData.clientId;

    final clientUpcomingSchedules = clientId != null
        ? scheduleState.schedules
            .where((schedule) =>
                schedule.clientId == clientId &&
                schedule.date.isAfter(now) &&
                schedule.status != 'CANCELED')
            .toList()
        : <Schedule>[];

    // Sort schedules by date (closest first)
    clientUpcomingSchedules.sort((a, b) => a.date.compareTo(b.date));

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: _AppBarTitle(
          messageData: widget.messageData,
        ),
        backgroundColor: AppColors.background,
        border: null,
      ),
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: Column(
          children: [
            // Display schedule info if available
            if (clientUpcomingSchedules.isNotEmpty)
              _buildAllSchedulesInfo(clientUpcomingSchedules),

            // Show loading indicator when loading more messages
            if (_isLoadingMore)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: CupertinoActivityIndicator(),
              ),

            Expanded(
              child: Stack(
                children: [
                  conversationState.isLoading
                      ? const Center(child: CupertinoActivityIndicator())
                      : conversationState.error != null
                          ? Center(
                              child: Text(
                                conversationState.error!,
                                style: const TextStyle(color: Colors.red),
                              ),
                            )
                          : ListView.builder(
                              controller: _scrollController,
                              reverse: true,
                              padding: const EdgeInsets.only(
                                left: 8.0,
                                right: 8.0,
                                bottom: 40.0,
                              ),
                              itemCount: conversationState
                                      .conversation?.messages.length ??
                                  0,
                              itemBuilder: (context, index) {
                                final messages =
                                    conversationState.conversation!.messages;
                                messages.sort((a, b) =>
                                    b.createdAt.compareTo(a.createdAt));
                                final message = messages[index];
                                final DateFormat formatter =
                                    DateFormat('h:mm a');
                                final String formattedTime = formatter
                                    .format(message.createdAt.toLocal());
                                final authState = ref.read(authProvider);
                                return message.senderId == authState.user.id
                                    ? _MessageOwnTile(
                                        message: message.content,
                                        messageDate: formattedTime,
                                        senderName: 'You',
                                      )
                                    : _MessageTile(
                                        message: message.content,
                                        messageDate: formattedTime,
                                        senderName: widget.messageData.username,
                                      );
                              },
                            ),
                  // Show typing indicator at the bottom left
                  Positioned(
                    left: 16,
                    bottom: 12,
                    child: AnimatedOpacity(
                      opacity: _isTyping ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: _typingAnimationController != null
                          ? TypingIndicator(
                              animationController: _typingAnimationController!,
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),
                ],
              ),
            ),
            _ActionBar(
              textController: _textController,
              onSendMessage: _sendMessage,
              onTyping: _handleTyping,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllSchedulesInfo(List<Schedule> schedules) {
    if (schedules.isEmpty) return const SizedBox.shrink();

    final dateFormatter = DateFormat('EEE, MMM d');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Upcoming Visits',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.blue.shade800,
            ),
          ),
          const SizedBox(height: 8),
          ...schedules.take(3).map((schedule) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Icon(
                    CupertinoIcons.calendar,
                    size: 14,
                    color: _getScheduleTypeColor(schedule.type.toString()),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${dateFormatter.format(schedule.date)} • ${schedule.startTime}',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getScheduleTypeColor(schedule.type.toString())
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _formatScheduleType(schedule.type.toString()),
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: _getScheduleTypeColor(schedule.type.toString()),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),

          // If there are more schedules, show a count
          if (schedules.length > 3)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '+ ${schedules.length - 3} more upcoming visits',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.blue.shade800,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getScheduleTypeColor(String scheduleType) {
    switch (scheduleType.toLowerCase()) {
      case 'scheduletype.homevisit':
        return Colors.green;
      case 'scheduletype.appointment':
        return Colors.purple;
      case 'scheduletype.weeklycheckup':
        return Colors.blue;
      case 'scheduletype.checkup':
        return Colors.cyan;
      case 'scheduletype.emergency':
        return Colors.red;
      case 'scheduletype.routine':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }
}

class _MessageTile extends StatelessWidget {
  const _MessageTile({
    Key? key,
    required this.message,
    required this.messageDate,
    required this.senderName,
  }) : super(key: key);

  final String message;
  final String messageDate;
  final String senderName;

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
                '$senderName • $messageDate',
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
    required this.senderName,
  }) : super(key: key);

  final String message;
  final String messageDate;
  final String senderName;

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
                '$senderName • $messageDate',
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
          backgroundImage: messageData.urlAvatar != null
              ? NetworkImage(messageData.urlAvatar!)
              : null,
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
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                formatRole(messageData.role),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

String formatRole(Role role) {
  return role.name
      .toUpperCase()
      .replaceAll('_', ' ')
      .split(' ')
      .map((word) => word[0].toUpperCase() + word.substring(1))
      .join(' ');
}

class _ActionBar extends StatelessWidget {
  final TextEditingController textController;
  final VoidCallback onSendMessage;
  final Function(String) onTyping;

  const _ActionBar({
    Key? key,
    required this.textController,
    required this.onSendMessage,
    required this.onTyping,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: true,
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(12),
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
                        onChanged: onTyping,
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
    );
  }
}
