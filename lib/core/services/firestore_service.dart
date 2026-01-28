import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/packing_list/domain/entities/category.dart';
import '../../features/packing_list/domain/entities/packing_item.dart';
import '../../features/trip_setup/domain/entities/trip.dart';
import 'auth_service.dart';

/// Firestore Database Service for syncing data across devices
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  CollectionReference get _usersCollection => _firestore.collection('users');
  
  DocumentReference _userDoc(String uid) => _usersCollection.doc(uid);
  
  CollectionReference _tripsCollection(String uid) => 
      _userDoc(uid).collection('trips');
  
  CollectionReference _categoriesCollection(String uid, String tripId) => 
      _tripsCollection(uid).doc(tripId).collection('categories');
  
  CollectionReference _itemsCollection(String uid, String tripId, String categoryId) => 
      _categoriesCollection(uid, tripId).doc(categoryId).collection('items');

  // ==================== TRIPS ====================

  /// Save a trip to Firestore
  Future<void> saveTrip(String uid, Trip trip) async {
    await _tripsCollection(uid).doc(trip.id).set(trip.toJson());
  }

  /// Get all trips for a user
  Stream<List<Trip>> getTrips(String uid) {
    return _tripsCollection(uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Trip.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }

  /// Get a single trip
  Future<Trip?> getTrip(String uid, String tripId) async {
    final doc = await _tripsCollection(uid).doc(tripId).get();
    if (!doc.exists) return null;
    return Trip.fromJson(doc.data() as Map<String, dynamic>);
  }

  /// Get latest trip for a user
  Future<Trip?> getLatestTrip(String uid) async {
    final snapshot = await _tripsCollection(uid)
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;
    return Trip.fromJson(snapshot.docs.first.data() as Map<String, dynamic>);
  }

  /// Delete a trip
  Future<void> deleteTrip(String uid, String tripId) async {
    // Delete all categories and items first
    final categories = await _categoriesCollection(uid, tripId).get();
    for (final categoryDoc in categories.docs) {
      final items = await _itemsCollection(uid, tripId, categoryDoc.id).get();
      for (final itemDoc in items.docs) {
        await itemDoc.reference.delete();
      }
      await categoryDoc.reference.delete();
    }
    // Delete the trip
    await _tripsCollection(uid).doc(tripId).delete();
  }

  // ==================== CATEGORIES ====================

  /// Save categories for a trip
  Future<void> saveCategories(String uid, String tripId, List<Category> categories) async {
    final batch = _firestore.batch();
    
    for (final category in categories) {
      final categoryRef = _categoriesCollection(uid, tripId).doc(category.id);
      batch.set(categoryRef, category.toJson());
      
      // Save items
      for (final item in category.items) {
        final itemRef = _itemsCollection(uid, tripId, category.id).doc(item.id);
        batch.set(itemRef, item.toJson());
      }
    }
    
    await batch.commit();
  }

  /// Get categories for a trip
  Stream<List<Category>> getCategories(String uid, String tripId) {
    return _categoriesCollection(uid, tripId)
        .orderBy('sortOrder')
        .snapshots()
        .asyncMap((snapshot) async {
          final categories = <Category>[];
          
          for (final doc in snapshot.docs) {
            final categoryData = doc.data() as Map<String, dynamic>;
            
            // Get items for this category
            final itemsSnapshot = await _itemsCollection(uid, tripId, doc.id)
                .orderBy('sortOrder')
                .get();
            
            final items = itemsSnapshot.docs
                .map((itemDoc) => PackingItem.fromJson(itemDoc.data() as Map<String, dynamic>))
                .toList();
            
            categories.add(Category.fromJson({
              ...categoryData,
              'items': items.map((i) => i.toJson()).toList(),
            }));
          }
          
          return categories;
        });
  }

  /// Get categories for a trip (one-time)
  Future<List<Category>> getCategoriesOnce(String uid, String tripId) async {
    final snapshot = await _categoriesCollection(uid, tripId)
        .orderBy('sortOrder')
        .get();

    final categories = <Category>[];

    for (final doc in snapshot.docs) {
      final categoryData = doc.data() as Map<String, dynamic>;

      final itemsSnapshot = await _itemsCollection(uid, tripId, doc.id)
          .orderBy('sortOrder')
          .get();

      final items = itemsSnapshot.docs
          .map((itemDoc) => PackingItem.fromJson(itemDoc.data() as Map<String, dynamic>))
          .toList();

      categories.add(Category.fromJson({
        ...categoryData,
        'items': items.map((i) => i.toJson()).toList(),
      }));
    }

    return categories;
  }

  // ==================== ITEMS ====================

  /// Update a single item (e.g., toggle packed status)
  Future<void> updateItem(String uid, String tripId, String categoryId, PackingItem item) async {
    await _itemsCollection(uid, tripId, categoryId).doc(item.id).update(item.toJson());
  }

  /// Add a new item
  Future<void> addItem(String uid, String tripId, String categoryId, PackingItem item) async {
    await _itemsCollection(uid, tripId, categoryId).doc(item.id).set(item.toJson());
  }

  /// Delete an item
  Future<void> deleteItem(String uid, String tripId, String categoryId, String itemId) async {
    await _itemsCollection(uid, tripId, categoryId).doc(itemId).delete();
  }

  // ==================== USER PROFILE ====================

  /// Save user profile
  Future<void> saveUserProfile(String uid, Map<String, dynamic> profile) async {
    await _userDoc(uid).set(profile, SetOptions(merge: true));
  }

  /// Get user profile
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final doc = await _userDoc(uid).get();
    if (!doc.exists) return null;
    return doc.data() as Map<String, dynamic>;
  }

  // ==================== TEMPLATES ====================

  CollectionReference _templatesCollection(String uid) => 
      _userDoc(uid).collection('templates');

  /// Save a trip as template
  Future<void> saveTemplate(String uid, Trip trip, List<Category> categories) async {
    final templateRef = _templatesCollection(uid).doc(trip.id);
    
    await templateRef.set({
      'trip': trip.toJson(),
      'categories': categories.map((c) => c.toJson()).toList(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Get all templates
  Stream<List<Map<String, dynamic>>> getTemplates(String uid) {
    return _templatesCollection(uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList());
  }
}

/// Provider for Firestore service
final firestoreServiceProvider = Provider<FirestoreService>((ref) => FirestoreService());

/// Provider for user's trips stream
final userTripsProvider = StreamProvider<List<Trip>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value([]);
  
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getTrips(user.uid);
});
