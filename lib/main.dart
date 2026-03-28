import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:metronome/blocs/metronome/metronome_bloc.dart';
import 'package:metronome/blocs/theme/theme_bloc.dart';
import 'package:metronome/data/audio_player_impl.dart';
import 'package:metronome/data/metronome_impl.dart';
import 'package:metronome/view/app_widget.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory:
        kIsWeb
            ? HydratedStorageDirectory.web
            : HydratedStorageDirectory((await getTemporaryDirectory()).path),
  );
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<ThemeBloc>(create: (context) => ThemeBloc()),
        BlocProvider<MetronomeBloc>(
          create: (context) {
            return MetronomeBloc(
              metronome: MetronomeImpl(),
            );
          },
        ),
      ],
      child: const AppWidget(),
    ),
  );
}
