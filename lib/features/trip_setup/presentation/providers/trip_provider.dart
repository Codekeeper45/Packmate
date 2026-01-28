import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/trip.dart';
import '../../../packing_list/domain/entities/category.dart';
import '../../../packing_list/domain/entities/packing_item.dart';

// Current trip state
final currentTripProvider = StateNotifierProvider<TripNotifier, Trip?>((ref) {
  return TripNotifier();
});

class TripNotifier extends StateNotifier<Trip?> {
  TripNotifier() : super(null);

  final _uuid = const Uuid();

  void startNewTrip(String type) {
    state = Trip(
      id: _uuid.v4(),
      type: type,
      destination: '',
      startDate: DateTime.now().add(const Duration(days: 7)),
      endDate: DateTime.now().add(const Duration(days: 14)),
      durationDays: 7,
      accommodation: 'hotel',
      activities: [],
      createdAt: DateTime.now(),
      status: 'draft',
    );
  }

  /// Set trip from external source.
  /// If [fromRemote] is true, skip any sync callbacks to prevent loops.
  void setTrip(Trip trip, {bool fromRemote = false}) {
    state = trip;
    _fromRemote = fromRemote;
  }

  bool _fromRemote = false;
  bool get isFromRemote => _fromRemote;

  /// Reset the fromRemote flag after sync operations
  void clearFromRemote() {
    _fromRemote = false;
  }

  void updateDestination(String destination) {
    if (state != null) {
      state = state!.copyWith(destination: destination);
    }
  }

  void updateDates(DateTime start, DateTime end) {
    if (state != null) {
      final duration = end.difference(start).inDays + 1;
      state = state!.copyWith(
        startDate: start,
        endDate: end,
        durationDays: duration,
      );
    }
  }

  void updateAccommodation(String accommodation) {
    if (state != null) {
      state = state!.copyWith(accommodation: accommodation);
    }
  }

  void updateActivities(List<String> activities) {
    if (state != null) {
      state = state!.copyWith(activities: activities);
    }
  }

  void updateWeather(String conditions, String temp) {
    if (state != null) {
      state = state!.copyWith(
        weatherConditions: conditions,
        weatherTemp: temp,
      );
    }
  }

  void updateStatus(String status) {
    if (state != null) {
      state = state!.copyWith(status: status);
    }
  }

  void clear() {
    state = null;
  }
}

// Trip type selection
final selectedTripTypeProvider = StateProvider<String?>((ref) => null);

// Packing list for current trip
final packingListProvider = StateNotifierProvider<PackingListNotifier, List<Category>>((ref) {
  return PackingListNotifier();
});

class PackingListNotifier extends StateNotifier<List<Category>> {
  PackingListNotifier() : super([]);

  final _uuid = const Uuid();
  bool _fromRemote = false;
  bool get isFromRemote => _fromRemote;

  /// Reset the fromRemote flag after sync operations
  void clearFromRemote() {
    _fromRemote = false;
  }

  /// Set categories from external source.
  /// If [fromRemote] is true, skip any sync callbacks to prevent loops.
  void setCategories(List<Category> categories, {bool fromRemote = false}) {
    state = categories;
    _fromRemote = fromRemote;
  }

  void addItem(String categoryId, String name, {int quantity = 1, bool isEssential = false, String? note}) {
    state = state.map((category) {
      if (category.id == categoryId) {
        final newItem = PackingItem(
          id: _uuid.v4(),
          tripId: category.tripId,
          categoryId: categoryId,
          name: name,
          quantity: quantity,
          isPacked: false,
          isEssential: isEssential,
          note: note,
          sortOrder: category.items.length,
          createdAt: DateTime.now(),
        );
        return category.copyWith(
          items: [...category.items, newItem],
          totalItems: category.totalItems + 1,
        );
      }
      return category;
    }).toList();
  }

  void removeItem(String categoryId, String itemId) {
    state = state.map((category) {
      if (category.id == categoryId) {
        final item = category.items.firstWhere((i) => i.id == itemId);
        return category.copyWith(
          items: category.items.where((i) => i.id != itemId).toList(),
          totalItems: category.totalItems - 1,
          packedItems: item.isPacked ? category.packedItems - 1 : category.packedItems,
        );
      }
      return category;
    }).toList();
  }

  void updateItemQuantity(String categoryId, String itemId, int quantity) {
    state = state.map((category) {
      if (category.id == categoryId) {
        return category.copyWith(
          items: category.items.map((item) {
            if (item.id == itemId) {
              return item.copyWith(quantity: quantity);
            }
            return item;
          }).toList(),
        );
      }
      return category;
    }).toList();
  }

  void toggleItemPacked(String categoryId, String itemId) {
    state = state.map((category) {
      if (category.id == categoryId) {
        int packedDelta = 0;
        final updatedItems = category.items.map((item) {
          if (item.id == itemId) {
            packedDelta = item.isPacked ? -1 : 1;
            return item.copyWith(
              isPacked: !item.isPacked,
              packedAt: !item.isPacked ? DateTime.now() : null,
            );
          }
          return item;
        }).toList();
        return category.copyWith(
          items: updatedItems,
          packedItems: category.packedItems + packedDelta,
        );
      }
      return category;
    }).toList();
  }

  void reorderItems(String categoryId, int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    state = state.map((category) {
      if (category.id == categoryId) {
        final items = [...category.items];
        if (oldIndex < 0 || oldIndex >= items.length) return category;
        if (newIndex < 0 || newIndex >= items.length) return category;

        final movedItem = items.removeAt(oldIndex);
        items.insert(newIndex, movedItem);

        final updatedItems = items
            .asMap()
            .entries
            .map((entry) => entry.value.copyWith(sortOrder: entry.key))
            .toList();

        return category.copyWith(items: updatedItems);
      }
      return category;
    }).toList();
  }

  void clear() {
    state = [];
  }

  /// Add a new category
  void addCategory({
    required String tripId,
    required String name,
    required String icon,
    String colorHex = '#6366F1',
  }) {
    final newCategory = Category(
      id: _uuid.v4(),
      tripId: tripId,
      name: name,
      icon: icon,
      sortOrder: state.length,
      colorHex: colorHex,
      items: [],
      totalItems: 0,
      packedItems: 0,
    );
    state = [...state, newCategory];
  }

  /// Remove a category
  void removeCategory(String categoryId) {
    state = state.where((c) => c.id != categoryId).toList();
  }
}

// Progress calculation
final packingProgressProvider = Provider<double>((ref) {
  final categories = ref.watch(packingListProvider);
  if (categories.isEmpty) return 0.0;
  
  int totalItems = 0;
  int packedItems = 0;
  
  for (final category in categories) {
    totalItems += category.totalItems;
    packedItems += category.packedItems;
  }
  
  if (totalItems == 0) return 0.0;
  return (packedItems / totalItems) * 100;
});

// Is packing complete
final isPackingCompleteProvider = Provider<bool>((ref) {
  final progress = ref.watch(packingProgressProvider);
  return progress >= 100.0;
});
