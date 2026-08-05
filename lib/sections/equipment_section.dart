import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme.dart';

class EquipmentSection extends StatelessWidget {
  const EquipmentSection({super.key});

  @override
  Widget build(packageContext) {
    final width = MediaQuery.of(packageContext).size.width;
    final isDesktop = width > 900;

    return Container(
      width: double.infinity,
      color: Colors.white,
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
                  'TOP-TIER EQUIPMENT & FREIGHT',
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
                'Modern trucks and reliable freight options give our drivers an edge on the road.',
                textAlign: TextAlign.center,
                style: Theme.of(packageContext).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textMuted,
                  fontSize: 18,
                ),
              ).animate().fadeIn(delay: 150.ms, duration: 500.ms),
              const SizedBox(height: 48),
              
              // Equipment Cards Grid
              isDesktop
                  ? const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: EquipmentCard(
                            imagePath: 'assets/images/truck_2.jpg',
                            fallbackIcon: Icons.star_border,
                            title: 'Owner-Operator Spec',
                            description: 'Late-model Mack, Volvo, and Kenworth trucks built for comfort, reliability, and style on the road.',
                            index: 0,
                          ),
                        ),
                        SizedBox(width: 24),
                        Expanded(
                          child: EquipmentCard(
                            imagePath: 'assets/images/truck_3.jpg',
                            fallbackIcon: Icons.dashboard_customize_outlined,
                            title: 'Van Freight',
                            description: 'Dry van freight lanes with routes selected directly by the driver. Ride in safety and stability.',
                            index: 1,
                          ),
                        ),
                        SizedBox(width: 24),
                        Expanded(
                          child: EquipmentCard(
                            imagePath: 'assets/images/truck_4.jpg',
                            fallbackIcon: Icons.ac_unit_outlined,
                            title: 'Reefer Freight',
                            description: 'Refrigerated loads for drivers who want dependable, premium freight options and steady routes.',
                            index: 2,
                          ),
                        ),
                      ],
                    )
                  : const Column(
                      children: [
                        EquipmentCard(
                          imagePath: 'assets/images/truck_2.jpg',
                          fallbackIcon: Icons.star_border,
                          title: 'Owner-Operator Spec',
                          description: 'Late-model Mack, Volvo, and Kenworth trucks built for comfort, reliability, and style on the road.',
                          index: 0,
                        ),
                        SizedBox(height: 32),
                        EquipmentCard(
                          imagePath: 'assets/images/truck_3.jpg',
                          fallbackIcon: Icons.dashboard_customize_outlined,
                          title: 'Van Freight',
                          description: 'Dry van freight lanes with routes selected directly by the driver. Ride in safety and stability.',
                          index: 1,
                        ),
                        SizedBox(height: 32),
                        EquipmentCard(
                          imagePath: 'assets/images/truck_4.jpg',
                          fallbackIcon: Icons.ac_unit_outlined,
                          title: 'Reefer Freight',
                          description: 'Refrigerated loads for drivers who want dependable, premium freight options and steady routes.',
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

class EquipmentCard extends StatefulWidget {
  final String imagePath;
  final IconData fallbackIcon;
  final String title;
  final String description;
  final int index;

  const EquipmentCard({
    super.key,
    required this.imagePath,
    required this.fallbackIcon,
    required this.title,
    required this.description,
    required this.index,
  });

  @override
  State<EquipmentCard> createState() => _EquipmentCardState();
}

class _EquipmentCardState extends State<EquipmentCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        transform: Matrix4.identity()..translate(0.0, _isHovered ? -6.0 : 0.0),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_isHovered ? 0.08 : 0.04),
              blurRadius: _isHovered ? 20 : 10,
              offset: Offset(0, _isHovered ? 10 : 5),
            ),
          ],
          border: Border.all(
            color: _isHovered ? AppTheme.primary.withOpacity(0.3) : Colors.grey.withOpacity(0.15),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Container
              AspectRatio(
                aspectRatio: 16 / 10,
                child: Container(
                  color: AppTheme.navyDark,
                  child: AnimatedScale(
                    scale: _isHovered ? 1.05 : 1.0,
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOut,
                    child: Image.asset(
                      widget.imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppTheme.navyDark, AppTheme.navyMedium],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              widget.fallbackIcon,
                              color: Colors.white.withOpacity(0.5),
                              size: 40,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              // Content Container
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    )
    .animate()
    .fadeIn(delay: (widget.index * 150).ms, duration: 600.ms)
    .slideY(begin: 0.1, end: 0);
  }
}
