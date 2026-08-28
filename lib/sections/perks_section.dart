import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme.dart';

class PerksSection extends StatelessWidget {
  const PerksSection({super.key});

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
              // Section label / header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'DRIVE YOUR CAREER FORWARD',
                  style: TextStyle(
                    color: AppTheme.primaryDark,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                    fontSize: 13,
                  ),
                ),
              ).animate().fadeIn(duration: 500.ms),
              const SizedBox(height: 48),
              // Grid layout
              isDesktop
                  ? const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: HoverBenefitCard(
                            icon: Icons.monetization_on_outlined,
                            title: 'Competitive Pay',
                            description: '\$65,000 to \$95,000 per year plus health benefits for experienced drivers.',
                            index: 0,
                          ),
                        ),
                        SizedBox(width: 24),
                        Expanded(
                          child: HoverBenefitCard(
                            icon: Icons.thumb_up_alt_outlined,
                            title: 'Driver Choice',
                            description: 'Choose loads in the areas you feel most comfortable, including local evening/night routes with no heavy lifting.',
                            index: 1,
                          ),
                        ),
                        SizedBox(width: 24),
                        Expanded(
                          child: HoverBenefitCard(
                            icon: Icons.local_shipping_outlined,
                            title: 'Van & Reefer Freight',
                            description: 'We run dry van and refrigerated freight with late-model Mack, Volvo, and Kenworth owner-operator spec trucks.',
                            index: 2,
                          ),
                        ),
                      ],
                    )
                  : const Column(
                      children: [
                        HoverBenefitCard(
                          icon: Icons.monetization_on_outlined,
                          title: 'Competitive Pay',
                          description: '\$65,000 to \$95,000 per year plus health benefits for experienced drivers.',
                          index: 0,
                        ),
                        SizedBox(height: 24),
                        HoverBenefitCard(
                          icon: Icons.thumb_up_alt_outlined,
                          title: 'Driver Choice',
                          description: 'Choose loads in the areas you feel most comfortable, including local evening/night routes with no heavy lifting.',
                          index: 1,
                        ),
                        SizedBox(height: 24),
                        HoverBenefitCard(
                          icon: Icons.local_shipping_outlined,
                          title: 'Van & Reefer Freight',
                          description: 'We run dry van and refrigerated freight with late-model Mack, Volvo, and Kenworth owner-operator spec trucks.',
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

class HoverBenefitCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String description;
  final int index;

  const HoverBenefitCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.index,
  });

  @override
  State<HoverBenefitCard> createState() => _HoverBenefitCardState();
}

class _HoverBenefitCardState extends State<HoverBenefitCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        transform: Matrix4.identity()..translate(0.0, _isHovered ? -8.0 : 0.0),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: _isHovered ? AppTheme.primary.withOpacity(0.5) : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: _isHovered 
                  ? AppTheme.primary.withOpacity(0.08) 
                  : Colors.black.withOpacity(0.04),
              blurRadius: _isHovered ? 24 : 12,
              offset: Offset(0, _isHovered ? 12 : 6),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _isHovered 
                    ? AppTheme.primary 
                    : AppTheme.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                widget.icon,
                color: _isHovered ? Colors.white : AppTheme.primary,
                size: 28,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              widget.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    )
    .animate()
    .fadeIn(delay: (widget.index * 150).ms, duration: 500.ms)
    .slideY(begin: 0.1, end: 0);
  }
}
