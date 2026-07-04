import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/default_categories.dart';
import '../../../core/database/repositories/category_repository.dart';
import '../../../core/l10n/l10n_extension.dart';
import '../../../core/providers/database_providers.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/widgets/document_thumbnail.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/skeletons.dart';

/// Home screen: category grid with counts + a "recently added" row.
class LibraryHomePage extends ConsumerWidget {
  const LibraryHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final categoriesAsync = ref.watch(categoriesWithCountsProvider);
    final recentAsync = ref.watch(recentDocumentsProvider);

    return Scaffold(
      body: categoriesAsync.when(
        loading: () => const SkeletonList(),
        error: (_, _) => Center(child: Text(l10n.scanErrorTitle)),
        data: (categories) {
          final total = categories.fold<int>(
            0,
            (sum, c) => sum + c.documentCount,
          );
          if (total == 0) {
            return CustomScrollView(
              slivers: [
                _appBar(context, l10n.appName),
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyState(
                    icon: Icons.folder_open,
                    title: l10n.libEmptyTitle,
                    message: l10n.libEmptyBody,
                  ),
                ),
              ],
            );
          }
          return CustomScrollView(
            slivers: [
              _appBar(context, l10n.appName),
              recentAsync.maybeWhen(
                data: (docs) => docs.isEmpty
                    ? const SliverToBoxAdapter(child: SizedBox.shrink())
                    : _RecentSection(documents: docs),
                orElse: () =>
                    const SliverToBoxAdapter(child: SizedBox.shrink()),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    l10n.libCategories,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 260,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.5,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => _CategoryCard(item: categories[i]),
                    childCount: categories.length,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _appBar(BuildContext context, String title) {
    return SliverAppBar.large(title: Text(title), pinned: true);
  }
}

class _RecentSection extends StatelessWidget {
  const _RecentSection({required this.documents});
  final List<Document> documents;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(
              l10n.libRecentlyAdded,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          SizedBox(
            height: 168,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: documents.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, i) => _RecentCard(document: documents[i]),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentCard extends StatelessWidget {
  const _RecentCard({required this.document});
  final Document document;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => context.push(AppRoutes.document(document.id)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DocumentThumbnail(
              documentId: document.id,
              thumbnailPath: document.thumbnailPath,
              width: 120,
              height: 130,
            ),
            const SizedBox(height: 6),
            Text(
              document.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.item});
  final CategoryWithCount item;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final color = Color(item.category.colorValue);
    return Card(
      child: InkWell(
        onTap: () => context.pushNamed(
          AppRoutes.categoryName,
          pathParameters: {'id': '${item.category.id}'},
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.15),
                foregroundColor: color,
                child: Icon(categoryIcon(item.category.iconName)),
              ),
              const Spacer(),
              Text(
                item.category.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              Text(
                l10n.documentsCount(item.documentCount),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
