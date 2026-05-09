import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../core/theme.dart';
import '../models/history_entry.dart';
import '../services/database_service.dart';
import '../utils/app_constants.dart';
import '../utils/l10n_helper.dart';
import '../services/pdf_service.dart';
import 'package:printing/printing.dart';
import '../l10n/app_localizations.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> with SingleTickerProviderStateMixin {
  late Future<List<HistoryEntry>> _historyFuture;
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  int _activeTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() => _activeTab = _tabController.index);
      }
    });
    _historyFuture = DatabaseService.instance.getHistoryEntries();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _refresh() {
    setState(() {
      _historyFuture = DatabaseService.instance.getHistoryEntries();
    });
  }

  List<HistoryEntry> _filterHistory(List<HistoryEntry> items) {
    if (_activeTab == 1) {
      return items.where((e) => e.type == HistoryEntryType.vaccine).toList();
    } else if (_activeTab == 2) {
      return items.where((e) => e.type != HistoryEntryType.vaccine).toList();
    }
    return items;
  }

  Map<String, List<HistoryEntry>> _groupHistory(List<HistoryEntry> items) {
    final Map<String, List<HistoryEntry>> grouped = {};
    for (var entry in items) {
      final month = DateFormat('MMMM yyyy').format(entry.createdAt);
      if (!grouped.containsKey(month)) {
        grouped[month] = [];
      }
      grouped[month]!.add(entry);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<HistoryEntry>>(
      future: _historyFuture,
      builder: (context, snapshot) {
        final allHistory = snapshot.data ?? [];
        final history = _filterHistory(allHistory);
        final grouped = _groupHistory(history);
        final months = grouped.keys.toList();

        return Scaffold(
          backgroundColor: AppTheme.background(context),
          appBar: _buildFixedAppBar(allHistory),
          body: snapshot.connectionState == ConnectionState.waiting
              ? const Center(child: CircularProgressIndicator())
              : CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    if (history.isEmpty)
                      _buildEmptyState()
                    else ...[
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                          child: _buildExportReportCard(allHistory),
                        ),
                      ),
                      ...months.map((month) => SliverMainAxisGroup(
                        slivers: [
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                              child: Row(
                                children: [
                                  Container(
                                    width: 4, height: 16,
                                    decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(2)),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    month.toUpperCase(),
                                    style: GoogleFonts.outfit(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                      color: AppTheme.textPrimary(context),
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final entry = grouped[month]![index];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: _HistoryCard(entry: entry),
                                  );
                                },
                                childCount: grouped[month]!.length,
                              ),
                            ),
                          ),
                        ],
                      )).toList(),
                    ],
                    const SliverToBoxAdapter(child: SizedBox(height: 120)),
                  ],
                ),
        );
      },
    );
  }

  PreferredSizeWidget _buildFixedAppBar(List<HistoryEntry> allHistory) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: AppTheme.border(context).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary(context), size: 20),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Medical History',
        style: GoogleFonts.outfit(
          color: AppTheme.textPrimary(context),
          fontWeight: FontWeight.w900,
          fontSize: 18,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Column(
          children: [
            TabBar(
              controller: _tabController,
              indicatorColor: AppTheme.primary,
              indicatorWeight: 3,
              labelColor: AppTheme.primary,
              unselectedLabelColor: AppTheme.textSecondary(context),
              labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 13),
              unselectedLabelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 13),
              tabs: const [
                Tab(text: 'ALL LOGS'),
                Tab(text: 'VACCINES'),
                Tab(text: 'ASSESSMENTS'),
              ],
            ),
            Container(
              color: AppTheme.border(context).withOpacity(0.5),
              height: 1,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SliverFillRemaining(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: Icon(Icons.history_rounded, size: 64, color: AppTheme.primary),
              ),
              const SizedBox(height: 24),
              Text('No History Yet', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text(
                'Your vaccination records and health assessments will be chronicled here to provide a longitudinal overview of your clinical profile.',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(color: AppTheme.textSecondary(context), height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildExportReportCard(List<HistoryEntry> history) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.surface(context),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppTheme.border(context), width: 1.5),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              gradient: AppTheme.purpleGradient,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(16)),
                  child: const Icon(Icons.picture_as_pdf_rounded, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CLINICAL REPORTING',
                        style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.7), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5),
                      ),
                      Text(
                        'Export Health History',
                        style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildReportMetric('Total Logs', '${history.length}', AppTheme.purple),
                    _buildReportMetric('Verified', '${history.where((e) => e.type == HistoryEntryType.vaccine).length}', AppTheme.success),
                    _buildReportMetric('Clinical', '${history.where((e) => e.type != HistoryEntryType.vaccine).length}', AppTheme.secondary),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => _showExportMenu(history),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.purple,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text('GENERATE VERIFIED PDF', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 14, letterSpacing: 0.5)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportMetric(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w900, color: color)),
        const SizedBox(height: 2),
        Text(label.toUpperCase(), style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.w800, color: AppTheme.textTertiary(context), letterSpacing: 0.5)),
      ],
    );
  }

  void _showExportMenu(List<HistoryEntry> history) {
    if (history.isEmpty) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.surface(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('EXPORT OPTIONS', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w900, color: AppTheme.textTertiary(context), letterSpacing: 1.2)),
            const SizedBox(height: 8),
            Text('Generate Clinical Report', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w900, color: AppTheme.textPrimary(context))),
            const SizedBox(height: 24),
            
            _exportOption(
              'Full Medical History', 
              'Complete longitudinal record of all health data.', 
              Icons.description_rounded, 
              AppTheme.primary,
              () { Navigator.pop(context); _showTimeSelection(history, 'all'); }
            ),
            const SizedBox(height: 16),
            _exportOption(
              'Immunization Records', 
              'Certification of all vaccines and doses.', 
              Icons.vaccines_rounded, 
              AppTheme.success,
              () { Navigator.pop(context); _showTimeSelection(history, 'vaccine'); }
            ),
            const SizedBox(height: 16),
            _exportOption(
              'Diagnostic Assessments', 
              'Reports for triage and symptom analysis.', 
              Icons.analytics_rounded, 
              AppTheme.purple,
              () { Navigator.pop(context); _showTimeSelection(history, 'assessment'); }
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _exportOption(String title, String sub, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.border(context).withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 16)),
                  Text(sub, style: GoogleFonts.outfit(color: AppTheme.textSecondary(context), fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppTheme.textTertiary(context)),
          ],
        ),
      ),
    );
  }

  void _showTimeSelection(List<HistoryEntry> history, String type) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.surface(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('SELECT TIME RANGE', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w900, color: AppTheme.textTertiary(context), letterSpacing: 1.5)),
            const SizedBox(height: 20),
            _timeTile('Last 30 Days', () { 
              Navigator.pop(context); 
              _exportFiltered(history, type, 30); 
            }),
            _timeTile('Last 6 Months', () { 
              Navigator.pop(context); 
              _exportFiltered(history, type, 180); 
            }),
            _timeTile('Full History', () { 
              Navigator.pop(context); 
              _exportFiltered(history, type, null); 
            }),
          ],
        ),
      ),
    );
  }

  Widget _timeTile(String label, VoidCallback onTap) {
    return ListTile(
      title: Text(label, style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
      onTap: onTap,
    );
  }

  void _exportFiltered(List<HistoryEntry> history, String type, int? days) {
    var items = history;
    if (type == 'vaccine') {
      items = items.where((e) => e.type == HistoryEntryType.vaccine).toList();
    } else if (type == 'assessment') {
      items = items.where((e) => e.type != HistoryEntryType.vaccine).toList();
    }

    if (days != null) {
      final cutOff = DateTime.now().subtract(Duration(days: days));
      items = items.where((e) => e.createdAt.isAfter(cutOff)).toList();
    }

    _exportPdf(items);
  }

  Future<void> _exportPdf(List<HistoryEntry> items) async {
    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No records found for the selected filter.')));
      return;
    }
    try {
      final l10n = AppLocalizations.of(context)!;
      final pdf = await PdfService.generateAssessmentsReport(entries: items, l10n: l10n);
      await Printing.layoutPdf(onLayout: (format) async => pdf.save(), name: 'VaxGuard_Clinical_Report.pdf');
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}

class _HistoryCard extends StatelessWidget {
  final HistoryEntry entry;
  const _HistoryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    final statusColor = AppTheme.statusColor(entry.statusLabel);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _openEntry(context);
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface(context),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.border(context).withOpacity(0.4)),
          boxShadow: AppTheme.shadowSm,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 6, color: color),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(16)),
                          child: Icon(_getIcon(), color: color, size: 24),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(entry.title, style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 16, color: AppTheme.textPrimary(context))),
                              const SizedBox(height: 2),
                              Text(entry.summary, style: GoogleFonts.outfit(fontSize: 13, color: AppTheme.textSecondary(context)), maxLines: 1, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.access_time_rounded, size: 10, color: AppTheme.textTertiary(context)),
                                  const SizedBox(width: 4),
                                  Text(DateFormat('MMM dd • hh:mm a').format(entry.createdAt), style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.textTertiary(context))),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: statusColor, 
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [BoxShadow(color: statusColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))],
                              ),
                              child: Text(
                                entry.statusLabel.toUpperCase(), 
                                style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIcon() {
    switch (entry.type) {
      case HistoryEntryType.vaccine: return Icons.vaccines_rounded;
      case HistoryEntryType.triage: return Icons.emergency_rounded;
      case HistoryEntryType.animalBite: return Icons.pets_rounded;
      case HistoryEntryType.symptomChecker: return Icons.psychology_rounded;
      case HistoryEntryType.diseaseAssessment: return Icons.coronavirus_rounded;
    }
  }

  Color _getColor() {
    switch (entry.type) {
      case HistoryEntryType.vaccine: return AppTheme.primary;
      case HistoryEntryType.triage: return AppTheme.danger;
      case HistoryEntryType.animalBite: return AppTheme.warning;
      case HistoryEntryType.symptomChecker: return AppTheme.secondary;
      case HistoryEntryType.diseaseAssessment: return AppTheme.purple;
    }
  }

  void _openEntry(BuildContext context) {
    if (entry.type == HistoryEntryType.vaccine) {
      Navigator.pushNamed(context, AppConstants.vaccineScheduleRoute);
      return;
    }
    final args = {
      'title': entry.title,
      'subtitle': entry.summary,
      'severity': entry.statusLabel,
      'score': entry.riskScore,
      'summary': entry.details ?? '',
      'actions': (entry.metadata['actions'] as List?)?.cast<String>() ?? [],
      'drivers': (entry.metadata['drivers'] as List?)?.cast<String>() ?? [],
      'type': entry.type.name,
      'answers': (entry.metadata['answers'] as Map?)?.cast<String, String>() ?? {},
    };
    Navigator.pushNamed(context, AppConstants.assessmentResultRoute, arguments: args);
  }
}
