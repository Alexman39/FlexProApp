import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';

enum LegalDocType { privacyPolicy, terms }

class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key, required this.type});

  final LegalDocType type;

  @override
  Widget build(BuildContext context) {
    final isPrivacy = type == LegalDocType.privacyPolicy;
    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: context.bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: context.primaryText,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isPrivacy ? 'Privacy Policy' : 'Terms of Service',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: context.primaryText,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 60),
        child: isPrivacy ? const _PrivacyContent() : const _TermsContent(),
      ),
    );
  }
}

// ── Shared widgets ───────────────────────────────────────

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.accent,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13.5,
              fontWeight: FontWeight.w400,
              color: context.secondaryText,
              height: 1.65,
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.updated});

  final String updated;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            'Last updated: $updated',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: context.tertiaryText,
            ),
          ),
          const SizedBox(height: 16),
          Container(height: 1, color: context.border),
        ],
      ),
    );
  }
}

// ── Privacy Policy content ───────────────────────────────

class _PrivacyContent extends StatelessWidget {
  const _PrivacyContent();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Header(updated: 'June 2025'),

        _Section(
          title: '1. DATA CONTROLLER',
          body:
              'FlexPro Coaching is operated by Tasos Misailidis ("we", "us", or "our"). '
              'You may contact us at: tasos@flexpro.app\n\n'
              'As data controller under the EU General Data Protection Regulation (GDPR), '
              'we are responsible for the personal data you provide to us through the app.',
        ),

        _Section(
          title: '2. DATA WE COLLECT',
          body:
              '• Account data: name, email address, and profile photo (optional).\n'
              '• Fitness data: workout logs, exercise history, sets, reps, and weights.\n'
              '• Body metrics: weight entries you manually log in the app.\n'
              '• Goals & preferences: training goals and onboarding responses.\n'
              '• Device data: device type, operating system version, and push notification token for workout reminders.\n'
              '• Usage data: app interactions collected anonymously for performance monitoring.',
        ),

        _Section(
          title: '3. HOW WE USE YOUR DATA',
          body:
              '• To provide and personalise your training experience.\n'
              '• To enable your coach (Tasos Misailidis) to design and adjust your program.\n'
              '• To send workout reminder push notifications (only if you opt in).\n'
              '• To improve app performance and fix bugs.\n\n'
              'We do not sell, rent, or share your personal data with third parties for marketing purposes.',
        ),

        _Section(
          title: '4. LEGAL BASIS FOR PROCESSING (GDPR)',
          body:
              'We process your data under the following legal bases:\n'
              '• Performance of a contract (Art. 6(1)(b)): to provide the coaching service.\n'
              '• Legitimate interest (Art. 6(1)(f)): app security and performance analytics.\n'
              '• Consent (Art. 6(1)(a)): push notifications — you may withdraw consent at any time in Profile → Notifications.',
        ),

        _Section(
          title: '5. DATA STORAGE & SECURITY',
          body:
              'Your data is stored securely on Google Firebase (Firestore & Authentication), '
              'hosted in EU-based data centres where possible, subject to Google\'s data processing terms. '
              'We implement industry-standard technical and organisational measures to protect your data against '
              'unauthorised access, loss, or disclosure.',
        ),

        _Section(
          title: '6. DATA RETENTION',
          body:
              'We retain your personal data for as long as your account is active. '
              'If you delete your account, we will delete your data within 30 days, '
              'except where retention is required by law.',
        ),

        _Section(
          title: '7. YOUR RIGHTS UNDER GDPR',
          body:
              'As an EU resident you have the right to:\n'
              '• Access the personal data we hold about you.\n'
              '• Rectify inaccurate data.\n'
              '• Request erasure of your data ("right to be forgotten").\n'
              '• Restrict or object to processing.\n'
              '• Data portability — receive your data in a machine-readable format.\n'
              '• Withdraw consent at any time (for notifications).\n\n'
              'To exercise any of these rights, email us at tasos@flexpro.app. '
              'You also have the right to lodge a complaint with your national data protection authority.',
        ),

        _Section(
          title: '8. THIRD-PARTY SERVICES',
          body:
              '• Google Firebase — authentication, cloud database, and storage. '
              'Privacy policy: https://firebase.google.com/support/privacy\n'
              '• RevenueCat — in-app subscription management. '
              'Privacy policy: https://www.revenuecat.com/privacy\n'
              '• Google Sign-In — optional social login. '
              'Privacy policy: https://policies.google.com/privacy',
        ),

