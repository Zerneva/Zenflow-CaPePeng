import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/app_theme.dart';
import '../../core/animations.dart';
import '../../models/category.dart';
import '../../models/transaction.dart';
import '../../providers/category_provider.dart';

class CategoryManagementScreen extends ConsumerStatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  ConsumerState<CategoryManagementScreen> createState() =>
      _CategoryManagementScreenState();
}

class _CategoryManagementScreenState
    extends ConsumerState<CategoryManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddOrEditCategoryForm(
    BuildContext context,
    TransactionType type, {
    CategoryItem? categoryToEdit,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          _CategoryFormSheet(type: type, categoryToEdit: categoryToEdit),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onSurface,
        ),
        title: Text(
          'KATEGORI',
          style: AppTheme.headlineMedium(context).copyWith(letterSpacing: 2),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).colorScheme.onSurface,
          unselectedLabelColor: Theme.of(
            context,
          ).colorScheme.onSurface.withValues(alpha: 0.6),
          indicatorColor: Theme.of(context).colorScheme.onSurface,
          indicatorWeight: 3,
          labelStyle: AppTheme.labelSmall(context).copyWith(fontSize: 12),
          tabs: [
            Tab(text: 'PENGELUARAN'),
            Tab(text: 'PEMASUKAN'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final type = _tabController.index == 0
              ? TransactionType.expense
              : TransactionType.income;
          _showAddOrEditCategoryForm(context, type);
        },
        backgroundColor: Theme.of(context).colorScheme.onSurface,
        foregroundColor: Theme.of(context).colorScheme.surface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        ),
        child: Icon(Icons.add, size: 28),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _CategoryList(type: TransactionType.expense),
          _CategoryList(type: TransactionType.income),
        ],
      ),
    );
  }
}

class _CategoryList extends ConsumerWidget {
  final TransactionType type;

  const _CategoryList({required this.type});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customCategoriesAsync = ref.watch(categoriesStreamProvider);

    if (customCategoriesAsync.hasError) {
      return Center(
        child: Text(
          'Error: ${customCategoriesAsync.error}\n\n${customCategoriesAsync.stackTrace}',
          style: const TextStyle(color: Colors.red),
          textAlign: TextAlign.center,
        ),
      );
    }
    if (customCategoriesAsync.isLoading && !customCategoriesAsync.hasValue) {
      return const Center(child: CircularProgressIndicator());
    }

    final allCategories = (customCategoriesAsync.value ?? [])
        .where((c) => c.type == type)
        .toList();

