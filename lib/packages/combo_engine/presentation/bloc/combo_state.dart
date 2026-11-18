part of 'combo_bloc.dart';

sealed class ComboState extends Equatable {
  const ComboState();

  @override
  List<Object?> get props => [];
}

class ComboInitialState extends ComboState {
  const ComboInitialState();
}

class ComboLoadingState extends ComboState {
  const ComboLoadingState();
}

class ComboLoadedState extends ComboState {
  final List<Combo> combos;
  final bool hasReachedMax;
  final String? searchQuery;

  const ComboLoadedState({
    required this.combos,
    this.hasReachedMax = false,
    this.searchQuery,
  });

  ComboLoadedState copyWith({
    List<Combo>? combos,
    bool? hasReachedMax,
    String? searchQuery,
  }) {
    return ComboLoadedState(
      combos: combos ?? this.combos,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [combos, hasReachedMax, searchQuery];
}

class ComboActionSuccessState extends ComboState {
  final String message;

  const ComboActionSuccessState(this.message);

  @override
  List<Object?> get props => [message];
}

class ComboErrorState extends ComboState {
  final String errorMessage;

  const ComboErrorState(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}
