import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import '../../core/app_theme.dart';
import '../../core/animations.dart';
import '../../core/currency_format.dart';
import '../../models/transaction.dart';
import '../../models/category.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/category_provider.dart';
import '../widgets/transaction_form_sheet.dart';
import '../dialogs/transaction_detail_dialog.dart';
import '../../providers/filter_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Selamat Pagi';
    if (hour < 17) return 'Selamat Siang';
    return 'Selamat Malam';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch filtered providers
    final transactions = ref.watch(filteredTransactionsProvider);
    final balance = ref.watch(balanceProvider);
    final income = ref.watch(totalIncomeProvider);
    final expense = ref.watch(totalExpenseProvider);

    final customCategoriesAsync = ref.watch(categoriesStreamProvider);
    final customCategories = customCategoriesAsync.value ?? [];
    final searchQuery = ref.watch(searchQueryProvider);
    final timeFilter = ref.watch(timeFilterProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => const TransactionFormSheet(),
          );
        },
        backgroundColor: Theme.of(context).colorScheme.onSurface,
        foregroundColor: Theme.of(context).colorScheme.surface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        ),
        child: Icon(Icons.add, size: 28),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            FadeSlideIn(
              delay: const Duration(milliseconds: 100),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  AppTheme.sp24,
                  AppTheme.sp24,
                  AppTheme.sp24,
                  AppTheme.sp4,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_greeting(), style: AppTheme.bodyMedium(context)),
                    SizedBox(height: 2),
                    Text(
                      'ZENFLOW',
                      style: AppTheme.headlineLarge(
                        context,
                      ).copyWith(letterSpacing: 3),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: AppTheme.sp16),

            // ── Balance Card ──
            FadeSlideIn(
              delay: const Duration(milliseconds: 250),
              child: _BalanceCard(
                balance: balance,
                income: income,
                expense: expense,
              ),
            ),

            SizedBox(height: AppTheme.sp24),

            // ── Search & Filter ──
            FadeSlideIn(
              delay: const Duration(milliseconds: 300),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: AppTheme.sp24),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusMd,
                          ),
                        ),
                        child: TextField(
                          onChanged: (val) {
                            ref.read(searchQueryProvider.notifier).update(val);
                          },
                          decoration: InputDecoration(
                            hintText: 'Cari catatan...',
                            hintStyle: AppTheme.bodyMedium(context).copyWith(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.6),
                              size: 20,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                          style: AppTheme.bodyMedium(context),
                        ),
                      ),
                    ),
                    SizedBox(width: AppTheme.sp12),
                    GestureDetector(
                      onTap: () async {
                        // Show month picker (simplified: just standard date picker for now)
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime(
                            timeFilter.year,
                            timeFilter.month,
                          ),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: ColorScheme.light(
                                  primary: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          ref
                              .read(timeFilterProvider.notifier)
                              .update(
                                TimeFilter(
                                  month: picked.month,
                                  year: picked.year,
                                ),
                              );
                        }
                      },
                      child: Container(
                        height: 48,
                        padding: EdgeInsets.symmetric(
                          horizontal: AppTheme.sp16,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusMd,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 16,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            SizedBox(width: AppTheme.sp8),
                            Text(
                              DateFormat('MMM yyyy').format(
                                DateTime(timeFilter.year, timeFilter.month),
                              ),
                              style: AppTheme.titleMedium(
                                context,
                              ).copyWith(fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: AppTheme.sp24),

            // ── Section Title ──
            FadeSlideIn(
              delay: const Duration(milliseconds: 400),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: AppTheme.sp24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'TRANSAKSI TERBARU',
                      style: AppTheme.labelSmall(context).copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    Text(
                      DateFormat(
                        'MMMM yyyy',
                        'id_ID',
                      ).format(DateTime.now()).toUpperCase(),
                      style: AppTheme.labelSmall(context),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: AppTheme.sp12),

            // ── Transaction List ──
            Expanded(
              child: transactions.isEmpty
                  ? Center(
                      child: FadeSlideIn(
                        delay: const Duration(milliseconds: 500),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.receipt_long,
                              size: 48,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            SizedBox(height: AppTheme.sp12),
                            Text(
                              searchQuery.isNotEmpty
                                  ? 'Pencarian tidak ditemukan'
                                  : 'Belum ada transaksi',
                              style: AppTheme.bodyMedium(context),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: AppTheme.sp16),
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        final item = transactions[index];
                        return AnimatedListItem(
                          key: ValueKey(item.id),
                          index: index,
                          baseDelay: const Duration(milliseconds: 80),
                          stagger: const Duration(milliseconds: 45),
                          child: _TransactionTile(
                            item: item,
                            customCategories: customCategories,
                            onDelete: () {
                              ref
                                  .read(transactionProvider.notifier)
                                  .deleteTransaction(item.id);
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Balance Card Widget ──
class _BalanceCard extends StatelessWidget {
  final double balance;
  final double income;
  final double expense;

  const _BalanceCard({
    required this.balance,
    required this.income,
    required this.expense,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: AppTheme.sp24),
      padding: EdgeInsets.all(AppTheme.sp24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TOTAL SALDO',
            style: AppTheme.labelSmall(context).copyWith(color: Colors.white38),
          ),
          SizedBox(height: AppTheme.sp8),
          CountUpText(
            value: balance,
            formatter: CurrencyFormat.convertToIdr,
            style: AppTheme.mono(context).copyWith(fontSize: 32),
            duration: const Duration(milliseconds: 1500),
          ),
          SizedBox(height: AppTheme.sp24),
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  icon: Icons.arrow_upward_rounded,
                  label: 'MASUK',
                  value: income,
                ),
              ),
              Container(width: 1, height: 40, color: Colors.white12),
              Expanded(
                child: _MiniStat(
                  icon: Icons.arrow_downward_rounded,
                  label: 'KELUAR',
                  value: expense,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final double value;

  const _MiniStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppTheme.sp16),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Icon(icon, size: 14, color: Colors.white60),
          ),
          SizedBox(width: AppTheme.sp8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTheme.labelSmall(
                    context,
                  ).copyWith(color: Colors.white30, fontSize: 9),
                ),
                SizedBox(height: 2),
                CountUpText(
                  value: value,
                  formatter: CurrencyFormat.convertToIdr,
                  style: AppTheme.titleMedium(
                    context,
                  ).copyWith(color: Colors.white, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Transaction Tile Widget ──
class _TransactionTile extends StatelessWidget {
  final TransactionItem item;
  final List<CategoryItem> customCategories;
  final VoidCallback onDelete;

  const _TransactionTile({
    required this.item,
    required this.customCategories,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final category = AppCategories.getCategoryById(
      item.categoryId,
      customCategories,
    );
    final isIncome = item.type == TransactionType.income;

    return Padding(
      padding: EdgeInsets.only(bottom: AppTheme.sp8),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const BehindMotion(),
          extentRatio: 0.25,
          children: [
            SlidableAction(
              onPressed: (_) => onDelete(),
              backgroundColor: Theme.of(context).colorScheme.onSurface,
              foregroundColor: Theme.of(context).colorScheme.surface,
              icon: Icons.delete_outline,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
          ],
        ),
        child: AnimatedPressable(
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => TransactionDetailDialog(transaction: item),
            );
          },
          child: Container(
            padding: EdgeInsets.all(AppTheme.sp16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Row(
              children: [
                // Category icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  child: Icon(
                    category.icon,
                    size: 20,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                SizedBox(width: AppTheme.sp12),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(category.name, style: AppTheme.titleMedium(context)),
                      SizedBox(height: 2),
                      Text(
                        item.note.isNotEmpty
                            ? item.note
                            : DateFormat('dd MMM yyyy').format(item.date),
                        style: AppTheme.bodyMedium(context),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Amount
                Text(
                  '${isIncome ? '+' : '-'}${CurrencyFormat.convertToIdr(item.amount)}',
                  style: AppTheme.titleMedium(
                    context,
                  ).copyWith(fontSize: 14, letterSpacing: -0.3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
