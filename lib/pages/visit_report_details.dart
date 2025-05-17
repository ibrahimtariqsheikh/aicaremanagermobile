import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:aicaremanagermob/widgets/custom_card.dart';
import 'package:intl/intl.dart';
import 'package:aicaremanagermob/utils/image_utils.dart';

class VisitReportDetails extends StatelessWidget {
  final Map<String, dynamic> visit;

  const VisitReportDetails({
    super.key,
    required this.visit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('EEEE, MMMM d, yyyy');
    final timeFormat = DateFormat('h:mm a');

    return CupertinoPageScaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: theme.cardColor.withValues(alpha: 0.9),
        border: null,
        middle: Text(
          'Visit Report Details',
          style: theme.textTheme.bodyMedium,
        ),
      ),
      child: SafeArea(
        child: CupertinoScrollbar(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Client Info Card
                _buildClientInfoCard(theme, dateFormat, timeFormat),

                // Visit Details Card
                _buildVisitDetailsCard(theme),

                // Notes Card
                _buildNotesCard(theme),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildClientInfoCard(
      ThemeData theme, DateFormat dateFormat, DateFormat timeFormat) {
    return CustomCard(
      hasShadow: false,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: ImageUtils.getPlaceholderImage(
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        visit['clientName'],
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${dateFormat.format(visit['date'])} at ${timeFormat.format(visit['date'])}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    visit['type'],
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisitDetailsCard(ThemeData theme) {
    return CustomCard(
      hasShadow: false,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Visit Details',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              theme,
              icon: CupertinoIcons.clock,
              label: 'Duration',
              value: visit['duration'],
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              theme,
              icon: CupertinoIcons.heart_circle,
              label: 'Client Mood',
              value: visit['mood'],
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              theme,
              icon: CupertinoIcons.heart,
              label: 'Health Status',
              value: visit['healthStatus'],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesCard(ThemeData theme) {
    return CustomCard(
      hasShadow: false,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notes',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                visit['notes'],
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    ThemeData theme, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onTertiary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
