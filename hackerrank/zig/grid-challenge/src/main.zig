const std = @import("std");
const assert = std.debug.assert;
const Solution = @import("Solution.zig");
const ArrayList = std.ArrayList;

pub fn main() !void {
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});

    // Setup a buffered reader for stdin
    const stdin = std.io.getStdIn();
    var br = std.io.bufferedReader(stdin.reader());
    var reader = br.reader();
    var buf: [4096]u8 = undefined;
    var buf2: [4096]u8 = undefined;
    var buf3: [4096]u8 = undefined;

    // Setup a buffered writer for stdout
    const stdout = std.io.getStdOut();
    var bw = std.io.bufferedWriter(stdout.writer());
    var writer = bw.writer();

    var t: u8 = undefined;
    var isValidInput = false;
    while (!isValidInput) {
        const t_str = (reader.readUntilDelimiterOrEof(&buf, '\n') catch {
            std.debug.print("Unable to read your input, please try again:\n", .{});
            continue;
        }) orelse "0";

        t = std.fmt.parseInt(u8, t_str, 0) catch {
            std.debug.print("Unable to parse your input as a number, please try again:\n", .{});
            continue;
        };

        if (1 <= t and t <= 100) {
            isValidInput = true;
        } else {
            std.debug.print("Please input a number between 1 and 100.\n", .{});
            continue;
        }
    }

    assert(1 <= t);
    assert(t <= 20);

    var n: u8 = undefined;
    for (0..t) |_| {
        const n_str = (reader.readUntilDelimiterOrEof(&buf2, '\n') catch {
            std.debug.print("Unable to read your input, please try again:\n", .{});
            continue;
        }) orelse "0";

        n = std.fmt.parseInt(u8, n_str, 0) catch {
            std.debug.print("Unable to parse your input as a number, please try again:\n", .{});
            continue;
        };

        // Copy the input into an arena allocated ArrayList to ensure value is retained in memory
        var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        defer arena.deinit();
        const allocator = arena.allocator();

        var grid = ArrayList([]const u8).init(allocator);
        defer grid.deinit();

        isValidInput = false;
        while (!isValidInput) {
            inner: for (0..n) |_| {
                const str = (reader.readUntilDelimiterOrEof(&buf3, '\n') catch {
                    std.debug.print("Unable to read your input, please try again:\n", .{});
                    break :inner;
                }) orelse "";

                if (str.len == n) {
                    grid.append(allocator.dupe(u8, str) catch unreachable) catch unreachable;
                    isValidInput = true;
                } else {
                    std.debug.print("Please provide a string of a-z characters of length {d}.\n", .{n});
                    break :inner;
                }
            }

            if (grid.items.len == n) {
                isValidInput = true;
            }
        }

        const result = Solution.gridChallenge(&grid);
        try writer.print("{s}\n", .{result});
    }

    try bw.flush();
}
