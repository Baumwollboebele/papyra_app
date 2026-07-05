import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/library/presentation/category_page.dart';
import '../../features/library/presentation/document_detail_page.dart';
import '../../features/due/presentation/due_page.dart';
import '../../features/library/presentation/library_home_page.dart';
import '../../features/onboarding/presentation/onboarding_page.dart';
import '../../features/scan/presentation/ingest_flow_page.dart';
import '../../features/scan/presentation/scan_flow_page.dart';
import '../../features/search/presentation/search_page.dart';
import '../../features/settings/presentation/settings_page.dart';
import '../l10n/l10n_extension.dart';
import '../providers/settings_providers.dart';
import 'app_routes.dart';
import 'app_shell.dart';

/// Root navigator key, used for full-screen routes pushed above the shell.
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.library,
    redirect: (context, state) {
      final completed = ref
          .read(settingsControllerProvider)
          .onboardingCompleted;
      final atOnboarding = state.matchedLocation == AppRoutes.onboarding;
      if (!completed && !atOnboarding) return AppRoutes.onboarding;
      if (completed && atOnboarding) return AppRoutes.library;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.onboarding,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const OnboardingPage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            navigatorKey: _shellNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.library,
                builder: (context, state) => const LibraryHomePage(),
                routes: [
                  GoRoute(
                    path: 'category/:id',
                    name: AppRoutes.categoryName,
                    builder: (context, state) => CategoryPage(
                      categoryId: int.parse(state.pathParameters['id']!),
                    ),
                  ),
                  GoRoute(
                    path: 'document/:id',
                    name: AppRoutes.documentName,
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) => DocumentDetailPage(
                      documentId: int.parse(state.pathParameters['id']!),
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.due,
                builder: (context, state) => const DuePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.search,
                builder: (context, state) => const SearchPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.settings,
                builder: (context, state) => const SettingsPage(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.scan,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ScanFlowPage(),
      ),
      GoRoute(
        path: AppRoutes.ingest,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) =>
            IngestFlowPage(request: state.extra! as IngestRequest),
      ),
    ],
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text(context.l10n.commonRetry))),
  );
});
