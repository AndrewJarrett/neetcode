const std = @import("std");
const assert = std.debug.assert;
const Solution = @import("Solution.zig");

pub fn main() !void {
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});

    // Setup a buffered reader for stdin
    const stdin = std.io.getStdIn();
    var br = std.io.bufferedReader(stdin.reader());
    var reader = br.reader();
    var buf: [4096]u8 = undefined;

    // Setup a buffered writer for stdout
    const stdout = std.io.getStdOut();
    var bw = std.io.bufferedWriter(stdout.writer());
    var writer = bw.writer();

    var t: u32 = undefined;
    var isValidInput = false;
    while (!isValidInput) {
        const t_str = (reader.readUntilDelimiterOrEof(&buf, '\n') catch {
            std.debug.print("Unable to read your input, please try again:\n", .{});
            continue;
        }) orelse "0";

        t = std.fmt.parseInt(u32, t_str, 0) catch {
            std.debug.print("Unable to parse your input as a number, please try again:\n", .{});
            continue;
        };

        if (1 <= t and t <= 100) {
            isValidInput = true;
        } else {
            std.debug.print("Please input a number between 1 and 20.\n", .{});
            continue;
        }
    }

    assert(1 <= t);
    assert(t <= 100);
    for (0..t) |_| {
        isValidInput = false;
        var maybeN: ?u32 = null;
        var maybeM: ?u32 = null;
        retry: while (!isValidInput) {
            const nm_line = (reader.readUntilDelimiterOrEof(&buf, '\n') catch {
                std.debug.print("Unable to read your input, please try again:\n", .{});
                continue;
            }) orelse "0";

            var split = std.mem.split(u8, nm_line, " ");
            while (split.next()) |c| {
                if (maybeN == null) {
                    maybeN = std.fmt.parseInt(u32, c, 0) catch {
                        std.debug.print("Unable to parse your input as a number, please try again:\n", .{});
                        continue :retry;
                    };

                    if (1 > maybeN.? or maybeN.? > 1000000) {
                        std.debug.print("Please input a number between 1 and 1000000.\n", .{});
                        continue :retry;
                    }
                } else if (maybeM == null) {
                    maybeM = std.fmt.parseInt(u32, c, 0) catch {
                        std.debug.print("Unable to parse your input as a number, please try again:\n", .{});
                        continue :retry;
                    };

                    if (1 <= maybeM.? and maybeM.? <= 1000000) {
                        isValidInput = true;
                        break;
                    } else {
                        std.debug.print("Please input a number between 1 and 1000000.\n", .{});
                        continue :retry;
                    }
                }
            }

            if (maybeN != null and maybeM != null) {
                isValidInput = true;
            } else {
                std.debug.print("Please provide two numbers for 'n' and 'm'.\n", .{});
            }
        }

        const n = maybeN.?;
        const m = maybeM.?;
        assert(1 <= n);
        assert(n <= 1000000);
        assert(1 <= m);
        assert(m <= 1000000);

        try writer.print("{d}\n", .{Solution.towerBreakers(n, m)});
    }

    try bw.flush();
}
