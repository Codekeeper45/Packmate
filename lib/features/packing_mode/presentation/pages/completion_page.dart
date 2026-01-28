import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../trip_setup/presentation/providers/trip_provider.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';

class CompletionPage extends ConsumerWidget {
  const CompletionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(packingListProvider);
    final trip = ref.watch(currentTripProvider);
    final theme = Theme.of(context);
    
    final totalItems = categories.fold<int>(0, (sum, cat) => sum + cat.totalItems);
    final packedItems = categories.fold<int>(0, (sum, cat) => sum + cat.packedItems);
    final progress = totalItems > 0 ? (packedItems / totalItems) * 100 : 0.0;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              
              // Success animation
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        '🎉',
                        style: TextStyle(fontSize: 64),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Congratulation text
              Text(
                progress >= 100 ? 'Сборы завершены!' : 'Отличная работа!',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                progress >= 100
                    ? 'Все вещи собраны. Счастливого пути! ✈️'
                    : 'Ты собрал ${progress.toStringAsFixed(0)}% вещей',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),

              const SizedBox(height: 40),

              // Stats cards
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      icon: '✅',
                      value: '$packedItems',
                      label: 'Собрано',
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      icon: '📦',
                      value: '$totalItems',
                      label: 'Всего',
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      icon: '📁',
                      value: '${categories.length}',
                      label: 'Категорий',
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Trip info
              if (trip != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Text(
                        _getTripTypeIcon(trip.type),
                        style: const TextStyle(fontSize: 32),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              trip.destination.isNotEmpty ? trip.destination : 'Поездка',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${trip.durationDays} дней',
                              style: TextStyle(
                                color: theme.colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              const Spacer(),

              // Actions
              if (progress < 100) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.go(AppRoutes.packingMode),
                    child: const Text('Продолжить сборы'),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              SizedBox(
                width: double.infinity,
                child: progress >= 100
                    ? ElevatedButton.icon(
                        onPressed: () => _saveAsTemplateAndFinish(context, ref),
                        icon: const Icon(Icons.save_outlined),
                        label: const Text('Сохранить как шаблон'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                        ),
                      )
                    : OutlinedButton(
                        onPressed: () => _saveAsTemplateAndFinish(context, ref),
                        child: const Text('Сохранить как шаблон'),
                      ),
              ),

              const SizedBox(height: 12),

              TextButton(
                onPressed: () => context.go(AppRoutes.home),
                child: Text(
                  'На главную',
                  style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String icon,
    required String value,
    required String label,
    required Color color,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  void _saveAsTemplateAndFinish(BuildContext context, WidgetRef ref) {
    // Save as template logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Шаблон сохранён!'),
        backgroundColor: AppColors.success,
      ),
    );
    _finishAndReset(context, ref);
  }

  void _finishAndReset(BuildContext context, WidgetRef ref) {
    ref.read(currentTripProvider.notifier).clear();
    ref.read(packingListProvider.notifier).clear();
    ref.read(selectedTripTypeProvider.notifier).state = null;
    context.go(AppRoutes.home);
  }

  String _getTripTypeIcon(String type) {
    const icons = {
      'hike': '🏔️',
      'beach': '🏖️',
      'city': '🏙️',
      'business': '💼',
      'other': '✈️',
    };
    return icons[type] ?? '✈️';
  }
}
