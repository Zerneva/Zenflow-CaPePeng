import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import '../../core/app_theme.dart';
import '../../core/animations.dart';
import '../../core/currency_format.dart';
import '../../models/transaction.dart';
import '../../models/category.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/filter_provider.dart';
import '../../services/export_service.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(filteredTransactionsProvider);
    final customCategoriesAsync = ref.watch(categoriesStreamProvider);
    final customCategories = customCategoriesAsync.value ?? [];
    final timeFilter = ref.watch(timeFilterProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: _StatsBody(
          transactions: transactions,
          customCategories: customCategories,
          timeFilter: timeFilter,
        ),
      ),
    );
  }
}

class _StatsBody extends StatelessWidget {
  final List<TransactionItem> transactions;
  final List<CategoryItem> customCategories;
  final TimeFilter timeFilter;

  const _StatsBody({
    required this.transactions,
    required this.customCategories,
    required this.timeFilter,
  });

  Map<String, double> _expenseByCategory() {
    final map = <String, double>{};
    for (final tx in transactions) {
      if (tx.type == TransactionType.expense) {
        map[tx.categoryId] = (map[tx.categoryId] ?? 0) + tx.amount;
      }
    }
    return map;
  }

  Map<String, double> _incomeByCategory() {
    final map = <String, double>{};
    for (final tx in transactions) {
      if (tx.type == TransactionType.income) {
        map[tx.categoryId] = (map[tx.categoryId] ?? 0) + tx.amount;
      }
    }
    return map;
  }

  double _totalExpenseThisMonth() {
    return transactions
        .where((tx) => tx.type == TransactionType.expense)
        .fold<double>(0.0, (sum, tx) => sum + tx.amount);
  }

  double _totalIncomeThisMonth() {
    return transactions
        .where((tx) => tx.type == TransactionType.income)
        .fold<double>(0.0, (sum, tx) => sum + tx.amount);
  }

