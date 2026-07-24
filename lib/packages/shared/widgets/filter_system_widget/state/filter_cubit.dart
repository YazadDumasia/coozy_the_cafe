import '../props/applied_filter_model.dart';
import '../props/filter_item_model.dart';
import '../props/filter_list_model.dart';
import '../props/filter_props.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart' as core;

part 'filter_state.dart';

class FilterCubit extends Cubit<FilterState> {
  FilterCubit({required this.filterProps})
    : super(
        FilterState.init(
          filters: filterProps.filters,
          activeFilterIndex: 0,
          type: filterProps.filters.first.type ?? FilterType.checkboxList,
        ),
      );

  final FilterProps filterProps;

  List<FilterListModel>? filters;
  int? activeFilterIndex;

  bool checked(List<FilterItemModel> items, FilterItemModel item) {
    return items.contains(item);
  }

  void onFilterTitleTap(int index) {
    activeFilterIndex = index;
    emit(
      state.copyWith(
        activeFilterIndex: index,
        type: filterProps.filters[index].type ?? FilterType.checkboxList,
      ),
    );
  }

  Future<void> onFilterItemCheck(dynamic item) async {
    final List<FilterListModel> filterModels = <FilterListModel>[
      ...?state.filters,
    ];
    final FilterListModel filterItem = filterModels[state.activeFilterIndex];
    List<FilterItemModel> checkedItems = <FilterItemModel>[
      ...filterItem.previousApplied,
    ];

    switch (filterItem.type) {
      case FilterType.checkboxList:
        {
          if (checkedItems.contains(item)) {
            checkedItems.remove(item);
          } else {
            checkedItems.add(item);
          }
        }
        break;
      case FilterType.radioGroup:
        {
          if (checkedItems.contains(item)) {
            checkedItems = <FilterItemModel>[];
          } else {
            checkedItems = <FilterItemModel>[item];
          }
        }
        break;
      case FilterType.slider:
        {
          checkedItems = <FilterItemModel>[item];
        }
        break;

      case FilterType.rangeSlider:
        {
          checkedItems = <FilterItemModel>[];
          for (FilterItemModel model in item) {
            checkedItems.add(model);
          }
        }
        break;
      case FilterType.datePicker:
        {
          if (item == null) {
            checkedItems = <FilterItemModel>[];
          } else {
            checkedItems.add(item);
          }
        }
        break;
      case FilterType.timePicker:
        {
          if (item == null) {
            checkedItems = <FilterItemModel>[];
          } else {
            checkedItems.add(item);
          }
        }
        break;
      case FilterType.rangeDatePicker:
        {
          if (item == null) {
            checkedItems = <FilterItemModel>[];
          } else {
            checkedItems = <FilterItemModel>[];
            for (FilterItemModel model in item) {
              checkedItems.add(model);
            }
          }
        }
        break;
      case FilterType.rangeTimePicker:
        break;

      default:
        break;
    }

    final FilterListModel updatedItem = filterItem.copyWith(
      previousApplied: checkedItems,
    );

    filterModels[state.activeFilterIndex] = updatedItem;
    filters = filterModels;
    emit(state.copyWith(filters: filterModels));
  }

  void onFilterSubmit() {
    final List<AppliedFilterModel> appliedFilters = <AppliedFilterModel>[];
    for (FilterListModel element in state.filters ?? []) {
      appliedFilters.add(
        AppliedFilterModel(
          filterKey: element.filterKey,
          applied: element.previousApplied,
          filterTitle: element.title,
        ),
      );
    }
    core.PlatformUtils.debugLog(
      FilterCubit,
      'appliedFilters:${appliedFilters.toString()}',
    );
    if (filterProps.onFilterChange != null) {
      filterProps.onFilterChange!(appliedFilters);
    }
  }

  void onFilterRemove() {
    final List<FilterListModel> clearFilterList = <FilterListModel>[];
    final List<FilterListModel> filtered = <FilterListModel>[...?state.filters];
    for (FilterListModel element in filtered) {
      final FilterListModel newModel = element.copyWith(
        previousApplied: <FilterItemModel>[],
      );
      clearFilterList.add(newModel);
    }
    emit(state.copyWith(filters: clearFilterList));
    if (filterProps.onFilterChange != null) {
      filterProps.onFilterChange!(<AppliedFilterModel>[]);
    }
  }

  void filterBySearch(String text) {
    if (text.isEmpty) {
      return;
    }
    final FilterListModel filteringItem =
        filterProps.filters[state.activeFilterIndex];
    final List<FilterItemModel> filterOption = <FilterItemModel>[
      ...filteringItem.filterOptions,
    ];
    if (filterOption.isNotEmpty) {
      final List<FilterItemModel> searchedItems = <FilterItemModel>[];
      for (FilterItemModel element in filterOption) {
        if (element.filterTitle.toLowerCase().contains(text.toLowerCase())) {
          searchedItems.add(element);
        }
      }
      final List<FilterListModel> filters = <FilterListModel>[
        ...?state.filters,
      ];

      final FilterListModel updatedItem = filters[state.activeFilterIndex]
          .copyWith(filterOptions: searchedItems);
      filters[state.activeFilterIndex] = updatedItem;
      emit(state.copyWith(filters: filters));
    }
  }

  void clearSearch() {
    final FilterListModel filteringItem =
        filterProps.filters[state.activeFilterIndex];
    final List<FilterItemModel> filterOption = <FilterItemModel>[
      ...filteringItem.filterOptions,
    ];
    if (filterOption.isNotEmpty) {
      final List<FilterItemModel> searchedItems = filterOption;

      final List<FilterListModel> filters = <FilterListModel>[
        ...?state.filters,
      ];

      final FilterListModel updatedItem = filters[state.activeFilterIndex]
          .copyWith(filterOptions: searchedItems);

      filters[state.activeFilterIndex] = updatedItem;
      emit(state.copyWith(filters: filters));
    }
  }
}

