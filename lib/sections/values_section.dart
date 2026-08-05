import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme.dart';

class ValuesSection extends StatelessWidget {
  const ValuesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 900;

    return Container(
      width: double.infinity,
      color: AppTheme.bgLight,
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: AppTheme.maxContentWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Section Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'WHO WE ARE LOOKING FOR',
                  style: TextStyle(
                    color: AppTheme.primaryDark,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                    fontSize: 13,
                  ),
                ),
              ).animate().fadeIn(duration: 500.ms),
              const SizedBox(height: 16),
              Text(
                'We want experienced, professional drivers who value independence and a strong company culture.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textMuted,
                  fontSize: 18,
                ),
              ).animate().fadeIn(delay: 150.ms, duration: 500.ms),
              const SizedBox(height: 48),

              // Qualifications Row / Column
              isDesktop
                  ? const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ValueCard(
                            title: 'Experienced Professional Drivers',
                            subtitle: 'Demonstrated road competence, secure cargo handling, and a professional attitude.',
                            index: 0,
                          ),
                        ),
                        SizedBox(width: 24),
                        Expanded(
                          child: ValueCard(
                            title: 'Clean Driving Record',
                            subtitle: 'High safety consciousness, commitment to compliance, and a strong history of safe transit.',
                            index: 1,
                          ),
                        ),
                        SizedBox(width: 24),
                        Expanded(
                          child: ValueCard(
                            title: 'Safety, Independence & Family',
                            subtitle: 'Alignment with our values. We treat you like family, respect your freedom, and prioritize safety.',
                            index: 2,
                          ),
                        ),
                      ],
                    )
                  : const Column(
                      children: [
                        ValueCard(
                          title: 'Experienced Professional Drivers',
                          subtitle: 'Demonstrated road competence, secure cargo handling, and a professional attitude.',
                          index: 0,
                        ),
                        SizedBox(height: 24),
                        ValueCard(
                          title: 'Clean Driving Record',
                          subtitle: 'High safety consciousness, commitment to compliance, and a strong history of safe transit.',
                          index: 1,
                        ),
                        SizedBox(height: 24),
                        ValueCard(
                          title: 'Safety, Independence & Family',
                          subtitle: 'Alignment with our values. We treat you like family, respect your freedom, and prioritize safety.',
                          index: 2,
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class ValueCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final int index;

  const ValueCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(30),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )
    .animate()
    .fadeIn(delay: (index * 150).ms, duration: 500.ms)
    .slideX(begin: 0.05, end: 0);
  }
}
