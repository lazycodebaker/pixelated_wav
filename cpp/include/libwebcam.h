// libwebcam.h
#ifndef LIBWEBCAM_H
#define LIBWEBCAM_H

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

    bool init_camera(int index);
    unsigned char *get_frame(int *width, int *height, int *channels);
    void release_camera();
    void show_pixelated_camera(int pixel_size);
    unsigned char *get_pixelated_frame(int *width, int *height, int *channels, int pixel_size);
    void show_frame_from_data(const unsigned char *data, int width, int height, int channels, const char *window_name);

#ifdef __cplusplus
}
#endif

#endif // LIBWEBCAM_H
