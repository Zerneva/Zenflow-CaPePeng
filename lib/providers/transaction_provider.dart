import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transaction.dart';
import '../services/firebase_service.dart';
import 'filter_provider.dart';

final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  return FirebaseService();
});

class TransactionNotifier extends StreamNotifier<List<TransactionItem>> {
  FirebaseService get _firebaseService => ref.read(firebaseServiceProvider);

  @override
  Stream<List<TransactionItem>> build() {
    return _firebaseService.getTransactionsStream();
  }

  Future<void> addTransaction(TransactionItem transaction) async {
    await _firebaseService.addTransaction(transaction);
  }

  Future<void> updateTransaction(TransactionItem transaction) async {
    await _firebaseService.updateTransaction(transaction);
  }

  Future<void> deleteTransaction(String id) async {
    await _firebaseService.deleteTransaction(id);
  }
}

final transactionProvider =
    StreamNotifierProvider<TransactionNotifier, List<TransactionItem>>(() {
      return TransactionNotifier();
    });

final filteredTransactionsProvider = Provider<List<TransactionItem>>((ref) {
  final transactions = ref.watch(transactionProvider).value ?? [];
  final timeFilter = ref.watch(timeFilterProvider);
  final searchQuery = ref.watch(searchQueryProvider).toLowerCase();

  return transactions.where((tx) {
    // 1. Time Filter
    final matchesTime =
        tx.date.month == timeFilter.month && tx.date.year == timeFilter.year;

    // 2. Search Filter
    final matchesSearch =
        searchQuery.isEmpty ||
        tx.note.toLowerCase().contains(searchQuery) ||
        tx.amount.toString().contains(searchQuery);

    return matchesTime && matchesSearch;
  }).toList();
});

final totalIncomeProvider = Provider<double>((ref) {
  final transactions = ref.watch(filteredTransactionsProvider);
  return transactions
      .where((t) => t.type == TransactionType.income)
      .fold<double>(0.0, (sum, t) => sum + t.amount);
});

final totalExpenseProvider = Provider<double>((ref) {
  final transactions = ref.watch(filteredTransactionsProvider);
  return transactions
      .where((t) => t.type == TransactionType.expense)
      .fold<double>(0.0, (sum, t) => sum + t.amount);
});

final balanceProvider = Provider<double>((ref) {
  final income = ref.watch(totalIncomeProvider);
  final expense = ref.watch(totalExpenseProvider);
  return income - expense;
});
