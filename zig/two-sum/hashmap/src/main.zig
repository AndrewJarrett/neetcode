const std = @import("std");
const AutoHashMap = std.hash_map.AutoHashMap;
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    arena.deinit();

    std.debug.print("Test1... {s}\n", .{if (try test1(arena.allocator())) "passed" else "failed"});
    std.debug.print("Test2... {s}\n", .{if (try test2(arena.allocator())) "passed" else "failed"});
    std.debug.print("Test3... {s}\n", .{if (try test3(arena.allocator())) "passed" else "failed"});
}

const Solution = struct {
    allocator: Allocator,

    pub fn init(allocator: Allocator) Solution {
        return Solution{
            .allocator = allocator,
        };
    }

    pub fn twoSum(self: Solution, nums: []const i32, target: i32) [2]u16 {
        var map = AutoHashMap(i32, u16).init(self.allocator);
        defer map.deinit();

        for (nums, 0..nums.len) |num, i| {
            const diff = target - num;

            if (map.contains(diff)) {
                return [2]u16{ map.get(diff).?, @intCast(i) };
            } else {
                map.put(num, @intCast(i)) catch unreachable;
            }
        }

        return [2]u16{ 0, 0 };
    }
};

test "[3, 4, 5, 6] / 7 = [0, 1]" {
    _ = try test1(std.testing.allocator);
}

test "[4, 5, 6] / 10 = [0, 2]" {
    _ = try test2(std.testing.allocator);
}

test "[5, 5] / 10 = [0, 1]" {
    _ = try test3(std.testing.allocator);
}

pub fn test1(allocator: Allocator) !bool {
    const nums = &.{ 3, 4, 5, 6 };
    const target = 7;
    const result = [2]u16{ 0, 1 };
    const solution = Solution.init(allocator);
    std.testing.expect(std.mem.eql(u16, &solution.twoSum(nums, target), &result)) catch return false;
    return true;
}

pub fn test2(allocator: Allocator) !bool {
    const nums = &.{ 4, 5, 6 };
    const target = 10;
    const result = [2]u16{ 0, 2 };
    const solution = Solution.init(allocator);
    std.testing.expect(std.mem.eql(u16, &solution.twoSum(nums, target), &result)) catch return false;
    return true;
}

pub fn test3(allocator: Allocator) !bool {
    const nums = &.{ 5, 5 };
    const target = 10;
    const result = [2]u16{ 0, 1 };
    const solution = Solution.init(allocator);
    std.testing.expect(std.mem.eql(u16, &solution.twoSum(nums, target), &result)) catch return false;
    return true;
}
