import 'dart:math';

final Random _random = Random();

/// A short, filesystem-safe unique id (timestamp + randomness). Good enough for
/// naming local files; not a security token.
String uniqueId() {
  final ts = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
  final rand = _random.nextInt(1 << 32).toRadixString(36);
  return '$ts$rand';
}
