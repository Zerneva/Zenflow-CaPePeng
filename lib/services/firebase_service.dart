import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/transaction.dart';
import '../models/category.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  CollectionReference get _transactionsRef {
    final uid = currentUserId;
    if (uid == null) throw Exception('User not logged in');
    return _firestore.collection('users').doc(uid).collection('transactions');
  }

  CollectionReference get _categoriesRef {
    final uid = currentUserId;
    if (uid == null) throw Exception('User not logged in');
    return _firestore.collection('users').doc(uid).collection('categories');
  }

  Stream<List<TransactionItem>> getTransactionsStream() {
    final uid = currentUserId;
    if (uid == null) return Stream.value([]);

    return _transactionsRef.orderBy('date', descending: true).snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return _fromJson(data);
      }).toList();
    });
  }

  Future<void> addTransaction(TransactionItem transaction) async {
    await _transactionsRef.doc(transaction.id).set(_toJson(transaction));
  }

  Future<void> updateTransaction(TransactionItem transaction) async {
    await _transactionsRef.doc(transaction.id).update(_toJson(transaction));
  }

  Future<void> deleteTransaction(String id) async {
    await _transactionsRef.doc(id).delete();
  }

  // --- Category Methods ---

  Stream<List<CategoryItem>> getCategoriesStream() {
    final uid = currentUserId;
    if (uid == null) return Stream.value([]);

    return _categoriesRef.snapshots().map((snapshot) {
      final categories = snapshot.docs
          .where((doc) => doc.id != '_metadata')
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return CategoryItem.fromMap(data, doc.id);
          })
          .toList();
      categories.sort((a, b) => a.name.compareTo(b.name));
      return categories;
    });
  }

  Future<void> ensureCategoriesSeeded() async {
    try {
      final uid = currentUserId;
      if (uid == null) return;

      final metadataDoc = await _categoriesRef.doc('_metadata').get();
      if (metadataDoc.exists && metadataDoc.data() != null) {
        final data = metadataDoc.data() as Map<String, dynamic>;
        if (data['hasSeeded'] == true) {
          return; // Already seeded
        }
      }

      final batch = _firestore.batch();
      for (final cat in AppCategories.defaultCategories) {
        final docRef = _categoriesRef.doc(cat.id);
        final data = cat.toMap();
        data['isDefault'] = false;
        batch.set(docRef, data);
      }
      batch.set(_categoriesRef.doc('_metadata'), {'hasSeeded': true});
      await batch.commit();
    } catch (e) {
      debugPrint('Error seeding categories: $e');
    }
  }

  Future<void> addCategory(CategoryItem category) async {
    await _categoriesRef.doc(category.id).set(category.toMap());
  }

  Future<void> updateCategory(CategoryItem category) async {
    await _categoriesRef.doc(category.id).update(category.toMap());
  }

  Future<void> deleteCategory(String id) async {
    await _categoriesRef.doc(id).delete();
  }

  TransactionItem _fromJson(Map<String, dynamic> json) {
    return TransactionItem(
      id: json['id'],
      amount: (json['amount'] as num).toDouble(),
      type: json['type'] == 'income'
          ? TransactionType.income
          : TransactionType.expense,
      categoryId: json['category_id'],
      date: DateTime.parse(json['date']),
      note: json['note'] ?? '',
    );
  }

  Map<String, dynamic> _toJson(TransactionItem tx) {
    return {
      'id': tx.id,
      'amount': tx.amount,
      'type': tx.type == TransactionType.income ? 'income' : 'expense',
      'category_id': tx.categoryId,
      'date': tx.date.toIso8601String(),
      'note': tx.note,
    };
  }
}