/*
import 'package:coozy_the_cafe/widgets/filter_system_widget/props/applied_filter_model.dart';
import 'package:coozy_the_cafe/widgets/filter_system_widget/props/filter_item_model.dart';
import 'package:coozy_the_cafe/widgets/filter_system_widget/props/filter_list_model.dart';
import 'package:rxdart/rxdart.dart';

class FilterCubit {
  final BehaviorSubject<int> _activeFilterIndexSubject = BehaviorSubject<int>();
  final BehaviorSubject<FilterType> _filterTypeSubject = BehaviorSubject<FilterType>();
  final BehaviorSubject<List<FilterListModel>> _filtersSubject = BehaviorSubject<List<FilterListModel>>();

  Stream<int> get activeFilterIndexStream => _activeFilterIndexSubject.stream;
  Stream<FilterType> get filterTypeStream => _filterTypeSubject.stream;
  Stream<List<FilterListModel>> get filtersStream => _filtersSubject.stream;

  FilterCubit({
    required List<FilterListModel> filters,
    required int activeFilterIndex,
    required FilterType filterType,
  }) {
    _filtersSubject.add(filters);
    _activeFilterIndexSubject.add(activeFilterIndex);
    _filterTypeSubject.add(filterType);
  }

  void setActiveFilterIndex(int index) {
    _activeFilterIndexSubject.add(index);
  }

  void setFilterType(FilterType type) {
    _filterTypeSubject.add(type);
  }

  void setFilters(List<FilterListModel> filters) {
    _filtersSubject.add(filters);
  }

  bool checked(List<FilterItemModel> items, FilterItemModel item) {
    return items.contains(item);
  }

  void onFilterItemCheck(var item) {
    final currentIndex = _activeFilterIndexSubject.value;
    final currentFilters = _filtersSubject.value ?? [];
    final currentFilter = currentFilters[currentIndex];
    final List<FilterItemModel> checkedItems = [...currentFilter.previousApplied];

    switch (currentFilter.type) {
      case FilterType.checkboxList:
        if (checkedItems.contains(item)) {
          checkedItems.remove(item);
        } else {
          checkedItems.add(item);
        }
        break;
      case FilterType.radioGroup:
        checkedItems.clear();
        checkedItems.add(item);
        break;
      case FilterType.slider:
        checkedItems.clear();
        checkedItems.add(item);
        break;
      case FilterType.rangeSlider:
        checkedItems.clear();
        for(int i=0;i<item!.lenght;i++){
          checkedItems.add(item[i]);
        }
        */
/*for (FilterItemModel model in item) {
          checkedItems.add(model);
        }*/ /*

        break;
      case FilterType.timePicker:
        break;
      case FilterType.rangeTimePicker:
        break;
      case FilterType.datePicker:
        break;
      case FilterType.rangeDatePicker:
        break;
      default:
        break;
    }

    final updatedItem = currentFilter.copyWith(previousApplied: checkedItems);
    final updatedFilters = List<FilterListModel>.from(currentFilters);
    updatedFilters[currentIndex] = updatedItem;

    _filtersSubject.add(updatedFilters);
  }

  void onFilterSubmit(Function(List<AppliedFilterModel>)? onFilterChange) {
    final currentFilters = _filtersSubject.value ?? [];
    final appliedFilters = <AppliedFilterModel>[];
    for (var element in currentFilters) {
      appliedFilters.add(AppliedFilterModel(
        filterKey: element.title,
        applied: element.previousApplied,
        filterTitle: element.title,
      ));
    }
    if (onFilterChange != null) {
      onFilterChange(appliedFilters);
    }
  }

  void onFilterRemove(Function(List<AppliedFilterModel>)? onFilterChange) {
    final currentFilters = _filtersSubject.value ?? [];
    final clearFilterList = <FilterListModel>[];
    for (var element in currentFilters) {
      final newModel = element.copyWith(
        previousApplied: [],
      );
      clearFilterList.add(newModel);
    }
    _filtersSubject.add(clearFilterList);
    if (onFilterChange != null) {
      onFilterChange([]);
    }
  }

  void filterBySearch(String text) {
    if (text.isEmpty) {
      return;
    }
    final currentFilters = _filtersSubject.value ?? [];
    final currentFilter = currentFilters[_activeFilterIndexSubject.value];
    final filterOptions = [...currentFilter.filterOptions];
    if (filterOptions.isNotEmpty) {
      List<FilterItemModel> searchedItems = [];
      for (var element in filterOptions) {
        if (element.filterTitle.toLowerCase().contains(text.toLowerCase())) {
          searchedItems.add(element);
        }
      }
      final updatedItem = currentFilter.copyWith(filterOptions: searchedItems);
      final updatedFilters = List<FilterListModel>.from(currentFilters);
      updatedFilters[_activeFilterIndexSubject.value] = updatedItem;
      _filtersSubject.add(updatedFilters);
    }
  }

  void clearSearch() {
    final currentFilters = _filtersSubject.value ?? [];
    final currentFilter = currentFilters[_activeFilterIndexSubject.value];
    final filterOptions = [...currentFilter.filterOptions];
    if (filterOptions.isNotEmpty) {
      final updatedItem = currentFilter.copyWith(filterOptions: filterOptions);
      final updatedFilters = List<FilterListModel>.from(currentFilters);
      updatedFilters[_activeFilterIndexSubject.value] = updatedItem;
      _filtersSubject.add(updatedFilters);
    }
  }

  void dispose() {
    _activeFilterIndexSubject.close();
    _filterTypeSubject.close();
    _filtersSubject.close();
  }

}*/
