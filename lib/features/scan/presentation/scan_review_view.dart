import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_extension.dart';
import 'scan_controller.dart';

/// Review captured pages: reorder, delete, add more, then continue to OCR.
class ScanReviewView extends ConsumerWidget {
  const ScanReviewView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final controller = ref.read(scanControllerProvider.notifier);
    final pages = ref.watch(scanControllerProvider.select((s) => s.pages));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.scanReviewTitle),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(28),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              '${l10n.scanPagesLabel(pages.length)} · ${l10n.scanReorderHint}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ),
      ),
      body: pages.isEmpty
          ? Center(child: Text(l10n.scanEmpty))
          : ReorderableListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
              itemCount: pages.length,
              onReorderItem: controller.reorderPages,
              itemBuilder: (context, index) {
                final page = pages[index];
                return Card(
                  key: ValueKey(page.imagePath),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(page.imagePath),
                        width: 56,
                        height: 72,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const SizedBox(
                          width: 56,
                          height: 72,
                          child: Icon(Icons.broken_image_outlined),
                        ),
                      ),
                    ),
                    title: Text('${l10n.scanReviewTitle} ${index + 1}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: l10n.commonDelete,
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => controller.removePage(index),
                        ),
                        const Icon(Icons.drag_handle),
                      ],
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: controller.addPages,
                  icon: const Icon(Icons.add_a_photo_outlined),
                  label: Text(l10n.scanAddPage),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: pages.isEmpty ? null : controller.process,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                  child: Text(l10n.commonNext),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
