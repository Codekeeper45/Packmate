import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/category.dart';
import '../providers/packing_list_provider.dart';
import '../widgets/category_section.dart';
import '../../../trip_setup/presentation/providers/trip_provider.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/ai_service.dart';

class GeneratedListPage extends ConsumerStatefulWidget {
  const GeneratedListPage({super.key});

  @override
  ConsumerState<GeneratedListPage> createState() => _GeneratedListPageState();
}

class _GeneratedListPageState extends ConsumerState<GeneratedListPage> {
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _generateList();
  }

  Future<void> _generateList() async {
    final trip = ref.read(currentTripProvider);
    if (trip == null) {
      setState(() {
        _error = 'Нет данных о поездке';
        _isLoading = false;
      });
      return;
    }

    try {
      final aiService = ref.read(aiServiceProvider);
      final categories = await aiService.generatePackingList(
        tripId: trip.id,
        tripType: trip.type,
        destination: trip.destination,
        durationDays: trip.durationDays,
        accommodation: trip.accommodation,
        activities: trip.activities,
        weatherConditions: trip.weatherConditions,
        weatherTemp: trip.weatherTemp,
      );

      ref.read(packingListProvider.notifier).setCategories(categories);
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Ошибка генерации: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(packingListProvider);
    final trip = ref.watch(currentTripProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Твой список'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push(AppRoutes.editList),
            tooltip: 'Редактировать',
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingState()
          : _error != null
              ? _buildErrorState()
              : _buildListContent(categories, trip),
      bottomNavigationBar: !_isLoading && _error == null
          ? _buildBottomBar(categories)
          : null,
    );
  }

  Widget _buildLoadingState() {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 80,
            height: 80,
            child: CircularProgressIndicator(
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Генерируем список...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Учитываем тип поездки, погоду и активности',
            style: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _error = null;
                });
                _generateList();
              },
              child: const Text('Попробовать снова'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListContent(List<Category> categories, trip) {
    final totalItems = categories.fold<int>(0, (sum, cat) => sum + cat.totalItems);
    final theme = Theme.of(context);

    return CustomScrollView(
      slivers: [
        // Trip summary
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      _getTripTypeIcon(trip?.type ?? 'other'),
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trip?.destination ?? 'Поездка',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '$totalItems вещей в ${categories.length} категориях',
                        style: TextStyle(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Categories
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final category = categories[index];
              return CategorySection(
                category: category,
                isExpanded: true,
                showCheckboxes: false,
              );
            },
            childCount: categories.length,
          ),
        ),

        // Bottom padding
        const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
      ],
    );
  }

  Widget _buildBottomBar(List<Category> categories) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.onSurface.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => context.push(AppRoutes.editList),
                child: const Text('Редактировать'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () => context.push(AppRoutes.saveList),
                child: const Text('Сохранить'),
              ),
            ),
          ],
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
      'other': '✈️',
    };
    return icons[type] ?? '✈️';
  }
}
