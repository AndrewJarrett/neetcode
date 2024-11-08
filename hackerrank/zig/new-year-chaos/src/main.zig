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

    var buffer: [2]u8 = undefined;
    var buffer2: [6]u8 = undefined;
    var t: usize = undefined;
    var n: usize = undefined;
    var qArray: [100000]usize = undefined;
    var q: []usize = undefined;
    var isValidInput = false;
    while (!isValidInput) {
        const t_str = reader.readUntilDelimiterOrEof(&buffer, '\n') catch {
            std.debug.print("Unable to read your input, please try again:\n", .{});
            continue;
        } orelse "1";

        t = std.fmt.parseInt(u32, t_str, 10) catch {
            std.debug.print("Unable to parse your input as a number, please try again:\n", .{});
            continue;
        };

        if (1 <= t and t <= 10) {
            isValidInput = true;
        } else {
            std.debug.print("Please enter a number between 1 and 10.", .{});
            continue;
        }
    }

    for (0..t) |_| {
        const n_str = reader.readUntilDelimiterOrEof(&buffer2, '\n') catch {
            std.debug.print("Unable to read your input, please try again:\n", .{});
            continue;
        } orelse "1";

        n = std.fmt.parseInt(usize, n_str, 10) catch {
            std.debug.print("Unable to parse your input as a number, please try again:\n", .{});
            continue;
        };

        if (1 <= n and n <= 100000) {} else {
            std.debug.print("Please enter a positive number between 1 and 100000.\n", .{});
            continue;
        }

        isValidInput = false;
        while (!isValidInput) {
            const q_str = reader.readUntilDelimiterOrEofAlloc(arena.allocator(), '\n', 10 * 4 * 1024) catch {
                std.debug.print("Unable to read your input, please try again:\n", .{});
                continue;
            } orelse "1";

            var iter = std.mem.tokenize(u8, q_str, " \n");

            var i: usize = 0;
            while (iter.next()) |numStr| : (i += 1) {
                const num = std.fmt.parseInt(usize, numStr, 10) catch {
                    std.debug.print("Unable to parse your input as a number, please try again:\n", .{});
                    continue;
                };
                qArray[i] = num;
            }
            q = qArray[0..i];

            if (1 <= q.len and q.len <= 100000) {
                isValidInput = true;
            } else {
                std.debug.print("Unable to read your input of numbers. Please add spaces inbetween the numbers for the queue input.\n", .{});
                continue;
            }
        }

        assert(1 <= n);
        assert(n <= 100000);
        assert(1 <= q.len);
        assert(q.len <= 100000);

        try writer.print("{s}\n", .{Solution.minimumBribes(q)});
    }

    try bw.flush();
}
