import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/trip_provider.dart';
import '../widgets/trip_type_card.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';

class TripTypePage extends ConsumerWidget {
  const TripTypePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedType = ref.watch(selectedTripTypeProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Новая поездка'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.home),
        ),
        actions: [
          TextButton(
            onPressed: () => context.push(AppRoutes.templates),
            child: const Text('Шаблоны'),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'Куда собираемся?',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Выбери тип поездки для персонализации списка',
                style: TextStyle(
                  fontSize: 16,
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 32),

              // Trip type cards
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.1,
                  children: AppConstants.tripTypes.map((type) {
                    return TripTypeCard(
                      type: type,
                      name: AppConstants.tripTypeNames[type]!,
                      icon: AppConstants.tripTypeIcons[type]!,
                      color: _getTripTypeColor(type),
                      isSelected: selectedType == type,
                      onTap: () {
                        ref.read(selectedTripTypeProvider.notifier).state = type;
                        ref.read(currentTripProvider.notifier).startNewTrip(type);
                      },
                    );
                  }).toList(),
                ),
              ),

              // Next button
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: selectedType != null
                      ? () => context.push(AppRoutes.tripParams)
                      : null,
                  child: const Text('Продолжить'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
