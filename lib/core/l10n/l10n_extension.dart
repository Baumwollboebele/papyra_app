import 'package:flutter/widgets.dart';

import '../../l10n/app_localizations.dart';

/// Convenience access to localized strings: `context.l10n.scanButton`.
extension L10nX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
