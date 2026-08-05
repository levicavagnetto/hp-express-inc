import 'package:flutter/material.dart';
import '../theme.dart';
import '../config.dart';

class FooterSection extends StatelessWidget {
  final VoidCallback onBackToTopPressed;

  const FooterSection({super.key, required this.onBackToTopPressed});

  @override
  Widget build(BuildContext context) {
    final currentYear = DateTime.now().year;

    return Container(
      width: double.infinity,
      color: AppTheme.navyDark,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: AppTheme.maxContentWidth),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Logo/Brand Name
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/logo_red.png',
                        height: 90,
                        errorBuilder: (context, error, stackTrace) {
                          return const Text(
                            'H&P',
                            style: TextStyle(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      Text(
                        AppConfig.companyName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  // Back to Top button
                  IconButton(
                    onPressed: onBackToTopPressed,
                    icon: const Icon(Icons.arrow_upward, color: Colors.white70),
                    tooltip: 'Back to Top',
                  ),
                ],
              ),
              const Divider(color: Colors.white24, height: 40),
              // Copyright details
              Text(
                '© $currentYear ${AppConfig.companyName} All rights reserved. • High-Quality Freight Operations',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
