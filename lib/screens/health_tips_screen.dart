import 'package:flutter/material.dart';
import '../../core/theme.dart';

class HealthTipsScreen extends StatefulWidget {
  const HealthTipsScreen({super.key});

  @override
  State<HealthTipsScreen> createState() => _HealthTipsScreenState();
}

class _HealthTipsScreenState extends State<HealthTipsScreen> {
  String _selectedCategory = 'All';
  
  final List<_HealthTip> _allTips = [
    _HealthTip(category: 'Vaccination', title: 'Stay Up to Date', content: 'Keep your vaccinations current for maximum protection against preventable diseases.', icon: Icons.vaccines_rounded, color: AppTheme.primary),
    _HealthTip(category: 'Vaccination', title: 'Vaccine Side Effects', content: 'Mild side effects like soreness or low fever are normal. Serious reactions are rare.', icon: Icons.thermostat_rounded, color: AppTheme.primary),
    _HealthTip(category: 'Nutrition', title: 'Boost Your Immunity', content: 'Citrus fruits, leafy greens, and lean proteins strengthen your immune system.', icon: Icons.restaurant_rounded, color: AppTheme.success),
    _HealthTip(category: 'Nutrition', title: 'Vitamin D', content: 'Sunlight and fortified foods help maintain optimal Vitamin D levels.', icon: Icons.wb_sunny_rounded, color: AppTheme.success),
    _HealthTip(category: 'Exercise', title: 'Stay Active', content: '30 minutes of moderate exercise daily improves overall health and immunity.', icon: Icons.fitness_center_rounded, color: AppTheme.warning),
    _HealthTip(category: 'Exercise', title: 'Stretch Daily', content: 'Regular stretching reduces muscle tension and improves circulation.', icon: Icons.accessibility_new_rounded, color: AppTheme.warning),
    _HealthTip(category: 'Sleep', title: 'Quality Sleep', content: 'Adults need 7-9 hours of sleep for optimal immune function.', icon: Icons.bedtime_rounded, color: AppTheme.purple),
    _HealthTip(category: 'Sleep', title: 'Sleep Hygiene', content: 'Keep your bedroom dark and cool for better sleep quality.', icon: Icons.nightlight_rounded, color: AppTheme.purple),
    _HealthTip(category: 'Hygiene', title: 'Hand Washing', content: 'Wash hands for 20 seconds with soap to prevent disease spread.', icon: Icons.clean_hands_rounded, color: AppTheme.secondary),
    _HealthTip(category: 'Hygiene', title: 'Cover Coughs', content: 'Cough into your elbow, not your hands, to prevent germ spread.', icon: Icons.masks_rounded, color: AppTheme.secondary),
    _HealthTip(category: 'Mental Health', title: 'Manage Stress', content: 'Chronic stress weakens immunity. Practice relaxation techniques daily.', icon: Icons.self_improvement_rounded, color: AppTheme.danger),
    _HealthTip(category: 'Mental Health', title: 'Stay Connected', content: 'Social connections improve mental health and immune function.', icon: Icons.people_rounded, color: AppTheme.danger),
    _HealthTip(category: 'Hydration', title: 'Stay Hydrated', content: 'Drink at least 8 glasses of water daily for optimal health.', icon: Icons.water_drop_rounded, color: AppTheme.primary),
    _HealthTip(category: 'Hydration', title: 'Limit Caffeine', content: 'Excessive caffeine can disrupt sleep and hydration.', icon: Icons.coffee_rounded, color: AppTheme.primary),
    _HealthTip(category: 'Prevention', title: 'Regular Check-ups', content: 'Annual health screenings catch potential issues early.', icon: Icons.medical_services_rounded, color: AppTheme.warning),
    _HealthTip(category: 'Prevention', title: 'Know Your Numbers', content: 'Track blood pressure, cholesterol, and blood sugar levels.', icon: Icons.monitor_heart_rounded, color: AppTheme.warning),
    _HealthTip(category: 'First Aid', title: 'Wound Care', content: 'Clean wounds immediately with soap and water to prevent infection.', icon: Icons.healing_rounded, color: AppTheme.danger),
    _HealthTip(category: 'First Aid', title: 'Burn Treatment', content: 'Run cool water over burns for 10-15 minutes. Do not apply ice.', icon: Icons.local_fire_department_rounded, color: AppTheme.danger),
    _HealthTip(category: 'Emergency', title: 'Know Emergency Signs', content: 'Difficulty breathing, chest pain, and severe bleeding need immediate care.', icon: Icons.emergency_rounded, color: AppTheme.danger),
    _HealthTip(category: 'Emergency', title: 'CPR Basics', content: 'Learn CPR - 100-120 chest compressions per minute.', icon: Icons.favorite_rounded, color: AppTheme.danger),
  ];

