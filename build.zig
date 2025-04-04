const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    // VARIABLES
    const lib_dir = "lib";
    const include_dir = "cpp/include";
    const homebrew_include = "/opt/homebrew/include";
    const homebrew_lib = "/opt/homebrew/lib";
    const libwebcam_dir = "lib/libwebcam.dylib";
    const libs_dir = "lib/libsound.dylib";

    // Step to build libsound.dylib
    const build_sound = b.addSystemCommand(&.{
        "clang++",
        "-dynamiclib",
        "-o",
        "lib/libsound.dylib",
        "cpp/sound.cpp",
        "-Ilib",
        "-I",
        homebrew_include,
        "-L",
        homebrew_lib,
        "-lportaudio",
    });
    build_sound.setName("build-sound");

    // Step to build libwebcam.dylib
    const build_webcam = b.addSystemCommand(&.{
        "sh", "-c",
        \\ clang++ -dynamiclib -o lib/libwebcam.dylib cpp/webcam.cpp -Ilib -I/opt/homebrew/include -L/opt/homebrew/lib -lportaudio `pkg-config --cflags --libs opencv4`
    });
    build_webcam.setName("build-webcam");

    // const raylib_dep = b.dependency("raylib_zig", .{
    //    .target = target,
    //    .optimize = optimize,
    //});

    // const raylib = raylib_dep.module("raylib");
    // const raygui = raylib_dep.module("raygui");
    // const raylib_artifact = raylib_dep.artifact("raylib");

    const exe = b.addExecutable(.{
        .name = "pixelated_sound",
        .root_module = exe_mod,
    });

    // Raylib
    // exe.linkLibrary(raylib_artifact);
    // exe.root_module.addImport("raylib", raylib);
    // exe.root_module.addImport("raygui", raygui);

    // OpenCV
    // exe.addIncludePath(.{ .cwd_relative = "/opt/homebrew/Cellar/opencv/4.11.0_1/include/opencv4/" });
    // exe.addLibraryPath(.{ .cwd_relative = "/opt/homebrew/Cellar/opencv/4.11.0_1/lib" });
    // exe.linkSystemLibrary("opencv_core");
    // exe.linkSystemLibrary("opencv_videoio");
    // exe.linkSystemLibrary("opencv_imgproc");

    // clang++ -dynamiclib -o lib/libsound.dylib cpp/libsound.cpp -Ilib -I/opt/homebrew/include -L/opt/homebrew/lib -lportaudio

    // PortAudio
    // exe.addIncludePath(.{ .cwd_relative = "/opt/homebrew/include" });
    // exe.addLibraryPath(.{ .cwd_relative = "/opt/homebrew/lib" });
    // exe.addIncludePath(.{ .cwd_relative = "/opt/homebrew/Cellar/portaudio/19.7.0/include/" });
    // exe.addLibraryPath(.{ .cwd_relative = "/opt/homebrew/Cellar/portaudio/19.7.0/lib" });
    // exe.linkSystemLibrary("portaudio");
    // wrapper .dylib
    // exe.addLibraryPath(.{ .cwd_relative = "/Users/lazycodebaker/Desktop/pixelated_sound/lib/" });

    exe.addRPath(.{ .cwd_relative = include_dir });
    exe.addRPath(.{ .cwd_relative = lib_dir });
    exe.addIncludePath(.{ .cwd_relative = include_dir });

    // testing webcam
    exe.addObjectFile(.{ .cwd_relative = libwebcam_dir });

    // lib sound -> portaudio use
    exe.addObjectFile(.{ .cwd_relative = libs_dir });

    exe.linkLibC(); // Required for C library interop

    // Build steps dependency
    exe.step.dependOn(&build_sound.step);
    exe.step.dependOn(&build_webcam.step);

    //  Install
    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