    return ListView.builder(
      padding: EdgeInsets.all(AppTheme.sp16),
      itemCount: allCategories.length,
      itemBuilder: (context, index) {
        final cat = allCategories[index];
        return FadeSlideIn(
          delay: Duration(milliseconds: 100 + (index * 50)),
          child: Container(
            margin: EdgeInsets.only(bottom: AppTheme.sp12),
            padding: EdgeInsets.all(AppTheme.sp16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  child: Icon(
                    cat.icon,
                    size: 20,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                SizedBox(width: AppTheme.sp16),
                Expanded(
                  child: Text(cat.name, style: AppTheme.titleMedium(context)),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedPressable(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => _CategoryFormSheet(
                            type: type,
                            categoryToEdit: cat,
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.edit_outlined,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedPressable(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text('Hapus Kategori?'),
                            content: Text(
                              'Apakah Anda yakin ingin menghapus kategori "${cat.name}"?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: Text(
                                  'Batal',
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(ctx);
                                  ref
                                      .read(categoryProvider)
                                      .deleteCategory(cat.id);
                                },
                                child: Text(
                                  'Hapus',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(Icons.delete_outline, color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CategoryFormSheet extends ConsumerStatefulWidget {
  final TransactionType type;
  final CategoryItem? categoryToEdit;

  const _CategoryFormSheet({required this.type, this.categoryToEdit});

  @override
  ConsumerState<_CategoryFormSheet> createState() => _CategoryFormSheetState();
}

class _CategoryFormSheetState extends ConsumerState<_CategoryFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  IconData _selectedIcon = Icons.star_border_rounded;

  // Simple grid of icons for the user to pick
  final List<IconData> _availableIcons = [
    Icons.star_border_rounded,
    Icons.favorite_border_rounded,
    Icons.fastfood_outlined,
    Icons.local_cafe_outlined,
    Icons.shopping_cart_outlined,
    Icons.directions_car_outlined,
    Icons.flight_takeoff_outlined,
    Icons.pets_outlined,
    Icons.home_outlined,
    Icons.laptop_chromebook_outlined,
    Icons.phone_iphone_outlined,
    Icons.fitness_center_outlined,
    Icons.school_outlined,
    Icons.account_balance_wallet_outlined,
    Icons.monetization_on_outlined,
    Icons.redeem_outlined,
    Icons.receipt_long_outlined,
    Icons.trending_up_rounded,
    Icons.trending_down_rounded,
    Icons.card_giftcard_outlined,
    Icons.videogame_asset_outlined,
    Icons.movie_outlined,
    Icons.music_note_outlined,
    Icons.palette_outlined,
    Icons.child_friendly_outlined,
    Icons.local_hospital_outlined,
    Icons.spa_outlined,
    Icons.build_outlined,
    Icons.camera_alt_outlined,
    Icons.electric_bolt_outlined,
  ];

  @override
  void initState() {
    super.initState();
    if (widget.categoryToEdit != null) {
      _nameController.text = widget.categoryToEdit!.name;
      _selectedIcon = widget.categoryToEdit!.icon;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool _isLoading = false;

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        if (widget.categoryToEdit != null) {
          // Update existing
          final updatedCategory = widget.categoryToEdit!.copyWith(
            name: _nameController.text.trim(),
            icon: _selectedIcon,
          );
          await ref.read(categoryProvider).updateCategory(updatedCategory);
        } else {
          // Create new
          final newCategory = CategoryItem(
            id: const Uuid().v4(),
            name: _nameController.text.trim(),
            icon: _selectedIcon,
            type: widget.type,
          );
          await ref.read(categoryProvider).addCategory(newCategory);
        }
        if (mounted) Navigator.pop(context);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menyimpan kategori: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

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
              // Handle
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

              Text(
                widget.categoryToEdit != null
                    ? 'EDIT KATEGORI'
                    : 'KATEGORI BARU',
                style: AppTheme.headlineMedium(
                  context,
                ).copyWith(letterSpacing: 2),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppTheme.sp24),

              // Name Input
              TextFormField(
                controller: _nameController,
                style: AppTheme.bodyLarge(
                  context,
                ).copyWith(color: Theme.of(context).colorScheme.onSurface),
                decoration: InputDecoration(
                  labelText: 'NAMA KATEGORI',
                  labelStyle: AppTheme.labelSmall(context).copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
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
                validator: (val) => val == null || val.isEmpty
                    ? 'Masukkan nama kategori'
                    : null,
              ),
              SizedBox(height: AppTheme.sp24),

              Text(
                'PILIH IKON',
                style: AppTheme.labelSmall(context).copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              SizedBox(height: AppTheme.sp12),

              // Icon Grid
              SizedBox(
                height: 200,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    crossAxisSpacing: AppTheme.sp12,
                    mainAxisSpacing: AppTheme.sp12,
                  ),
                  itemCount: _availableIcons.length,
                  itemBuilder: (context, index) {
                    final icon = _availableIcons[index];
                    final isSelected = icon == _selectedIcon;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedIcon = icon),
                      child: AnimatedContainer(
                        duration: AppTheme.fast,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context).colorScheme.onSurface
                              : Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusSm,
                          ),
                        ),
                        child: Icon(
                          icon,
                          color: isSelected
                              ? Theme.of(context).colorScheme.surface
                              : Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: AppTheme.sp24),

              SizedBox(
                height: 56,
                child: FilledButton(
                  onPressed: _isLoading ? null : _save,
                  style: FilledButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: AppTheme.sp16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          'SIMPAN',
                          style: AppTheme.titleMedium(context).copyWith(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
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
