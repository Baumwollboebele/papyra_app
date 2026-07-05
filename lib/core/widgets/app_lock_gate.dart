import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/l10n_extension.dart';
import '../providers/settings_providers.dart';
import '../services/app_lock_service.dart';

/// Wraps the app and, when the app lock is enabled, requires biometric/passcode
/// authentication once on cold start.
///
/// It deliberately does NOT re-lock when the app returns from the background:
/// opening the camera scanner, file picker or share sheet briefly backgrounds
/// the app, and re-locking on every resume forced a fingerprint prompt after
/// each of those normal actions. A fresh unlock is only required on a real
/// cold start (a new process runs [initState] again).
class AppLockGate extends ConsumerStatefulWidget {
  const AppLockGate({required this.child, super.key});
  final Widget child;

  @override
  ConsumerState<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends ConsumerState<AppLockGate> {
  bool _unlocked = true;
  bool _authenticating = false;

  @override
  void initState() {
    super.initState();
    final enabled = ref.read(settingsControllerProvider).appLockEnabled;
    if (enabled) {
      _unlocked = false;
      WidgetsBinding.instance.addPostFrameCallback((_) => _authenticate());
    }
  }

  Future<void> _authenticate() async {
    if (_authenticating) return;
    setState(() => _authenticating = true);
    final ok = await ref
        .read(appLockServiceProvider)
        .authenticate(context.mounted ? context.l10n.lockReason : '');
    if (mounted) {
      setState(() {
        _authenticating = false;
        if (ok) _unlocked = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final enabled = ref.watch(
      settingsControllerProvider.select((s) => s.appLockEnabled),
    );
    if (!enabled || _unlocked) return widget.child;

    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        backgroundColor: scheme.surface,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock, size: 72, color: scheme.primary),
              const SizedBox(height: 24),
              Text(
                l10n.lockTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: _authenticating ? null : _authenticate,
                icon: const Icon(Icons.fingerprint),
                label: Text(l10n.lockUnlock),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
