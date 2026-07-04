/// Centralized route paths and names for go_router.
abstract final class AppRoutes {
  const AppRoutes._();

  static const onboarding = '/onboarding';

  static const library = '/';
  static const search = '/search';
  static const settings = '/settings';

  static const categoryName = 'category';
  static String category(int id) => '/category/$id';
  static const categoryPath = '/category/:id';

  static const documentName = 'document';
  static String document(int id) => '/document/$id';
  static const documentPath = '/document/:id';

  static const scan = '/scan';

  static const settingsCategories = '/settings/categories';
  static const settingsBackup = '/settings/backup';
  static const settingsPrivacy = '/settings/privacy';
}
