import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n_extension.dart';
import '../../../core/providers/settings_providers.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/services/app_lock_service.dart';
import '../../../core/widgets/onboarding_art.dart';

/// First-launch onboarding: 3 pages (what it does, privacy, optional app lock).
class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final _controller = PageController();
  int _index = 0;
  bool _busy = false;

  static const _pageCount = 3;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    if (_busy) return;
    setState(() => _busy = true);
    await ref.read(settingsControllerProvider.notifier).completeOnboarding();
    if (mounted) context.go(AppRoutes.library);
  }

  void _next() {
    if (_index < _pageCount - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    } else {
      _finish();
    }
  }

  Future<void> _enableAppLock() async {
    final l10n = context.l10n;
    final service = ref.read(appLockServiceProvider);
    final available = await service.isAvailable();
    if (!available) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.onbLockUnavailable)));
      }
      return;
    }
    final ok = await service.authenticate(l10n.lockReason);
    if (ok) {
      await ref
          .read(settingsControllerProvider.notifier)
          .setAppLockEnabled(true);
    }
    if (mounted) await _finish();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final appLockEnabled = ref.watch(settingsControllerProvider).appLockEnabled;

    final pages = [
      _OnboardingSlide(
        art: OnboardingArt(icon: Icons.document_scanner, color: scheme.primary),
        title: l10n.onbWelcomeTitle,
        body: l10n.onbWelcomeBody,
      ),
      _OnboardingSlide(
        art: OnboardingArt(icon: Icons.lock_outline, color: scheme.tertiary),
        title: l10n.onbPrivacyTitle,
        body: l10n.onbPrivacyBody,
      ),
      _OnboardingSlide(
        art: OnboardingArt(icon: Icons.fingerprint, color: scheme.secondary),
        title: l10n.onbLockTitle,
        body: l10n.onbLockBody,
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _busy ? null : _finish,
                child: Text(l10n.commonSkip),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pageCount,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) => pages[i],
              ),
            ),
            _Dots(count: _pageCount, index: _index),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: _index == _pageCount - 1
                  ? Column(
                      children: [
                        if (!appLockEnabled)
                          OutlinedButton.icon(
                            onPressed: _busy ? null : _enableAppLock,
                            icon: const Icon(Icons.fingerprint),
                            label: Text(l10n.onbEnableLock),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(52),
                            ),
                          ),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: _busy ? null : _finish,
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(52),
                          ),
                          child: Text(l10n.onbGetStarted),
                        ),
                      ],
                    )
                  : FilledButton(
                      onPressed: _next,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                      ),
                      child: Text(l10n.commonNext),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingSlide extends StatelessWidget {
  const _OnboardingSlide({
    required this.art,
    required this.title,
    required this.body,
  });

  final Widget art;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          art,
          const SizedBox(height: 40),
          Text(
            title,
            textAlign: TextAlign.center,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            body,
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.index});
  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: i == index ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: i == index
                  ? scheme.primary
                  : scheme.primary.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
      ],
    );
  }
}
