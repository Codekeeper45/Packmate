import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SyncService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> get _tripsCollection =>
      _firestore.collection('users').doc(_userId).collection('trips');

  CollectionReference<Map<String, dynamic>> get _templatesCollection =>
      _firestore.collection('users').doc(_userId).collection('templates');

  CollectionReference<Map<String, dynamic>> get _categoriesCollection =>
      _firestore.collection('users').doc(_userId).collection('categories');

  CollectionReference<Map<String, dynamic>> get _itemsCollection =>
      _firestore.collection('users').doc(_userId).collection('items');

  // Trips
  Future<void> saveTrip(Map<String, dynamic> tripData) async {
    if (_userId == null) return;
    final tripId = tripData['tripId'] as String;
    await _tripsCollection.doc(tripId).set({
      ...tripData,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<List<Map<String, dynamic>>> getTrips() async {
    if (_userId == null) return [];
    final snapshot = await _tripsCollection.orderBy('createdAt', descending: true).get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Stream<List<Map<String, dynamic>>> watchTrips() {
    if (_userId == null) return Stream.value([]);
    return _tripsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Future<void> deleteTrip(String tripId) async {
    if (_userId == null) return;
    await _tripsCollection.doc(tripId).delete();
    // Delete related categories and items
    final categoriesSnapshot = await _categoriesCollection
        .where('tripId', isEqualTo: tripId)
        .get();
    for (final doc in categoriesSnapshot.docs) {
      await doc.reference.delete();
    }
    final itemsSnapshot = await _itemsCollection
        .where('tripId', isEqualTo: tripId)
        .get();
    for (final doc in itemsSnapshot.docs) {
      await doc.reference.delete();
    }
  }

  // Templates
  Future<void> saveTemplate(Map<String, dynamic> templateData) async {
    if (_userId == null) return;
    final templateId = templateData['templateId'] as String;
    await _templatesCollection.doc(templateId).set({
      ...templateData,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<List<Map<String, dynamic>>> getTemplates() async {
    if (_userId == null) return [];
    final snapshot = await _templatesCollection.orderBy('createdAt', descending: true).get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Stream<List<Map<String, dynamic>>> watchTemplates() {
    if (_userId == null) return Stream.value([]);
    return _templatesCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Future<void> deleteTemplate(String templateId) async {
    if (_userId == null) return;
    await _templatesCollection.doc(templateId).delete();
  }

  // Categories
  Future<void> saveCategory(Map<String, dynamic> categoryData) async {
    if (_userId == null) return;
    final categoryId = categoryData['categoryId'] as String;
    await _categoriesCollection.doc(categoryId).set(categoryData, SetOptions(merge: true));
  }

  Future<List<Map<String, dynamic>>> getCategoriesForTrip(String tripId) async {
    if (_userId == null) return [];
    final snapshot = await _categoriesCollection
        .where('tripId', isEqualTo: tripId)
        .orderBy('sortOrder')
        .get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Stream<List<Map<String, dynamic>>> watchCategoriesForTrip(String tripId) {
    if (_userId == null) return Stream.value([]);
    return _categoriesCollection
        .where('tripId', isEqualTo: tripId)
        .orderBy('sortOrder')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  // Items
  Future<void> saveItem(Map<String, dynamic> itemData) async {
    if (_userId == null) return;
    final itemId = itemData['itemId'] as String;
    await _itemsCollection.doc(itemId).set(itemData, SetOptions(merge: true));
  }

  Future<void> updateItemPacked(String itemId, bool isPacked) async {
    if (_userId == null) return;
    await _itemsCollection.doc(itemId).update({
      'isPacked': isPacked,
      'packedAt': isPacked ? FieldValue.serverTimestamp() : null,
    });
  }

  Future<List<Map<String, dynamic>>> getItemsForTrip(String tripId) async {
    if (_userId == null) return [];
    final snapshot = await _itemsCollection
        .where('tripId', isEqualTo: tripId)
        .orderBy('sortOrder')
        .get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Stream<List<Map<String, dynamic>>> watchItemsForTrip(String tripId) {
    if (_userId == null) return Stream.value([]);
    return _itemsCollection
        .where('tripId', isEqualTo: tripId)
        .orderBy('sortOrder')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Future<void> deleteItem(String itemId) async {
    if (_userId == null) return;
    await _itemsCollection.doc(itemId).delete();
  }

  // Batch sync (for initial sync or full backup)
  Future<void> syncAllData({
    required List<Map<String, dynamic>> trips,
    required List<Map<String, dynamic>> templates,
    required List<Map<String, dynamic>> categories,
    required List<Map<String, dynamic>> items,
  }) async {
    if (_userId == null) return;

    final batch = _firestore.batch();

    for (final trip in trips) {
      batch.set(_tripsCollection.doc(trip['tripId']), trip, SetOptions(merge: true));
    }
    for (final template in templates) {
      batch.set(_templatesCollection.doc(template['templateId']), template, SetOptions(merge: true));
    }
    for (final category in categories) {
      batch.set(_categoriesCollection.doc(category['categoryId']), category, SetOptions(merge: true));
    }
    for (final item in items) {
      batch.set(_itemsCollection.doc(item['itemId']), item, SetOptions(merge: true));
    }

    await batch.commit();
  }
}
