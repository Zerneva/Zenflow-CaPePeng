import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category.dart';
import 'transaction_provider.dart';

final categoriesStreamProvider = StreamProvider.autoDispose<List<CategoryItem>>(
  (ref) async* {
    final firebaseService = ref.watch(firebaseServiceProvider);
    await firebaseService.ensureCategoriesSeeded();
    yield* firebaseService.getCategoriesStream();
  },
);

class CategoryService {
  final Ref ref;
  CategoryService(this.ref);

  Future<void> addCategory(CategoryItem category) async {
    final firebaseService = ref.read(firebaseServiceProvider);
    await firebaseService.addCategory(category);
  }

  Future<void> updateCategory(CategoryItem category) async {
    final firebaseService = ref.read(firebaseServiceProvider);
    await firebaseService.updateCategory(category);
  }

  Future<void> deleteCategory(String id) async {
    final firebaseService = ref.read(firebaseServiceProvider);
    await firebaseService.deleteCategory(id);
  }
}

final categoryProvider = Provider.autoDispose<CategoryService>((ref) {
  return CategoryService(ref);
});
