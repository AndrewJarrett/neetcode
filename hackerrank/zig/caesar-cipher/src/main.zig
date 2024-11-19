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
    var buf3: [4096]u8 = undefined;

    // Setup a buffered writer for stdout
    const stdout = std.io.getStdOut();
    var bw = std.io.bufferedWriter(stdout.writer());
    var writer = bw.writer();

    var isValidInput = false;
    while (!isValidInput) {
        const n_str = (reader.readUntilDelimiterOrEof(&buf, '\n') catch {
            std.debug.print("Unable to read your input, please try again:\n", .{});
            continue;
        }) orelse "0";

        const n: u8 = std.fmt.parseInt(u8, n_str, 0) catch {
            std.debug.print("Unable to parse your input as a number, please try again:\n", .{});
            continue;
        };

        if (1 > n and n > 100) {
            std.debug.print("Please input a number between 1 and 100.\n", .{});
            continue;
        }

        const str = (reader.readUntilDelimiterOrEof(&buf2, '\n') catch {
            std.debug.print("Unable to read your input, please try again:\n", .{});
            continue;
        }) orelse "";

        if (str.len != n) {
            std.debug.print("You specified a word of size {d}, but input a string of size {d}. Please try again.\n", .{ n, str.len });
            continue;
        }

        const k_str = (reader.readUntilDelimiterOrEof(&buf3, '\n') catch {
            std.debug.print("Unable to read your input, please try again:\n", .{});
            continue;
        }) orelse "0";

        const k: u8 = std.fmt.parseInt(u8, k_str, 0) catch {
            std.debug.print("Unable to parse your input as a number, please try again:\n", .{});
            continue;
        };

        if (0 <= k and k <= 100) {
            isValidInput = true;
        } else {
            std.debug.print("Please input a number between 0 and 100.\n", .{});
            continue;
        }

        assert(1 <= n);
        assert(n <= 100);
        assert(n == str.len);
        assert(0 <= k);
        assert(k <= 100);

        // Copy the input into a heap allocated str to ensure value is retained in memory
        var buffer: [100]u8 = undefined;
        var fba = std.heap.FixedBufferAllocator.init(&buffer);
        const allocator = fba.allocator();

        const heapStr = try allocator.dupe(u8, str);
        defer allocator.free(heapStr);

        const result = Solution.caesarCipher(heapStr, k);
        try writer.print("{s}\n", .{result});
        try bw.flush();
    }
}
