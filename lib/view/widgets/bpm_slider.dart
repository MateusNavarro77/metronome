import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:metronome/blocs/metronome/metronome_bloc.dart';
import 'package:metronome/shared/constants.dart';

class BpmSlider extends StatelessWidget {
  const BpmSlider({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MetronomeBloc, MetronomeState>(
      buildWhen: (previous, current) => previous.bpm != current.bpm,
      builder: (context, state) {
        return Slider(
          value: state.bpm.toDouble(),
          min: kMinBpm.toDouble(),
          max: kMaxBpm.toDouble(),
          onChanged: (value) {
            context.read<MetronomeBloc>().add(
              MetronomeBpmChanged(bpm: value.round()),
            );
          },
        );
      },
    );
  }
}
