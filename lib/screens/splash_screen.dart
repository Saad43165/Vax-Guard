import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../services/user_profile_service.dart';
import '../utils/app_constants.dart';
import '../utils/l10n_helper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _mainController;
  
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _contentFade;
  late Animation<Offset> _contentSlide;
  late Animation<double> _bgBlur;

  @override
  void initState() {
    super.initState();
    
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );
    
    _logoScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.15).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.15, end: 1.0).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 60,
      ),
    ]).animate(_mainController);
    
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.0, 0.4, curve: Curves.easeIn)),
    );
    
    _contentFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.4, 0.8, curve: Curves.easeIn)),
    );
    
    _contentSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.4, 0.9, curve: Curves.easeOutCubic)),
    );
    
    _bgBlur = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.0, 0.6, curve: Curves.easeOut)),
    );
    
    _startSequence();
  }

  void _startSequence() async {
    _mainController.forward();
    
    final hasCompleted = await UserProfileService.hasCompletedOnboarding();
    
    await Future.delayed(const Duration(milliseconds: 2500));
    if (mounted) {
      if (hasCompleted) {
        Navigator.pushReplacementNamed(context, AppConstants.homeRoute);
      } else {
        Navigator.pushReplacementNamed(context, AppConstants.onboardingRoute);
      }
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: AppTheme.premiumDarkGradient,
            ),
          ),
          
          // Background "Aura" Glow (Subtle)
          Positioned(
            top: -100,
            right: -100,
            child: _buildAura(AppTheme.primary.withOpacity(0.02), 300),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: _buildAura(AppTheme.secondary.withOpacity(0.02), 250),
          ),
          
          // Main Content
          AnimatedBuilder(
            animation: _mainController,
            builder: (context, child) {
              return Stack(
                children: [
                  SafeArea(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Spacer(flex: 3),
                          _buildAnimatedLogo(),
                          const SizedBox(height: 40),
                          _buildAnimatedText(),
                          const Spacer(flex: 2),
                          _buildFooter(),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                  
                  // Initial Blur Overlay
                  if (_bgBlur.value > 0.1)
                    Positioned.fill(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: _bgBlur.value, sigmaY: _bgBlur.value),
                        child: Container(color: Colors.transparent),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAura(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: size / 2,
            spreadRadius: size / 4,
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedLogo() {
    return ScaleTransition(
      scale: _logoScale,
      child: FadeTransition(
        opacity: _logoOpacity,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withOpacity(0.3),
                  blurRadius: 40,
                  offset: const Offset(0, 10),
                ),
              ],
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 2,
              ),
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/splash_icon.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.health_and_safety_rounded,
                  color: Colors.white,
                  size: 90,
                ),
              ),
            ),
          ),
      ),
    );
  }

  Widget _buildAnimatedText() {
    return FadeTransition(
      opacity: _contentFade,
      child: SlideTransition(
        position: _contentSlide,
        child: Column(
          children: [
            Text(
              L10n.s(context, 'app_name'),
              style: AppTheme.darkTheme().textTheme.displayLarge?.copyWith(
                color: Colors.white,
                letterSpacing: -1.5,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Text(
                L10n.s(context, 'app_tagline').toUpperCase(),
                style: AppTheme.darkTheme().textTheme.labelMedium?.copyWith(
                  color: Colors.white.withOpacity(0.7),
                  letterSpacing: 3.0,
                  fontWeight: FontWeight.w800,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return FadeTransition(
      opacity: _contentFade,
      child: Column(
        children: [
          SizedBox(
            width: 140,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                backgroundColor: Colors.white.withOpacity(0.1),
                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                minHeight: 2,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Version 1.0.0',
            style: AppTheme.darkTheme().textTheme.bodySmall?.copyWith(
              color: Colors.white.withOpacity(0.3),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
