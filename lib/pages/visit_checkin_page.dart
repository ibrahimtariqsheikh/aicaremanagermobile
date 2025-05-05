import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:aicaremanagermob/models/schedule.dart';
import 'package:aicaremanagermob/models/user.dart';
import 'package:intl/intl.dart';

class VisitCheckinPage extends StatefulWidget {
  final Schedule schedule;

  const VisitCheckinPage({
    super.key,
    required this.schedule,
  });

  @override
  State<VisitCheckinPage> createState() => _VisitCheckinPageState();
}

class _VisitCheckinPageState extends State<VisitCheckinPage> {
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _moodController = TextEditingController();
  final TextEditingController _healthStatusController = TextEditingController();
  bool _isCompleted = false;
  DateTime? _checkInTime;

  @override
  void initState() {
    super.initState();
    _checkInTime = DateTime.now();
  }

  @override
  void dispose() {
    _notesController.dispose();
    _moodController.dispose();
    _healthStatusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final client = widget.schedule.client;
    
    return CupertinoPageScaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: theme.cardColor.withValues(alpha: 0.9),
        border: null,
        middle: Text(
          'Visit Check-in',
          style: theme.textTheme.bodyMedium,
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _isCompleted ? null : () {
            setState(() {
              _isCompleted = true;
            });
            // TODO: Save visit information
            Navigator.pop(context);
          },
          child: Text(
            'Complete',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Client Info Card
              _buildClientInfoCard(client, theme),
              
              // Check-in Time
              _buildSectionHeader('Check-in Time', theme),
              _buildTimeCard(_checkInTime!, theme),
              
              // Visit Status
              _buildSectionHeader('Visit Status', theme),
              _buildVisitStatusCard(theme),
              
              // Notes
              _buildSectionHeader('Visit Notes', theme),
              _buildNotesCard(theme),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClientInfoCard(User? client, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: theme.colorScheme.primary,
            child: Text(
              _getInitials(client?.fullName ?? ''),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  client?.fullName ?? 'Unknown Client',
                  style: theme.textTheme.titleMedium,
                ),
                if (client?.preferredName != null)
                  Text(
                    'Preferred name: ${client!.preferredName}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onTertiary,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onTertiary,
        ),
      ),
    );
  }

  Widget _buildTimeCard(DateTime time, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              CupertinoIcons.clock,
              color: theme.colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            DateFormat('h:mm a').format(time),
            style: theme.textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildVisitStatusCard(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildTextField(
            controller: _moodController,
            label: 'Client Mood',
            placeholder: 'How is the client feeling today?',
            icon: CupertinoIcons.heart_circle,
            theme: theme,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _healthStatusController,
            label: 'Health Status',
            placeholder: 'Any health concerns or observations?',
            icon: CupertinoIcons.heart,
            theme: theme,
          ),
        ],
      ),
    );
  }

  Widget _buildNotesCard(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Visit Notes',
            style: theme.textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          CupertinoTextField(
            controller: _notesController,
            placeholder: 'Add notes about the visit...',
            maxLines: 5,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.colorScheme.onTertiary.withValues(alpha: 0.2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String placeholder,
    required IconData icon,
    required ThemeData theme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        CupertinoTextField(
          controller: controller,
          placeholder: placeholder,
          prefix: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Icon(
              icon,
              color: theme.colorScheme.primary,
              size: 20,
            ),
          ),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: theme.colorScheme.onTertiary.withValues(alpha: 0.2),
            ),
          ),
        ),
      ],
    );
  }

  String _getInitials(String fullName) {
    if (fullName.isEmpty) return '';
    
    final nameParts = fullName.split(' ');
    if (nameParts.length > 1) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    }
    return fullName[0].toUpperCase();
  }
} 