#include "include/libsound.h"
#include <portaudio.h>
#include <stdlib.h>
#include <string.h>

#define SAMPLE_RATE 44100

static PaStream *stream;

void init_audio()
{
    Pa_Initialize();
    Pa_OpenDefaultStream(&stream, 0, 1, paFloat32, SAMPLE_RATE, 256, NULL, NULL);
    Pa_StartStream(stream);
}

void play_samples(const float *samples, int count)
{
    Pa_WriteStream(stream, samples, count);
}

void terminate_audio()
{
    Pa_StopStream(stream);
    Pa_CloseStream(stream);
    Pa_Terminate();
}


// /opt/homebrew/Cellar/portaudio/19.7.0
// clang++ -dynamiclib -o lib/libsound.dylib cpp/sound.cpp -Ilib -I/opt/homebrew/include -L/opt/homebrew/lib -lportaudio
// clang++ -dynamiclib -o lib/libwebcam.dylib cpp/webcam.cpp -Ilib -I/opt/homebrew/include -L/opt/homebrew/lib -lportaudio  `pkg-config --cflags --libs opencv4`
