import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'theme.dart';
import 'config.dart';
import 'sections/footer_section.dart';

import 'dart:js_interop';
import 'dart:ui_web' as ui_web;
import 'package:flutter/gestures.dart';
import 'package:web/web.dart' as web;

class ApplyScreen extends StatefulWidget {
  const ApplyScreen({super.key});

  @override
  State<ApplyScreen> createState() => _ApplyScreenState();
}

class _ApplyScreenState extends State<ApplyScreen> {
  int _activeFormIndex = 0; // 0 = Form 1, 1 = Form 2, 2 = Form 3
  final List<double> _formHeights = [1912.0, 3161.0, 1880.0];
  String _decodedEmail = 'Loading...';
  String _decodedPhone = 'Loading...';
  String _phoneUrl = '';
  
  bool _isLeavingApproved = false;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _decodeContacts();
    _registerCognitoPlatformViews();
    _enableUnloadWarning();
    _setupIframeScrollBridge();
  }

  @override
  void dispose() {
    _disableUnloadWarning();
    _scrollController.dispose();
    super.dispose();
  }

  void _setupIframeScrollBridge() {
    if (kIsWeb) {
      web.window.addEventListener('message', ((web.MessageEvent event) {
        try {
          final rawData = event.data;
          if (rawData != null) {
            String dataStr = '';
            try {
              dataStr = rawData.dartify()?.toString() ?? rawData.toString();
            } catch (e) {
              dataStr = rawData.toString();
            }
            
            if (dataStr.startsWith('COGNITO_SCROLL:')) {
              final parts = dataStr.split(':');
              if (parts.length >= 2) {
                final double deltaY = double.tryParse(parts[1]) ?? 0.0;
                if (deltaY != 0.0 && _scrollController.hasClients) {
                  final newOffset = (_scrollController.offset + deltaY).clamp(
                      0.0,
                      _scrollController.position.maxScrollExtent,
                    );
                    _scrollController.jumpTo(newOffset);
                  }
                }
            } else if (dataStr.startsWith('COGNITO_HEIGHT:')) {
              final parts = dataStr.split(':');
              if (parts.length >= 3) {
                final formHeight = double.tryParse(parts[1]) ?? _formHeights[_activeFormIndex];
                final formIndex = int.tryParse(parts[2]) ?? _activeFormIndex;
                if (formIndex >= 0 && formIndex < _formHeights.length) {
                  _updateFormHeight(formIndex, formHeight);
                }
              }
            }
          }
        } catch (e) {
          // Ignore non-json or unrelated window messages
        }
      }).toJS);
    }
  }

  void _updateFormHeight(int index, double height) {
    final updatedHeight = height.clamp(900.0, 9000.0);
    if (_formHeights[index] != updatedHeight) {
      setState(() {
        _formHeights[index] = updatedHeight;
      });
    }
  }

  void _enableUnloadWarning() {
    if (kIsWeb) {
      web.window.onbeforeunload = ((web.Event event) {
        if (_isLeavingApproved) return null;
        event.preventDefault();
        return 'You may lose your unsaved application progress if you leave this page.'.toJS;
      }).toJS;
    }
  }

  void _disableUnloadWarning() {
    if (kIsWeb) {
      web.window.onbeforeunload = null;
    }
  }

  void _decodeContacts() {
    try {
      final emailBytes = base64.decode(AppConfig.encodedEmail);
      _decodedEmail = utf8.decode(emailBytes);

      final phoneBytes = base64.decode(AppConfig.encodedPhone);
      _decodedPhone = utf8.decode(phoneBytes);
      _phoneUrl = 'tel:${_decodedPhone.replaceAll(RegExp(r'\D'), '')}';
    } catch (e) {
      _decodedEmail = 'Error loading contact info';
      _decodedPhone = 'Error loading contact info';
    }
  }

  void _registerCognitoPlatformViews() {
    if (kIsWeb) {
      ui_web.platformViewRegistry.registerViewFactory(
        'cognito-form-1-view',
        (int viewId) {
          final iframe = web.HTMLIFrameElement()
            ..style.border = 'none'
            ..style.width = '100%'
            ..style.height = '100%'
            ..style.overflow = 'hidden'
            ..srcdoc = AppConfig.cognitoFormEmbedHtml(formNumber: 1, formIndex: 0).toJS;
          return iframe;
        },
      );

      ui_web.platformViewRegistry.registerViewFactory(
        'cognito-form-2-view',
        (int viewId) {
          final iframe = web.HTMLIFrameElement()
            ..style.border = 'none'
            ..style.width = '100%'
            ..style.height = '100%'
            ..style.overflow = 'hidden'
            ..srcdoc = AppConfig.cognitoFormEmbedHtml(formNumber: 4, formIndex: 1).toJS;
          return iframe;
        },
      );

      ui_web.platformViewRegistry.registerViewFactory(
        'cognito-form-3-view',
        (int viewId) {
          final iframe = web.HTMLIFrameElement()
            ..style.border = 'none'
            ..style.width = '100%'
            ..style.height = '100%'
            ..style.overflow = 'hidden'
            ..srcdoc = AppConfig.cognitoFormEmbedHtml(formNumber: 3, formIndex: 2).toJS;
          return iframe;
        },
      );
    }
  }

  Future<bool> _confirmLeave() async {
    if (_isLeavingApproved) return true;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        elevation: 24,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppTheme.primary, size: 28),
            SizedBox(width: 12),
            Text(
              'Leave Application Portal?',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to leave? Any unsubmitted progress in your application forms will be lost.',
          style: TextStyle(fontSize: 15, color: AppTheme.textDark, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'STAY ON PAGE',
              style: TextStyle(color: AppTheme.textMuted, fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('LEAVE PAGE', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (mounted) {
      // No UI state is tied to dialog visibility.
    }

    if (result == true) {
      _isLeavingApproved = true;
      _disableUnloadWarning();
      return true;
    }
    return false;
  }

  Future<void> _onHandleBackToHome() async {
    final approved = await _confirmLeave();
    if (approved && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 900;

    return PopScope(
      canPop: _isLeavingApproved,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) return;
        final navigator = Navigator.of(context);
        final approved = await _confirmLeave();
        if (approved && mounted) {
          navigator.pop();
        }
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: _buildHeader(isDesktop),
        ),
        drawer: isDesktop ? null : _buildMobileDrawer(),
        body: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
              // Top Informational Section
              _buildInformationalSection(isDesktop),
              const SizedBox(height: 32),

              // Form Area (Full width & height)
              _buildFormSection(isDesktop),
              const SizedBox(height: 64),

              // Contact Info Section
              _buildContactSection(),
              const SizedBox(height: 64),

              // Footer
              FooterSection(
                onBackToTopPressed: () {
                  if (_scrollController.hasClients) {
                    _scrollController.animateTo(
                      0,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDesktop) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.navyDark,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 15,
            offset: Offset(0, 5),
          )
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: AppTheme.maxContentWidth),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo button (returns Home with warning check)
              GestureDetector(
                onTap: _onHandleBackToHome,
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

              if (isDesktop)
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: _onHandleBackToHome,
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      label: const Text(
                        'Back to Home',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
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
              child: Image.asset(
                'assets/images/logo_red.png',
                height: 90,
                errorBuilder: (context, error, stackTrace) => const SizedBox(),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home, color: Colors.white70),
            title: const Text('Back to Home', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context); // Close drawer
              _onHandleBackToHome(); // Prompt confirmation
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInformationalSection(bool isDesktop) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.navyDark,
            AppTheme.navyMedium,
          ],
        ),
      ),
      padding: EdgeInsets.symmetric(
        vertical: isDesktop ? 60 : 40,
        horizontal: 24,
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withAlpha((0.15 * 255).round()),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'DRIVER APPLICATION PORTAL',
                  style: TextStyle(
                    color: Color(0xFFF6B5B7),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    fontSize: 13,
                  ),
                ),
              ).animate().fadeIn(duration: 500.ms),
              const SizedBox(height: 16),
              Text(
                'Complete Your Application',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isDesktop ? 40 : 28,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Outfit',
                ),
              ).animate().fadeIn(delay: 150.ms, duration: 500.ms),
              const SizedBox(height: 16),
              
              // Notice Box
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha((0.07 * 255).round()),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.primary.withAlpha((0.4 * 255).round())),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppTheme.primary, size: 28),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'IMPORTANT: Applicants must complete all 3 forms below. '
                        'Please fill out an Application for Employment, Background Check, and a Certificate of Compliance by switching between the tabs below.',
                        style: TextStyle(
                          color: Colors.white.withAlpha((0.95 * 255).round()),
                          fontSize: 15,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 300.ms, duration: 500.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormSection(bool isDesktop) {
    return Container(
      width: double.infinity,
      color: AppTheme.bgLight,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          decoration: BoxDecoration(
            color: AppTheme.cardBg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.grey.withAlpha((0.16 * 255).round())),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((0.03 * 255).round()),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildFormTabs(),
              const SizedBox(height: 24),

              // Embedded Form iFrame View (Dynamic height for each form)
              _buildActiveFormView(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormTabs() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bgLight,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey.withAlpha((0.2 * 255).round())),
      ),
      padding: const EdgeInsets.all(6),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: [
          _buildTabButton('Application for Employment', 0),
          _buildTabButton('Background Check', 1),
          _buildTabButton('Certificate of Compliance', 2),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, int index) {
    final isActive = _activeFormIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeFormIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primary : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isActive ? AppTheme.primary : Colors.grey.withAlpha((0.3 * 255).round()),
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppTheme.primary.withAlpha((0.25 * 255).round()),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? Icons.check_circle : Icons.description_outlined,
              color: isActive ? Colors.white : AppTheme.textMuted,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : AppTheme.textDark,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveFormView() {
    final formHeight = _formHeights[_activeFormIndex];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 75),
      curve: Curves.easeOut,
      height: formHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color.fromRGBO(158, 158, 158, 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.05 * 255).round()),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(8),
      child: kIsWeb
          ? Listener(
              behavior: HitTestBehavior.translucent,
              onPointerSignal: (event) {
                if (event is PointerScrollEvent && _scrollController.hasClients) {
                  final newOffset = (_scrollController.offset + event.scrollDelta.dy)
                      .clamp(0.0, _scrollController.position.maxScrollExtent);
                  _scrollController.jumpTo(newOffset);
                }
              },
              child: IndexedStack(
                index: _activeFormIndex,
                children: const [
                  HtmlElementView(viewType: 'cognito-form-1-view'),
                  HtmlElementView(viewType: 'cognito-form-2-view'),
                  HtmlElementView(viewType: 'cognito-form-3-view'),
                ],
              ),
            )
          : const Center(
              child: Text(
                'Cognito Forms require Web view.',
                style: TextStyle(color: AppTheme.textMuted),
              ),
            ),
    );
  }

  Widget _buildContactSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.withAlpha((0.15 * 255).round())),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((0.03 * 255).round()),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Questions About Applying?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'If you need assistance completing your application forms, feel free to reach out directly:',
                style: TextStyle(color: AppTheme.textMuted, fontSize: 14),
              ),
              const SizedBox(height: 24),
              
              // Phone Item
              _buildContactItem(
                icon: Icons.phone_outlined,
                label: 'Phone Number',
                value: _decodedPhone,
                onTap: () {
                  if (kIsWeb) {
                    web.window.location.href = _phoneUrl;
                  }
                },
              ),
              const SizedBox(height: 16),

              // Email Item
              _buildContactItem(
                icon: Icons.email_outlined,
                label: 'Email Address',
                value: _decodedEmail,
                onTap: () {
                  if (kIsWeb) {
                    web.window.location.href = 'mailto:$_decodedEmail';
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primary.withAlpha((0.08 * 255).round()),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppTheme.primary, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
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
}
