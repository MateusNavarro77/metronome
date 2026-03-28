#pragma once

#ifdef __cplusplus
extern "C" {
#endif

typedef void (*TickCallback)(int);

void start_metronome(double bpm);
void stop_metronome();
void set_bpm(double bpm);
void set_beats_per_bar(int beatsPerBar);
void set_tick_callback(TickCallback callback);

#ifdef __cplusplus
}
#endif