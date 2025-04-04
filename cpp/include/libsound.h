// libsound.h
#ifndef LIBSOUND_H
#define LIBSOUND_H

#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <errno.h>
#include <sys/mman.h>
#include <sys/stat.h>

#ifdef __cplusplus
extern "C"
{
#endif

    void init_audio();
    void play_samples(const float *samples, int count);
    void terminate_audio();

#ifdef __cplusplus
}
#endif

#endif // LIBSOUND_H
