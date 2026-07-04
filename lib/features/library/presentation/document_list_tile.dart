import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/app_database.dart';
import '../../../core/formatting/formatters.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/widgets/document_thumbnail.dart';
import '../../../core/widgets/highlighted_text.dart';

/// List row for a document: thumbnail, title, sender/date/amount, favorite mark.
/// When [highlightTerms] is provided, matching parts of the title are emphasized.
class DocumentListTile extends StatelessWidget {
  const DocumentListTile({
    required this.document,
    this.highlightTerms = const [],
    super.key,
  });

  final Document document;
  final List<String> highlightTerms;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitleParts = <String>[
      if (document.sender != null && document.sender!.isNotEmpty)
        document.sender!,
      if (document.documentDate != null) formatDate(document.documentDate!),
    ];

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
        subtitle: subtitleParts.isEmpty
            ? null
            : Text(
                subtitleParts.join(' · '),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (document.isFavorite)
              Icon(Icons.star, size: 18, color: theme.colorScheme.primary),
            if (document.amountCents != null)
              Text(
                formatAmount(
                  document.amountCents!,
                  currency: document.currency,
                ),
                style: theme.textTheme.labelLarge,
              ),
          ],
        ),
      ),
    );
  }
}
