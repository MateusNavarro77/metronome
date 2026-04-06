import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:metronome/blocs/theme/theme_bloc.dart';
import 'package:metronome/shared/app_theme.dart';
import 'package:metronome/view/pages/home_page.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Metronome',
          themeMode: state is ThemeDark ? ThemeMode.dark : ThemeMode.light,
          darkTheme: AppTheme.darkTheme,
          theme: AppTheme.lightTheme,
          home: const HomePage(),
        );
      },
    );
  }
}
