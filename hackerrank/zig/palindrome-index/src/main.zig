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
    var buf2: [4096]u8 = undefined;

    // Setup a buffered writer for stdout
    const stdout = std.io.getStdOut();
    var bw = std.io.bufferedWriter(stdout.writer());
    var writer = bw.writer();

    var q: u8 = undefined;
    var isValidInput = false;
    while (!isValidInput) {
        const q_str = (reader.readUntilDelimiterOrEof(&buf, '\n') catch {
            std.debug.print("Unable to read your input, please try again:\n", .{});
            continue;
        }) orelse "0";

        q = std.fmt.parseInt(u8, q_str, 0) catch {
            std.debug.print("Unable to parse your input as a number, please try again:\n", .{});
            continue;
        };

        if (1 <= q and q <= 20) {
            isValidInput = true;
        } else {
            std.debug.print("Please input a number between 1 and 20.\n", .{});
            continue;
        }
    }

    assert(1 <= q);
    assert(q <= 20);

    for (0..q) |_| {
        const str = (reader.readUntilDelimiterOrEof(&buf2, '\n') catch {
            std.debug.print("Unable to read your input, please try again:\n", .{});
            continue;
        }) orelse "";

        if (1 <= str.len and str.len <= 100005 and Solution.isValidStr(str)) {
            isValidInput = true;
        } else {
            std.debug.print("Please provide a string of a-z characters.\n", .{});
            continue;
        }

        // Copy the input into a heap allocated str to ensure value is retained in memory
        var buffer: [100]u8 = undefined;
        var fba = std.heap.FixedBufferAllocator.init(&buffer);
        const allocator = fba.allocator();

        const heapStr = try allocator.dupe(u8, str);
        defer allocator.free(heapStr);

        const result = Solution.palindromeIndex(heapStr);
        try writer.print("{d}\n", .{result});
    }

    try bw.flush();
}
