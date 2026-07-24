import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

import '../../coozy_shared.dart';

part 'theme_event.dart';
part 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(const ThemeState(themeMode: ThemeMode.light)) {
    on<ThemeEvent>((event, emit) async {
      if (event is ThemeLoadRequested) {
        await _onLoadTheme(event, emit);
      } else if (event is ThemeToggleRequested) {
        await _onToggleTheme(event, emit);
      } else if (event is ThemeSelected) {
        await _onThemeSelected(event, emit);
      }
    });
  }

  Future<void> _onLoadTheme(
    ThemeLoadRequested event,
    Emitter<ThemeState> emit,
  ) async {
    final bool isDarkMode = LocalManager.instance.getBoolValue(
      key: PreferencesKeys.appEnableDarkTheme,
    );

    final ThemeMode theme = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    emit(ThemeState(themeMode: theme));
  }

  Future<void> _onToggleTheme(
    ThemeToggleRequested event,
    Emitter<ThemeState> emit,
  ) async {
    if (event.isDarkMode == true) {
      await LocalManager.instance.setBoolValue(
        key: PreferencesKeys.appEnableDarkTheme,
        value: true,
      );
      emit(const ThemeState(themeMode: ThemeMode.dark));
    } else {
      await LocalManager.instance.setBoolValue(
        key: PreferencesKeys.appEnableDarkTheme,
        value: false,
      );
      emit(const ThemeState(themeMode: ThemeMode.light));
    }
  }

  Future<void> _onThemeSelected(
    ThemeSelected event,
    Emitter<ThemeState> emit,
  ) async {
    if (event.themeMode == ThemeMode.dark) {
      await LocalManager.instance.setBoolValue(
        key: PreferencesKeys.appEnableDarkTheme,
        value: true,
      );
      emit(const ThemeState(themeMode: ThemeMode.dark));
    } else if (event.themeMode == ThemeMode.light) {
      await LocalManager.instance.setBoolValue(
        key: PreferencesKeys.appEnableDarkTheme,
        value: false,
      );
      emit(const ThemeState(themeMode: ThemeMode.light));
    } else if (event.themeMode == ThemeMode.system) {
      await LocalManager.instance.setBoolValue(
        key: PreferencesKeys.appEnableDarkTheme,
        value: false,
      );
      emit(const ThemeState(themeMode: ThemeMode.system));
    } else {
      await LocalManager.instance.setBoolValue(
        key: PreferencesKeys.appEnableDarkTheme,
        value: false,
      );
      emit(const ThemeState(themeMode: ThemeMode.light));
    }
  }
}
