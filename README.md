# Pixelated Sound

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Build Status](https://img.shields.io/badge/build-passing-brightgreen.svg)]()

A creative audio-visual experiment that transforms live webcam footage into pixelated visuals and generates corresponding sound waves based on pixel colors. Built with Zig, OpenCV, and PortAudio, this project captures video, pixelates it, maps RGB values to frequencies, and outputs the result as a WAV file.

## Features

- **Real-time Webcam Processing**: Captures and pixelates live video feed using OpenCV.
- **Color-to-Sound Mapping**: Converts RGB pixel values into audible frequencies.
- **Audio Generation**: Produces a WAV file from generated sound samples using PortAudio.
- **Cross-Platform**: Designed to work on macOS with Homebrew dependencies (adaptable to other systems).
- **Modular Design**: Separate C++ libraries (`libwebcam.dylib`, `libsound.dylib`) interfaced with Zig.

## Prerequisites

Before building, ensure you have the following installed:

- [Zig](https://ziglang.org/download/) (latest version recommended)
- [Homebrew](https://brew.sh/) (for macOS dependency management)
- OpenCV: `brew install opencv`
- PortAudio: `brew install portaudio`
- Clang++ (included with Xcode or Command Line Tools on macOS)

## Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/lazycodebaker/pixelated_wav_opencv.git
   cd pixelated_sound
   ```

2. Build the project:

   ```bash
   zig build
   ```

   This compiles the C++ libraries (`libsound.dylib`, `libwebcam.dylib`) and the main executable (`pixelated_sound`).

3. Run the application:

   ```bash
   zig build run
   ```

   The program will:

   - Open your webcam.
   - Display a pixelated feed in a window titled "Pixelated Frame".
   - Generate sound based on pixel colors.
   - Save the audio output to `output.wav` (max 15 seconds).

## Usage

- Press `q` while the window is focused to exit the pixelated feed display.
- The resulting `output.wav` file will be written to the project root.
- Modify `PIXEL_SIZE` in `src/main.zig` to adjust pixelation granularity (default: 20).

## Project Structure

```
pixelated_sound/
├── build.zig          # Zig build script
├── src/
│   └── main.zig       # Main application logic
├── cpp/
│   ├── sound.cpp      # PortAudio sound library source
│   └── webcam.cpp     # OpenCV webcam library source
├── include/
│   ├── libsound.h     # Sound library header
│   └── libwebcam.h    # Webcam library header
├── lib/
│   ├── libsound.dylib # Compiled sound library
│   └── libwebcam.dylib# Compiled webcam library
└── README.md          # This file
```

## How It Works

1. **Video Capture**: The `libwebcam.dylib` library uses OpenCV to capture webcam frames and pixelate them.
2. **Color Mapping**: RGB values from each pixel block are mapped to frequency ranges (200–1000 Hz for red, 1000–2000 Hz for green, 2000–4000 Hz for blue).
3. **Sound Generation**: Sine waves are generated for each color channel, averaged, and appended to a sample buffer.
4. **Audio Output**: Samples are written to a WAV file with a 44.1 kHz sample rate.

## Customization

- **Frequency Ranges**: Adjust `colorToFrequencies` in `src/main.zig` to change the sound mapping.
- **Duration**: Modify `DURATION` (default: 0.1s) or `max_duration` (default: 15s) in `src/main.zig`.
- **Pixelation**: Tweak `PIXEL_SIZE` for finer or coarser pixelation.

## Troubleshooting

- **Webcam Fails to Open**: Ensure your webcam is connected and accessible. Check permissions on macOS.
- **Library Linking Errors**: Verify OpenCV and PortAudio paths match your Homebrew installation (e.g., `/opt/homebrew/`).
- **No Sound Output**: Confirm `output.wav` is generated and contains valid data (open in an audio player).

## Contributing

Contributions are welcome! Please:

1. Fork the repo.
2. Create a feature branch (`git checkout -b feature/amazing-idea`).
3. Commit your changes (`git commit -m "Add amazing idea"`).
4. Push to the branch (`git push origin feature/amazing-idea`).
5. Open a pull request.

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.

## Acknowledgments

- [Zig](https://ziglang.org/) for a modern, safe systems programming language.
- [OpenCV](https://opencv.org/) for computer vision capabilities.
- [PortAudio](http://www.portaudio.com/) for cross-platform audio I/O.
