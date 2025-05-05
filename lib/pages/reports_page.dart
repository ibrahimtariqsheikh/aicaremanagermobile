import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:aicaremanagermob/widgets/custom_card.dart';
import 'package:aicaremanagermob/widgets/circular_progress.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  String _selectedPeriod = 'This Month';
  final List<String> _periods = ['This Week', 'This Month', 'Last Month', 'This Year'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return CupertinoPageScaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: theme.cardColor.withValues(alpha: 0.9),
        border: null,
        middle: Text(
          'Reports',
          style: theme.textTheme.bodyMedium,
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(CupertinoIcons.calendar, size: 16, color: theme.colorScheme.primary),
              const SizedBox(width: 4),
              Text(
                _selectedPeriod,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          onPressed: () {
            _showPeriodPicker();
          },
        ),
      ),
      child: SafeArea(
        child: CupertinoScrollbar(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary Cards
                _buildSummaryCards(),
                
                // Visit Statistics
                _buildSectionHeader('Visit Statistics'),
                _buildVisitStatistics(),
                
                // Client Satisfaction
                _buildSectionHeader('Client Satisfaction'),
                _buildSatisfactionMetrics(),
                
                // Care Metrics
                _buildSectionHeader('Care Metrics'),
                _buildCareMetrics(),
                
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  title: 'Total Visits',
                  value: '156',
                  change: '+12%',
                  isPositive: true,
                  icon: CupertinoIcons.calendar_badge_plus,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  title: 'Active Clients',
                  value: '42',
                  change: '+5%',
                  isPositive: true,
                  icon: CupertinoIcons.person_2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  title: 'Hours Worked',
                  value: '248',
                  change: '+8%',
                  isPositive: true,
                  icon: CupertinoIcons.clock,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  title: 'Completion Rate',
                  value: '98%',
                  change: '-2%',
                  isPositive: false,
                  icon: CupertinoIcons.checkmark_circle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required String change,
    required bool isPositive,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    
    return CustomCard(
      hasShadow: false,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  icon,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (isPositive ? CupertinoColors.activeGreen : CupertinoColors.systemRed)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    change,
                    style: TextStyle(
                      color: isPositive ? CupertinoColors.activeGreen : CupertinoColors.systemRed,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisitStatistics() {
    return CustomCard(
      hasShadow: false,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatRow('Home Visits', '124', '79%'),
            const SizedBox(height: 16),
            _buildStatRow('Office Appointments', '32', '21%'),
            const SizedBox(height: 16),
            _buildStatRow('Emergency Calls', '0', '0%'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, String percentage) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: theme.textTheme.bodyMedium,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: Text(
            percentage,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onTertiary,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildSatisfactionMetrics() {
    return CustomCard(
      hasShadow: false,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildCircularMetric(
                  title: 'Overall',
                  value: 4.8,
                  total: 5,
                ),
                _buildCircularMetric(
                  title: 'Care Quality',
                  value: 4.9,
                  total: 5,
                ),
                _buildCircularMetric(
                  title: 'Communication',
                  value: 4.7,
                  total: 5,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularMetric({
    required String title,
    required double value,
    required double total,
  }) {
    final theme = Theme.of(context);
    final percentage = (value / total) * 100;
    
    return Column(
      children: [
        SizedBox(
          width: 80,
          height: 80,
          child: CircularProgress(
            percentage: percentage,
            color: theme.colorScheme.primary,
            width: 80,
            height: 80,
            paintWidth: 8,
            centerText: value.toString(),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onTertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildCareMetrics() {
    return CustomCard(
      hasShadow: false,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildMetricRow(
              label: 'Average Visit Duration',
              value: '1h 35m',
              icon: CupertinoIcons.clock,
            ),
            const SizedBox(height: 16),
            _buildMetricRow(
              label: 'On-time Arrival Rate',
              value: '96%',
              icon: CupertinoIcons.checkmark_circle,
            ),
            const SizedBox(height: 16),
            _buildMetricRow(
              label: 'Documentation Completion',
              value: '100%',
              icon: CupertinoIcons.doc_text,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow({
    required String label,
    required String value,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _showPeriodPicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 200,
          color: CupertinoColors.systemBackground,
          child: SafeArea(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      child: const Text('Cancel'),
                      onPressed: () => Navigator.pop(context),
                    ),
                    CupertinoButton(
                      child: const Text('Done'),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                Expanded(
                  child: CupertinoPicker(
                    itemExtent: 32,
                    onSelectedItemChanged: (int index) {
                      setState(() {
                        _selectedPeriod = _periods[index];
                      });
                    },
                    children: _periods.map((String period) {
                      return Center(child: Text(period));
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
} 