import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/app_database.dart';
import '../../../core/formatting/formatters.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/widgets/document_thumbnail.dart';
import '../../../core/widgets/highlighted_text.dart';

/// List row for a document: thumbnail, title, sender, then a meta line with
/// date, amount and (optionally) its sub-group — enough to find it at a glance.
/// When [highlightTerms] is provided, matching parts of the title are emphasized.
class DocumentListTile extends StatelessWidget {
  const DocumentListTile({
    required this.document,
    this.highlightTerms = const [],
    this.groupName,
    super.key,
  });

  final Document document;
  final List<String> highlightTerms;
  final String? groupName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final hasSender = document.sender != null && document.sender!.isNotEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        onTap: () => context.push(AppRoutes.document(document.id)),
        leading: DocumentThumbnail(
          documentId: document.id,
          thumbnailPath: document.thumbnailPath,
        ),
        title: HighlightedText(
          text: document.title,
          terms: highlightTerms,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasSender)
                Text(
                  document.sender!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(color: muted),
                ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 10,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (document.documentDate != null)
                    _MetaItem(
                      icon: Icons.event_outlined,
                      label: formatDate(document.documentDate!),
                    ),
                  if (document.amountCents != null)
                    Text(
                      formatAmount(
                        document.amountCents!,
                        currency: document.currency,
                      ),
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  if (groupName != null && groupName!.isNotEmpty)
                    _GroupTag(name: groupName!),
                ],
              ),
            ],
          ),
        ),
        trailing: document.isFavorite
            ? Icon(Icons.star, size: 20, color: theme.colorScheme.primary)
            : null,
      ),
    );
  }
}

class _MetaItem extends StatelessWidget {
  const _MetaItem({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: muted),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: muted),
        ),
      ],
    );
  }
}

class _GroupTag extends StatelessWidget {
  const _GroupTag({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.folder_outlined, size: 12, color: scheme.onSecondaryContainer),
          const SizedBox(width: 4),
          Text(
            name,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: scheme.onSecondaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
