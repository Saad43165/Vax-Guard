import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/theme.dart';
import '../services/emergency_sos_service.dart';
import '../utils/app_constants.dart';
import '../widgets/glass_app_bar.dart';
import '../widgets/glass_container.dart';

class EmergencyModeScreen extends StatefulWidget {
  const EmergencyModeScreen({super.key});

  @override
  State<EmergencyModeScreen> createState() => _EmergencyModeScreenState();
}

class _EmergencyModeScreenState extends State<EmergencyModeScreen>
    with TickerProviderStateMixin {
  bool _isDetecting = false;
  String? _detectedNumber;
  String? _detectedRegion;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _callEmergency() async {
    setState(() => _isDetecting = true);

    final result = await EmergencySOSService.instance.callEmergency();

    if (!mounted) return;
    setState(() {
      _isDetecting = false;
      _detectedNumber = result.number;
      _detectedRegion = result.region;
    });

    if (!result.launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not open dialer. Your emergency number is ${result.number}',
            style: GoogleFonts.outfit(),
          ),
          backgroundColor: AppTheme.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background(context),
      appBar: AppBar(
        title: Text(
          '🚨 EMERGENCY SOS', 
          style: GoogleFonts.outfit(fontWeight: FontWeight.w900, letterSpacing: 1)
        ),
        centerTitle: true,
        backgroundColor: AppTheme.danger.withOpacity(0.1),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Big SOS Button ──────────────────────────────────────────
            GestureDetector(
              onTap: _isDetecting ? null : _callEmergency,
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) => Transform.scale(
                  scale: _pulseAnimation.value,
                  child: child,
                ),
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.danger, Color(0xFFFF5252)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.danger.withOpacity(0.4),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isDetecting)
                        const CircularProgressIndicator(color: Colors.white, strokeWidth: 4)
                      else ...[
                        const Icon(Icons.emergency_rounded, color: Colors.white, size: 64),
                        const SizedBox(height: 16),
                        Text(
                          'CALL EMERGENCY',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (_detectedNumber != null)
                          Text(
                            '$_detectedRegion • ${_detectedNumber!}',
                            style: GoogleFonts.outfit(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          )
                        else
                          Text(
                            'Tap to detect & call',
                            style: GoogleFonts.outfit(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            if (_detectedNumber != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.success.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.success.withOpacity(0.3), width: 1.5),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: AppTheme.success, borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.location_on_rounded, color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Location detected: $_detectedRegion. Dialer ready for $_detectedNumber.',
                        style: GoogleFonts.outfit(
                          color: AppTheme.textPrimary(context),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 32),

            // ── Section Title ────────────────────────────────────────────
            Text(
              'Emergency Tools',
              style: GoogleFonts.outfit(
                color: AppTheme.textPrimary(context),
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 20),

            // ── Quick Action Tiles ───────────────────────────────────────
            _tile(
              icon: Icons.local_hospital_rounded,
              iconColor: AppTheme.success,
              title: 'Find Nearest Hospital',
              subtitle: 'Opens Google Maps with live hospital search.',
              onTap: () => Navigator.pushNamed(context, AppConstants.hospitalMapRoute),
            ),
            _tile(
              icon: Icons.healing_rounded,
              iconColor: AppTheme.primary,
              title: 'First Aid Steps',
              subtitle: 'Access step-by-step first aid guides offline.',
              onTap: () => Navigator.pushNamed(context, AppConstants.firstAidRoute),
            ),
            _tile(
              icon: Icons.pets_rounded,
              iconColor: AppTheme.warning,
              title: 'Animal Bite Guide',
              subtitle: 'WHO-approved rabies & wound urgency assessment.',
              onTap: () => Navigator.pushNamed(context, AppConstants.animalBiteRoute),
            ),
            _tile(
              icon: Icons.radar_rounded,
              iconColor: AppTheme.danger,
              title: 'Live Outbreak Radar',
              subtitle: 'Check if there are active outbreaks near you.',
              onTap: () => Navigator.pushNamed(context, AppConstants.liveOutbreaksRoute),
            ),

            const SizedBox(height: 24),

            // ── Emergency Disclaimer ─────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.surfaceVariant(context).withOpacity(0.5),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.border(context).withOpacity(0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded, color: AppTheme.danger, size: 24),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MEDICAL DISCLAIMER',
                          style: GoogleFonts.outfit(
                            color: AppTheme.danger,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'For life-threatening emergencies, always call your local emergency number immediately. This app provides clinical guidance only.',
                          style: GoogleFonts.outfit(
                            color: AppTheme.textSecondary(context),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.surface(context) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark ? AppTheme.border(context).withOpacity(0.5) : AppTheme.border(context).withOpacity(0.2),
              width: 1.5,
            ),
            boxShadow: isDark ? [] : [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: iconColor, size: 26),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.outfit(
                        color: AppTheme.textPrimary(context),
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.outfit(
                        color: AppTheme.textSecondary(context),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: AppTheme.textTertiary(context), size: 24),
            ],
          ),
        ),
      ),
    );
  }
}
