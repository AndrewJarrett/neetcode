const std = @import("std");
const assert = std.debug.assert;

const Self = @This();

pub fn isValidStr(str: []const u8) bool {
    var isValid = true;

    for (str) |c| {
        if ('a' > c or c > 'z') {
            isValid = false;
        }
    }

    return isValid;
}

pub fn palindromeIndex(str: []u8) i32 {
    assert(1 <= str.len);
    assert(str.len <= 100005);
    assert(isValidStr(str));

    var result: i32 = -1;
    const index: i32 = getIndex(str);

    if (index == -1) {
        return result;
    }

    const i: usize = @intCast(index);
    assert(i >= 0);

    const j = str.len - 1 - i;
    assert(j > 0);

    var buffer: [100005]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buffer);

    const left = std.mem.concat(fba.allocator(), u8, &.{ str[0..i], str[i + 1 ..] }) catch "";
    defer fba.allocator().free(left);

    const right = std.mem.concat(fba.allocator(), u8, &.{ str[0..j], str[j + 1 ..] }) catch "";
    defer fba.allocator().free(right);

    if (getIndex(left) == -1) {
        result = @intCast(i);
    } else if (getIndex(right) == -1) {
        result = @intCast(j);
    }

    return result;
}

fn getIndex(str: []const u8) i32 {
    var index: i32 = -1;

    if (str.len == 1 or str.len == 2 and str[0] == str[1]) {
        return index;
    }

    for (0..(str.len / 2)) |i| {
        if (str[i] != str[str.len - 1 - i]) {
            index = @intCast(i);
        }
    }

    return index;
}

test "Test Case 1" {
    const str1 = try std.testing.allocator.dupe(u8, "aaab");
    defer std.testing.allocator.free(str1);
    const str2 = try std.testing.allocator.dupe(u8, "baa");
    defer std.testing.allocator.free(str2);
    const str3 = try std.testing.allocator.dupe(u8, "aaa");
    defer std.testing.allocator.free(str3);
    try std.testing.expect(3 == palindromeIndex(str1));
    try std.testing.expect(0 == palindromeIndex(str2));
    try std.testing.expect(-1 == palindromeIndex(str3));
}

test "Test Case 2" {
    const str1 = try std.testing.allocator.dupe(u8, "a");
    defer std.testing.allocator.free(str1);
    const str2 = try std.testing.allocator.dupe(u8, "ab");
    defer std.testing.allocator.free(str2);
    const str3 = try std.testing.allocator.dupe(u8, "abaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa");
    defer std.testing.allocator.free(str3);

    try std.testing.expect(-1 == palindromeIndex(str1));
    try std.testing.expect(0 == palindromeIndex(str2));
    try std.testing.expect(1 == palindromeIndex(str3));
}
