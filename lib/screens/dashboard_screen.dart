import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../services/database_service.dart';
import '../widgets/animated_counter.dart';
import '../widgets/status_badge.dart' hide AnimatedProgressBar, AnimatedCounter;

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final db = DatabaseService.instance;
    final total = db.totalVaccines;
    final completed = db.completedVaccines;
    final pending = db.pendingVaccines;
    final progress = db.completionPercentage;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Health Dashboard'),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () => setState(() {}),
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHealthScoreCard(progress),
              const SizedBox(height: AppTheme.spacingMd),
              _buildStatsRow(total, completed, pending),
              const SizedBox(height: AppTheme.spacingMd),
              _buildVaccineProgressChart(completed, pending),
              const SizedBox(height: AppTheme.spacingMd),
              _buildHealthInsightsCard(progress, total, completed),
              const SizedBox(height: AppTheme.spacingMd),
              _buildVaccineRecommendations(),
              const SizedBox(height: AppTheme.spacingMd),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Health Score Card ─────────────────────────────────────────────────────
  Widget _buildHealthScoreCard(double progress) {
    final score = progress.round();

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      decoration: BoxDecoration(
        gradient: AppTheme.deepBlueGradient,
        borderRadius: BorderRadius.circular(AppTheme.radius2xl),
        boxShadow: AppTheme.shadowPrimary,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Overall Health Score',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                AnimatedCounter(
                  value: score,
                  suffix: '%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 44,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1.5,
                  ),
                ),
                const SizedBox(height: 12),
                AnimatedProgressBar(
                  progress: progress / 100,
                  progressColor: Colors.white,
                  backgroundColor: Colors.white.withValues(alpha: 0.20),
                  height: 6,
                ),
                const SizedBox(height: 10),
                Text(
                  score >= 75
                      ? 'Excellent vaccination coverage!'
                      : score >= 50
                      ? 'Good progress — keep going!'
                      : 'Consider updating your vaccines.',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppTheme.spacingLg),
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              shape: BoxShape.circle,
              border:
              Border.all(color: Colors.white.withValues(alpha: 0.25), width: 1.5),
            ),
            child: Center(
              child: Text(
                score >= 75
                    ? '🏆'
                    : score >= 50
                    ? '💪'
                    : '💉',
                style: const TextStyle(fontSize: 34),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Stats Row ─────────────────────────────────────────────────────────────
  Widget _buildStatsRow(int total, int completed, int pending) {
    return Row(
      children: [
        Expanded(
          child: AnimatedStatCard(
            title: 'Total',
            value: total,
            icon: Icons.vaccines_rounded,
            color: AppTheme.primary,
          ),
        ),
        const SizedBox(width: AppTheme.spacingSm),
        Expanded(
          child: AnimatedStatCard(
            title: 'Completed',
            value: completed,
            icon: Icons.check_circle_rounded,
            color: AppTheme.success,
          ),
        ),
        const SizedBox(width: AppTheme.spacingSm),
        Expanded(
          child: AnimatedStatCard(
            title: 'Pending',
            value: pending,
            icon: Icons.schedule_rounded,
            color: AppTheme.warning,
          ),
        ),
      ],
    );
  }

  // ─── Pie Chart ─────────────────────────────────────────────────────────────
  Widget _buildVaccineProgressChart(int completed, int pending) {
    if (completed == 0 && pending == 0) {
      return _buildEmptyCard(
        'Vaccine Progress',
        'Add vaccine records to see your progress chart',
        Icons.pie_chart_outline_rounded,
      );
    }

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Vaccine Progress'),
          const SizedBox(height: AppTheme.spacingMd),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 160,
                  child: PieChart(
                    PieChartData(
                      sections: [
                        if (completed > 0)
                          PieChartSectionData(
                            value: completed.toDouble(),
                            color: AppTheme.success,
                            title: '$completed',
                            titleStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                            radius: 64,
                          ),
                        if (pending > 0)
                          PieChartSectionData(
                            value: pending.toDouble(),
                            color: AppTheme.warning,
                            title: '$pending',
                            titleStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                            radius: 64,
                          ),
                      ],
                      borderData: FlBorderData(show: false),
                      sectionsSpace: 3,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.spacingMd),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _chartLegend(AppTheme.success, 'Completed'),
                  const SizedBox(height: 12),
                  _chartLegend(AppTheme.warning, 'Pending'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chartLegend(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ─── Line Chart ────────────────────────────────────────────────────────────
  Widget _buildMonthlyChart(Map<String, int> monthlyData) {
    final sortedKeys = monthlyData.keys.toList()..sort();
    final recentKeys = sortedKeys.length > 6
        ? sortedKeys.sublist(sortedKeys.length - 6)
        : sortedKeys;

    final spots = recentKeys.asMap().entries.map((entry) {
      return FlSpot(
        entry.key.toDouble(),
        (monthlyData[entry.value] ?? 0).toDouble(),
      );
    }).toList();

    final labels = recentKeys.map((key) {
      final parts = key.split('-');
      if (parts.length == 2) {
        final month = int.tryParse(parts[1]) ?? 1;
        const months = [
          'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
        ];
        return months[month - 1];
      }
      return key;
    }).toList();

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Monthly Activity'),
          const SizedBox(height: AppTheme.spacingMd),
          SizedBox(
            height: 160,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: AppTheme.border,
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, _) {
                        final index = value.toInt();
                        if (index >= 0 && index < labels.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              labels[index],
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppTheme.textTertiary,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                      reservedSize: 24,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      interval: 1,
                      getTitlesWidget: (value, _) {
                        if (value == value.roundToDouble()) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppTheme.textTertiary,
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppTheme.primary,
                    barWidth: 2.5,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (_, __, ___, ____) =>
                          FlDotCirclePainter(
                            radius: 3,
                            color: AppTheme.primary,
                            strokeColor: Colors.white,
                            strokeWidth: 1.5,
                          ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primary.withValues(alpha: 0.15),
                          AppTheme.primary.withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Insights Card ─────────────────────────────────────────────────────────
  Widget _buildHealthInsightsCard(
      double progress, int total, int completed) {
    final insights = _generateInsights(progress, total, completed);

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Health Insights'),
          const SizedBox(height: AppTheme.spacingMd),
          ...insights.map(
                (insight) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 32,
                    width: 32,
                    decoration: BoxDecoration(
                      color: (insight['color'] as Color).withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      insight['icon'] as IconData,
                      size: 16,
                      color: insight['color'] as Color,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      insight['text'] as String,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, Object>> _generateInsights(
      double progress, int total, int completed) {
    final insights = <Map<String, Object>>[];

    if (total == 0) {
      insights.add({
        'icon': Icons.lightbulb_outline_rounded,
        'color': AppTheme.primary,
        'text': 'Start tracking your vaccines by adding your first record.',
      });
    } else if (progress >= 75) {
      insights.add({
        'icon': Icons.star_rounded,
        'color': AppTheme.success,
        'text': 'Excellent! You have great vaccination coverage.',
      });
    } else if (progress >= 50) {
      insights.add({
        'icon': Icons.trending_up_rounded,
        'color': AppTheme.warning,
        'text': 'Good progress! Consider completing your pending vaccines.',
      });
    } else {
      insights.add({
        'icon': Icons.warning_amber_rounded,
        'color': AppTheme.danger,
        'text':
        'You have several pending vaccines. Consult your doctor to update them.',
      });
    }

    insights.addAll([
      {
        'icon': Icons.vaccines_rounded,
        'color': AppTheme.secondary,
        'text':
        'WHO recommends staying up-to-date with all recommended vaccines for your age group.',
      },
      {
        'icon': Icons.calendar_month_rounded,
        'color': AppTheme.purple,
        'text':
        'Annual flu vaccines are recommended for everyone 6 months and older.',
      },
      {
        'icon': Icons.local_hospital_rounded,
        'color': AppTheme.primary,
        'text':
        'Regular health check-ups help identify vaccine needs based on your health profile.',
      },
    ]);

    return insights;
  }

  // ─── WHO Recommendations ───────────────────────────────────────────────────
  Widget _buildVaccineRecommendations() {
    final recommendations = [
      {
        'vaccine': 'COVID-19',
        'description': 'Stay up-to-date with boosters',
        'icon': Icons.coronavirus_rounded,
        'color': AppTheme.danger,
      },
      {
        'vaccine': 'Influenza',
        'description': 'Annual vaccination recommended',
        'icon': Icons.air_rounded,
        'color': AppTheme.warning,
      },
      {
        'vaccine': 'Tdap',
        'description': 'Every 10 years for adults',
        'icon': Icons.vaccines_rounded,
        'color': AppTheme.primary,
      },
    ];

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('WHO Recommendations'),
          const SizedBox(height: AppTheme.spacingMd),
          ...recommendations.map(
                (rec) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.surfaceVariant,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(color: AppTheme.border),
              ),
              child: Row(
                children: [
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: (rec['color'] as Color).withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      rec['icon'] as IconData,
                      size: 20,
                      color: rec['color'] as Color,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          rec['vaccine'] as String,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          rec['description'] as String,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppTheme.textTertiary,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────
  Widget _buildEmptyCard(String title, String message, IconData icon) {
    return _card(
      child: Column(
        children: [
          _sectionTitle(title),
          const SizedBox(height: AppTheme.spacingLg),
          Icon(icon, size: 48, color: AppTheme.textTertiary),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.shadowSm,
      ),
      child: child,
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppTheme.textPrimary,
        letterSpacing: -0.2,
      ),
    );
  }
}