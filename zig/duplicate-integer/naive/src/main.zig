const std = @import("std");
const AutoHashMap = std.hash_map.AutoHashMap;

pub fn main() !void {
    std.debug.print("Test1... {s}\n", .{if (try test1()) "passed" else "failed"});
    std.debug.print("Test2... {s}\n", .{if (try test2()) "passed" else "failed"});
}

pub fn hasDuplicates(nums: *const [4]u32) bool {
    var hasDuplicate: bool = false;
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();
    var map = AutoHashMap(u32, u32).init(allocator);
    defer map.deinit();

    for (nums) |i| {
        const result = map.getOrPut(i) catch unreachable; // Just panic if no more memory

        if (result.found_existing) {
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

pub fn test1() !bool {
    const nums = [_]u32{ 1, 2, 3, 3 };
    std.testing.expect(hasDuplicates(&nums)) catch return false;
    return true;
}

pub fn test2() !bool {
    const nums = [_]u32{ 1, 2, 3, 4 };
    std.testing.expectEqual(hasDuplicates(&nums), false) catch return false;
    return true;
}
