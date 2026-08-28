import 'package:flutter/material.dart';
import 'theme.dart';
import 'config.dart';
import 'apply_screen.dart';
import 'sections/hero_section.dart';
import 'sections/perks_section.dart';
import 'sections/equipment_section.dart';
import 'sections/values_section.dart';
import 'sections/apply_section.dart';
import 'sections/footer_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Global keys to find section widget offsets dynamically
  final GlobalKey _homeKey = GlobalKey();
  final GlobalKey _perksKey = GlobalKey();
  final GlobalKey _equipmentKey = GlobalKey();
  final GlobalKey _applyKey = GlobalKey();

  final ScrollController _scrollController = ScrollController();
  bool _showStickyHeaderShadow = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.offset > 20) {
      if (!_showStickyHeaderShadow) {
        setState(() => _showStickyHeaderShadow = true);
      }
    } else {
      if (_showStickyHeaderShadow) {
        setState(() => _showStickyHeaderShadow = false);
      }
    }
  }

  void _scrollToSection(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    }
  }

  void _navigateToApply() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const ApplyScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 900;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(110),
        child: _buildHeader(isDesktop),
      ),
      drawer: isDesktop ? null : _buildMobileDrawer(),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            HeroSection(
              key: _homeKey,
              onApplyPressed: _navigateToApply,
            ),
            PerksSection(key: _perksKey),
            EquipmentSection(key: _equipmentKey),
            const ValuesSection(),
            ApplySection(key: _applyKey),
            FooterSection(
              onBackToTopPressed: () => _scrollToSection(_homeKey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDesktop) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.navyDark,
        boxShadow: _showStickyHeaderShadow
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                )
              ]
            : null,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: AppTheme.maxContentWidth),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Brand Logo link
              GestureDetector(
                onTap: () => _scrollToSection(_homeKey),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Row(
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
                    ],
                  ),
                ),
              ),
              
              // Navigation Options
              if (isDesktop)
                Row(
                  children: [
                    _buildNavLink('Home', () => _scrollToSection(_homeKey)),
                    const SizedBox(width: 24),
                    _buildNavLink('Perks', () => _scrollToSection(_perksKey)),
                    const SizedBox(width: 24),
                    _buildNavLink('Equipment', () => _scrollToSection(_equipmentKey)),
                    const SizedBox(width: 24),
                    _buildNavLink('Contact', () => _scrollToSection(_applyKey)),
                    const SizedBox(width: 32),
                    ElevatedButton(
                      onPressed: _navigateToApply,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      child: const Text(
                        'APPLY NOW',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                  ],
                )
              else
                Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white, size: 28),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavLink(String label, VoidCallback onTap) {
    return _HoverableTextButton(
      label: label,
      onTap: onTap,
    );
  }

  Widget _buildMobileDrawer() {
    return Drawer(
      backgroundColor: AppTheme.navyDark,
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white12)),
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/logo_red.png',
                    height: 90,
                    errorBuilder: (context, error, stackTrace) => const SizedBox(),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home, color: Colors.white70),
            title: const Text('Home', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              _scrollToSection(_homeKey);
            },
          ),
          ListTile(
            leading: const Icon(Icons.star, color: Colors.white70),
            title: const Text('Perks', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              _scrollToSection(_perksKey);
            },
          ),
          ListTile(
            leading: const Icon(Icons.local_shipping, color: Colors.white70),
            title: const Text('Equipment', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              _scrollToSection(_equipmentKey);
            },
          ),
          ListTile(
            leading: const Icon(Icons.contact_mail, color: Colors.white70),
            title: const Text('Contact', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              _scrollToSection(_applyKey);
            },
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _navigateToApply();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: const Text(
                  'APPLY NOW',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HoverableTextButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _HoverableTextButton({required this.label, required this.onTap});

  @override
  State<_HoverableTextButton> createState() => _HoverableTextButtonState();
}

class _HoverableTextButtonState extends State<_HoverableTextButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            color: _isHovered ? AppTheme.primary : Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
            fontFamily: 'Inter',
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(widget.label),
          ),
        ),
      ),
    );
  }
}
