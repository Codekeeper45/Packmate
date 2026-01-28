import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../providers/trip_provider.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/weather_service.dart';

class TripParamsPage extends ConsumerStatefulWidget {
  const TripParamsPage({super.key});

  @override
  ConsumerState<TripParamsPage> createState() => _TripParamsPageState();
}

class _TripParamsPageState extends ConsumerState<TripParamsPage> {
  final _formKey = GlobalKey<FormState>();
  final _destinationController = TextEditingController();
  
  DateTime _startDate = DateTime.now().add(const Duration(days: 7));
  DateTime _endDate = DateTime.now().add(const Duration(days: 14));
  bool _isLoadingWeather = false;
  WeatherData? _weatherData;

  @override
  void initState() {
    super.initState();
    final trip = ref.read(currentTripProvider);
    if (trip != null) {
      _destinationController.text = trip.destination;
      _startDate = trip.startDate;
      _endDate = trip.endDate;
    }
  }

  @override
  void dispose() {
    _destinationController.dispose();
    super.dispose();
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      builder: (context, child) {
        final theme = Theme.of(context);
        return Theme(
          data: theme,
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      ref.read(currentTripProvider.notifier).updateDates(_startDate, _endDate);
    }
  }

  Future<void> _loadWeather() async {
    if (_destinationController.text.isEmpty) return;

    setState(() {
      _isLoadingWeather = true;
    });

    try {
      final weatherService = ref.read(weatherServiceProvider);
      final weather = await weatherService.getWeatherForecast(
        _destinationController.text,
        days: 7,
      );

      setState(() {
        _weatherData = weather;
        _isLoadingWeather = false;
      });

      if (weather != null) {
        ref.read(currentTripProvider.notifier).updateWeather(
          weather.summary,
          weather.tempRange,
        );
      }
    } catch (e) {
      setState(() {
        _isLoadingWeather = false;
      });
    }
  }

  void _proceed() {
    if (_formKey.currentState!.validate()) {
      ref.read(currentTripProvider.notifier).updateDestination(
        _destinationController.text,
      );
      context.push(AppRoutes.tripConditions);
    }
  }

  @override
  Widget build(BuildContext context) {
    final trip = ref.watch(currentTripProvider);
    final dateFormat = DateFormat('d MMM', 'ru');
    final durationDays = _endDate.difference(_startDate).inDays + 1;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Параметры поездки'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24.0),
            children: [
              // Trip type indicator
              if (trip != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Text(
                        _getTripTypeIcon(trip.type),
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _getTripTypeName(trip.type),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              
              const SizedBox(height: 24),

              // Destination
              const Text(
                'Куда едем?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _destinationController,
                decoration: InputDecoration(
                  hintText: 'Город или страна',
                  prefixIcon: const Icon(Icons.location_on_outlined),
                  suffixIcon: _isLoadingWeather
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : IconButton(
                          icon: const Icon(Icons.cloud_outlined),
                          onPressed: _loadWeather,
                          tooltip: 'Загрузить погоду',
                        ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Укажите место назначения';
                  }
                  return null;
                },
                onFieldSubmitted: (_) => _loadWeather(),
              ),

              // Weather info
              if (_weatherData != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.wb_sunny, color: theme.colorScheme.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_weatherData!.locationName}, ${_weatherData!.country}',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              '${_weatherData!.tempRange} • ${_weatherData!.condition}',
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
              ],

              const SizedBox(height: 24),

              // Dates
              const Text(
                'Даты поездки',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
                GestureDetector(
                  onTap: _selectDateRange,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.dividerColor),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 24),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${dateFormat.format(_startDate)} - ${dateFormat.format(_endDate)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$durationDays ${_getDaysWord(durationDays)}',
                              style: TextStyle(
                                color: theme.colorScheme.onSurface.withOpacity(0.6),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: theme.colorScheme.onSurface.withOpacity(0.4),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Continue button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _proceed,
                  child: const Text('Продолжить'),
                ),
              ),
            ],
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
      'other': '✈️',
    };
    return icons[type] ?? '✈️';
  }

  String _getTripTypeName(String type) {
    const names = {
      'hike': 'Поход',
      'beach': 'Пляж',
      'city': 'Город',
      'business': 'Командировка',
      'other': 'Другое',
    };
    return names[type] ?? 'Поездка';
  }

  String _getDaysWord(int days) {
    if (days % 10 == 1 && days % 100 != 11) {
      return 'день';
    } else if ([2, 3, 4].contains(days % 10) && ![12, 13, 14].contains(days % 100)) {
      return 'дня';
    } else {
      return 'дней';
    }
  }
}
