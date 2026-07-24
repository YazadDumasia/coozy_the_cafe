part of 'theme_bloc.dart';

sealed class ThemeEvent extends Equatable {
  const ThemeEvent();
}

final class ThemeLoadRequested extends ThemeEvent {
  @override
  List<Object?> get props => [];
}

class ThemeToggleRequested extends ThemeEvent {
  final bool? isDarkMode;
  const ThemeToggleRequested(this.isDarkMode);

  @override
  List<Object?> get props => [isDarkMode];
}

class ThemeSelected extends ThemeEvent {
  final ThemeMode? themeMode;
  const ThemeSelected(this.themeMode);

  @override
  List<Object?> get props => [themeMode];
}
