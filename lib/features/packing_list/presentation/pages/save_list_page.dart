import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/auth_service.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../trip_setup/presentation/providers/trip_provider.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';

class SaveListPage extends ConsumerStatefulWidget {
  const SaveListPage({super.key});

  @override
  ConsumerState<SaveListPage> createState() => _SaveListPageState();
}

class _SaveListPageState extends ConsumerState<SaveListPage> {
  final _nameController = TextEditingController();
  bool _saveAsTemplate = false;

  @override
  void initState() {
    super.initState();
    final trip = ref.read(currentTripProvider);
    if (trip != null) {
      _nameController.text = trip.destination.isNotEmpty
          ? trip.destination
          : 'Моя поездка';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveAndProceed() async {
    final user = ref.read(currentUserProvider);
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Войдите в аккаунт для сохранения.')),
      );
      return;
    }

    final trip = ref.read(currentTripProvider);
    if (trip == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось найти данные поездки.')),
      );
      return;
    }

    final categories = ref.read(packingListProvider);
    final firestoreService = ref.read(firestoreServiceProvider);

    try {
      await firestoreService.saveTrip(user.uid, trip);
      if (categories.isNotEmpty) {
        await firestoreService.saveCategories(user.uid, trip.id, categories);
      }

      if (_saveAsTemplate) {
        await firestoreService.saveTemplate(user.uid, trip, categories);
      }

      ref.read(currentTripProvider.notifier).updateStatus('packing');

      if (!mounted) return;
      context.go(AppRoutes.packingMode);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка сохранения. Проверьте сеть и попробуйте снова.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final trip = ref.watch(currentTripProvider);
    final categories = ref.watch(packingListProvider);
    final totalItems = categories.fold<int>(0, (sum, cat) => sum + cat.totalItems);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Сохранение'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Summary card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primaryLight,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            _getTripTypeIcon(trip?.type ?? 'other'),
                            style: const TextStyle(fontSize: 28),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Список готов!',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '$totalItems вещей в ${categories.length} категориях',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Stats row
                  Row(
                    children: [
                      _buildStatItem(
                        Icons.location_on,
                        trip?.destination ?? 'Неизвестно',
                      ),
                      const SizedBox(width: 16),
                      _buildStatItem(
                        Icons.calendar_today,
                        '${trip?.durationDays ?? 0} дней',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Name field
            const Text(
              'Название списка',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: 'Например: Отпуск в Турции',
              ),
            ),

            const SizedBox(height: 24),

            // Save as template
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.dividerColor),
              ),
              child: SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                title: const Text(
                  'Сохранить как шаблон',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  'Используй этот список для будущих поездок',
                  style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6)),
                ),
                value: _saveAsTemplate,
                onChanged: (value) {
                  setState(() {
                    _saveAsTemplate = value;
                  });
                },
              ),
            ),

            const SizedBox(height: 40),

            // Buttons
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saveAndProceed,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Начать сборы'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                ),
              ),
            ),

            const SizedBox(height: 12),

            Center(
              child: TextButton(
                onPressed: () => context.go(AppRoutes.tripType),
                child: Text(
                  'Отменить и начать заново',
                  style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.white.withOpacity(0.8),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 14,
          ),
        ),
      ],
    );
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
