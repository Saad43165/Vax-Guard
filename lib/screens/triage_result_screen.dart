import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../services/triage_service.dart';
import '../utils/app_constants.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../widgets/custom_button.dart';

class TriageResultScreen extends StatefulWidget {
  const TriageResultScreen({super.key});

  @override
  State<TriageResultScreen> createState() => _TriageResultScreenState();
}

class _TriageResultScreenState extends State<TriageResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _slideController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
    _slideAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOut),
    );

    Future.delayed(const Duration(milliseconds: 200), () {
      _scaleController.forward();
      Future.delayed(const Duration(milliseconds: 400), () {
        _slideController.forward();
      });
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Color _getRiskColor(RiskLevel level) {
    switch (level) {
      case RiskLevel.low:
        return AppTheme.riskLow;
      case RiskLevel.medium:
        return AppTheme.riskMedium;
      case RiskLevel.high:
        return AppTheme.riskHigh;
      case RiskLevel.critical:
        return AppTheme.riskCritical;
    }
  }

  LinearGradient _getRiskGradient(RiskLevel level) {
    switch (level) {
      case RiskLevel.low:
        return AppTheme.successGradient;
      case RiskLevel.medium:
        return const LinearGradient(
          colors: [Color(0xFFD97706), Color(0xFFFBBF24)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case RiskLevel.high:
        return const LinearGradient(
          colors: [Color(0xFFEA580C), Color(0xFFFB923C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case RiskLevel.critical:
        return AppTheme.dangerGradient;
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = ModalRoute.of(context)?.settings.arguments as TriageResult?;

    if (result == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Result'), centerTitle: false),
        body: const Center(child: Text('No result available')),
      );
    }

    final riskColor = _getRiskColor(result.level);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: riskColor,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: _getRiskGradient(result.level),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.5),
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              result.emoji,
                              style: const TextStyle(fontSize: 50),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        result.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          result.recommendation,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pushNamedAndRemoveUntil(
                context,
                AppConstants.homeRoute,
                (route) => false,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _slideAnimation,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildScoreCard(result, riskColor),
                    const SizedBox(height: 20),
                    _buildDescriptionCard(result),
                    const SizedBox(height: 20),
                    _buildActionsCard(result, riskColor),
                    if (result.drivers.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _buildDriversCard(result, riskColor),
                    ],
                    const SizedBox(height: 20),
                    _buildBottomActions(context, result),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCard(TriageResult result, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.shadowMd,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Risk Score',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                '${result.score}%',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: result.score / 100,
              minHeight: 12,
              backgroundColor: AppTheme.border,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Low', style: TextStyle(fontSize: 11, color: AppTheme.riskLow)),
              Text('Medium', style: TextStyle(fontSize: 11, color: AppTheme.riskMedium)),
              Text('High', style: TextStyle(fontSize: 11, color: AppTheme.riskHigh)),
              Text('Critical', style: TextStyle(fontSize: 11, color: AppTheme.riskCritical)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard(TriageResult result) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.shadowMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Assessment',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            result.description,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsCard(TriageResult result, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.shadowMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recommended Actions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ...result.actions.map(
            (action) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.check, color: color, size: 14),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      action,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textPrimary,
                        height: 1.4,
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

  Widget _buildBottomActions(BuildContext context, TriageResult result) {
    final isInsufficient = result.isInputInsufficient;
    return Column(
      children: [
        if (!isInsufficient &&
            (result.level == RiskLevel.critical || result.level == RiskLevel.high))
          CustomButton(
            label: '🏥 Find Nearby Hospital',
            onPressed: () => Navigator.pushNamed(context, AppConstants.hospitalMapRoute),
            variant: ButtonVariant.danger,
          ),
        if (!isInsufficient) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: () => _shareResult(result),
              icon: const Icon(Icons.share_rounded, size: 20),
              label: const Text('Share Result'),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppTheme.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: 12),
        CustomButton(
          label: isInsufficient ? 'Complete Assessment' : 'Retake Assessment',
          onPressed: () => Navigator.pushReplacementNamed(context, AppConstants.triageRoute),
          variant: ButtonVariant.outlined,
        ),
        const SizedBox(height: 12),
        CustomButton(
          label: 'Go to Home',
          onPressed: () => Navigator.pushNamedAndRemoveUntil(
            context,
            AppConstants.homeRoute,
            (route) => false,
          ),
          variant: ButtonVariant.secondary,
        ),
      ],
    );
  }

  void _shareResult(TriageResult result) {
    final date = DateFormat('MMMM dd, yyyy').format(DateTime.now());
    final text = '''
🦠 VaxGuard Triage Result

📊 Risk Level: ${result.level.name.toUpperCase()}
📝 Summary: ${result.description}
📅 Date: $date

${result.level == RiskLevel.critical || result.level == RiskLevel.high ? '⚠️ Recommendation: Seek immediate medical attention!' : '✅ Monitor your symptoms.'}

Shared from VaxGuard App
''';
    Share.share(text, subject: 'My Health Assessment');
  }

  Widget _buildDriversCard(TriageResult result, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.shadowMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Why This Result',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ...result.drivers.map(
            (d) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.fiber_manual_record, size: 10, color: color),
                  const SizedBox(width: 10),
                  Expanded(child: Text(d)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}