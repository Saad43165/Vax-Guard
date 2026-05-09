import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../services/disease_assessment_service.dart';
import '../utils/l10n_helper.dart';
import '../models/disease_assessment.dart';
import 'disease_assessment_quiz_screen.dart';

class DiseaseAssessmentHubScreen extends StatefulWidget {
  const DiseaseAssessmentHubScreen({super.key});

  @override
  State<DiseaseAssessmentHubScreen> createState() => _DiseaseAssessmentHubScreenState();
}

class _DiseaseAssessmentHubScreenState extends State<DiseaseAssessmentHubScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;
  final List<String> _categories = ['all_cat', 'vector_cat', 'respiratory_cat', 'gi_fluid_cat'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() => _selectedIndex = _tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<DiseaseAssessmentDefinition> get _filtered {
    final all = DiseaseAssessmentService.definitions;
    switch (_selectedIndex) {
      case 1: // Vector
        return all.where((d) => ['dengue', 'malaria', 'hantavirus'].contains(d.id)).toList();
      case 2: // Respiratory
        return all.where((d) => ['respiratory'].contains(d.id)).toList();
      case 3: // GI & Fluid
        return all.where((d) => ['typhoid', 'cholera', 'dehydration'].contains(d.id)).toList();
      default:
        return all;
    }
  }

  @override
  Widget build(BuildContext context) {
    final assessments = _filtered;
    return Scaffold(
      backgroundColor: AppTheme.background(context),
      appBar: _buildFixedAppBar(context),
      body: TabBarView(
        controller: _tabController,
        children: _categories.map((category) => ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          itemCount: assessments.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildInfoBanner(context),
            );
            final a = assessments[index - 1];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _AssessmentTile(
                definition: a,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DiseaseAssessmentQuizScreen(definitionId: a.id),
                  ),
                ),
              ),
            );
          },
        )).toList(),
      ),
    );
  }

  PreferredSizeWidget _buildFixedAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppTheme.primary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/images/appbar_icon.png', height: 26, fit: BoxFit.contain),
          const SizedBox(width: 10),
          Text(
            L10n.s(context, 'risk_assessment'),
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
        ],
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        onPressed: () => Navigator.maybePop(context),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.surface(context),
            border: Border(bottom: BorderSide(color: AppTheme.border(context), width: 0.5)),
          ),
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            indicatorColor: AppTheme.primary,
            indicatorWeight: 3,
            labelColor: AppTheme.primary,
            unselectedLabelColor: AppTheme.textSecondary(context),
            labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 13),
            unselectedLabelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 13),
            tabs: _categories.map((c) => Tab(text: L10n.s(context, c))).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildStatPill(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 13),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.info_outline_rounded, color: AppTheme.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              L10n.s(context, 'assessment_hub_info'),
              style: GoogleFonts.outfit(
                fontSize: 12.5,
                color: AppTheme.textSecondary(context),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AssessmentTile extends StatelessWidget {
  final DiseaseAssessmentDefinition definition;
  final VoidCallback onTap;

  const _AssessmentTile({required this.definition, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: AppTheme.surface(context),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.border(context)),
            boxShadow: AppTheme.shadowSm,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: definition.gradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(definition.icon, color: Colors.white, size: 26),
                ),
                const SizedBox(width: 14),
                // Text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        L10n.s(context, definition.title),
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary(context),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        L10n.s(context, definition.subtitle),
                        style: GoogleFonts.outfit(
                          fontSize: 12.5,
                          color: AppTheme.textSecondary(context),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Question count badge
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: definition.accentColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${definition.questions.length} ${L10n.s(context, "questions_label")}',
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: definition.accentColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppTheme.border(context).withOpacity(0.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.warning_amber_rounded,
                                    size: 11, color: AppTheme.textTertiary(context)),
                                const SizedBox(width: 3),
                                Text(
                                  '${definition.urgentFlags.length} ${L10n.s(context, "flags_label")}',
                                  style: GoogleFonts.outfit(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textTertiary(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Arrow
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: definition.accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: definition.accentColor,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
