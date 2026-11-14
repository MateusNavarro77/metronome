import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart'
    hide CornerRounding, RoundedPolygon;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/repositories/metronome_repository.dart';
import 'data/repositories/preferences_repository.dart';
import 'data/repositories/preset_library_repository.dart';
import 'data/services/metronome_engine.dart';
import 'data/services/soloud_metronome_engine.dart';
import 'domain/models/app_theme_mode.dart';
import 'ui/core/theme/app_theme.dart';
import 'ui/features/metronome/view_models/metronome_view_model.dart';
import 'ui/features/navigation/views/adaptive_navigation_shell.dart';
import 'ui/features/preferences/view_models/preferences_view_model.dart';
import 'ui/features/presets/view_models/presets_view_model.dart';
import 'ui/features/setlists/view_models/setlists_view_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();
  runApp(MetronomeApp(preferences: preferences));
}

/// Root application widget wiring Dependency Injection via `package:provider`
/// and applying Material 3 Expressive theming (`package:material_3_expressive`).
class MetronomeApp extends StatelessWidget {
  const MetronomeApp({
    super.key,
    this.engineOverride,
    this.preferencesRepositoryOverride,
    this.presetLibraryRepositoryOverride,
    this.preferences,
  });

  /// Optional [MetronomeEngine] override for widget and integration testing.
  final MetronomeEngine? engineOverride;

  /// Optional [PreferencesRepository] override for testing.
  final PreferencesRepository? preferencesRepositoryOverride;

  /// Optional [PresetLibraryRepository] override for testing.
  final PresetLibraryRepository? presetLibraryRepositoryOverride;

  /// Optional [SharedPreferences] instance from entrypoint.
  final SharedPreferences? preferences;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<MetronomeEngine>(
          create: (_) => engineOverride ?? SoloudMetronomeEngine(),
          dispose: (_, engine) => engine.dispose(),
        ),
        ProxyProvider<MetronomeEngine, MetronomeRepository>(
          update: (_, engine, previous) =>
              previous ?? MetronomeRepository(engine: engine),
          dispose: (_, repo) => repo.dispose(),
        ),
        Provider<PreferencesRepository>(
          create: (_) =>
              preferencesRepositoryOverride ??
              PreferencesRepository(preferences: preferences),
        ),
        Provider<PresetLibraryRepository>(
          create: (_) =>
              presetLibraryRepositoryOverride ??
              PresetLibraryRepository(preferences: preferences),
          dispose: (_, repo) => repo.dispose(),
        ),
        ChangeNotifierProxyProvider3<
          MetronomeRepository,
          PreferencesRepository,
          PresetLibraryRepository,
          MetronomeViewModel
        >(
          create: (context) => MetronomeViewModel(
            repository: context.read<MetronomeRepository>(),
            preferencesRepository: context.read<PreferencesRepository>(),
            presetLibraryRepository: context.read<PresetLibraryRepository>(),
          ),
          update:
              (_, repository, preferencesRepository, presetLibrary, previous) =>
                  previous ??
                  MetronomeViewModel(
                    repository: repository,
                    preferencesRepository: preferencesRepository,
                    presetLibraryRepository: presetLibrary,
                  ),
        ),
        ChangeNotifierProxyProvider<
          PreferencesRepository,
          PreferencesViewModel
        >(
          create: (context) => PreferencesViewModel(
            repository: context.read<PreferencesRepository>(),
          ),
          update: (_, repository, previous) =>
              previous ?? PreferencesViewModel(repository: repository),
        ),
        ChangeNotifierProxyProvider2<
          PresetLibraryRepository,
          MetronomeViewModel,
          PresetsViewModel
        >(
          create: (context) => PresetsViewModel(
            repository: context.read<PresetLibraryRepository>(),
            metronomeViewModel: context.read<MetronomeViewModel>(),
          ),
          update: (_, repository, metronomeViewModel, previous) =>
              previous ??
              PresetsViewModel(
                repository: repository,
                metronomeViewModel: metronomeViewModel,
              ),
        ),
        ChangeNotifierProxyProvider2<
          PresetLibraryRepository,
          MetronomeViewModel,
          SetlistsViewModel
        >(
          create: (context) => SetlistsViewModel(
            repository: context.read<PresetLibraryRepository>(),
            metronomeViewModel: context.read<MetronomeViewModel>(),
          ),
          update: (_, repository, metronomeViewModel, previous) =>
              previous ??
              SetlistsViewModel(
                repository: repository,
                metronomeViewModel: metronomeViewModel,
              ),
        ),
      ],
      child: Consumer<PreferencesViewModel>(
        builder: (context, preferencesViewModel, _) {
          return _M3EAppHost(
            themeMode: preferencesViewModel.themeMode,
            home: Builder(
              builder: (context) {
                return AdaptiveNavigationShell(
                  metronomeViewModel: context.read<MetronomeViewModel>(),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _M3EAppHost extends StatefulWidget {
  const _M3EAppHost({required this.themeMode, required this.home});

  final AppThemeMode themeMode;
  final Widget home;

  @override
  State<_M3EAppHost> createState() => _M3EAppHostState();
}

class _M3EAppHostState extends State<_M3EAppHost> {
  late final M3EThemeController _themeController;
  late final M3EThemeData _lightThemeData;
  late final ThemeData _lightTheme;
  late final ThemeData _darkTheme;

  @override
  void initState() {
    super.initState();
    _themeController = M3EThemeController();
    _lightThemeData = AppTheme.lightThemeData;
    _lightTheme = _lightThemeData.toThemeData();
    _darkTheme = AppTheme.darkThemeData.toThemeData();
    _syncController(widget.themeMode);
  }

  @override
  void didUpdateWidget(covariant _M3EAppHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.themeMode != widget.themeMode) {
      _syncController(widget.themeMode);
    }
  }

  @override
  void dispose() {
    _themeController.dispose();
    super.dispose();
  }

  void _syncController(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.system:
        _themeController.followSystem();
      case AppThemeMode.light:
        _themeController.setBrightness(Brightness.light);
      case AppThemeMode.dark:
        _themeController.setBrightness(Brightness.dark);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool autoTheming = widget.themeMode == AppThemeMode.system;
    final Brightness? initialTheme = switch (widget.themeMode) {
      AppThemeMode.system => null,
      AppThemeMode.light => Brightness.light,
      AppThemeMode.dark => Brightness.dark,
    };

    return M3EMaterialApp(
      title: 'Metronome',
      debugShowCheckedModeBanner: false,
      data: _lightThemeData,
      theme: _lightTheme,
      darkTheme: _darkTheme,
      autoTheming: autoTheming,
      dynamicColoring: false,
      initialTheme: initialTheme,
      controller: _themeController,
      home: widget.home,
    );
  }
}
