const std = @import("std");

pub fn main() !void {
    try test1();
    try test2();
}

pub fn hasDuplicates(nums: @Vector(4, u32)) bool {
    var hasDuplicate = false;

    for (0..4) |i| {
        if (nums[i]) {
            hasDuplicate = true;
            break;
        }
    }

    return hasDuplicate;
}

test "has a duplicate returns true" {
    try test1();
}

test "has no duplicates returns false" {
    try test2();
}

pub fn test1() !void {
    const nums: @Vector(4, u32) = .{ 1, 2, 3, 3 };
    try std.testing.expect(hasDuplicates(nums));
}

pub fn test2() !void {
    const nums: @Vector(4, u32) = .{ 1, 2, 3, 4 };
    try std.testing.expectEqual(hasDuplicates(nums), false);
}