        _Section(
          title: '9. CHILDREN\'S PRIVACY',
          body:
              'FlexPro Coaching is not intended for users under the age of 16. '
              'We do not knowingly collect personal data from children. '
              'If you believe a child has provided us with personal data, please contact us immediately.',
        ),

        _Section(
          title: '10. CHANGES TO THIS POLICY',
          body:
              'We may update this Privacy Policy from time to time. '
              'We will notify you of significant changes via the app or by email. '
              'Continued use of the app after changes constitutes your acceptance of the updated policy.',
        ),

        _Section(
          title: '11. CONTACT',
          body:
              'For any privacy-related questions or requests:\n\n'
              'Tasos Misailidis\n'
              'Email: tasos@flexpro.app',
        ),
      ],
    );
  }
}

// ── Terms of Service content ─────────────────────────────

class _TermsContent extends StatelessWidget {
  const _TermsContent();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Header(updated: 'June 2025'),

        _Section(
          title: '1. ACCEPTANCE OF TERMS',
          body:
              'By downloading or using FlexPro Coaching ("the App"), you agree to be bound by these '
              'Terms of Service. If you do not agree, do not use the App.',
        ),

        _Section(
          title: '2. DESCRIPTION OF SERVICE',
          body:
              'FlexPro Coaching is a personalised fitness coaching application developed and operated '
              'by Tasos Misailidis. The App provides structured workout programs, exercise tracking, '
              'progress analytics, and direct coaching communication.',
        ),

        _Section(
          title: '3. USER ACCOUNTS',
          body:
              '• You are responsible for maintaining the confidentiality of your account credentials.\n'
              '• You must provide accurate and complete information when creating your account.\n'
              '• You may not share your account with others or use another person\'s account.\n'
              '• You are responsible for all activity that occurs under your account.',
        ),

        _Section(
          title: '4. SUBSCRIPTIONS & PAYMENTS',
          body:
              'Certain features require a FlexPro Premium subscription, processed through Apple App Store or Google Play.\n\n'
              '• Subscriptions renew automatically unless cancelled at least 24 hours before the renewal date.\n'
              '• Prices may vary by region and are shown at the time of purchase.\n'
              '• Refunds are handled in accordance with Apple App Store / Google Play refund policies.\n'
              '• The free trial (if offered) converts to a paid subscription unless cancelled before the trial ends.',
        ),

        _Section(
          title: '5. HEALTH DISCLAIMER',
          body:
              'IMPORTANT: FlexPro Coaching is not a medical service or substitute for professional medical advice, '
              'diagnosis, or treatment. Always consult a qualified healthcare professional before starting '
              'any new fitness programme, especially if you have a pre-existing medical condition, injury, '
              'or are pregnant.\n\n'
              'By using the App you acknowledge that physical exercise carries inherent risks. '
              'You assume full responsibility for your health and safety during workouts.',
        ),

        _Section(
          title: '6. ACCEPTABLE USE',
          body:
              'You agree not to:\n'
              '• Use the App for any unlawful purpose.\n'
              '• Attempt to reverse engineer, copy, or redistribute the App or its content.\n'
              '• Upload or transmit malicious code or interfere with the App\'s operation.\n'
              '• Misrepresent your identity or affiliation.',
        ),

        _Section(
          title: '7. INTELLECTUAL PROPERTY',
          body:
              'All content in the App — including programs, exercise descriptions, images, and interface design — '
              'is owned by or licensed to Tasos Misailidis and is protected by copyright. '
              'You may not reproduce or distribute it without prior written consent.',
        ),

        _Section(
          title: '8. LIMITATION OF LIABILITY',
          body:
              'To the maximum extent permitted by law, FlexPro Coaching and Tasos Misailidis shall not be '
              'liable for any indirect, incidental, special, or consequential damages arising from your '
              'use of the App, including injury, loss of data, or financial loss.',
        ),

        _Section(
          title: '9. TERMINATION',
          body:
              'We reserve the right to suspend or terminate your account at our discretion if you violate these Terms. '
              'You may delete your account at any time by contacting us at tasos@flexpro.app.',
        ),

        _Section(
          title: '10. GOVERNING LAW',
          body:
              'These Terms are governed by the laws of Greece and the European Union. '
              'Any disputes shall be subject to the exclusive jurisdiction of the competent courts of Greece.',
        ),

        _Section(
          title: '11. CONTACT',
          body:
              'Questions about these Terms?\n\n'
              'Tasos Misailidis\n'
              'Email: tasos@flexpro.app',
        ),
      ],
    );
  }
}
