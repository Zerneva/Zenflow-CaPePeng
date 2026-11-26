import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/app_theme.dart';
import '../../core/animations.dart';
import '../../core/currency_format.dart';
import '../../models/transaction.dart';
import '../../models/category.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/category_provider.dart';
import '../widgets/transaction_form_sheet.dart';

class TransactionDetailDialog extends ConsumerWidget {
  final TransactionItem transaction;

  const TransactionDetailDialog({super.key, required this.transaction});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customCategoriesAsync = ref.watch(categoriesStreamProvider);
    final customCategories = customCategoriesAsync.value ?? [];

    final category = AppCategories.getCategoryById(
      transaction.categoryId,
      customCategories,
    );
    final isIncome = transaction.type == TransactionType.income;

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
          // ── Handle ──
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.outline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: AppTheme.sp24),

          // ── Icon ──
          ScaleIn(
            delay: const Duration(milliseconds: 100),
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              ),
              child: Icon(
                category.icon,
                size: 28,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),

          SizedBox(height: AppTheme.sp16),

          // ── Category Name ──
          FadeSlideIn(
            delay: const Duration(milliseconds: 200),
            child: Text(category.name, style: AppTheme.headlineMedium(context)),
          ),

          SizedBox(height: AppTheme.sp8),

          // ── Amount ──
          FadeSlideIn(
            delay: const Duration(milliseconds: 300),
            child: Text(
              '${isIncome ? '+' : '-'}${CurrencyFormat.convertToIdr(transaction.amount)}',
              style: AppTheme.displayMedium(
                context,
              ).copyWith(fontSize: 32, letterSpacing: -0.5),
            ),
          ),

          SizedBox(height: AppTheme.sp24),

          // ── Details ──
          FadeSlideIn(
            delay: const Duration(milliseconds: 400),
            child: Container(
              padding: EdgeInsets.all(AppTheme.sp16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: Column(
                children: [
                  _DetailRow(
                    label: 'Tipe',
                    value: isIncome ? 'Pemasukan' : 'Pengeluaran',
                  ),
                  const Divider(height: AppTheme.sp24),
                  _DetailRow(
                    label: 'Tanggal',
                    value: DateFormat(
                      'dd MMMM yyyy',
                      'id_ID',
                    ).format(transaction.date),
                  ),
                  if (transaction.note.isNotEmpty) ...[
                    const Divider(height: AppTheme.sp24),
                    _DetailRow(label: 'Catatan', value: transaction.note),
                  ],
                ],
              ),
            ),
          ),

          SizedBox(height: AppTheme.sp24),

          // ── Actions ──
          FadeSlideIn(
            delay: const Duration(milliseconds: 500),
            child: Row(
              children: [
                // Delete
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusMd,
                          ),
                        ),
                      ),
                      icon: Icon(Icons.delete_outline, size: 18),
                      label: Text(
                        'HAPUS',
                        style: AppTheme.labelSmall(context).copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      onPressed: () => _confirmDelete(context, ref),
                    ),
                  ),
                ),
                SizedBox(width: AppTheme.sp12),
                // Edit
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.onSurface,
                        foregroundColor: Theme.of(context).colorScheme.surface,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusMd,
                          ),
                        ),
                      ),
                      icon: Icon(Icons.edit_outlined, size: 18),
                      label: Text(
                        'EDIT',
                        style: AppTheme.labelSmall(context).copyWith(
                          color: Theme.of(context).colorScheme.surface,
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => TransactionFormSheet(
                            existingTransaction: transaction,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: MediaQuery.of(context).viewPadding.bottom),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        ),
        title: Text(
          'Hapus Transaksi?',
          style: AppTheme.headlineMedium(context),
        ),
        content: Text(
          'Data transaksi ini akan dihapus permanen.',
          style: AppTheme.bodyLarge(context),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'BATAL',
              style: AppTheme.labelSmall(context).copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.onSurface,
              foregroundColor: Theme.of(context).colorScheme.surface,
              elevation: 0,
            ),
            onPressed: () {
              ref
                  .read(transactionProvider.notifier)
                  .deleteTransaction(transaction.id);
              Navigator.pop(context); // close confirm
              Navigator.pop(context); // close detail
            },
            child: Text('HAPUS'),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTheme.bodyMedium(context)),
        Text(
          value,
          style: AppTheme.titleMedium(context).copyWith(fontSize: 13),
        ),
      ],
    );
  }
}
