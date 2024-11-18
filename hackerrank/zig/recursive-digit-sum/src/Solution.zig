const std = @import("std");
const assert = std.debug.assert;
const ArrayList = std.ArrayList;

const Self = @This();

pub fn superDigit(n: []const u8, k: usize) u4 {
    assert(1 <= n.len);
    assert(1 <= k);
    assert(k <= 100000);

    var sum: u64 = 0;

    // The string can be very long so we need to sum the number
    // first by evaluating each char.
    for (n) |c| {
        assert('0' <= c);
        assert(c <= '9');
        sum += @as(u8, c) - '0';
    }

    sum *= k;

    // The digit sum is equivalent to the sum mod 9 except
    // for multiples of 9 (which should be 9)
    sum = if (@mod(sum, 9) == 0) 9 else @mod(sum, 9);

    // Return a number between 0-9
    return @intCast(sum);
}

test "Test Case 1" {
    try std.testing.expectEqual(3, superDigit("148", 3));
}

test "Test Case 2" {
    try std.testing.expectEqual(8, superDigit("9875", 4));
}

test "Test Case 3" {
    try std.testing.expectEqual(9, superDigit("123", 3));
}

test "Test Case 4" {
    const testFile1 = @embedFile("tests/1.txt");
    var iter = std.mem.tokenize(u8, testFile1, " \n");

    const n: []const u8 = iter.next() orelse "0";
    const k: usize = std.fmt.parseInt(usize, iter.next() orelse "0", 10) catch unreachable;

    try std.testing.expectEqual(7, superDigit(n, k));
}
