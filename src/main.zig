const std = @import("std");

const webcam = @cImport({
    @cInclude("libwebcam.h");
});
 
// const sound = @cImport({
//    @cInclude("libsound.h");
//});

const SAMPLE_RATE = 44100;
const DURATION = 0.1;
const PIXEL_SIZE = 20;

fn generateTone(freq: f32, duration: f32, allocator: std.mem.Allocator) ![]f32 {
    const sampleCount = @as(u32, @intFromFloat(@as(f32, @floatFromInt(SAMPLE_RATE)) * duration));
    const pi = 3.1415926;
    const buffer = try allocator.alloc(f32, sampleCount);
    var i: usize = 0;
    for (buffer) |*val| {
        const t = @as(f32, @floatFromInt(i)) / SAMPLE_RATE;
        const wave = @sin(2.0 * pi * freq * t);
        val.* = if (wave > 0.0) 0.3 else -0.3;
        i += 1;
    }
    return buffer;
}

fn colorToFrequencies(r: u8, g: u8, b: u8) [3]f32 {
    return .{
        200 + (@as(f32, @floatFromInt(r)) / 255.0) * 800,
        1000 + (@as(f32, @floatFromInt(g)) / 255.0) * 1000,
        2000 + (@as(f32, @floatFromInt(b)) / 255.0) * 2000,
    };
}

const wavHeaderSize = 44;

fn writeWav(filename: []const u8, samples: []f32) !void {
    const file = try std.fs.cwd().createFile(filename, .{ .truncate = true });
    defer file.close();

    const writer = file.writer();

    const sampleRate = SAMPLE_RATE;
    const numSamples = samples.len;
    const numChannels = 1;
    const bitsPerSample = 16;
    const byteRate = sampleRate * numChannels * bitsPerSample / 8;
    const blockAlign = numChannels * bitsPerSample / 8;
    const dataSize = numSamples * bitsPerSample / 8;
    const chunkSize = 36 + dataSize;

    try writer.writeAll("RIFF");
    try writer.writeInt(u32, @intCast(chunkSize), .little);
    try writer.writeAll("WAVE");

    // fmt subchunk
    try writer.writeAll("fmt ");
    try writer.writeInt(u32, 16, .little); // PCM header size
    try writer.writeInt(u16, 1, .little); // PCM format
    try writer.writeInt(u16, numChannels, .little);
    try writer.writeInt(u32, sampleRate, .little);
    try writer.writeInt(u32, byteRate, .little);
    try writer.writeInt(u16, blockAlign, .little);
    try writer.writeInt(u16, bitsPerSample, .little);

    // data subchunk
    try writer.writeAll("data");
    try writer.writeInt(u32, @intCast(dataSize), .little);

    // convert f32 [-1, 1] to i16 [-32768, 32767]
    for (samples) |sample| {
        const scaled: i16 = @intFromFloat(std.math.clamp(sample, -1.0, 1.0) * 32767.0);
        try writer.writeInt(i16, scaled, .little);
    }
}

pub fn main() !void {
    // sound.init_audio();
    if (!webcam.init_camera(0)) {
        std.debug.print("Error: Failed to open webcam using wrapper.\n", .{});
        return;
    }

    std.debug.print("Webcam initialized successfully.\n", .{});

    var width: c_int = 0;
    var height: c_int = 0;
    var channels: c_int = 30;

    const _frame = webcam.get_frame(&width, &height, &channels);
    if (_frame == null) {
        std.debug.print("Error: Failed to get frame.\n", .{});
    } else {
        std.debug.print("Got frame: {d}x{d}, channels: {d}\n", .{ width, height, channels });
    }

    defer webcam.release_camera();

    const allocator = std.heap.page_allocator;

    var all_samples = std.ArrayList(f32).init(allocator);
    defer all_samples.deinit();

    var sample_counter: usize = 0;

    const max_duration = 15.0;
    const max_samples = @as(usize, @intFromFloat(SAMPLE_RATE)) * @as(usize, @intFromFloat(max_duration));

    while (true) {
        const frame = webcam.get_pixelated_frame(&width, &height, &channels, PIXEL_SIZE);
        if (frame == null) {
            std.debug.print("Error: No frame\n", .{});
            continue;
        }

        webcam.show_frame_from_data(frame, width, height, channels, "Pixelated Frame");
        defer std.debug.print("Frame released\n", .{});

        // const total_pixels = @as(u32, width * height);
        // var sound_blocks = std.ArrayList(f32).init(std.heap.page_allocator);
        //const pixel_stride = @as(u32, channels); // * PIXEL_SIZE * PIXEL_SIZE);

        if (channels < 0) return;

        const pixel_stride = @as(u32, @intCast(channels));

        const row_stride = @as(u32, @as(u32, @intCast(width)) * pixel_stride);
        // const byte_ptr = @as(*u8, frame);
        const frame_size = @as(usize, @intCast(width * height * channels));

        std.debug.print("Frame size: {d}\n", .{frame_size});
        std.debug.print("Row stride: {d}\n", .{row_stride});
        std.debug.print("Pixel stride: {d}\n", .{pixel_stride});
        std.debug.print("Width: {d}\n", .{width});
        std.debug.print("Height: {d}\n", .{height});
        std.debug.print("Channels: {d}\n", .{channels});

        const byte_ptr: *u8 = @ptrCast(frame);

        std.debug.print("Byte pointer: {p}\n", .{byte_ptr}); // Byte pointer: u8@148068000

        const many_ptr: [*]u8 = @ptrCast(frame);
        // Then create the slice with runtime bounds
        const data = many_ptr[0..frame_size];

        std.debug.print("Data pointer Length : {d}\n", .{data.len}); // Data pointer Length: 0

        var tones = std.ArrayList(f32).init(allocator);
        defer tones.deinit();

        var y: usize = 0;

        while (y < @as(usize, @intCast(height))) : (y += PIXEL_SIZE) {
            var x: usize = 0;

            while (x < @as(usize, @intCast(width))) : (x += PIXEL_SIZE) {
                const index = y * row_stride + x * pixel_stride;

                const r: u8 = data[index];
                const g: u8 = data[index + 1];
                const b: u8 = data[index + 2];

                const freqs = colorToFrequencies(r, g, b);

                const r_tone = try generateTone(freqs[0], DURATION, allocator);
                const g_tone = try generateTone(freqs[1], DURATION, allocator);
                const b_tone = try generateTone(freqs[2], DURATION, allocator);

                for (r_tone, 0..) |r_val, i| {
                    const avg = (r_val + g_tone[i] + b_tone[i]) / 3.0;
                    try tones.append(avg);
                }

                allocator.free(r_tone);
                allocator.free(g_tone);
                allocator.free(b_tone);
            }
        }

        if (tones.items.len > 0) {
            if (all_samples.items.len < max_samples) {
                try all_samples.appendSlice(tones.items);
                sample_counter += tones.items.len;
            } else {
                std.debug.print("Max samples reached, not writing to file.\n", .{});
                break;
            }
        }

        if (sample_counter >= max_samples) {
            std.debug.print("Max samples reached, not writing to file.\n", .{});
            break;
        }
    }
    webcam.release_camera();

    try writeWav("output.wav", all_samples.items);
    std.debug.print("Wrote WAV file with {d} samples.\n", .{all_samples.items.len});
}
