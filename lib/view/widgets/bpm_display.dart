import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:metronome/blocs/metronome/metronome_bloc.dart';

class BpmDisplay extends StatelessWidget {
  const BpmDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BlocBuilder<MetronomeBloc, MetronomeState>(
      builder: (context, state) {
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: () {
                    context.read<MetronomeBloc>().add(
                      MetronomeBpmDecremented(),
                    );
                  },
                  icon: const Icon(Icons.remove),
                ),

                Text('${state.bpm}', style: textTheme.displayLarge),

                IconButton(
                  onPressed: () {
                    context.read<MetronomeBloc>().add(
                      MetronomeBpmIncremented(),
                    );
                  },
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text('BPM', style: textTheme.labelMedium),
          ],
        );
      },
    );
  }
}
