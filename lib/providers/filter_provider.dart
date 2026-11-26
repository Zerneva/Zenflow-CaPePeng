import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void update(String query) => state = query;
}

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(() {
  return SearchQueryNotifier();
});

// Time Filter (Month and Year)
class TimeFilter {
  final int month;
  final int year;

  TimeFilter({required this.month, required this.year});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TimeFilter && other.month == month && other.year == year;
  }

  @override
  int get hashCode => month.hashCode ^ year.hashCode;
}

class TimeFilterNotifier extends Notifier<TimeFilter> {
  @override
  TimeFilter build() {
    final now = DateTime.now();
    return TimeFilter(month: now.month, year: now.year);
  }

  void update(TimeFilter filter) => state = filter;
}

final timeFilterProvider = NotifierProvider<TimeFilterNotifier, TimeFilter>(() {
  return TimeFilterNotifier();
});
