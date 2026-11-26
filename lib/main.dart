import 'dart:async';

import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart'
    hide CornerRounding, RoundedPolygon;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/repositories/metronome_repository.dart';
import 'data/repositories/preferences_repository.dart';
import 'data/repositories/preset_library_repository.dart';
import 'data/services/app_info_service.dart';
import 'data/services/audio_service_background_playback_service.dart';
import 'data/services/background_playback_coordinator.dart';
import 'data/services/background_playback_service.dart';
import 'data/services/metronome_engine.dart';
import 'data/services/soloud_metronome_engine.dart';
import 'data/services/url_launcher_service.dart';
import 'data/services/wakelock_coordinator.dart';
import 'data/services/wakelock_plus_service.dart';
import 'data/services/wakelock_service.dart';
import 'domain/models/app_theme_mode.dart';
import 'l10n/app_localizations.dart';
import 'ui/core/l10n/l10n_extensions.dart';
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
    this.backgroundPlaybackServiceOverride,
    this.wakelockServiceOverride,
    this.appInfoServiceOverride,
    this.urlLauncherServiceOverride,
    this.preferences,
  });

  /// Optional [MetronomeEngine] override for widget and integration testing.
  final MetronomeEngine? engineOverride;

  /// Optional [PreferencesRepository] override for testing.
  final PreferencesRepository? preferencesRepositoryOverride;

  /// Optional [PresetLibraryRepository] override for testing.
  final PresetLibraryRepository? presetLibraryRepositoryOverride;

  /// Optional [BackgroundPlaybackService] override for testing.
  final BackgroundPlaybackService? backgroundPlaybackServiceOverride;

  /// Optional [WakelockService] override for testing.
  final WakelockService? wakelockServiceOverride;

  /// Optional [AppInfoService] override for testing.
  final AppInfoService? appInfoServiceOverride;

  /// Optional [UrlLauncherService] override for testing.
  final UrlLauncherService? urlLauncherServiceOverride;

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
        Provider<BackgroundPlaybackService>(
          create: (_) =>
              backgroundPlaybackServiceOverride ??
              (engineOverride != null
                  ? NoopBackgroundPlaybackService()
                  : AudioServiceBackgroundPlaybackService()),
          dispose: (_, service) => service.dispose(),
        ),
        Provider<WakelockService>(
          create: (_) =>
              wakelockServiceOverride ??
              (engineOverride != null
                  ? NoopWakelockService()
                  : WakelockPlusService()),
          dispose: (_, service) => service.dispose(),
        ),
        ProxyProvider3<
          MetronomeRepository,
          PreferencesRepository,
          WakelockService,
          WakelockCoordinator
        >(
          lazy: false,
          update:
              (
                _,
                metronomeRepository,
                preferencesRepository,
                wakelockService,
                previous,
              ) {
                return previous ??
                    WakelockCoordinator(
                      metronomeRepository: metronomeRepository,
                      preferencesRepository: preferencesRepository,
                      wakelockService: wakelockService,
                    );
              },
          dispose: (_, coordinator) => coordinator.dispose(),
        ),
        ProxyProvider4<
          MetronomeRepository,
          PreferencesRepository,
          PresetLibraryRepository,
          BackgroundPlaybackService,
          BackgroundPlaybackCoordinator
        >(
          lazy: false,
          update:
              (
                _,
                metronomeRepository,
                preferencesRepository,
                presetLibraryRepository,
                backgroundService,
                previous,
              ) {
                if (previous != null) return previous;
                final coordinator = BackgroundPlaybackCoordinator(
                  metronomeRepository: metronomeRepository,
                  preferencesRepository: preferencesRepository,
                  presetLibraryRepository: presetLibraryRepository,
                  backgroundService: backgroundService,
                );
                unawaited(coordinator.initialize());
                return coordinator;
              },
          dispose: (_, coordinator) => coordinator.dispose(),
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
        ChangeNotifierProxyProvider4<
          PreferencesRepository,
          MetronomeRepository,
          BackgroundPlaybackCoordinator,
          WakelockCoordinator,
          PreferencesViewModel
        >(
          create: (context) => PreferencesViewModel(
            repository: context.read<PreferencesRepository>(),
            metronomeRepository: context.read<MetronomeRepository>(),
            backgroundPlaybackCoordinator: context
                .read<BackgroundPlaybackCoordinator>(),
            wakelockCoordinator: context.read<WakelockCoordinator>(),
            appInfoService: appInfoServiceOverride,
            urlLauncherService: urlLauncherServiceOverride,
          ),
          update:
              (
                _,
                repository,
                metronomeRepository,
                backgroundPlaybackCoordinator,
                wakelockCoordinator,
                previous,
              ) =>
                  previous ??
                  PreferencesViewModel(
                    repository: repository,
                    metronomeRepository: metronomeRepository,
                    backgroundPlaybackCoordinator:
                        backgroundPlaybackCoordinator,
                    wakelockCoordinator: wakelockCoordinator,
                    appInfoService: appInfoServiceOverride,
                    urlLauncherService: urlLauncherServiceOverride,
                  ),
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
          final backgroundCoordinator = context
              .read<BackgroundPlaybackCoordinator>();
          final wakelockCoordinator = context.read<WakelockCoordinator>();
          return _M3EAppHost(
            themeMode: preferencesViewModel.themeMode,
            locale: preferencesViewModel.materialLocale,
            onAppBackgrounded: () {
              unawaited(backgroundCoordinator.onAppBackgrounded());
              unawaited(wakelockCoordinator.onAppBackgrounded());
            },
            onAppResumed: () => unawaited(wakelockCoordinator.onAppResumed()),
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
  const _M3EAppHost({
    required this.themeMode,
    required this.locale,
    required this.home,
    this.onAppBackgrounded,
    this.onAppResumed,
  });

  final AppThemeMode themeMode;
  final Locale? locale;
  final Widget home;
  final VoidCallback? onAppBackgrounded;
  final VoidCallback? onAppResumed;

  @override
  State<_M3EAppHost> createState() => _M3EAppHostState();
}

class _M3EAppHostState extends State<_M3EAppHost> {
  late final M3EThemeController _themeController;
  late final AppLifecycleListener _lifecycleListener;
  late final M3EThemeData _lightThemeData;
  late final ThemeData _lightTheme;
  late final ThemeData _darkTheme;

  @override
  void initState() {
    super.initState();
    _themeController = M3EThemeController();
    _lifecycleListener = AppLifecycleListener(
      onPause: () => widget.onAppBackgrounded?.call(),
      onResume: () => widget.onAppResumed?.call(),
    );
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
    _lifecycleListener.dispose();
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
      onGenerateTitle: (context) => context.l10n.appTitle,
      debugShowCheckedModeBanner: false,
      locale: widget.locale,
      localizationsDelegates: appLocalizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
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
