const std = @import("std");

const Allocator = std.mem.Allocator;
const stdout = std.io.getStdOut().writer();

const Child = std.process.Child;

const fields = std.meta.fields;
const colors = @import("matplotlib_colors.zig");

pub fn Gnuzplot() type {
    return struct {
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

        // plot a single vector (values over each index) use:
        //
        // plt.plot( .{x, "title 'x' with lines ls 5 lw 1"});
        //
        // to plot multiple vector in same plot (values over each index) use:
        //
        //  plt.plot( .{
        //          x, "title 'x' with lines ls 2 lw 1",
        //          y, "title 'x' with lines ls 2 lw 1",
        //          z, "title 'x' with lines ls 2 lw 1",
        //          });

        pub fn plot(self: *const Self, argstruct: anytype) !void {
            const argvec = fields(@TypeOf(argstruct));
            comptime var i = 0;
            var vlen: usize = 0;

            const preamble = "plot ";
            const plotline_pre = " '-' u 1:2 ";
            const plotline_post = ", ";

            try self.cmdfmt("{s}", .{preamble});

            // write command string
            inline while (i < argvec.len) : (i += 2) {
                try self.cmdfmt("{s}", .{plotline_pre});
                try self.cmdfmt("{s}", .{@field(argstruct, argvec[i + 1].name)});
                try self.cmdfmt("{s}", .{plotline_post});
            }
            try self.cmdfmt("\n", .{});

            i = 0;
            inline while (i < argvec.len) : (i += 2) {
                vlen = @field(argstruct, argvec[i].name).len;
                var j: usize = 0;
                while (j < vlen) : (j += 1) {
                    try self.cmdfmt("{d}  {e:10.4}\n", .{ j, @field(argstruct, argvec[i].name)[j] });
                }
                try self.cmdfmt("e\n", .{});
            }
        }

        // plot the graph of vector x vs. vector y using:
        //
        // plt.plotXY( .{x, y, "title 'y vs. x' with lines lw 3"});
        //
        pub fn plotXY(self: *const Self, argstruct: anytype) !void {
            const argvec = fields(@TypeOf(argstruct));
            comptime var i = 0;
            var vlen: usize = 0;
            const preamble = "plot ";
            const plotline_pre = " '-' u 1:2 ";
            const plotline_post = ", ";

            try self.cmdfmt("{s}", .{preamble});

            // write command string
            inline while (i < argvec.len) : (i += 3) {
                try self.cmdfmt("{s}", .{plotline_pre});
                try self.cmdfmt("{s}", .{@field(argstruct, argvec[i + 2].name)});
                try self.cmdfmt("{s}", .{plotline_post});
            }
            try self.cmdfmt("\n", .{});

            i = 0;
            inline while (i < argvec.len) : (i += 3) {
                vlen = @field(argstruct, argvec[i].name).len;
                var j: usize = 0;
                while (j < vlen) : (j += 1) {
                    try self.cmdfmt("{e:10.4}   {e:10.4}\n", .{ @field(argstruct, argvec[i].name)[j], @field(argstruct, argvec[i + 1].name)[j] });
                }
                try self.cmdfmt("e\n", .{});
            }
        }

        // set the figure title
        pub fn title(self: *const Self, title_str: [*:0]const u8) !void {
            try self.cmdfmt("set title '{s}'\n", .{title_str});
        }

        // put label on x-axis
        pub fn xLabel(self: *const Self, c: [*:0]const u8) !void {
            try self.cmdfmt("set xlabel '{s}'\n", .{c});
        }

        // put label on y-axis
        pub fn yLabel(self: *const Self, c: [*:0]const u8) !void {
            try self.cmdfmt("set ylabel '{s}'\n", .{c});
        }

        // bar graph of a single vector, specifying the width
        //
        // plt.bar( .{x, width, "title 'x'"});
        //
        // a width must be specified
        //
        pub fn bar(self: *const Self, argstruct: anytype) !void {
            const num_args_per = 3;
            const argvec = fields(@TypeOf(argstruct));
            const num_vars: usize = argvec.len / num_args_per;
            var vlen: usize = 0;

            var width: f64 = @as(f64, @floatCast(@field(argstruct, argvec[1].name)));
            width = @as(f64, @floatFromInt(num_args_per)) * width / @as(f64, @floatFromInt(argvec.len));

            vlen = @field(argstruct, argvec[0].name).len;

            try self.cmdfmt("set xrange [-1:{d}]\n", .{vlen + 1});

            const preamble = "set style fill solid 0.5 \n plot ";
            const plotline_pre = " '-' u 1:2:3 with boxes ";
            const plotline_post = ", ";
            try self.cmdfmt("{s}", .{preamble});

            // write command string
            comptime var i = 0;
            inline while (i < argvec.len) : (i += 3) {
                try self.cmdfmt("{s}", .{plotline_pre});
                try self.cmdfmt("{s}", .{@field(argstruct, argvec[i + 2].name)});
                try self.cmdfmt("{s}", .{plotline_post});
            }
            try self.cmdfmt("\n", .{});

            i = 0;
            inline while (i < argvec.len) : (i += 3) {
                vlen = @field(argstruct, argvec[i].name).len;
                var j: usize = 0;

                while (j < vlen) : (j += 1) {
                    try self.cmdfmt("{d}   {e:10.4} {e:10.4}\n", .{
                        @as(f64, @floatFromInt(j)) + @as(f64, @floatFromInt(i)) * width / @as(f64, @floatFromInt(num_vars)),

                        @field(argstruct, argvec[i].name)[j],
                        // @field(argstruct, argvec[i+1].name)
                        width,
                    });
                }
                try self.cmdfmt("e\n", .{});
            }
        }
    };
}
