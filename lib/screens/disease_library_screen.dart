import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../services/disease_data_service.dart';
import '../utils/l10n_helper.dart';

class DiseaseLibraryScreen extends StatefulWidget {
  const DiseaseLibraryScreen({super.key});

  @override
  State<DiseaseLibraryScreen> createState() => _DiseaseLibraryScreenState();
}

class _DiseaseLibraryScreenState extends State<DiseaseLibraryScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  List<Disease> _results = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  void _loadAll() async {
    setState(() => _isLoading = true);
    final data = await DiseaseDataService.instance.searchDiseases('');
    setState(() {
      _results = data;
      _isLoading = false;
    });
  }

  void _onSearch(String q) async {
    setState(() => _isLoading = true);
    final data = await DiseaseDataService.instance.searchDiseases(q);
    setState(() {
      _results = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background(context),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(child: _buildSearchSection()),
          if (_isLoading)
            const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
          else if (_results.isEmpty)
            SliverFillRemaining(child: _buildEmptyState())
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final delay = (index * 50).clamp(0, 500);
                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: Duration(milliseconds: 400 + delay),
                      curve: Curves.easeOutQuart,
                      builder: (context, value, child) {
                        return Transform.translate(
                          offset: Offset(0, 30 * (1 - value)),
                          child: Opacity(opacity: value, child: child),
                        );
                      },
                      child: _buildDiseaseCard(_results[index]),
                    );
                  },
                  childCount: _results.length,
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 180,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: AppTheme.purple,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/appbar_icon.png', height: 26, fit: BoxFit.contain),
            const SizedBox(width: 10),
            Text(
              L10n.s(context, 'health_library').toUpperCase(),
              style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 16, letterSpacing: 1.5),
            ),
          ],
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppTheme.purple, AppTheme.secondary],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -50, top: -20,
                child: Icon(Icons.menu_book_rounded, color: Colors.white.withOpacity(0.1), size: 200),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    Icon(Icons.auto_stories_rounded, color: Colors.white.withOpacity(0.9), size: 48),
                    const SizedBox(height: 12),
                    Text(
                      'GLOBAL DISEASE ARCHIVE',
                      style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.7), fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      decoration: BoxDecoration(
        color: AppTheme.surface(context),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _searchCtrl,
            onChanged: _onSearch,
            style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 16),
            decoration: InputDecoration(
              hintText: L10n.s(context, 'search_diseases_hint'),
              prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.purple),
              suffixIcon: _searchCtrl.text.isNotEmpty 
                  ? IconButton(icon: const Icon(Icons.clear_rounded), onPressed: () { _searchCtrl.clear(); _onSearch(''); })
                  : null,
              filled: true,
              fillColor: AppTheme.background(context),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: AppTheme.purple.withOpacity(0.3), width: 2)),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'SUGGESTED RESEARCH', 
            style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w900, color: AppTheme.textTertiary(context), letterSpacing: 1.5),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                'Ebola', 'Rabies', 'COVID-19', 'Polio', 'Dengue', 'Malaria', 'Cholera', 'Tetanus'
              ].map((q) => Padding(
                padding: const EdgeInsets.only(right: 10),
                child: FilterChip(
                  label: Text(q),
                  selected: _searchCtrl.text == q,
                  onSelected: (selected) {
                    HapticFeedback.selectionClick();
                    _searchCtrl.text = selected ? q : '';
                    _onSearch(_searchCtrl.text);
                  },
                  backgroundColor: AppTheme.background(context),
                  selectedColor: AppTheme.purple.withOpacity(0.15),
                  labelStyle: GoogleFonts.outfit(
                    fontSize: 13, 
                    fontWeight: _searchCtrl.text == q ? FontWeight.w800 : FontWeight.w600, 
                    color: _searchCtrl.text == q ? AppTheme.purple : AppTheme.textSecondary(context),
                  ),
                  side: BorderSide(color: _searchCtrl.text == q ? AppTheme.purple : AppTheme.border(context).withOpacity(0.5)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiseaseCard(Disease disease) {
    final severityColor = _getSeverityColor(disease.severity);
    final categoryColor = _getCategoryColor(disease.category);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.surface(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.border(context).withOpacity(0.5)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: () {
            HapticFeedback.mediumImpact();
            _showDiseaseDetail(disease);
          },
          child: IntrinsicHeight(
            child: Row(
              children: [
                Container(width: 6, color: categoryColor),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [categoryColor.withOpacity(0.2), categoryColor.withOpacity(0.05)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(_getCategoryIcon(disease.category), color: categoryColor, size: 24),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                disease.name, 
                                style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w900, color: AppTheme.textPrimary(context), height: 1.1),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(color: severityColor.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                                    child: Text(
                                      disease.severity.toUpperCase(), 
                                      style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.w900, color: severityColor, letterSpacing: 0.8),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      disease.category, 
                                      style: GoogleFonts.outfit(fontSize: 11, color: AppTheme.textTertiary(context), fontWeight: FontWeight.w700, letterSpacing: 0.5),
                                      maxLines: 1, overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios_rounded, color: AppTheme.textTertiary(context).withOpacity(0.4), size: 14),
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

  Color _getCategoryColor(String category) {
    final cat = category.toLowerCase();
    if (cat.contains('viral')) return AppTheme.primary;
    if (cat.contains('bacterial')) return AppTheme.purple;
    if (cat.contains('parasitic')) return AppTheme.warning;
    if (cat.contains('vector')) return AppTheme.danger;
    return AppTheme.success;
  }

  IconData _getCategoryIcon(String category) {
    final cat = category.toLowerCase();
    if (cat.contains('viral')) return Icons.biotech_rounded;
    if (cat.contains('bacterial')) return Icons.coronavirus_rounded;
    if (cat.contains('parasitic')) return Icons.bug_report_rounded;
    if (cat.contains('vector')) return Icons.pest_control_rodent_rounded;
    return Icons.medication_rounded;
  }

  Color _getSeverityColor(String severity) {
    final s = severity.toLowerCase();
    if (s.contains('critical')) return AppTheme.danger;
    if (s.contains('high')) return AppTheme.warning;
    if (s.contains('moderate')) return AppTheme.primary;
    return AppTheme.success;
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(color: AppTheme.surface(context), shape: BoxShape.circle),
            child: Icon(Icons.search_off_rounded, size: 64, color: AppTheme.textTertiary(context).withOpacity(0.3)),
          ),
          const SizedBox(height: 24),
          Text(
            L10n.s(context, 'no_diseases_found'), 
            style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.textSecondary(context)),
          ),
          const SizedBox(height: 8),
          Text(
            'Try searching for another medical term', 
            style: GoogleFonts.outfit(color: AppTheme.textTertiary(context), fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  void _showDiseaseDetail(Disease disease) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.6,
        maxChildSize: 0.95,
        builder: (_, controller) => Container(
          decoration: BoxDecoration(
            color: AppTheme.background(context),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, -10))],
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 16),
                width: 48, height: 6,
                decoration: BoxDecoration(color: AppTheme.border(context).withOpacity(0.5), borderRadius: BorderRadius.circular(3)),
              ),
              Expanded(
                child: ListView(
                  controller: controller,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 60),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppTheme.surface(context),
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(color: AppTheme.border(context).withOpacity(0.5)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _getSeverityColor(disease.severity).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  disease.severity.toUpperCase(), 
                                  style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w900, color: _getSeverityColor(disease.severity), letterSpacing: 1),
                                ),
                              ),
                              const SizedBox.shrink(),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Text(disease.name, style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.w900, color: AppTheme.textPrimary(context), height: 1.1, letterSpacing: -1)),
                          const SizedBox(height: 8),
                          Text(disease.category.toUpperCase(), style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.primary, letterSpacing: 2)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildInfoSection(L10n.s(context, 'clinical_description'), disease.description, Icons.info_outline_rounded, AppTheme.primary),
                    const SizedBox(height: 32),
                    _buildListSection(L10n.s(context, 'common_symptoms'), disease.symptoms, Icons.thermostat_rounded, AppTheme.warning),
                    const SizedBox(height: 32),
                    _buildListSection(L10n.s(context, 'prevention_strategies'), disease.prevention, Icons.gpp_good_rounded, AppTheme.success),
                    const SizedBox(height: 32),
                    _buildListSection(L10n.s(context, 'treatment_care'), disease.treatment, Icons.medication_liquid_rounded, AppTheme.purple),
                    const SizedBox(height: 48),
                    _buildSourceBadge(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, String content, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(title, icon, color),
        const SizedBox(height: 16),
        Text(content, style: GoogleFonts.outfit(fontSize: 16, color: AppTheme.textPrimary(context), height: 1.6, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildListSection(String title, List<String> items, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(title, icon, color),
        const SizedBox(height: 16),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 6),
                width: 8, height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 16),
              Expanded(child: Text(item, style: GoogleFonts.outfit(fontSize: 16, color: AppTheme.textPrimary(context), height: 1.4, fontWeight: FontWeight.w500))),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title.toUpperCase(), 
          style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w900, color: AppTheme.textTertiary(context), letterSpacing: 1.5),
        ),
      ],
    );
  }

  Widget _buildSourceBadge() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surface(context),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppTheme.border(context).withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(Icons.verified_user_rounded, color: AppTheme.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Medical Verification', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 16)),
                const SizedBox(height: 2),
                Text(
                  'Data sourced from WHO, CDC, and peer-reviewed clinical guidelines.', 
                  style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textSecondary(context), fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
