import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/scan/domain/classification/document_classifier.dart';
import '../../features/scan/domain/classification/metadata_extractor.dart';
import '../../features/scan/domain/classification/rule_based_classifier.dart';

/// The active classifier. Phase 2 can override this with an LLM-backed
/// implementation without touching the pipeline (see ARCHITECTURE.md).
final documentClassifierProvider = Provider<DocumentClassifier>(
  (ref) => RuleBasedClassifier(),
);

final metadataExtractorProvider = Provider<MetadataExtractor>(
  (ref) => const MetadataExtractor(),
);
