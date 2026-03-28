#include "metronome.h"
#include <oboe/Oboe.h>
#include <math.h>

using namespace oboe;

class Metronome : public AudioStreamCallback {
public:
    double bpm = 120.0;
    double sampleRate = 48000.0;
    int beatsPerBar = 4;

    double samplesPerBeat;
    double sampleCounter = 0;

    int clickRemaining = 0;
    double frequency = 1000.0;
    int beat = 0;
    TickCallback tickCallback = nullptr; 

    Metronome(double bpm_) : bpm(bpm_) {
        samplesPerBeat = sampleRate * 60.0 / bpm;
    }

    void setBpm(double newBpm) {
        bpm = newBpm;
        samplesPerBeat = sampleRate * 60.0 / bpm;
    }

    void setBeatsPerBar(int newBeatsPerBar) {
        beatsPerBar = newBeatsPerBar;
    }

    DataCallbackResult onAudioReady(AudioStream *stream,
                                    void *audioData,
                                    int32_t numFrames) override {

        float *out = static_cast<float*>(audioData);

        for (int i = 0; i < numFrames; i++) {

            if (sampleCounter >= samplesPerBeat) {
                sampleCounter -= samplesPerBeat;

                clickRemaining = 200;

                frequency = (beat % beatsPerBar == 0) ? 1500.0 : 1000.0;
                
                if (tickCallback) {
                    tickCallback(beat % beatsPerBar);
                }

                beat++;
            }

            float sample = 0.0f;

            if (clickRemaining > 0) {
                double t = (double)clickRemaining / sampleRate;

                sample = (float)(
                    0.8 *
                    sin(2.0 * M_PI * frequency * t) *
                    (clickRemaining / 200.0)
                );

                clickRemaining--;
            }

            *out++ = sample;
            sampleCounter++;
        }

        return DataCallbackResult::Continue;
    }
};

// Global instance
static Metronome *gMetronome = nullptr;
static AudioStream *gStream = nullptr;
static TickCallback gTickCallback = nullptr;

extern "C" {

void start_metronome(double bpm) {
    if (gStream) return;

    gMetronome = new Metronome(bpm);

    AudioStreamBuilder builder;
    builder.setDirection(Direction::Output);
    builder.setPerformanceMode(PerformanceMode::LowLatency);
    builder.setSharingMode(SharingMode::Exclusive);
    builder.setFormat(AudioFormat::Float);
    builder.setChannelCount(1);
    builder.setCallback(gMetronome);

    builder.openStream(&gStream);

    gMetronome->sampleRate = gStream->getSampleRate();
    gMetronome->setBpm(bpm);
    gMetronome->tickCallback = gTickCallback;

    gStream->requestStart();
}

void stop_metronome() {
    if (!gStream) return;

    gStream->stop();
    gStream->close();

    delete gMetronome;

    gStream = nullptr;
    gMetronome = nullptr;
}

void set_bpm(double bpm) {
    if (gMetronome) {
        gMetronome->setBpm(bpm);
    }
}

void set_beats_per_bar(int beatsPerBar) {
    if (gMetronome) {
        gMetronome->setBeatsPerBar(beatsPerBar);
    }
}

void set_tick_callback(TickCallback callback) {
    gTickCallback = callback;
    if (gMetronome) {
        gMetronome->tickCallback = callback;
    }
}

}