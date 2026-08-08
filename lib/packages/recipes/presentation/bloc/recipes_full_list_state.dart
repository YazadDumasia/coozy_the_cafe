part of 'recipes_full_list_cubit.dart';

sealed class RecipesFullListState extends Equatable {
  const RecipesFullListState();

  @override
  List<Object?> get props => <Object?>[];
}

class RecipesInitialState extends RecipesFullListState {}

class RecipesLoadingState extends RecipesFullListState {
  final double? progress;
  final String? message;
  final int? currentProgress;
  final int? totalProgress;

  const RecipesLoadingState({
    this.progress,
    this.message,
    this.currentProgress,
    this.totalProgress,
  });

  @override
  List<Object?> get props => [
    progress,
    message,
    currentProgress,
    totalProgress,
  ];
}

class RecipesLoadedState extends RecipesFullListState {
  final List<Recipe>? list;
  final List<Recipe>? paginatedData;
  final List<AppliedFilterModel>? appliedFilterList;
  final int? currentPage;
  final int? itemsPerPage;
  final int? totalPages;
  final int? totalElements;
  final List<int>? itemsPerPageList;
  final int? startIndex;
  final int? endIndex;
  final bool? isInternalLoading;

  const RecipesLoadedState({
    required this.appliedFilterList,
    this.list,
    this.paginatedData,
    this.currentPage,
    this.itemsPerPage,
    this.totalPages,
    this.totalElements,
    this.itemsPerPageList,
    this.startIndex,
    this.endIndex,
    this.isInternalLoading = false,
  });

  RecipesLoadedState copyWith({
    List<Recipe>? list,
    List<Recipe>? paginatedData,
    List<AppliedFilterModel>? appliedFilterList,
    int? currentPage,
    int? itemsPerPage,
    int? totalPages,
    int? totalElements,
    List<int>? itemsPerPageList,
    int? startIndex,
    int? endIndex,
    bool? isInternalLoading,
  }) {
    return RecipesLoadedState(
      list: list ?? this.list,
      paginatedData: paginatedData ?? this.paginatedData,
      appliedFilterList: appliedFilterList ?? this.appliedFilterList,
      currentPage: currentPage ?? this.currentPage,
      itemsPerPage: itemsPerPage ?? this.itemsPerPage,
      totalPages: totalPages ?? this.totalPages,
      totalElements: totalElements ?? this.totalElements,
      itemsPerPageList: itemsPerPageList ?? this.itemsPerPageList,
      startIndex: startIndex ?? this.startIndex,
      endIndex: endIndex ?? this.endIndex,
      isInternalLoading: isInternalLoading ?? this.isInternalLoading,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    list,
    paginatedData,
    appliedFilterList,
    currentPage,
    itemsPerPage,
    totalPages,
    totalElements,
    itemsPerPageList,
    startIndex,
    endIndex,
    isInternalLoading,
  ];
}

class RecipesErrorState extends RecipesFullListState {
  final String? errorMessage;
  const RecipesErrorState(this.errorMessage);

  @override
  List<Object?> get props => <Object?>[errorMessage];
}

class NoInternetRecipesState extends RecipesFullListState {}
