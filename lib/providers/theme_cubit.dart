// lib/blocs/theme_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:hive/hive.dart';

class ThemeState {
  final bool isDarkMode;
  const ThemeState({required this.isDarkMode});
}

class ThemeCubit extends Cubit<ThemeState> {
  static const _boxName = 'settings_box';
  static const _keyIsDark = 'is_dark_mode';

  late Box _box;

  ThemeCubit() : super(const ThemeState(isDarkMode: false)) {
    _init();
  }

  Future<void> _init() async {
    if (!Hive.isBoxOpen(_boxName)) {
      _box = await Hive.openBox(_boxName);
    } else {
      _box = Hive.box(_boxName);
    }

    final isDark = _box.get(_keyIsDark, defaultValue: false) as bool;
    emit(ThemeState(isDarkMode: isDark));
  }

  Future<void> toggleTheme() async {
    final newVal = !state.isDarkMode;
    await _box.put(_keyIsDark, newVal);
    emit(ThemeState(isDarkMode: newVal));
  }
}
