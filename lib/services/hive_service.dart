import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction.dart';

class HiveService {
  static const String _boxName = 'transactionsBox';

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(TransactionTypeAdapter());
    Hive.registerAdapter(TransactionItemAdapter());
    await Hive.openBox<TransactionItem>(_boxName);
  }

  Box<TransactionItem> get _box => Hive.box<TransactionItem>(_boxName);

  List<TransactionItem> getAllTransactions() {
    return _box.values.toList()..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> addTransaction(TransactionItem transaction) async {
    await _box.put(transaction.id, transaction);
  }

  Future<void> updateTransaction(TransactionItem transaction) async {
    await _box.put(transaction.id, transaction);
  }

  Future<void> deleteTransaction(String id) async {
    await _box.delete(id);
  }
}
