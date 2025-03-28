const std = @import("std");

const Allocator = std.mem.Allocator;
const stdout = std.io.getStdOut().writer();

const Child = std.process.Child;

const fields = std.meta.fields;
const colors = @import("matplotlib_colors.zig");

pub const Gnuzplot = struct {
    const Self = @This();

    g: Child,
    writer: std.fs.File.Writer,
    debug_mode: bool = false,

    pub fn init(allocator: Allocator) !Self {
        const child_name = "gnuplot";
        var g = Child.init(&[_][]const u8{child_name}, allocator);

        g.stdin_behavior = .Pipe;
        g.spawn() catch |err| {
            std.log.err("Could not spawn child process: {s}\n", .{child_name});
            return err;
        };

        // // ideally would like to verify if pid is up and running, but unclear how just now

        var writer = g.stdin.?.writer();

        try writer.print("set term qt size 1200, 900 position 20, 30\n", .{});
        try writer.print("set title font ',16'\n", .{});
        try writer.print("set grid\n", .{});
        try writer.print("{s}\n", .{colors.matplotlib_colors});

        return Self{
            .g = g,
            .writer = writer,
        };
    }

    // manually execute any gnuplot command with zig string formatting
    pub fn cmdfmt(self: *const Self, comptime fmt: []const u8, args: anytype) !void {
        if (self.debug_mode) {
            std.debug.print(fmt, args);
        }
        try self.writer.print(fmt, args);
    }

    // manually execute any gnuplot command with automatically added Enter
    pub fn cmd(self: *const Self, c: []const u8) !void {
        if (self.debug_mode) {
            std.debug.print("{s}\n", .{c});
        }
        try self.writer.print("{s}\n", .{c});
    }

    // clear the plot figure
    pub fn clear(self: *const Self) !void {
        try self.cmdfmt("clear\n", .{});
    }

    // close gnuplot child process
    pub fn exit(self: *const Self) !void {
        try self.cmdfmt("exit\n", .{});
    }

    // place figure window on screen
    pub fn figPos(self: *const Self, x: i64, y: i64) !void {
        try self.cmdfmt("set term qt position {d} , {d} \n", .{ x, y });
    }

    // size figure window
    pub fn figSize(self: *const Self, wid: i64, ht: i64) !void {
        try self.cmdfmt("set term qt size {d} , {d} \n", .{ wid, ht });
    }

    // remove grid from the plot
    pub fn gridOff(self: *const Self) !void {
        try self.cmdfmt("unset grid\n", .{});
    }

    // place a grid on the plot
    pub fn gridOn(self: *const Self) !void {
        try self.cmdfmt("set grid\n", .{});
    }

    // pause both parent zig process and child gnuplot process (maintain sync)
    // prints a message to stdout terminal
    pub fn pause(self: *const Self, secs: f64) !void {
        try stdout.print("pausing {d} s\n", .{secs}); //
        try self.cmdfmt("pause {d}\n", .{secs}); //gnu

        const nanosecs: u64 = @intFromFloat(secs * 1.0e9);

        std.time.sleep(nanosecs); // std.time.sleep expects nanoseconds
    }

    // pause both parent zig process and child gnuplot process (maintain sync)
    // without terminal message
    pub fn pauseQuiet(self: *const Self, secs: f64) !void {
        try self.cmdfmt("pause {d}\n", .{secs}); //gnu

        const nanosecs: u64 = @intFromFloat(secs * 1.0e9);

        std.time.sleep(nanosecs); // std.time.sleep expects nanoseconds
    }

    // set the figure title
    pub fn title(self: *const Self, title_str: []const u8) !void {
        try self.cmdfmt("set title '{s}'\n", .{title_str});
    }

    // put label on x-axis
    pub fn xLabel(self: *const Self, c: []const u8) !void {
        try self.cmdfmt("set xlabel '{s}'\n", .{c});
    }

    // put label on y-axis
    pub fn yLabel(self: *const Self, c: []const u8) !void {
        try self.cmdfmt("set ylabel '{s}'\n", .{c});
    }

    // plot a single vector (values over each index) use:
    //
    // self.plot( .{x, "title 'x' with lines ls 5 lw 1"});
    //
    // to plot multiple vector in same plot (values over each index) use:
    //
    //  self.plot( .{
    //          x, "title 'x' with lines ls 2 lw 1",
    //          y, "title 'x' with lines ls 2 lw 1",
    //          z, "title 'x' with lines ls 2 lw 1",
    //          });
    pub fn plot(self: *const Self, argstruct: anytype) !void {
        const argvec = fields(@TypeOf(argstruct));

        if (argvec.len % 2 != 0) {
            return error.WrongArgument;
        }

        inline for (0..argvec.len / 2) |i| {
            try self.cmdfmt("$data{d} << EOD\n", .{i});
            const ys = @field(argstruct, argvec[i * 2].name);
            for (0.., ys) |j, y| {
                try self.cmdfmt("{d} {e:10.4}\n", .{ j, y });
            }
            try self.cmdfmt("EOD\n", .{});
        }

        // write command string
        try self.cmdfmt("plot ", .{});
        inline for (0..argvec.len / 2) |i| {
            const command_suffix = @field(argstruct, argvec[i * 2 + 1].name);
            try self.cmdfmt("$data{d} {s}, ", .{
                i,
                command_suffix,
            });
        }
        try self.cmdfmt("\n", .{});
    }

    // plot the graph of vector x vs. vector y using:
    //
    // self.plotXY( .{x, y, "title 'y vs. x' with lines lw 3"});
    //
    pub fn plotXY(self: *const Self, argstruct: anytype) !void {
        const argvec = fields(@TypeOf(argstruct));

        if (argvec.len % 3 != 0) {
            return error.WrongArgument;
        }

        inline for (0..argvec.len / 3) |i| {
            try self.cmdfmt("$data{d} << EOD\n", .{i});
            const xs = @field(argstruct, argvec[i * 3].name);
            const ys = @field(argstruct, argvec[i * 3 + 1].name);
            for (xs, ys) |x, y| {
                try self.cmdfmt("{e:10.4} {e:10.4}\n", .{ x, y });
            }
            try self.cmdfmt("EOD\n", .{});
        }

        // write command string
        try self.cmdfmt("plot ", .{});
        inline for (0..argvec.len / 3) |i| {
            const command_suffix = @field(argstruct, argvec[i * 3 + 2].name);
            try self.cmdfmt("$data{d} {s}, ", .{
                i,
                command_suffix,
            });
        }
        try self.cmdfmt("\n", .{});
    }
    // plot the bar graph of vectors
    // if multiple vectors are provided, their corresponding elements are grouped together
    //
    // self.bar(.{x, width, "title 'x'"});
    //
    // a width in range of [0, 1] must be specified
    pub fn bar(self: Self, argstruct: anytype) !void {
        const argvec = fields(@TypeOf(argstruct));

        if (argvec.len % 3 != 0) {
            return error.WrongArgument;
        }

        const n_plots = argvec.len / 3;
        // Basically we just want to group bars a bit if more than 1 vector was provided
        const offset_x = if (n_plots == 1) n_plots else n_plots + 1;

        inline for (0..n_plots) |i| {
            try self.cmdfmt("$data{d} << EOD\n", .{i});
            const xs = @field(argstruct, argvec[i * 3].name);
            const width: f64 = @field(argstruct, argvec[i * 3 + 1].name);
            for (0.., xs) |j, x| {
                try self.cmdfmt("{d} {e:.4} {e:.4}\n", .{
                    i + j * offset_x,
                    x,
                    width,
                });
            }
            try self.cmdfmt("EOD\n", .{});
        }

        // write command string
        try self.cmdfmt("set style fill solid 0.5\n ", .{});
        try self.cmdfmt("plot ", .{});
        inline for (0..n_plots) |i| {
            const command_suffix = @field(argstruct, argvec[i * 3 + 2].name);
            try self.cmdfmt("$data{d} with boxes {s}, ", .{
                i,
                command_suffix,
            });
        }
        try self.cmdfmt("\n", .{});
    }

    // splot with nonuniform matrix
    // splot(.{
    //  xs1, ys1, zs1, "with lines title title1"
    //  xs2, ys2, zs2, "with lines title title2"
    //  ...
    // })
    // zs should be an array of shape [N][M] where N is len of xs and M is len of ys
    pub fn splot(self: *const Self, argstruct: anytype) !void {
        const argvec = std.meta.fields(@TypeOf(argstruct));

        if (argvec.len % 4 != 0) {
            return error.WrongArgument;
        }

        inline for (0..argvec.len / 4) |i| {
            try self.cmdfmt("$data{d} << EOD\n", .{i});

            const xs = @field(argstruct, argvec[i * 4].name);
            const ys = @field(argstruct, argvec[i * 4 + 1].name);
            const zs = @field(argstruct, argvec[i * 4 + 2].name);

            try self.cmdfmt("{d:.3} ", .{ys.len});
            for (ys) |y| {
                try self.cmdfmt("{d:.3} ", .{y});
            }
            try self.cmdfmt("\n", .{});
            for (xs, 0..) |x, j| {
                try self.cmdfmt("{d:.3} ", .{x});
                for (0..ys.len) |k| {
                    try self.cmdfmt("{d:.3} ", .{zs[j][k]});
                }
                try self.cmdfmt("\n", .{});
            }
            try self.cmdfmt("EOD\n", .{});
        }

        // write command string
        try self.cmdfmt("splot ", .{});
        inline for (0..argvec.len / 4) |i| {
            const command_suffix = @field(argstruct, argvec[i * 4 + 3].name);
            try self.cmdfmt("$data{d} nonuniform matrix {s}, ", .{
                i,
                command_suffix,
            });
        }
        try self.cmdfmt("\n", .{});
    }
};
