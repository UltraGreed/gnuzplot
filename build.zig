const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // library module ------------------------------------------------
    const gnuzplot_mod = b.addModule("gnuzplot", .{
        .root_source_file = b.path("src/gnuzplot.zig"),
        .target = target,
        .optimize = optimize,
    });

    // example executable --------------------------------------------
    const exe_example = b.addExecutable(.{
        .name = "examples",
        .root_source_file = b.path("example/examples.zig"),
        .target = target,
        .optimize = optimize,
    });
    exe_example.root_module.addImport("gnuzplot", gnuzplot_mod);

    b.installArtifact(exe_example);

    const run_cmd = b.addRunArtifact(exe_example);
    run_cmd.setCwd(.{ .cwd_relative = "example/" });

    const run_step = b.step("run", "Run example program parser");
    run_step.dependOn(&run_cmd.step);

    // unit tests ----------------------------------------------------
    const unit_tests = b.addTest(.{
        .root_source_file = b.path("./test/main_test.zig"),
        .target = target,
        .optimize = optimize,
    });

    unit_tests.root_module.addImport("gnuzplot", gnuzplot_mod);

    const unit_tests_step = b.step("test", "Run unit tests");
    unit_tests_step.dependOn(&unit_tests.step);
}
