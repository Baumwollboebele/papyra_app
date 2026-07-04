import 'package:flutter/material.dart';

import '../../../core/l10n/l10n_extension.dart';
import '../../../core/widgets/onboarding_art.dart';

/// Plain-language German privacy statement ("Über & Datenschutz").
class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  /// Kept in sync with pubspec `version:`.
  static const appVersion = '1.0.0';

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.setAbout)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        children: [
          Center(
            child: OnboardingArt(
              icon: Icons.lock_outline,
              color: theme.colorScheme.primary,
              size: 160,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.privacyHeadline,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.privacyBody,
            style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
          ),
          const SizedBox(height: 32),
          Center(
            child: Text(
              '${l10n.appName} · ${l10n.privacyVersion(appVersion)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
