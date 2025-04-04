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