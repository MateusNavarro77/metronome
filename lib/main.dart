import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/repositories/metronome_repository.dart';
import 'data/services/metronome_engine.dart';
import 'data/services/soloud_metronome_engine.dart';
import 'ui/core/theme/sonic_theme.dart';
import 'ui/features/metronome/view_models/metronome_view_model.dart';
import 'ui/features/metronome/views/metronome_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MetronomeApp());
}

/// Root application widget wiring Dependency Injection via `package:provider`
/// and applying "The Sonic Architect" theme (`DESIGN.md`).
class MetronomeApp extends StatelessWidget {
  const MetronomeApp({
    super.key,
    this.engineOverride,
  });

  /// Optional [MetronomeEngine] override for widget and integration testing.
  final MetronomeEngine? engineOverride;

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
        ChangeNotifierProxyProvider<MetronomeRepository, MetronomeViewModel>(
          create: (context) => MetronomeViewModel(
            repository: context.read<MetronomeRepository>(),
          ),
          update: (_, repository, previous) =>
              previous ?? MetronomeViewModel(repository: repository),
        ),
      ],
      child: MaterialApp(
        title: 'Metronome',
        debugShowCheckedModeBanner: false,
        theme: SonicTheme.darkTheme,
        darkTheme: SonicTheme.darkTheme,
        themeMode: ThemeMode.dark,
        home: Consumer<MetronomeViewModel>(
          builder: (context, viewModel, _) {
            return MetronomeView(viewModel: viewModel);
          },
        ),
      ),
    );
  }
}
