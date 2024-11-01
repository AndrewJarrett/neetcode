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

    // Setup a buffered writer for stdout
    const stdout = std.io.getStdOut();
    var bw = std.io.bufferedWriter(stdout.writer());
    var writer = bw.writer();

    var n: []const u8 = undefined;
    var k: usize = undefined;
    var isValidInput = false;
    while (!isValidInput) {
        //var allChunks: std.BoundedArray(u8, (32 * 1024)) = .{};
        //var fba = std.heap.FixedBufferAllocator.init(&buffer);
        //var buffer: [2 * 4096]u8 = undefined;
        var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        defer arena.deinit();

        //var lineList = std.ArrayList(u8).init(arena.allocator());
        //while (reader.readUntilDelimiterOrEof(&buffer, '\n') catch {
        //    std.debug.print("Unable to read your input, please try again:\n", .{});
        //    continue;
        //}) |chunk| {
        //    lineList.appendSlice(chunk) catch unreachable;
        //}
        const line = reader.readUntilDelimiterOrEofAlloc(arena.allocator(), '\n', 10 * 4 * 1024) catch {
            std.debug.print("Unable to read your input, please try again:\n", .{});
            continue;
        } orelse {
            std.debug.print("Exiting.\n", .{});
            break;
        };
        //const line = lineList.toOwnedSlice() catch unreachable;
        std.debug.print("line: {s}; line.len: {d}\n", .{ line, line.len });
        //std.debug.print("allChunks: {s}; allChunks.len: {d}\n", .{ allChunks.constSlice(), allChunks.len });

        //var iter = std.mem.tokenize(u8, allChunks.constSlice(), " ");
        var iter = std.mem.tokenize(u8, line, " ");
        //var iter = std.mem.tokenize(u8, line.constSlice(), " ");
        n = iter.next() orelse "0";

        k = std.fmt.parseInt(usize, iter.next() orelse "0", 0) catch {
            std.debug.print("Unable to parse your input as a number, please try again:\n", .{});
            continue;
        };

        if (1 <= n.len) {
            isValidInput = true;
        } else {
            std.debug.print("Please enter a positive number of any size.\n", .{});
            continue;
        }
        std.debug.print("n: {s}; n.len: {d}\n", .{ n, n.len });
        std.debug.print("k: {d}; 1 <= k <= 100000: {any}\n", .{ k, (1 <= k and k <= 100000) });

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
