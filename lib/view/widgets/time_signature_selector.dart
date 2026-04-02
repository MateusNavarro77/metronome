import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:metronome/blocs/metronome/metronome_bloc.dart';
import 'package:metronome/view/widgets/time_signature_picker.dart';

class TimeSignatureSelector extends StatelessWidget {
  const TimeSignatureSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BlocBuilder<MetronomeBloc, MetronomeState>(
      buildWhen:
          (previous, current) => previous.beatsPerBar != current.beatsPerBar,
      builder: (context, state) {
        return GestureDetector(
          onTap: () async {
            final result = await TimeSignaturePicker.show(
              context,
              state.beatsPerBar,
            );
            if (result != null && context.mounted) {
              context.read<MetronomeBloc>().add(
                MetronomeBeatsPerBarChanged(beatsPerBar: result),
              );
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _beatsPerBarToLabel(state.beatsPerBar),
                  style: textTheme.titleSmall,
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.unfold_more,
                  color: colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _beatsPerBarToLabel(int beatsPerBar) {
    const map = {
      2: '2/4',
      3: '3/4',
      4: '4/4',
      5: '5/4',
      6: '6/8',
      7: '7/8',
      9: '9/8',
      12: '12/8',
    };
    return map[beatsPerBar] ?? '$beatsPerBar/4';
  }
}