  List<_HealthTip> get _filteredTips {
    if (_selectedCategory == 'All') return _allTips;
    return _allTips.where((tip) => tip.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ['All', 'Vaccination', 'Nutrition', 'Exercise', 'Sleep', 'Hygiene', 'Mental Health', 'Hydration', 'Prevention', 'First Aid', 'Emergency'];
    
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            backgroundColor: AppTheme.success,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Health Tips', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              background: Container(
                decoration: const BoxDecoration(gradient: AppTheme.successGradient),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search_rounded),
                onPressed: () => _showSearch(context),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: AppTheme.successGradient,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Daily Health Tips', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                              const SizedBox(height: 4),
                              Text('${_allTips.length} expert tips for you', style: TextStyle(color: Colors.white70, fontSize: 13)),
                            ],
                          ),
                        ),
                        Container(
                          width: 50, height: 50,
                          decoration: BoxDecoration(color: Colors.white.withAlpha(51), shape: BoxShape.circle),
                          child: const Icon(Icons.lightbulb_rounded, color: Colors.white, size: 28),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  final isSelected = _selectedCategory == cat;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = cat),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.success : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: isSelected ? null : Border.all(color: AppTheme.border),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        cat,
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppTheme.textSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final tip = _filteredTips[index];
                  return _buildTipCard(tip);
                },
                childCount: _filteredTips.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _buildTipCard(_HealthTip tip) {
    return GestureDetector(
      onTap: () => _showTipDetail(tip),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: AppTheme.shadowSm),
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(color: tip.color.withAlpha(26), borderRadius: BorderRadius.circular(12)),
              child: Icon(tip.icon, color: tip.color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tip.category, style: TextStyle(color: tip.color, fontSize: 11, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(tip.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(tip.content, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12, height: 1.3)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppTheme.textTertiary, size: 20),
          ],
        ),
      ),
    );
  }

  void _showSearch(BuildContext context) {
    showSearch(context: context, delegate: _HealthTipSearchDelegate(_allTips));
  }

  void _showTipDetail(_HealthTip tip) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.55,
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(
          children: [
            Container(margin: const EdgeInsets.symmetric(vertical: 12), width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.border, borderRadius: BorderRadius.circular(2))),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: tip.color.withAlpha(26), borderRadius: BorderRadius.circular(8)), child: Text(tip.category, style: TextStyle(color: tip.color, fontSize: 12, fontWeight: FontWeight.w600))),
                    const SizedBox(height: 16),
                    Row(children: [
                      Container(width: 52, height: 52, decoration: BoxDecoration(color: tip.color.withAlpha(26), borderRadius: BorderRadius.circular(14)), child: Icon(tip.icon, color: tip.color, size: 26)),
                      const SizedBox(width: 14),
                      Expanded(child: Text(tip.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800))),
                    ]),
                    const SizedBox(height: 20),
                    Text(tip.content, style: const TextStyle(fontSize: 15, height: 1.6, color: AppTheme.textSecondary)),
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

class _HealthTip {
  final String category;
  final String title;
  final String content;
  final IconData icon;
  final Color color;

  const _HealthTip({required this.category, required this.title, required this.content, required this.icon, required this.color});
}

class _HealthTipSearchDelegate extends SearchDelegate<_HealthTip> {
  final List<_HealthTip> _allTips;

  _HealthTipSearchDelegate(this._allTips);

  @override
  List<Widget> buildActions(BuildContext context) => [IconButton(icon: const Icon(Icons.clear_rounded), onPressed: () => query = '')];

  @override
  Widget buildLeading(BuildContext context) => IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => close(context, _allTips.first));

  @override
  Widget buildResults(BuildContext context) => _buildSearchResults();

  @override
  Widget buildSuggestions(BuildContext context) => _buildSearchResults();

  Widget _buildSearchResults() {
    final results = _allTips.where((tip) => tip.title.toLowerCase().contains(query.toLowerCase()) || tip.category.toLowerCase().contains(query.toLowerCase()) || tip.content.toLowerCase().contains(query.toLowerCase())).toList();
    if (results.isEmpty) return const Center(child: Text('No tips found'));
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final tip = results[index];
        return ListTile(leading: Icon(tip.icon, color: tip.color), title: Text(tip.title), subtitle: Text(tip.category), onTap: () => close(context, tip));
      },
    );
  }
}