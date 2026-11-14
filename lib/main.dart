import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/repositories/metronome_repository.dart';
import 'data/repositories/preferences_repository.dart';
import 'data/repositories/preset_library_repository.dart';
import 'data/services/metronome_engine.dart';
import 'data/services/soloud_metronome_engine.dart';
import 'ui/core/theme/sonic_theme.dart';
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
/// and applying "The Sonic Architect" light and dark themes
/// (`specs/DESIGN_DARK.md`, `specs/DESIGN_LIGHT.md`).
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
          return MaterialApp(
            title: 'Metronome',
            debugShowCheckedModeBanner: false,
            theme: SonicTheme.lightTheme,
            darkTheme: SonicTheme.darkTheme,
            themeMode: preferencesViewModel.materialThemeMode,
            home: Consumer<MetronomeViewModel>(
              builder: (context, metronomeViewModel, _) {
                return AdaptiveNavigationShell(
                  metronomeViewModel: metronomeViewModel,
                );
              },
            ),
          );
        },
      ),
    );
  }
}
