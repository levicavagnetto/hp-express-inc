import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme.dart';
import '../config.dart';

class HeroSection extends StatelessWidget {
  final VoidCallback onApplyPressed;

  const HeroSection({super.key, required this.onApplyPressed});

  @override
  Widget build(packageContext) {
    final width = MediaQuery.of(packageContext).size.width;
    final isDesktop = width > 900;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.navyDark,
            AppTheme.navyMedium,
            AppTheme.navyLight,
          ],
        ),
      ),
      padding: EdgeInsets.symmetric(
        vertical: isDesktop ? 100 : 60,
        horizontal: 24,
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: AppTheme.maxContentWidth),
          child: isDesktop
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(flex: 7, child: _buildCopy(packageContext, true)),
                    const SizedBox(width: 48),
                    Expanded(flex: 5, child: _buildImageCard(packageContext)),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCopy(packageContext, false),
                    const SizedBox(height: 48),
                    Center(child: _buildImageCard(packageContext)),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildCopy(BuildContext context, bool isDesktop) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          AppConfig.tagline.toUpperCase(),
          style: const TextStyle(
            color: Color(0xFFF6B5B7),
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2, end: 0),
        const SizedBox(height: 16),
        Text(
          'Join ${AppConfig.companyName}',
          style: textTheme.displayLarge?.copyWith(
            color: Colors.white,
            fontSize: isDesktop ? 54 : 38,
          ),
        ).animate().fadeIn(delay: 200.ms, duration: 600.ms).slideY(begin: 0.1, end: 0),
        const SizedBox(height: 24),
        Text(
          'For 23 years, H&P Express Inc. has operated as a proud, family-owned small trucking company. '
          'We specialize in running high-quality van and reefer freight, prioritizing a supportive '
          'culture where our drivers stay moving, maximize their earnings, and get home regularly.',
          style: textTheme.bodyLarge?.copyWith(
            color: Colors.white.withOpacity(0.85),
            fontSize: 17,
          ),
        ).animate().fadeIn(delay: 400.ms, duration: 600.ms).slideY(begin: 0.05, end: 0),
        const SizedBox(height: 36),
        ElevatedButton(
          onPressed: onApplyPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            elevation: 4,
          ),
          child: const Text(
            'APPLY NOW',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              letterSpacing: 1.0,
            ),
          ),
        ).animate().fadeIn(delay: 600.ms, duration: 500.ms).scaleXY(begin: 0.95, end: 1.0),
      ],
    );
  }

  Widget _buildImageCard(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 400, maxWidth: 500),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withOpacity(0.08),
            Colors.white.withOpacity(0.03),
          ],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: AspectRatio(
          aspectRatio: 4 / 3,
          child: Image.asset(
            'assets/images/truck_1.jpg',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              // Fallback if image asset has any issue
              return Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.primary,
                      AppTheme.primaryDark,
                      AppTheme.navyDark,
                    ],
                    center: Alignment.topLeft,
                    radius: 1.2,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.local_shipping,
                    color: Colors.white,
                    size: 64,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    ).animate().fadeIn(delay: 300.ms, duration: 800.ms).scaleXY(begin: 0.95, end: 1.0);
  }
}
