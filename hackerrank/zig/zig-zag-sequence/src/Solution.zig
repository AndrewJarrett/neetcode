const std = @import("std");
const assert = std.debug.assert;

const Self = @This();

pub fn findZigZagSequence(a: []const u32, n: u32) []u32 {
    assert(a.len == n);
    assert(1 <= n);
    assert(n <= 10000);
    assert(@mod(n, 2) == 1);

    var buffer: [10000]u32 = undefined;
    std.mem.copyForwards(u32, &buffer, a);
    const sorted = buffer[0..n];

    if (a.len == 1) {
        return sorted;
    }
    assert(n - 2 > 0); // Prevent overflow
    std.mem.sort(u32, sorted, {}, lessThan);

    const mid = ((n + 1) / 2) - 1;
    var temp = sorted[mid];
    sorted[mid] = sorted[n - 1];
    sorted[n - 1] = temp;

    var st = mid + 1;
    var ed = n - 2;
    while (st <= ed) : ({
        st += 1;
        ed -= 1;
    }) {
        temp = sorted[st];
        sorted[st] = sorted[ed];
        sorted[ed] = temp;
    }

    return sorted;
}

fn lessThan(_: void, a: u32, b: u32) bool {
    assert(a >= 1);
    assert(b >= 1);
    assert(a <= 1000000000);
    assert(b <= 1000000000);

    return if (a < b) true else false;
}

test "Test Case 1" {
    const a: []const u32 = &.{ 2, 3, 5, 1, 4 };
    const actual = findZigZagSequence(a, a.len);
    try std.testing.expect(checkZigZag(actual));
}

test "Test Case 2" {
    const a: []const u32 = &.{1};
    const actual = findZigZagSequence(a, a.len);
    try std.testing.expect(checkZigZag(actual));
}

test "Test Case 3" {
    const a: []const u32 = &.{ 1, 2, 3 };
    const actual = findZigZagSequence(a, a.len);
    try std.testing.expect(checkZigZag(actual));
}

test "Test Case 4" {
    const a: []const u32 = &.{ 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 11 };
    const actual = findZigZagSequence(a, a.len);
    try std.testing.expect(checkZigZag(actual));
}

test "Test Case 5" {
    const max = 1000 - 1;
    var buffer: [max]u32 = undefined;
    for (0..max) |i| {
        buffer[i] = @intCast(i + 1);
    }
    const a = buffer[0..];
    const actual = findZigZagSequence(a, a.len);
    try std.testing.expect(checkZigZag(actual));
}

test "Test Case 6" {
    const a: []const u32 = &.{1000000000};
    const actual = findZigZagSequence(a, a.len);
    try std.testing.expect(checkZigZag(actual));
}

fn checkZigZag(a: []const u32) bool {
    assert(a.len > 0);

    var isZigZag = true;
    var prev = a[0];
    const k = ((a.len + 1) / 2) - 1;

    for (a, 0..a.len) |num, i| {
        if ((i <= k and num < prev) or (i > k and num > prev)) {
            isZigZag = false;
            break;
        }

        prev = num;
    }

    return isZigZag;
}
