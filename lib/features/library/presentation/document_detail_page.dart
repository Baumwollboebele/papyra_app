import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/default_categories.dart';
import '../../../core/database/repositories/document_repository.dart';
import '../../../core/formatting/formatters.dart';
import '../../../core/l10n/l10n_extension.dart';
import '../../../core/providers/database_providers.dart';
import '../../../core/services/file_service.dart';
import '../../../core/services/share_service.dart';
import '../../../core/widgets/skeletons.dart';
import 'document_edit_page.dart';

/// Full document view: swipeable pages, metadata, extracted text and actions.
class DocumentDetailPage extends ConsumerWidget {
  const DocumentDetailPage({required this.documentId, super.key});

  final int documentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final detailAsync = ref.watch(documentDetailProvider(documentId));

    return detailAsync.when(
      loading: () =>
          Scaffold(appBar: AppBar(), body: const SkeletonList(rows: 4)),
      error: (_, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(l10n.scanErrorTitle)),
      ),
      data: (detail) {
        if (detail == null) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: Text(l10n.scanErrorTitle)),
          );
        }
        return _DetailView(detail: detail);
      },
    );
  }
}

class _DetailView extends ConsumerStatefulWidget {
  const _DetailView({required this.detail});
  final DocumentDetail detail;

  @override
  ConsumerState<_DetailView> createState() => _DetailViewState();
}

class _DetailViewState extends ConsumerState<_DetailView> {
  int _page = 0;

  Document get _doc => widget.detail.document;

  Future<void> _toggleFavorite() async {
    await ref
        .read(documentRepositoryProvider)
        .setFavorite(_doc.id, !_doc.isFavorite);
    ref.invalidate(documentDetailProvider(_doc.id));
  }

  Future<void> _share() async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(shareServiceProvider)
          .sharePdf(_doc.pdfPath, name: '${_doc.title}.pdf');
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.shareError)));
    }
  }

  Future<void> _edit() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DocumentEditPage(detail: widget.detail),
      ),
    );
  }

  Future<void> _move() async {
    final categories = await ref.read(categoryRepositoryProvider).getAll();
    if (!mounted) return;
    final selected = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                context.l10n.moveTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final c in categories)
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Color(
                          c.colorValue,
                        ).withValues(alpha: 0.15),
                        foregroundColor: Color(c.colorValue),
                        child: Icon(categoryIcon(c.iconName)),
                      ),
                      title: Text(c.name),
                      trailing: c.id == _doc.categoryId
                          ? const Icon(Icons.check)
                          : null,
                      onTap: () => Navigator.of(context).pop(c.id),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    if (selected != null && selected != _doc.categoryId) {
      await ref
          .read(documentRepositoryProvider)
          .moveToCategory(_doc.id, selected);
      ref.invalidate(documentDetailProvider(_doc.id));
    }
  }

  Future<void> _delete() async {
    final l10n = context.l10n;
    final navigator = Navigator.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteConfirmTitle),
        content: Text(l10n.deleteConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.commonDelete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final files = await ref
        .read(documentRepositoryProvider)
        .deleteDocument(_doc.id);
    if (files != null) {
      await ref.read(fileServiceProvider).deleteAll(files.all);
    }
    if (navigator.canPop()) navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final detail = widget.detail;
    final pages = detail.pages;

    return Scaffold(
      appBar: AppBar(
        title: Text(_doc.title, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            tooltip: _doc.isFavorite
                ? l10n.actionUnfavorite
                : l10n.actionFavorite,
            icon: Icon(_doc.isFavorite ? Icons.star : Icons.star_outline),
            onPressed: _toggleFavorite,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'share':
                  _share();
                case 'edit':
                  _edit();
                case 'move':
                  _move();
                case 'delete':
                  _delete();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'share',
                child: _menu(Icons.ios_share, l10n.actionShare),
              ),
              PopupMenuItem(
                value: 'edit',
                child: _menu(Icons.edit_outlined, l10n.actionEdit),
              ),
              PopupMenuItem(
                value: 'move',
                child: _menu(Icons.drive_file_move_outlined, l10n.actionMove),
              ),
              PopupMenuItem(
                value: 'delete',
                child: _menu(Icons.delete_outline, l10n.actionDelete),
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          _PageViewer(
            documentId: _doc.id,
            pages: pages,
            currentPage: _page,
            onPageChanged: (i) => setState(() => _page = i),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MetadataCard(detail: detail),
                const SizedBox(height: 16),
                _ExtractedText(text: _doc.ocrText),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _menu(IconData icon, String label) => Row(
    children: [Icon(icon, size: 20), const SizedBox(width: 12), Text(label)],
  );
}

class _PageViewer extends StatelessWidget {
  const _PageViewer({
    required this.documentId,
    required this.pages,
    required this.currentPage,
    required this.onPageChanged,
  });

  final int documentId;
  final List<DocumentPage> pages;
  final int currentPage;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AspectRatio(
      aspectRatio: 3 / 4,
      child: Stack(
        children: [
          PageView.builder(
            itemCount: pages.length,
            onPageChanged: onPageChanged,
            itemBuilder: (context, i) {
              final image = Image.file(
                File(pages[i].imagePath),
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) =>
                    const Center(child: Icon(Icons.broken_image_outlined)),
              );
              return InteractiveViewer(
                maxScale: 4,
                child: i == 0
                    ? Hero(tag: 'doc-thumb-$documentId', child: image)
                    : image,
              );
            },
          ),
          if (pages.length > 1)
            Positioned(
              bottom: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: scheme.surface.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  context.l10n.detailPageIndicator(
                    currentPage + 1,
                    pages.length,
                  ),
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MetadataCard extends StatelessWidget {
  const _MetadataCard({required this.detail});
  final DocumentDetail detail;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final doc = detail.document;
    final categoryColor = Color(detail.category.colorValue);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.detailMetadata,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                Chip(
                  avatar: Icon(
                    categoryIcon(detail.category.iconName),
                    size: 18,
                    color: categoryColor,
                  ),
                  label: Text(detail.category.name),
                  backgroundColor: categoryColor.withValues(alpha: 0.12),
                  side: BorderSide.none,
                ),
                if (detail.group != null)
                  Chip(
                    avatar: Icon(
                      Icons.folder_outlined,
                      size: 18,
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
                    label: Text(detail.group!.name),
                    backgroundColor:
                        Theme.of(context).colorScheme.secondaryContainer,
                    side: BorderSide.none,
                  ),
              ],
            ),
            if (doc.sender != null && doc.sender!.isNotEmpty)
              _row(
                context,
                Icons.business_outlined,
                l10n.fieldSender,
                doc.sender!,
              ),
            if (doc.documentDate != null)
              _row(
                context,
                Icons.event_outlined,
                l10n.fieldDate,
                formatDate(doc.documentDate!),
              ),
            if (doc.amountCents != null)
              _row(
                context,
                Icons.euro_outlined,
                l10n.fieldAmount,
                formatAmount(doc.amountCents!, currency: doc.currency),
              ),
            if (detail.tags.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final tag in detail.tags)
                    Chip(
                      label: Text(tag.name),
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _row(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(value, style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExtractedText extends StatelessWidget {
  const _ExtractedText({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Card(
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            l10n.detailExtractedText,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: SelectableText(
                text.trim().isEmpty ? l10n.detailNoText : text,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
