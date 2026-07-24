part of 'filter_cubit.dart';

class FilterState extends Equatable {
  const FilterState({
    required this.filters,
    required this.activeFilterIndex,
    this.type,
  });

  const FilterState.init({
    required this.filters,
    required this.activeFilterIndex,
    this.type,
  });
  final List<FilterListModel>? filters;
  final int activeFilterIndex;
  final FilterType? type;

  FilterState copyWith({
    List<FilterListModel>? filters,
    int? activeFilterIndex,
    FilterType? type,
  }) {
    return FilterState(
      activeFilterIndex: activeFilterIndex ?? this.activeFilterIndex,
      filters: filters ?? this.filters,
      type: type ?? this.type,
    );
  }

  @override
  List<Object?> get props => <Object?>[filters, activeFilterIndex, type];
}
