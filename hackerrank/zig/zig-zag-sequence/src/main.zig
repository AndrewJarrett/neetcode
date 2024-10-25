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

        if (1 <= t and t <= 20) {
            isValidInput = true;
        } else {
            std.debug.print("Please input a number between 1 and 20.\n", .{});
            continue;
        }
    }

    assert(1 <= t);
    assert(t <= 1000);
    for (0..t) |_| {
        isValidInput = false;
        var n: u32 = undefined;
        while (!isValidInput) {
            const n_str = (reader.readUntilDelimiterOrEof(&buf, '\n') catch {
                std.debug.print("Unable to read your input, please try again:\n", .{});
                continue;
            }) orelse "0";

            n = std.fmt.parseInt(u32, n_str, 0) catch {
                std.debug.print("Unable to parse your input as a number, please try again:\n", .{});
                continue;
            };

            if (1 <= n and n <= 10000 and @mod(n, 2) == 1) {
                isValidInput = true;
            } else {
                std.debug.print("Please input an odd number between 1 and 10000.\n", .{});
                continue;
            }
        }

        assert(1 <= n);
        assert(n <= 10000);
        assert(@mod(n, 2) == 1);

        var i: u32 = 0;
        var intBuffer: [10000]u32 = undefined;
        isValidInput = false;
        while (!isValidInput) : (i = 0) {
            const a_line = (reader.readUntilDelimiterOrEof(&buf, '\n') catch {
                std.debug.print("Unable to read your input, please try again:\n", .{});
                continue;
            }) orelse "";

            // Split line with numbers (as strings) separated by spaces
            var split = std.mem.split(u8, a_line, " ");
            while (split.next()) |a_str| {
                intBuffer[i] = std.fmt.parseInt(u32, a_str, 0) catch {
                    std.debug.print("Unable to parse at least one of your inputs as a number, please try again:\n", .{});
                    continue;
                };

                if (intBuffer[i] < 1 or intBuffer[i] > 1000000000) {
                    std.debug.print("Please only enter numbers from 1 to 1,000,000,000.\n", .{});
                    continue;
                }

                i += 1;
            }

            if (i != n) {
                std.debug.print("You need to input exactly {d} numbers, but you gave {d} numbers instead. Please try again.\n", .{ n, i });
                continue;
            }

            // Now, actually call the function to find the zig zag and output the results
            if (i == n) {
                isValidInput = true;
            }
            assert(i == n);
            const a = intBuffer[0..n];
            for (Solution.findZigZagSequence(a, n)) |num| {
                try writer.print("{d} ", .{num});
            }
            _ = try writer.write("\n");
        }
    }

    try bw.flush();
}
