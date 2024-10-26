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
        var n: u32 = undefined;
        var m: u32 = undefined;
        while (!isValidInput) {
            const n_str = (reader.readUntilDelimiterOrEof(&buf, ' ') catch {
                std.debug.print("Unable to read your input, please try again:\n", .{});
                continue;
            }) orelse "0";

            n = std.fmt.parseInt(u32, n_str, 0) catch {
                std.debug.print("Unable to parse your input as a number, please try again:\n", .{});
                continue;
            };

            if (1 > n or n > 1000000) {} else {
                std.debug.print("Please input a number between 1 and 1000000.\n", .{});
                continue;
            }

            const m_str = (reader.readUntilDelimiterOrEof(&buf, ' ') catch {
                std.debug.print("Unable to read your input, please try again:\n", .{});
                continue;
            }) orelse "0";

            m = std.fmt.parseInt(u32, m_str, 0) catch {
                std.debug.print("Unable to parse your input as a number, please try again:\n", .{});
                continue;
            };

            if (1 <= m and m <= 1000000) {
                isValidInput = true;
            } else {
                std.debug.print("Please input a number between 1 and 1000000.\n", .{});
                continue;
            }
        }

        assert(1 <= n);
        assert(n <= 1000000);
        assert(1 <= m);
        assert(m <= 1000000);

        try writer.print("{d} ", .{Solution.towerBreakers(n, m)});
    }

    try bw.flush();
}
