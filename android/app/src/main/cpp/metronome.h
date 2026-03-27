#pragma once

#ifdef __cplusplus
extern "C" {
#endif

void start_metronome(double bpm);
void stop_metronome();
void set_bpm(double bpm);

#ifdef __cplusplus
}
#endif