  @override
  Widget build(BuildContext context) {
    final expenseMap = _expenseByCategory();
    final incomeMap = _incomeByCategory();
    final totalExpense = _totalExpenseThisMonth();
    final totalIncome = _totalIncomeThisMonth();

    return SingleChildScrollView(
      padding: EdgeInsets.all(AppTheme.sp24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 100),
                    child: Text(
                      'STATISTIK',
                      style: AppTheme.headlineLarge(
                        context,
                      ).copyWith(letterSpacing: 3),
                    ),
                  ),
                  SizedBox(height: 4),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 150),
                    child: Text(
                      'Bulan ${DateFormat('MMMM yyyy', 'id_ID').format(DateTime(timeFilter.year, timeFilter.month))}',
                      style: AppTheme.bodyMedium(context),
                    ),
                  ),
                ],
              ),
              FadeSlideIn(
                delay: const Duration(milliseconds: 150),
                child: IconButton(
                  icon: Icon(
                    Icons.file_download_outlined,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  tooltip: 'Ekspor Data',
                  onPressed: () {
                    if (transactions.isEmpty) return;

                    final allCategories = customCategories;

                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      builder: (context) {
                        return Container(
                          padding: EdgeInsets.all(AppTheme.sp24),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(AppTheme.radiusXl),
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Pilih Format Laporan',
                                style: AppTheme.headlineMedium(context),
                              ),
                              SizedBox(height: AppTheme.sp24),
                              ListTile(
                                leading: Icon(
                                  Icons.table_chart_outlined,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                                title: Text(
                                  'CSV (Excel)',
                                  style: AppTheme.titleMedium(context),
                                ),
                                subtitle: Text(
                                  'Tabel mentah untuk diolah',
                                  style: AppTheme.bodyMedium(
                                    context,
                                  ).copyWith(fontSize: 12),
                                ),
                                onTap: () {
                                  Navigator.pop(context);
                                  ExportService.exportTransactionsToCSV(
                                    transactions,
                                    allCategories,
                                    timeFilter.month,
                                    timeFilter.year,
                                  );
                                },
                              ),
                              const Divider(),
                              ListTile(
                                leading: Icon(
                                  Icons.picture_as_pdf_outlined,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                                title: Text(
                                  'PDF (Dokumen)',
                                  style: AppTheme.titleMedium(context),
                                ),
                                subtitle: Text(
                                  'Laporan rapi siap cetak',
                                  style: AppTheme.bodyMedium(
                                    context,
                                  ).copyWith(fontSize: 12),
                                ),
                                onTap: () {
                                  Navigator.pop(context);
                                  ExportService.exportTransactionsToPDF(
                                    transactions,
                                    allCategories,
                                    timeFilter.month,
                                    timeFilter.year,
                                  );
                                },
                              ),
                              SizedBox(height: AppTheme.sp24),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.sp32),

          // ── Summary Cards ──
          FadeSlideIn(
            delay: const Duration(milliseconds: 250),
            child: Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    label: 'PENGELUARAN',
                    value: totalExpense,
                    icon: Icons.arrow_downward_rounded,
                  ),
                ),
                SizedBox(width: AppTheme.sp12),
                Expanded(
                  child: _SummaryCard(
                    label: 'PEMASUKAN',
                    value: totalIncome,
                    icon: Icons.arrow_upward_rounded,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: AppTheme.sp32),

          // ── Expense Chart ──
          if (expenseMap.isNotEmpty) ...[
            FadeSlideIn(
              delay: const Duration(milliseconds: 350),
              child: Text(
                'PENGELUARAN PER KATEGORI',
                style: AppTheme.labelSmall(context).copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
            SizedBox(height: AppTheme.sp16),
            ...expenseMap.entries.toList().asMap().entries.map((entry) {
              final index = entry.key;
              final categoryId = entry.value.key;
              final amount = entry.value.value;
              final category = AppCategories.getCategoryById(
                categoryId,
                customCategories,
              );
              return AnimatedListItem(
                key: ValueKey('expense_$categoryId'),
                index: index,
                baseDelay: const Duration(milliseconds: 200),
                stagger: const Duration(milliseconds: 60),
                child: _BarItem(
                  icon: category.icon,
                  label: category.name,
                  amount: amount,
                  maxAmount: expenseMap.values.reduce(math.max),
                ),
              );
            }),
          ],

          if (expenseMap.isEmpty && incomeMap.isEmpty) ...[
            SizedBox(height: 80),
            FadeSlideIn(
              delay: const Duration(milliseconds: 300),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.bar_chart_rounded,
                      size: 48,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    SizedBox(height: AppTheme.sp12),
                    Text(
                      'Belum ada data bulan ini',
                      style: AppTheme.bodyMedium(context),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // ── Income Chart ──
          if (incomeMap.isNotEmpty) ...[
            SizedBox(height: AppTheme.sp32),
            FadeSlideIn(
              delay: Duration(milliseconds: 400 + (expenseMap.length * 80)),
              child: Text(
                'PEMASUKAN PER KATEGORI',
                style: AppTheme.labelSmall(context).copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
            SizedBox(height: AppTheme.sp16),
            ...incomeMap.entries.toList().asMap().entries.map((entry) {
              final index = entry.key;
              final categoryId = entry.value.key;
              final amount = entry.value.value;
              final category = AppCategories.getCategoryById(
                categoryId,
                customCategories,
              );
              return AnimatedListItem(
                key: ValueKey('income_$categoryId'),
                index: index,
                baseDelay: const Duration(milliseconds: 200),
                stagger: const Duration(milliseconds: 60),
                child: _BarItem(
                  icon: category.icon,
                  label: category.name,
                  amount: amount,
                  maxAmount: incomeMap.values.reduce(math.max),
                ),
              );
            }),
          ],

          SizedBox(height: AppTheme.sp48),
        ],
      ),
    );
  }
}

// ── Summary Card ──
class _SummaryCard extends StatelessWidget {
  final String label;
  final double value;
  final IconData icon;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppTheme.sp20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Icon(
              icon,
              size: 16,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: AppTheme.sp12),
          Text(label, style: AppTheme.labelSmall(context)),
          SizedBox(height: AppTheme.sp4),
          CountUpText(
            value: value,
            formatter: CurrencyFormat.convertToIdr,
            style: AppTheme.titleMedium(context).copyWith(fontSize: 16),
          ),
        ],
      ),
    );
  }
}

// ── Bar Item ──
class _BarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final double amount;
  final double maxAmount;

  const _BarItem({
    required this.icon,
    required this.label,
    required this.amount,
    required this.maxAmount,
  });

  @override
  Widget build(BuildContext context) {
    final fraction = maxAmount > 0 ? (amount / maxAmount) : 0.0;

    return Padding(
      padding: EdgeInsets.only(bottom: AppTheme.sp12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Icon(
              icon,
              size: 16,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(width: AppTheme.sp12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      label,
                      style: AppTheme.titleMedium(
                        context,
                      ).copyWith(fontSize: 13),
                    ),
                    Text(
                      CurrencyFormat.convertToIdr(amount),
                      style: AppTheme.bodyMedium(
                        context,
                      ).copyWith(fontSize: 12),
                    ),
                  ],
                ),
                SizedBox(height: 6),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: fraction),
                  duration: const Duration(milliseconds: 800),
                  curve: AppTheme.defaultCurve,
                  builder: (context, value, _) {
                    return Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.outline,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: value.clamp(0.0, 1.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.onSurface,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
