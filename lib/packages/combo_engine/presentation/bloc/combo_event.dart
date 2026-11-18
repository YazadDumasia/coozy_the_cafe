part of 'combo_bloc.dart';

sealed class ComboEvent extends Equatable {
  const ComboEvent();

  @override
  List<Object?> get props => [];
}

class LoadCombosEvent extends ComboEvent {
  final String? searchQuery;
  final bool? onlyActive;
  final int limit;
  final int offset;

  const LoadCombosEvent({
    this.searchQuery,
    this.onlyActive,
    this.limit = 20,
    this.offset = 0,
  });

  @override
  List<Object?> get props => [searchQuery, onlyActive, limit, offset];
}

class SaveComboEvent extends ComboEvent {
  final Combo combo;

  const SaveComboEvent(this.combo);

  @override
  List<Object?> get props => [combo];
}

class DeleteComboEvent extends ComboEvent {
  final int id;

  const DeleteComboEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class ToggleComboStatusEvent extends ComboEvent {
  final int id;
  final bool isActive;

  const ToggleComboStatusEvent({required this.id, required this.isActive});

  @override
  List<Object?> get props => [id, isActive];
}

class ReorderCombosEvent extends ComboEvent {
  final int oldIndex;
  final int newIndex;

  const ReorderCombosEvent({required this.oldIndex, required this.newIndex});

  @override
  List<Object?> get props => [oldIndex, newIndex];
}
