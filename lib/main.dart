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
        BlocProvider<ThemeBloc>(create: (context) => ThemeBloc()),
        BlocProvider<MetronomeBloc>(
          create: (context) {
            return MetronomeBloc(metronome: MetronomeImpl());
          },
        ),
      ],
      child: const AppWidget(),
    ),
  );
}
