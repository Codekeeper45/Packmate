import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/category.dart';
import '../../domain/entities/packing_item.dart';
import 'package:uuid/uuid.dart';

final packingListGenerationStateProvider = StateProvider<PackingListGenerationState>((ref) {
  return PackingListGenerationState.initial;
});

enum PackingListGenerationState {
  initial,
  loading,
  success,
  error,
}
