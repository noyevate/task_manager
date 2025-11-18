import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/providers/theme_cubit.dart';

class ThemeToggle extends StatelessWidget {
  const ThemeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        return IconButton(
          icon: Icon(state.isDarkMode ? Icons.dark_mode : Icons.light_mode),
          onPressed: () => context.read<ThemeCubit>().toggleTheme(),
          tooltip: 'Toggle theme',
        );
      },
    );
  }
}
