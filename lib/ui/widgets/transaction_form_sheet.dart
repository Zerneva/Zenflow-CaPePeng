import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../core/app_theme.dart';
import '../../core/animations.dart';
import '../../models/transaction.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/category_provider.dart';
import '../../core/currency_format.dart';

class TransactionFormSheet extends ConsumerStatefulWidget {
  final TransactionItem? existingTransaction;

  const TransactionFormSheet({super.key, this.existingTransaction});

  @override
  ConsumerState<TransactionFormSheet> createState() =>
      _TransactionFormSheetState();
}

class _TransactionFormSheetState extends ConsumerState<TransactionFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  TransactionType _type = TransactionType.expense;
  DateTime _selectedDate = DateTime.now();
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    if (widget.existingTransaction != null) {
      final tx = widget.existingTransaction!;
      _amountController.text = NumberFormat.decimalPattern(
        'id',
      ).format(tx.amount.toInt());
      _noteController.text = tx.note;
      _type = tx.type;
      _selectedDate = tx.date;
      _selectedCategoryId = tx.categoryId;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _saveTransaction() {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategoryId == null) return;

      final amount =
          double.tryParse(_amountController.text.replaceAll('.', '')) ?? 0.0;
      final newTransaction = TransactionItem(
        id: widget.existingTransaction?.id ?? const Uuid().v4(),
        amount: amount,
        type: _type,
        categoryId: _selectedCategoryId!,
        date: _selectedDate,
        note: _noteController.text,
      );

      if (widget.existingTransaction == null) {
        ref.read(transactionProvider.notifier).addTransaction(newTransaction);
      } else {
        ref
            .read(transactionProvider.notifier)
            .updateTransaction(newTransaction);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final customCategoriesAsync = ref.watch(categoriesStreamProvider);
    final allCategories = customCategoriesAsync.value ?? [];

    final categories = allCategories.where((c) => c.type == _type).toList();

    if (!categories.any((c) => c.id == _selectedCategoryId)) {
      _selectedCategoryId = categories.isNotEmpty ? categories.first.id : null;
    }

    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final isEditing = widget.existingTransaction != null;

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppTheme.sp24,
        AppTheme.sp16,
        AppTheme.sp24,
        bottomPadding + AppTheme.sp24,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusXl),
        ),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Handle bar ──
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outline,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: AppTheme.sp20),

              // ── Title ──
              FadeSlideIn(
                delay: const Duration(milliseconds: 100),
                child: Text(
                  isEditing ? 'EDIT TRANSAKSI' : 'TRANSAKSI BARU',
                  style: AppTheme.headlineMedium(
                    context,
                  ).copyWith(letterSpacing: 2),
                  textAlign: TextAlign.center,
                ),
              ),

              SizedBox(height: AppTheme.sp24),

              // ── Type Toggle ──
              FadeSlideIn(
                delay: const Duration(milliseconds: 200),
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                  child: Row(
                    children: [
                      _TypeToggleButton(
                        label: 'PENGELUARAN',
                        isSelected: _type == TransactionType.expense,
                        onTap: () =>
                            setState(() => _type = TransactionType.expense),
                      ),
                      _TypeToggleButton(
                        label: 'PEMASUKAN',
                        isSelected: _type == TransactionType.income,
                        onTap: () =>
                            setState(() => _type = TransactionType.income),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: AppTheme.sp24),

              // ── Amount Input ──
              FadeSlideIn(
                delay: const Duration(milliseconds: 300),
                child: TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [ThousandsFormatter()],
                  style: AppTheme.displayMedium(
                    context,
                  ).copyWith(fontSize: 36, letterSpacing: -1),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: '0',
                    hintStyle: AppTheme.displayMedium(context).copyWith(
                      fontSize: 36,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                    prefixText: 'Rp ',
                    prefixStyle: AppTheme.displayMedium(context).copyWith(
                      fontSize: 36,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                    border: InputBorder.none,
                    errorStyle: AppTheme.bodyMedium(
                      context,
                    ).copyWith(color: Theme.of(context).colorScheme.onSurface),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Masukkan nominal';
                    final cleanVal = val.replaceAll('.', '');
                    if (double.tryParse(cleanVal) == null) {
                      return 'Nominal tidak valid';
                    }
                    return null;
                  },
                ),
              ),

              const Divider(height: 1),
              SizedBox(height: AppTheme.sp20),

              // ── Category Grid ──
              FadeSlideIn(
                delay: const Duration(milliseconds: 400),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'KATEGORI',
                      style: AppTheme.labelSmall(context).copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    SizedBox(height: AppTheme.sp12),
                    SizedBox(
                      height: 80,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        separatorBuilder: (_, a) =>
                            SizedBox(width: AppTheme.sp8),
                        itemBuilder: (context, index) {
                          final cat = categories[index];
                          final isSelected = cat.id == _selectedCategoryId;
                          return GestureDetector(
                            onTap: () =>
                                setState(() => _selectedCategoryId = cat.id),
                            child: AnimatedContainer(
                              duration: AppTheme.fast,
                              width: 72,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Theme.of(context).colorScheme.onSurface
                                    : Theme.of(
                                        context,
                                      ).colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(
                                  AppTheme.radiusMd,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    cat.icon,
                                    size: 22,
                                    color: isSelected
                                        ? Theme.of(context).colorScheme.surface
                                        : Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withValues(alpha: 0.6),
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    cat.name,
                                    style: AppTheme.bodyMedium(context)
                                        .copyWith(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: isSelected
                                              ? Theme.of(
                                                  context,
                                                ).colorScheme.surface
                                              : Theme.of(context)
                                                    .colorScheme
                                                    .onSurface
                                                    .withValues(alpha: 0.6),
                                        ),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: AppTheme.sp20),

              // ── Note ──
              FadeSlideIn(
                delay: const Duration(milliseconds: 500),
                child: TextFormField(
                  controller: _noteController,
                  style: AppTheme.bodyLarge(
                    context,
                  ).copyWith(color: Theme.of(context).colorScheme.onSurface),
                  decoration: InputDecoration(
                    labelText: 'CATATAN',
                    labelStyle: AppTheme.labelSmall(context).copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    hintText: 'Opsional',
                    hintStyle: AppTheme.bodyMedium(context).copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.onSurface,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: AppTheme.sp16),

              // ── Date Picker ──
              FadeSlideIn(
                delay: const Duration(milliseconds: 600),
                child: InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) setState(() => _selectedDate = date);
                  },
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppTheme.sp16,
                      vertical: AppTheme.sp12,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 18,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        SizedBox(width: AppTheme.sp12),
                        Text(
                          DateFormat(
                            'dd MMMM yyyy',
                            'id_ID',
                          ).format(_selectedDate),
                          style: AppTheme.titleMedium(
                            context,
                          ).copyWith(fontSize: 14),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.chevron_right,
                          size: 18,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.4),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: AppTheme.sp24),

              // ── Save Button ──
              FadeSlideIn(
                delay: const Duration(milliseconds: 700),
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.onSurface,
                      foregroundColor: Theme.of(context).colorScheme.surface,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      ),
                    ),
                    onPressed: _saveTransaction,
                    child: Text(
                      'SIMPAN',
                      style: AppTheme.titleMedium(context).copyWith(
                        color: Theme.of(context).colorScheme.surface,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypeToggleButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeToggleButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppTheme.fast,
          curve: AppTheme.defaultCurve,
          padding: EdgeInsets.symmetric(vertical: AppTheme.sp12),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.onSurface
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          ),
          child: Center(
            child: Text(
              label,
              style: AppTheme.labelSmall(context).copyWith(
                color: isSelected
                    ? Theme.of(context).colorScheme.surface
                    : Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: 11,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
