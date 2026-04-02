import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:metronome/blocs/metronome/metronome_bloc.dart';

class BpmDisplay extends StatelessWidget {
  const BpmDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BlocBuilder<MetronomeBloc, MetronomeState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                colorScheme.primary.withValues(alpha: 0.08),
                Colors.transparent,
              ],
              radius: 0.8,
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Decrement button
                  IconButton(
                    onPressed: () {
                      context.read<MetronomeBloc>().add(
                        MetronomeBpmDecremented(),
                      );
                    },
                    icon: const Icon(Icons.remove),
                  ),

                  // BPM value (hero element)
                  Text('${state.bpm}', style: textTheme.displayLarge),

                  // Increment button
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
          ),
        );
      },
    );
  }
}
