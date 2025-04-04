// webcam.cpp
#include <opencv2/opencv.hpp>
#include "include/libwebcam.h"

static cv::VideoCapture cap;
static cv::Mat frame;

extern "C"
{

    bool init_camera(int index)
    {
        return cap.open(index);
    }

    unsigned char *get_frame(int *width, int *height, int *channels)
    {
        if (!cap.isOpened())
            return nullptr;

        cap >> frame;
        if (frame.empty())
            return nullptr;

        *width = frame.cols;
        *height = frame.rows;
        *channels = frame.channels();

        return frame.data;
    }

    unsigned char *get_pixelated_frame(int *width, int *height, int *channels, int pixel_size)
    {
        if (!cap.isOpened())
            return nullptr;

        cap >> frame;
        if (frame.empty())
            return nullptr;

        cv::Mat small;
        cv::resize(frame, small, cv::Size(frame.cols / pixel_size, frame.rows / pixel_size), 0, 0, cv::INTER_NEAREST);
        cv::resize(small, frame, cv::Size(frame.cols, frame.rows), 0, 0, cv::INTER_NEAREST);

        *width = frame.cols;
        *height = frame.rows;
        *channels = frame.channels();

        return frame.data;
    }

    void show_frame_from_data(const unsigned char *data, int width, int height, int channels, const char *window_name)
    {
        if (data == nullptr || width <= 0 || height <= 0 || channels <= 0)
            return;

        cv::Mat image(height, width, channels == 3 ? CV_8UC3 : CV_8UC1, const_cast<unsigned char *>(data));
        cv::imshow(window_name, image);

        if (cv::waitKey(1) == 'q') 
        {
            cv::destroyWindow(window_name);
            return;
        }

        cv::waitKey(1);
    }

    void show_pixelated_camera(int pixel_size)
    {
        if (!cap.isOpened())
        {
            cap.open(0);
        }

        if (!cap.isOpened())
        {
            printf("Error: Unable to open camera.\n");
            return;
        }

        const char *window_name = "Whispering Pixels (C++ View)";
        cv::namedWindow(window_name, cv::WINDOW_AUTOSIZE);

        while (true)
        {
            cap >> frame;
            if (frame.empty())
                break;

            // Downsample
            cv::Mat small;
            cv::resize(frame, small, cv::Size(frame.cols / pixel_size, frame.rows / pixel_size), 0, 0, cv::INTER_NEAREST);

            // Upsample
            cv::Mat pixelated;
            cv::resize(small, pixelated, cv::Size(frame.cols, frame.rows), 0, 0, cv::INTER_NEAREST);

            // Show the pixelated frame
            cv::imshow(window_name, pixelated);

            if (cv::waitKey(1) == 'q')
                break;
        }

        cv::destroyWindow(window_name);
    }

    void release_camera()
    {
        if (cap.isOpened())
            cap.release();
    }
}
