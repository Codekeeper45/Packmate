import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../packing_list/presentation/widgets/category_section.dart';
import '../../../trip_setup/presentation/providers/trip_provider.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';

class PackingModePage extends ConsumerWidget {
  const PackingModePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(packingListProvider);
    final progress = ref.watch(packingProgressProvider);
    final isComplete = ref.watch(isPackingCompleteProvider);
    final trip = ref.watch(currentTripProvider);
    final theme = Theme.of(context);

    // Navigate to completion when done
    if (isComplete) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go(AppRoutes.completion);
      });
    }

    final totalItems = categories.fold<int>(0, (sum, cat) => sum + cat.totalItems);
    final packedItems = categories.fold<int>(0, (sum, cat) => sum + cat.packedItems);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Режим сборов'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _showExitDialog(context),
        ),
        actions: [
          if (packedItems > 0)
            TextButton(
              onPressed: () => context.go(AppRoutes.completion),
              child: const Text('Завершить'),
            ),
        ],
      ),
      body: Column(
        children: [
          // Progress header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.onSurface.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                // Progress circle
                Row(
                  children: [
                    // Progress indicator
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: Stack(
                        children: [
                          Center(
                            child: SizedBox(
                              width: 80,
                              height: 80,
                              child: CircularProgressIndicator(
                                value: progress / 100,
                                strokeWidth: 6,
                                backgroundColor: theme.colorScheme.onSurface.withOpacity(0.1),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  _getProgressColor(progress),
                                ),
                              ),
                            ),
                          ),
                          Center(
                            child: Text(
                              '${progress.toStringAsFixed(0)}%',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: _getProgressColor(progress),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    // Stats
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            trip?.destination ?? 'Сборы',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$packedItems из $totalItems вещей собрано',
                            style: TextStyle(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Linear progress
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progress / 100,
                              backgroundColor: theme.colorScheme.onSurface.withOpacity(0.1),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _getProgressColor(progress),
                              ),
                              minHeight: 8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Categories list
          Expanded(
            child: CustomScrollView(
              slivers: [
                // Instruction
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Отмечай вещи по мере сборов ✓',
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

                // Categories with checkboxes
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final category = categories[index];
                      return CategorySection(
                        category: category,
                        isExpanded: !category.isComplete,
                        showCheckboxes: true,
                        onToggleItem: (catId, itemId) {
                          ref.read(packingListProvider.notifier).toggleItemPacked(catId, itemId);
                        },
                      );
                    },
                    childCount: categories.length,
                  ),
                ),

                // Bottom padding
                const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
              ],
            ),
          ),
        ],
      ),
      // Quick complete FAB
      floatingActionButton: packedItems < totalItems
          ? FloatingActionButton.extended(
              onPressed: () => _showQuickCompleteDialog(context, ref, totalItems - packedItems),
              icon: const Icon(Icons.done_all),
              label: const Text('Собрать всё'),
              backgroundColor: AppColors.secondary,
            )
          : null,
    );
  }

  Color _getProgressColor(double progress) {
    if (progress >= 100) return AppColors.success;
    if (progress >= 70) return AppColors.secondary;
    if (progress >= 30) return AppColors.warning;
    return AppColors.primary;
  }

  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Выйти из режима сборов?'),
        content: const Text('Прогресс будет сохранён. Ты сможешь продолжить позже.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.go(AppRoutes.tripType);
            },
            child: const Text('Выйти'),
          ),
        ],
      ),
    );
  }

  void _showQuickCompleteDialog(BuildContext context, WidgetRef ref, int remaining) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Отметить всё как собранное?'),
        content: Text('Осталось $remaining вещей. Отметить их все?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              // Mark all as packed
              final categories = ref.read(packingListProvider);
              for (final category in categories) {
                for (final item in category.items) {
                  if (!item.isPacked) {
                    ref.read(packingListProvider.notifier).toggleItemPacked(category.id, item.id);
                  }
                }
              }
              Navigator.pop(context);
            },
            child: const Text('Отметить всё'),
          ),
        ],
      ),
    );
  }
}
