import 'package:metronome/domain/disposable.dart';
import 'package:metronome/domain/tick.dart';

abstract interface class Metronome implements Disposable {
  int get bpm;
  bool get isRunning;
  int get beatsPerBar;
  void stop();
  void start();
  void setBpm(int bpm);
  void setBeatsPerBar(int beatsPerBar);
  Stream<Tick> tickStream();
}
