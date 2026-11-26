import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'transaction.dart';

class CategoryItem {
  final String id;
  final String name;
  final IconData icon;
  final TransactionType type;
  final String? userId; // null if it's a default system category
  final bool isDefault;

  const CategoryItem({
    required this.id,
    required this.name,
    required this.icon,
    required this.type,
    this.userId,
    this.isDefault = false,
  });

  factory CategoryItem.fromMap(Map<String, dynamic> map, String docId) {
    return CategoryItem(
      id: docId,
      name: map['name'] ?? '',
      icon: IconData(
        map['iconCodePoint'] ?? Icons.category.codePoint,
        fontFamily: map['iconFontFamily'] ?? 'MaterialIcons',
      ),
      type: map['type'] == 'income'
          ? TransactionType.income
          : TransactionType.expense,
      userId: map['userId'],
      isDefault: map['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'iconCodePoint': icon.codePoint,
      'iconFontFamily': icon.fontFamily,
      'type': type == TransactionType.income ? 'income' : 'expense',
      'userId': userId,
      'isDefault': isDefault,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  CategoryItem copyWith({
    String? id,
    String? name,
    IconData? icon,
    TransactionType? type,
    String? userId,
    bool? isDefault,
  }) {
    return CategoryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      type: type ?? this.type,
      userId: userId ?? this.userId,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}

class AppCategories {
  static const List<CategoryItem> defaultCategories = [
    // Pemasukan
    CategoryItem(
      id: 'inc_salary',
      name: 'Gaji',
      icon: Icons.account_balance_wallet,
      type: TransactionType.income,
      isDefault: true,
    ),
    CategoryItem(
      id: 'inc_sales',
      name: 'Penjualan',
      icon: Icons.storefront,
      type: TransactionType.income,
      isDefault: true,
    ),
    CategoryItem(
      id: 'inc_invest',
      name: 'Investasi',
      icon: Icons.trending_up,
      type: TransactionType.income,
      isDefault: true,
    ),
    CategoryItem(
      id: 'inc_other',
      name: 'Lainnya',
      icon: Icons.more_horiz,
      type: TransactionType.income,
      isDefault: true,
    ),

    // Pengeluaran
    CategoryItem(
      id: 'exp_food',
      name: 'Makan & Minum',
      icon: Icons.restaurant,
      type: TransactionType.expense,
      isDefault: true,
    ),
    CategoryItem(
      id: 'exp_transport',
      name: 'Transportasi',
      icon: Icons.directions_car,
      type: TransactionType.expense,
      isDefault: true,
    ),
    CategoryItem(
      id: 'exp_bills',
      name: 'Tagihan',
      icon: Icons.receipt_long,
      type: TransactionType.expense,
      isDefault: true,
    ),
    CategoryItem(
      id: 'exp_shopping',
      name: 'Belanja',
      icon: Icons.shopping_bag,
      type: TransactionType.expense,
      isDefault: true,
    ),
    CategoryItem(
      id: 'exp_health',
      name: 'Kesehatan',
      icon: Icons.health_and_safety,
      type: TransactionType.expense,
      isDefault: true,
    ),
    CategoryItem(
      id: 'exp_other',
      name: 'Lainnya',
      icon: Icons.more_horiz,
      type: TransactionType.expense,
      isDefault: true,
    ),
  ];

  static CategoryItem getCategoryById(
    String id, [
    List<CategoryItem>? categories,
  ]) {
    final allCategories = categories ?? [];
    return allCategories.firstWhere(
      (cat) => cat.id == id,
      orElse: () => const CategoryItem(
        id: 'unknown',
        name: 'Tidak Diketahui',
        icon: Icons.help_outline,
        type: TransactionType.expense,
        isDefault: true,
      ),
    );
  }
}
