import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme.dart';
import '../config.dart';
import '../apply_screen.dart';

import 'package:web/web.dart' as web;

class ApplySection extends StatefulWidget {
  const ApplySection({super.key});

  @override
  State<ApplySection> createState() => _ApplySectionState();
}

class _ApplySectionState extends State<ApplySection> {
  String _decodedEmail = 'Loading...';
  String _decodedPhone = 'Loading...';
  String _phoneUrl = '';

  @override
  void initState() {
    super.initState();
    _decodeContacts();
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

  void _openFullApplyPage() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const ApplyScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 900;

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Section Header
              Text(
                'Ready to drive with ${AppConfig.companyName}?',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textMuted,
                  fontSize: 18,
                ),
              ).animate().fadeIn(delay: 150.ms, duration: 500.ms),
              const SizedBox(height: 24),

              // Button opening the 3-Form Application Portal Page
              ElevatedButton.icon(
                onPressed: _openFullApplyPage,
                icon: const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                label: const Text(
                  'APPLY NOW',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    letterSpacing: 0.5,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  elevation: 4,
                ),
              ).animate().fadeIn(delay: 250.ms, duration: 500.ms).scaleXY(begin: 0.95, end: 1.0),
              const SizedBox(height: 48),

              // Contact Info Box (General Inquiries)
              _buildContactTab(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactTab() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 500),
      decoration: BoxDecoration(
        color: AppTheme.bgLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(36),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Contact H&P Express Inc.',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'If you have questions about driving opportunities or freight logistics, get in touch with us directly:',
            style: TextStyle(color: AppTheme.textMuted, fontSize: 14),
          ),
          const SizedBox(height: 28),
          
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
          
          const SizedBox(height: 20),

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
                color: AppTheme.primary.withOpacity(0.08),
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
                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
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
