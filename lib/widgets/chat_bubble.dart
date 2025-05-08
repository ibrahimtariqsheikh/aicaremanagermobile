import 'package:flutter/material.dart';

class ChatBubble extends StatefulWidget {
  final String message;
  final bool isMe;
  final String? avatarUrl;
  final DateTime timestamp;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.avatarUrl,
    required this.timestamp,
  });

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  bool _showTime = false;
  double _startDragX = 0;
  final double _dragThreshold = 40.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    // Different animations for sender vs receiver
    if (widget.isMe) {
      _slideAnimation = Tween<double>(begin: 0, end: -40).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOut),
      );
    } else {
      _slideAnimation = Tween<double>(begin: 0, end: 40).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOut),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleDragStart(DragStartDetails details) {
    _startDragX = details.globalPosition.dx;
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    final dragDelta = details.globalPosition.dx - _startDragX;

    // Handle drag in correct direction based on sender/receiver
    if ((widget.isMe && dragDelta < 0) || (!widget.isMe && dragDelta > 0)) {
      final dragPercentage = (dragDelta.abs() / _dragThreshold).clamp(0.0, 1.0);
      _controller.value = dragPercentage;
      setState(() {
        _showTime = dragPercentage > 0.1;
      });
    }
  }

  void _handleDragEnd(DragEndDetails details) {
    if (_controller.value > 0.5) {
      _controller.forward();
      setState(() {
        _showTime = true;
      });
    } else {
      _controller.reverse().then((_) {
        setState(() {
          _showTime = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment:
            widget.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!widget.isMe && widget.avatarUrl != null) ...[
            CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage(widget.avatarUrl!),
            ),
            const SizedBox(width: 8),
          ],

          // Time for sender messages (left side)
          if (widget.isMe) _buildTimeWidget(isLeft: true),

          // Message bubble with correct iMessage styling
          GestureDetector(
            onHorizontalDragStart: _handleDragStart,
            onHorizontalDragUpdate: _handleDragUpdate,
            onHorizontalDragEnd: _handleDragEnd,
            child: AnimatedBuilder(
              animation: _slideAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(_slideAnimation.value, 0),
                  child: child,
                );
              },
              child: _buildMessageBubble(),
            ),
          ),

          // Time for receiver messages (right side)
          if (!widget.isMe) _buildTimeWidget(isLeft: false),

          if (widget.isMe && widget.avatarUrl != null) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage(widget.avatarUrl!),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeWidget({required bool isLeft}) {
    return AnimatedOpacity(
      opacity: _showTime ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: Container(
        width: 40,
        padding: EdgeInsets.only(
          left: isLeft ? 0 : 8,
          right: isLeft ? 8 : 0,
        ),
        child: Text(
          _formatTime(widget.timestamp),
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 11,
          ),
          textAlign: isLeft ? TextAlign.right : TextAlign.left,
        ),
      ),
    );
  }

  Widget _buildMessageBubble() {
    // Calculate proper bubble shape with tail
    const radius = 18.0;

    return Flexible(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: widget.isMe
              ? const Color(0xFF3B82F6) // iMessage blue
              : const Color(0xFFE5E5EA), // iMessage light gray
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(radius),
            topRight: const Radius.circular(radius),
            bottomLeft: widget.isMe
                ? const Radius.circular(radius)
                : const Radius.circular(radius / 3),
            bottomRight: widget.isMe
                ? const Radius.circular(radius / 3)
                : const Radius.circular(radius),
          ),
        ),
        child: Text(
          widget.message,
          style: TextStyle(
            color: widget.isMe ? Colors.white : Colors.black,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12
        ? time.hour - 12
        : time.hour == 0
            ? 12
            : time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}
