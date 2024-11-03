const std = @import("std");
const assert = std.debug.assert;
const Solution = @import("Solution.zig");
const ArrayList = std.ArrayList;

pub fn main() !void {
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});

    // When running in Linux, the TTY will only allow 4095 bytes to be entered when copying-pasting and will automatically
    // add a newline and truncate the line.
    // https://unix.stackexchange.com/questions/643777/is-there-any-limit-on-line-length-when-pasting-to-a-terminal-in-linux
    //
    // Probably best to cat a file or input the input through a pipe if you want to input more than 4096 bytes.

    // Setup a buffered reader for stdin
    const stdin = std.io.getStdIn();
    var br = std.io.bufferedReader(stdin.reader());
    var reader = br.reader();

    // Setup a buffered writer for stdout
    const stdout = std.io.getStdOut();
    var bw = std.io.bufferedWriter(stdout.writer());
    var writer = bw.writer();

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    var n: []const u8 = undefined;
    var k: usize = undefined;
    var isValidInput = false;
    while (!isValidInput) {
        const line = reader.readUntilDelimiterOrEofAlloc(arena.allocator(), '\n', 10 * 4 * 1024) catch {
            std.debug.print("Unable to read your input, please try again:\n", .{});
            continue;
        } orelse "0 1";

        var iter = std.mem.tokenize(u8, line, " \n");
        n = iter.next() orelse "0";

        k = std.fmt.parseInt(usize, iter.next() orelse "1", 10) catch {
            std.debug.print("Unable to parse your input as a number, please try again:\n", .{});
            continue;
        };

        if (1 <= n.len) {
            isValidInput = true;
        } else {
            std.debug.print("Please enter a positive number of any size.\n", .{});
            continue;
        }

        if (1 <= k and k <= 100000) {
            isValidInput = true;
        } else {
            isValidInput = false;
            std.debug.print("Please input a number between 1 and 100000.\n", .{});
            continue;
        }
    }

    assert(1 <= n.len);
    assert(1 <= k);
    assert(k <= 100000);

    const result = Solution.superDigit(n, k);
    try writer.print("{d}\n", .{result});

    try bw.flush();
}
