import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/auth_service.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../trip_setup/presentation/providers/trip_provider.dart';

/// Controller that syncs session data when user logs in/out.
/// - On login: loads latest trip + categories from Firestore
/// - If cloud is empty but local has data: pushes local to cloud
class SessionSyncController extends StateNotifier<SessionSyncState> {
  final Ref _ref;
  String? _loadedUid;

  SessionSyncController(this._ref) : super(const SessionSyncState.initial()) {
    // Listen to auth state changes
    _ref.listen<AsyncValue<User?>>(authStateProvider, (previous, next) {
      final prevUser = previous?.valueOrNull;
      final user = next.valueOrNull;

      // User changed (logged in as different user or switched accounts)
      if (user != null && _loadedUid != user.uid) {
        // Clear local data first if switching users
        if (_loadedUid != null && _loadedUid != user.uid) {
          _clearLocalData();
        }
        loadLatestSession(user.uid);
      } else if (user == null && prevUser != null) {
        // User logged out - clear local data
        _clearLocalData();
        _loadedUid = null;
        state = const SessionSyncState.initial();
      }
    });
  }

  /// Clears all local trip and packing data
  void _clearLocalData() {
    _ref.read(currentTripProvider.notifier).clear();
    _ref.read(packingListProvider.notifier).clear();
    _ref.read(selectedTripTypeProvider.notifier).state = null;
  }

  /// Loads the latest trip and categories from Firestore
  Future<void> loadLatestSession(String uid) async {
    if (_loadedUid == uid) return; // Already loaded for this user

    state = const SessionSyncState.loading();

    try {
      final firestoreService = _ref.read(firestoreServiceProvider);

      // Try to load latest trip from cloud
      final remoteTrip = await firestoreService.getLatestTrip(uid);

      if (remoteTrip != null) {
        // Load categories for this trip
        final categories = await firestoreService.getCategoriesOnce(uid, remoteTrip.id);

        // Set providers with remote data (fromRemote = true prevents re-saving)
        _ref.read(currentTripProvider.notifier).setTrip(remoteTrip, fromRemote: true);
        _ref.read(packingListProvider.notifier).setCategories(categories, fromRemote: true);
        _ref.read(selectedTripTypeProvider.notifier).state = remoteTrip.type;

        _loadedUid = uid;
        state = SessionSyncState.loaded(tripId: remoteTrip.id);
      } else {
        // Cloud is empty, check if we have local data to push
        final localTrip = _ref.read(currentTripProvider);
        final localCategories = _ref.read(packingListProvider);

        if (localTrip != null && localCategories.isNotEmpty) {
          // Push local data to cloud
          await firestoreService.saveTrip(uid, localTrip);
          await firestoreService.saveCategories(uid, localTrip.id, localCategories);

          _loadedUid = uid;
          state = SessionSyncState.loaded(tripId: localTrip.id, pushedToCloud: true);
        } else {
          // No data anywhere, just mark as loaded
          _loadedUid = uid;
          state = const SessionSyncState.empty();
        }
      }
    } catch (e) {
      state = SessionSyncState.error(e.toString());
    }
  }

  /// Saves the current trip and categories to Firestore
  Future<void> saveCurrentSession() async {
    final user = _ref.read(currentUserProvider);
    if (user == null) return;

    final trip = _ref.read(currentTripProvider);
    final categories = _ref.read(packingListProvider);

    if (trip == null) return;

    try {
      final firestoreService = _ref.read(firestoreServiceProvider);
      await firestoreService.saveTrip(user.uid, trip);
      await firestoreService.saveCategories(user.uid, trip.id, categories);
    } catch (e) {
      // Handle error silently or log
    }
  }

  /// Saves a single item change to Firestore
  Future<void> syncItem(String categoryId, String itemId) async {
    final user = _ref.read(currentUserProvider);
    if (user == null) return;

    final trip = _ref.read(currentTripProvider);
    if (trip == null) return;

    final categories = _ref.read(packingListProvider);
    final category = categories.firstWhere(
      (c) => c.id == categoryId,
      orElse: () => throw Exception('Category not found'),
    );
    final item = category.items.firstWhere(
      (i) => i.id == itemId,
      orElse: () => throw Exception('Item not found'),
    );

    try {
      final firestoreService = _ref.read(firestoreServiceProvider);
      await firestoreService.updateItem(user.uid, trip.id, categoryId, item);
    } catch (e) {
      // Handle error silently or log
    }
  }
}

/// State for session sync
class SessionSyncState {
  final SessionSyncStatus status;
  final String? tripId;
  final bool pushedToCloud;
  final String? error;

  const SessionSyncState._({
    required this.status,
    this.tripId,
    this.pushedToCloud = false,
    this.error,
  });

  const SessionSyncState.initial()
      : this._(status: SessionSyncStatus.initial);

  const SessionSyncState.loading()
      : this._(status: SessionSyncStatus.loading);

  const SessionSyncState.loaded({String? tripId, bool pushedToCloud = false})
      : this._(
          status: SessionSyncStatus.loaded,
          tripId: tripId,
          pushedToCloud: pushedToCloud,
        );

  const SessionSyncState.empty()
      : this._(status: SessionSyncStatus.empty);

  SessionSyncState.error(String message)
      : this._(status: SessionSyncStatus.error, error: message);

  bool get isLoading => status == SessionSyncStatus.loading;
  bool get isLoaded => status == SessionSyncStatus.loaded;
  bool get isEmpty => status == SessionSyncStatus.empty;
  bool get hasError => status == SessionSyncStatus.error;
}

enum SessionSyncStatus {
  initial,
  loading,
  loaded,
  empty,
  error,
}

/// Provider for SessionSyncController
final sessionSyncControllerProvider =
    StateNotifierProvider<SessionSyncController, SessionSyncState>((ref) {
  return SessionSyncController(ref);
});

/// Provider that watches for local changes and syncs to Firestore.
/// This should be watched in the app to enable auto-sync.
final autoSyncProvider = Provider<void>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return;

  final trip = ref.watch(currentTripProvider);
  final categories = ref.watch(packingListProvider);

  // Check if the data came from remote - skip sync if so
  final tripNotifier = ref.read(currentTripProvider.notifier);
  final packingListNotifier = ref.read(packingListProvider.notifier);

  if (tripNotifier.isFromRemote || packingListNotifier.isFromRemote) {
    // Clear the flag and skip this sync
    tripNotifier.clearFromRemote();
    packingListNotifier.clearFromRemote();
    return;
  }

  if (trip == null) return;

  // Debounce by scheduling async save
  Future.microtask(() async {
    try {
      final firestoreService = ref.read(firestoreServiceProvider);
      await firestoreService.saveTrip(user.uid, trip);
      if (categories.isNotEmpty) {
        await firestoreService.saveCategories(user.uid, trip.id, categories);
      }
    } catch (e) {
      // Silently handle errors - could add logging here
    }
  });
});
