//! These tests kinda don't work for now, and I don't know how to fix them
const gnuzplot = @import("gnuzplot");
const std = @import("std");
const print = std.debug.print;
const Gnuzplot = gnuzplot.Gnuzplot;

test "\t methods, \t .init \n" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    print("Apparently, for now, there is no way to fail spawning\n", .{});
    const plt = try Gnuzplot.init(allocator);
    _ = plt;
}

test "\t methods, \t .cmd (print pwd message and exit\n" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    var plt = try Gnuzplot.init(allocator);
    try plt.cmd("pwd");
    try plt.exit();
}

test "\t methods, \t .cmdfmt (print pwd message and exits\n" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    var plt = try Gnuzplot.init(allocator);
    try plt.cmdfmt("{s}\n", .{"pwd"});
    try plt.exit();
}

test "\t methods, \t .exit \n" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    var plt = try Gnuzplot.init(allocator);
    try plt.exit();
}

test "\t methods, \t .figPos \n" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    var plt = try Gnuzplot.init(allocator);
    try plt.figPos(40, 40);
    try plt.exit();
}

test "\t methods, \t .figSize \n" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    var plt = try Gnuzplot.init(allocator);
    try plt.figSize(40, 40);
    try plt.exit();
}

test "\t methods, \t .gridOff \n" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    var plt = try Gnuzplot.init(allocator);
    try plt.gridOff();
    try plt.exit();
}

test "\t methods, \t .gridOn \n" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    var plt = try Gnuzplot.init(allocator);
    try plt.gridOn();
    try plt.exit();
}

test "\t methods, \t .pause \n" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    var plt = try Gnuzplot.init(allocator);
    try plt.pause(0.5);
    try plt.exit();
}

test "\t methods, \t .pauseQuiet \n" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    var plt = try Gnuzplot.init(allocator);
    try plt.pauseQuiet(0.5);
    try plt.exit();
}

test "\t methods, \t .plot (single vector) \n" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();

    const x = [_]f32{ 1.1, -0.3, 2.2, -0.1 };

    const allocator = arena.allocator();
    var plt = try Gnuzplot.init(allocator);
    try plt.pauseQuiet(1);

    try plt.plot(.{ x, "title 'x' with lines ls 4 lw 3" });
    try plt.pauseQuiet(1.0);
    try plt.exit();
}

test "\t methods, \t .plot (multiple vectors) \n" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();

    const x = [_]f32{ 1.1, -0.3, 2.2, -0.1 };
    const y = [_]f32{ -1.3, 0.2, 1.2, 0.1 };
    const z = [_]f32{ 1.7, -0.9, -2.2, -0.3 };

    const allocator = arena.allocator();
    var plt = try Gnuzplot.init(allocator);
    try plt.pauseQuiet(0.2);

    try plt.plot(.{
        x, "title 'x' with lines ls 1 lw 1",
        y, "title 'y' with lines ls 2 lw 2",
        z, "title 'z' with lines ls 3 lw 3",
    });
    try plt.pauseQuiet(1.0);
    try plt.exit();
}

test "\t methods, \t .plotXY (y vs. x) \n" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();

    const x = [_]f32{ 1.1, -0.3, 2.2, 0.1 };
    const y = [_]f32{ -1.3, 0.2, 1.2, 0.1 };

    const allocator = arena.allocator();
    var plt = try Gnuzplot.init(allocator);
    try plt.pauseQuiet(0.2);

    try plt.plotXY(.{
        x,
        y,
        "title 'y vs. x' with lines lw 5",
    });
    try plt.pauseQuiet(1.0);
    try plt.exit();
}

test "\t methods, \t .title, .xLabel, .yLabel (with a sample plot) \n" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();

    const x = [_]f32{ 1.1, -0.3, 2.2, -0.1 };

    const allocator = arena.allocator();
    var plt = try Gnuzplot.init(allocator);
    try plt.pauseQuiet(0.2);

    try plt.title("This is the title");
    try plt.xLabel("This is the xLabel");
    try plt.yLabel("This is the yLabel");
    try plt.plot(.{ x, "title 'x' with lines ls 4 lw 3" });
    try plt.pauseQuiet(2.0);
    try plt.exit();
}

test "\t methods, \t .bar (of single vector) \n" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();

    const x = [_]f32{ 1.1, -0.3, 2.2, -0.1 };
    const width = 0.8;

    const allocator = arena.allocator();
    var plt = try Gnuzplot.init(allocator);
    try plt.pauseQuiet(0.2);

    try plt.bar(.{ x, width, "title 'x'" });
    try plt.pauseQuiet(1.0);
    try plt.exit();
}

test "\t methods, \t .bar (shared bar plot - multiple vectors) \n" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();

    const x = [_]f32{ 1.1, -0.3, 2.2, -0.1 };
    const y = [_]f32{ -1.3, 0.2, 1.2, 0.1 };
    const z = [_]f32{ 1.7, -0.9, -2.2, -0.3 };
    const width = 0.5;

    const allocator = arena.allocator();
    var plt = try Gnuzplot.init(allocator);
    try plt.pauseQuiet(0.2);

    try plt.bar(.{
        x, width, "title 'x' ls 33 ",
        y, width, "title 'y' ls 44 ",
        z, width, "title 'z' ls 55 ",
    });

    try plt.pauseQuiet(2.0);
    try plt.exit();
}

test "debug_mode for cmd and cmdfmt" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    var plt = try Gnuzplot.init(allocator);
    plt.debug_mode = true;
    try plt.cmd("pwd");
    try plt.cmdfmt("{s}\n", .{"pwd"});
    try plt.exit();
}

test "splot with nonunified matrix" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    var plt = try Gnuzplot.init(allocator);
    const xs = [_]f64{ 1.0, 2.5, 3.0 };
    const ys = [_]f64{ 1.0, 1.5, 3.0 };
    const zs = [_][3]f64{
        .{ 10.0, 5.0, 3.0 },
        .{ 6.0, 5.0, 8.0 },
        .{ 3.1, 8.1, 10.5 },
    };
    try plt.splot(.{
        xs, ys, zs, "with lines title 'test splot'",
    });
    try plt.pauseQuiet(3.0);
    try plt.exit();
}
