import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:metronome/blocs/metronome/metronome_bloc.dart';
import 'package:metronome/blocs/theme/theme_bloc.dart';
import 'package:metronome/view/widgets/pulse_button.dart';

class MetronomeControls extends StatelessWidget {
  const MetronomeControls({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Theme toggle
        BlocBuilder<ThemeBloc, ThemeState>(
          builder: (context, state) {
            return IconButton(
              onPressed: () => context.read<ThemeBloc>().add(ThemeToggled()),
              icon: Icon(
                state is ThemeDark
                    ? Icons.light_mode_outlined
                    : Icons.dark_mode_outlined,
              ),
            );
          },
        ),

        // Play / Pause ("Pulse Button")
        BlocBuilder<MetronomeBloc, MetronomeState>(
          buildWhen:
              (previous, current) => previous.isRunning != current.isRunning,
          builder: (context, state) {
            return PulseButton(
              isPlaying: state.isRunning,
              onPressed: () {
                if (state.isRunning) {
                  context.read<MetronomeBloc>().add(MetronomePaused());
                  return;
                }
                context.read<MetronomeBloc>().add(MetronomePlayed());
              },
            );
          },
        ),

        // Accent toggle
        BlocBuilder<MetronomeBloc, MetronomeState>(
          buildWhen:
              (previous, current) =>
                  previous.accentOnFirstBeat != current.accentOnFirstBeat,
          builder: (context, state) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Switch(
                  value: state.accentOnFirstBeat,
                  onChanged: (value) {
                    context.read<MetronomeBloc>().add(
                      MetronomeAccentFirstBeatToggled(),
                    );
                  },
                ),
                const SizedBox(height: 4),
                Text('ACCENT', style: textTheme.labelSmall),
              ],
            );
          },
        ),
      ],
    );
  }
}
