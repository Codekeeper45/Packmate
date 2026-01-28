import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/trip_provider.dart';
import '../widgets/condition_chip.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/constants/app_constants.dart';

class TripConditionsPage extends ConsumerStatefulWidget {
  const TripConditionsPage({super.key});

  @override
  ConsumerState<TripConditionsPage> createState() => _TripConditionsPageState();
}

class _TripConditionsPageState extends ConsumerState<TripConditionsPage> {
  String? _selectedAccommodation;
  final Set<String> _selectedActivities = {};

  final List<String> _accommodationTypes = [
    'tent',
    'hotel',
    'hostel',
    'apartment',
  ];

  final Map<String, List<String>> _activitiesByTripType = {
    'hike': ['Треккинг', 'Альпинизм', 'Кемпинг', 'Рыбалка', 'Фотография'],
    'beach': ['Плавание', 'Дайвинг', 'Серфинг', 'Снорклинг', 'Пляжный волейбол'],
    'city': ['Экскурсии', 'Шоппинг', 'Рестораны', 'Музеи', 'Ночная жизнь'],
    'business': ['Конференции', 'Переговоры', 'Нетворкинг', 'Презентации'],
    'other': ['Отдых', 'Спорт', 'Культура', 'Развлечения', 'Фотография'],
  };

  @override
  void initState() {
    super.initState();
    final trip = ref.read(currentTripProvider);
    if (trip != null) {
      _selectedAccommodation = trip.accommodation;
      _selectedActivities.addAll(trip.activities);
    }
  }

  void _proceed() {
    if (_selectedAccommodation != null) {
      ref.read(currentTripProvider.notifier).updateAccommodation(_selectedAccommodation!);
      ref.read(currentTripProvider.notifier).updateActivities(_selectedActivities.toList());
      context.push(AppRoutes.generatedList);
    }
  }

  @override
  Widget build(BuildContext context) {
    final trip = ref.watch(currentTripProvider);
    final activities = _activitiesByTripType[trip?.type ?? 'other'] ?? [];
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Уточнение'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            // Accommodation section
            const Text(
              'Где будешь жить?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'От этого зависит, какие вещи нужно брать',
              style: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            
            // Accommodation chips
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _accommodationTypes.map((type) {
                return ConditionChip(
                  label: AppConstants.accommodationNames[type]!,
                  icon: _getAccommodationIcon(type),
                  isSelected: _selectedAccommodation == type,
                  onTap: () {
                    setState(() {
                      _selectedAccommodation = type;
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 32),

            // Activities section
            const Text(
              'Планируемые активности',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Выбери, чем планируешь заниматься (необязательно)',
              style: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),

            // Activity chips
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: activities.map((activity) {
                final isSelected = _selectedActivities.contains(activity);
                return ConditionChip(
                  label: activity,
                  isSelected: isSelected,
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedActivities.remove(activity);
                      } else {
                        _selectedActivities.add(activity);
                      }
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 40),

            // Generate button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _selectedAccommodation != null ? _proceed : null,
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Сгенерировать список'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Skip activities hint
            if (_selectedActivities.isEmpty)
              Center(
                child: Text(
                  'Можно пропустить выбор активностей',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                    fontSize: 14,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getAccommodationIcon(String type) {
    switch (type) {
      case 'tent':
        return '⛺';
      case 'hotel':
        return '🏨';
      case 'hostel':
        return '🏠';
      case 'apartment':
        return '🏢';
      default:
        return '🏠';
    }
  }
}
