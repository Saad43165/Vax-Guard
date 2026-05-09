import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import '../core/theme.dart';
import '../utils/l10n_helper.dart';

class HospitalMapScreen extends StatefulWidget {
  const HospitalMapScreen({super.key});

  @override
  State<HospitalMapScreen> createState() => _HospitalMapScreenState();
}

class _HospitalMapScreenState extends State<HospitalMapScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;
  bool _isLocating = false;
  String? _activeSearch;
  final ScrollController _scrollController = ScrollController();
  bool _isCollapsed = false;

  final List<_SearchOption> _searchOptions = [
    _SearchOption(
      label: 'Hospitals',
      query: 'hospitals near me',
      icon: Icons.local_hospital_rounded,
      color: const Color(0xFFEF4444),
      description: 'Full-service hospitals with ER',
    ),
    _SearchOption(
      label: 'Clinics',
      query: 'medical clinic near me',
      icon: Icons.medical_services_rounded,
      color: const Color(0xFF3B82F6),
      description: 'Walk-in & outpatient clinics',
    ),
    _SearchOption(
      label: 'Pharmacies',
      query: 'pharmacy near me',
      icon: Icons.local_pharmacy_rounded,
      color: const Color(0xFF10B981),
      description: 'Drug stores & pharmacies',
    ),
    _SearchOption(
      label: 'Emergency',
      query: 'emergency room near me',
      icon: Icons.emergency_rounded,
      color: const Color(0xFFF59E0B),
      description: '24/7 emergency care units',
    ),
    _SearchOption(
      label: 'Dentists',
      query: 'dentist near me',
      icon: Icons.sentiment_very_satisfied_rounded,
      color: const Color(0xFF8B5CF6),
      description: 'Dental clinics & specialists',
    ),
    _SearchOption(
      label: 'Labs',
      query: 'medical laboratory near me',
      icon: Icons.biotech_rounded,
      color: const Color(0xFF06B6D4),
      description: 'Diagnostic labs & blood work',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);

    _scrollController.addListener(() {
      final collapsed = _scrollController.offset > 120;
      if (collapsed != _isCollapsed) setState(() => _isCollapsed = collapsed);
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _openMaps(String query) async {
    setState(() {
      _isLocating = true;
      _activeSearch = query;
    });

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) throw Exception('Location permission denied');
      }
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions permanently denied. Please enable in Settings.');
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      final encoded = Uri.encodeComponent(query);
      final url = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$encoded&location=${pos.latitude},${pos.longitude}',
      );

      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(url, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(child: Text(e.toString())),
            ],
          ),
          backgroundColor: AppTheme.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } finally {
      if (mounted) setState(() { _isLocating = false; _activeSearch = null; });
    }
  }

  PreferredSizeWidget _buildFixedAppBar() {
    return AppBar(
      backgroundColor: AppTheme.surface(context),
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      title: Text(
        L10n.s(context, 'nearby_hospitals'),
        style: GoogleFonts.outfit(
          color: AppTheme.textPrimary(context),
          fontWeight: FontWeight.w800,
          fontSize: 20,
        ),
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary(context)),
        onPressed: () => Navigator.maybePop(context),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          color: AppTheme.border(context).withValues(alpha: 0.5),
          height: 1,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background(context),
      appBar: _buildFixedAppBar(),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // ─── Emergency Banner ──────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: _buildEmergencyBanner(),
            ),
          ),

          // ─── Section Label ─────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Text(
                'SEARCH NEARBY',
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  color: AppTheme.textTertiary(context),
                ),
              ),
            ),
          ),

          // ─── Search Options Grid ───────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.55,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final option = _searchOptions[index];
                  final isLoading = _isLocating && _activeSearch == option.query;
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: _SearchCard(
                      option: option,
                      isLoading: isLoading,
                      onTap: _isLocating ? null : () => _openMaps(option.query),
                    ),
                  );
                },
                childCount: _searchOptions.length,
              ),
            ),
          ),

          // ─── Tips Section ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              child: _buildTipsCard(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyBanner() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          final uri = Uri.parse('tel:911');
          if (await canLaunchUrl(uri)) launchUrl(uri);
        },
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            gradient: AppTheme.dangerGradient,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: AppTheme.danger.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.emergency_rounded, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Medical Emergency?',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'Tap to call emergency services now',
                      style: GoogleFonts.outfit(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'CALL',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTipsCard(BuildContext context) {
    final tips = [
      (Icons.location_on_rounded, 'Location is used only to find nearby places on Google Maps.'),
      (Icons.wifi_rounded, 'Internet connection is required for map search.'),
      (Icons.update_rounded, 'Results are live — they update based on your current location.'),
    ];
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline_rounded, color: AppTheme.warning, size: 18),
              const SizedBox(width: 8),
              Text(
                'HOW IT WORKS',
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  color: AppTheme.textTertiary(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...tips.map((t) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(t.$1, size: 16, color: AppTheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    t.$2,
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      color: AppTheme.textSecondary(context),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

class _SearchCard extends StatelessWidget {
  final _SearchOption option;
  final bool isLoading;
  final VoidCallback? onTap;

  const _SearchCard({required this.option, required this.isLoading, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          decoration: BoxDecoration(
            color: AppTheme.surface(context),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isLoading ? option.color.withOpacity(0.5) : AppTheme.border(context),
              width: isLoading ? 2 : 1,
            ),
            boxShadow: AppTheme.shadowSm,
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: option.color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: isLoading
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: option.color,
                              ),
                            )
                          : Icon(option.icon, color: option.color, size: 20),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.open_in_new_rounded,
                      size: 14,
                      color: AppTheme.textTertiary(context),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  option.label,
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  option.description,
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    color: AppTheme.textSecondary(context),
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchOption {
  final String label;
  final String query;
  final IconData icon;
  final Color color;
  final String description;

  const _SearchOption({
    required this.label,
    required this.query,
    required this.icon,
    required this.color,
    required this.description,
  });
}