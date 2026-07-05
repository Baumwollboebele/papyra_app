import 'package:flutter/material.dart';

/// Stable keys for the seeded default categories.
///
/// These keys are the contract between the pure-Dart classifier
/// (which emits a key) and the database (which stores a row per key).
/// Do not rename existing keys.
abstract final class CategoryKeys {
  const CategoryKeys._();

  static const rechnungen = 'rechnungen';
  static const lohnGehalt = 'lohn_gehalt';
  static const steuern = 'steuern';
  static const vertraege = 'vertraege';
  static const versicherungen = 'versicherungen';
  static const bank = 'bank';
  static const gesundheit = 'gesundheit';
  static const behoerden = 'behoerden';

  /// Fallback category for low-confidence classification.
  static const sonstiges = 'sonstiges';
}

/// Immutable description of a seeded category (name is resolved via l10n at
/// display time using [key]; the [defaultName] here is the German seed value).
@immutable
class DefaultCategory {
  const DefaultCategory({
    required this.key,
    required this.defaultName,
    required this.iconName,
    required this.color,
    required this.sortOrder,
  });

  final String key;
  final String defaultName;

  /// Name from a stable icon set (see [categoryIcon]).
  final String iconName;
  final Color color;
  final int sortOrder;
}

/// The 9 default categories, in display order.
const List<DefaultCategory> kDefaultCategories = [
  DefaultCategory(
    key: CategoryKeys.rechnungen,
    defaultName: 'Rechnungen',
    iconName: 'receipt_long',
    color: Color(0xFF00695C),
    sortOrder: 0,
  ),
  DefaultCategory(
    key: CategoryKeys.lohnGehalt,
    defaultName: 'Lohn & Gehalt',
    iconName: 'payments',
    color: Color(0xFF2E7D32),
    sortOrder: 1,
  ),
  DefaultCategory(
    key: CategoryKeys.steuern,
    defaultName: 'Steuern & Finanzamt',
    iconName: 'account_balance',
    color: Color(0xFF1565C0),
    sortOrder: 2,
  ),
  DefaultCategory(
    key: CategoryKeys.vertraege,
    defaultName: 'Verträge',
    iconName: 'description',
    color: Color(0xFF6A1B9A),
    sortOrder: 3,
  ),
  DefaultCategory(
    key: CategoryKeys.versicherungen,
    defaultName: 'Versicherungen',
    iconName: 'shield',
    color: Color(0xFFAD1457),
    sortOrder: 4,
  ),
  DefaultCategory(
    key: CategoryKeys.bank,
    defaultName: 'Bank',
    iconName: 'account_balance_wallet',
    color: Color(0xFF00838F),
    sortOrder: 5,
  ),
  DefaultCategory(
    key: CategoryKeys.gesundheit,
    defaultName: 'Gesundheit',
    iconName: 'health_and_safety',
    color: Color(0xFFC62828),
    sortOrder: 6,
  ),
  DefaultCategory(
    key: CategoryKeys.behoerden,
    defaultName: 'Behörden',
    iconName: 'gavel',
    color: Color(0xFF4E342E),
    sortOrder: 7,
  ),
  DefaultCategory(
    key: CategoryKeys.sonstiges,
    defaultName: 'Sonstiges',
    iconName: 'folder',
    color: Color(0xFF546E7A),
    sortOrder: 8,
  ),
];

/// German document-type noun per category key, used by the title template
/// (`{docType}`). Custom/unknown categories fall back to "Dokument".
String categoryDocType(String key) {
  switch (key) {
    case CategoryKeys.rechnungen:
      return 'Rechnung';
    case CategoryKeys.lohnGehalt:
      return 'Abrechnung';
    case CategoryKeys.steuern:
      return 'Bescheid';
    case CategoryKeys.vertraege:
      return 'Vertrag';
    case CategoryKeys.versicherungen:
      return 'Versicherung';
    case CategoryKeys.bank:
      return 'Kontoauszug';
    case CategoryKeys.gesundheit:
      return 'Befund';
    case CategoryKeys.behoerden:
      return 'Bescheid';
    default:
      return 'Dokument';
  }
}

/// Maps a stored [iconName] to a Material icon. Unknown names fall back to a
/// generic folder so custom user categories always render.
IconData categoryIcon(String iconName) {
  switch (iconName) {
    case 'receipt_long':
      return Icons.receipt_long;
    case 'payments':
      return Icons.payments;
    case 'account_balance':
      return Icons.account_balance;
    case 'description':
      return Icons.description;
    case 'shield':
      return Icons.shield;
    case 'account_balance_wallet':
      return Icons.account_balance_wallet;
    case 'health_and_safety':
      return Icons.health_and_safety;
    case 'gavel':
      return Icons.gavel;
    case 'folder':
      return Icons.folder;
    case 'home':
      return Icons.home;
    case 'directions_car':
      return Icons.directions_car;
    case 'school':
      return Icons.school;
    case 'pets':
      return Icons.pets;
    case 'star':
      return Icons.star;
    default:
      return Icons.folder_outlined;
  }
}

/// Colors offered when the user creates/edits a custom category.
const List<Color> kSelectableColors = [
  Color(0xFF00695C),
  Color(0xFF2E7D32),
  Color(0xFF1565C0),
  Color(0xFF6A1B9A),
  Color(0xFFAD1457),
  Color(0xFF00838F),
  Color(0xFFC62828),
  Color(0xFF4E342E),
  Color(0xFF546E7A),
  Color(0xFFEF6C00),
  Color(0xFF283593),
  Color(0xFF00796B),
];

/// Icon names offered when the user creates/edits a custom category.
const List<String> kSelectableIconNames = [
  'receipt_long',
  'payments',
  'account_balance',
  'description',
  'shield',
  'account_balance_wallet',
  'health_and_safety',
  'gavel',
  'folder',
  'home',
  'directions_car',
  'school',
  'pets',
  'star',
];
