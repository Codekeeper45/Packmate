import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../packing_list/domain/entities/category.dart';
import '../../../trip_setup/presentation/providers/trip_provider.dart';
import '../../../trip_setup/domain/entities/trip.dart';

class TemplatesPage extends ConsumerWidget {
  const TemplatesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(currentUserProvider);
    final firestoreService = ref.watch(firestoreServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои шаблоны'),
        automaticallyImplyLeading: false,
      ),
      body: user == null
          ? _buildAuthRequiredState(theme)
          : StreamBuilder<List<Map<String, dynamic>>>(
              stream: firestoreService.getTemplates(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return _buildErrorState(theme, snapshot.error.toString());
                }

                final templates = _parseTemplates(snapshot.data ?? []);
                if (templates.isEmpty) {
                  return _buildEmptyState(theme);
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: templates.length,
                  itemBuilder: (context, index) {
                    final template = templates[index];
                    return _buildTemplateCard(context, ref, template);
                  },
                );
              },
            ),
    );
  }

  List<_TemplateEntry> _parseTemplates(List<Map<String, dynamic>> docs) {
    final templates = <_TemplateEntry>[];

    for (final doc in docs) {
      final tripJson = doc['trip'];
      if (tripJson is! Map<String, dynamic>) {
        continue;
      }

      try {
        final trip = Trip.fromJson(Map<String, dynamic>.from(tripJson));
        final categoriesRaw = doc['categories'];
        final categories = <Category>[];

        if (categoriesRaw is List) {
          for (final categoryRaw in categoriesRaw) {
            if (categoryRaw is Map<String, dynamic>) {
              categories.add(Category.fromJson(Map<String, dynamic>.from(categoryRaw)));
            }
          }
        }

        templates.add(_TemplateEntry(trip: trip, categories: categories));
      } catch (_) {
        continue;
      }
    }

    return templates;
  }

  Widget _buildAuthRequiredState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lock_outline,
            size: 80,
            color: theme.colorScheme.onSurface.withOpacity(0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'Войдите в аккаунт',
            style: TextStyle(
              fontSize: 18,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Чтобы видеть шаблоны из облака',
            style: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_outlined,
            size: 80,
            color: theme.colorScheme.onSurface.withOpacity(0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'Нет сохранённых шаблонов',
            style: TextStyle(
              fontSize: 18,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Создай список и сохрани его как шаблон',
            style: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 72,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 12),
            Text(
              'Не удалось загрузить данные',
              style: TextStyle(
                fontSize: 18,
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.65),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateCard(BuildContext context, WidgetRef ref, _TemplateEntry template) {
    final theme = Theme.of(context);
    final trip = template.trip;
    final startDate = '${trip.startDate.day.toString().padLeft(2, '0')}.${trip.startDate.month.toString().padLeft(2, '0')}';
    final endDate = '${trip.endDate.day.toString().padLeft(2, '0')}.${trip.endDate.month.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.onSurface.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            ref.read(currentTripProvider.notifier).setTrip(trip, fromRemote: true);
            ref.read(packingListProvider.notifier).setCategories(template.categories, fromRemote: true);
            ref.read(selectedTripTypeProvider.notifier).state = trip.type;

            context.go(AppRoutes.generatedList);
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: _getTripTypeColor(trip.type).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      _getTripTypeIcon(trip.type),
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trip.destination.isEmpty ? 'Без названия' : trip.destination,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$startDate - $endDate • ${trip.durationDays} дн.',
                        style: TextStyle(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Arrow
                Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onSurface.withOpacity(0.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getTripTypeIcon(String type) {
    const icons = {
      'hike': '🏔️',
      'beach': '🏖️',
      'city': '🏙️',
      'business': '💼',
      'adventure': '🧭',
      'other': '✈️',
    };
    return icons[type] ?? '✈️';
  }

  Color _getTripTypeColor(String type) {
    switch (type) {
      case 'hike':
        return AppColors.tripHike;
      case 'beach':
        return AppColors.tripBeach;
      case 'city':
        return AppColors.tripCity;
      case 'business':
        return AppColors.tripBusiness;
      default:
        return AppColors.tripOther;
    }
  }
}

class _TemplateEntry {
  final Trip trip;
  final List<Category> categories;

  const _TemplateEntry({
    required this.trip,
    required this.categories,
  });
}
