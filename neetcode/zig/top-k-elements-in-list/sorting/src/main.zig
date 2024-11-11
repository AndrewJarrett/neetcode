const std = @import("std");
const assert = std.debug.assert;
const AutoArrayHashMap = std.array_hash_map.AutoArrayHashMap;
const Allocator = std.mem.Allocator;

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

    pub fn topKFrequent(self: *Solution, nums: []const i16, k: u16) Allocator.Error![]const i16 {
        assert(1 <= nums.len and nums.len <= 10000);
        assert(1 <= k and k <= nums.len);

        var numFrequency = AutoArrayHashMap(i16, u16).init(self.allocator);
        defer numFrequency.deinit();

        // Create a hashmap of the number frequencies
        for (nums) |i| {
            assert(-1000 <= i and i <= 1000);

            const getResult = try numFrequency.getOrPut(i);
            if (getResult.found_existing) {
                // Increment the count for this existing number
                try numFrequency.put(i, getResult.value_ptr.* + 1);
            } else {
                // Set count for newly found number to 1
                try numFrequency.put(i, 1);
            }
        }

        // K must be less than the number of distinct elements in nums
        assert(k <= numFrequency.count());

        // Sort the keys of the map entries using the value/frequency (in reverse order, highest first)
        var buffer: [10000]i16 = undefined;
        const sorted = buffer[0..numFrequency.count()];
        std.mem.copyForwards(i16, sorted, numFrequency.keys());

        if (sorted.len > 1) {
            std.mem.sort(i16, sorted, numFrequency, greaterThan);
        }

        // Make sure that nothing was lost in sorting and we can make a valid slice
        assert(k <= sorted.len);

        // Return the first k elements as a slice
        return sorted[0..k];
    }

    fn greaterThan(map: AutoArrayHashMap(i16, u16), leftKey: i16, rightKey: i16) bool {
        const leftVal = if (map.get(leftKey)) |val| val else 0; // Return 0 if the optional is null
        const rightVal = if (map.get(rightKey)) |val| val else 0;
        return leftVal > rightVal;
    }
};

test "[1,2,2,3,3,3], k = 2 => [2,3]" {
    _ = try test1(std.testing.allocator);
}

test "[7,7], k = 1 => [7]" {
    _ = try test2(std.testing.allocator);
}

test "[1,1,1,2,2,3], k = 2 => [1,2]" {
    _ = try test3(std.testing.allocator);
}

pub fn test1(allocator: Allocator) !bool {
    var solution = Solution.init(allocator);

    const nums: []const i16 = &.{ 1, 2, 2, 3, 3, 3 };
    const k = 2;
    const expected: []const i16 = &.{ 3, 2 };

    const actual = try solution.topKFrequent(nums, k);
    std.testing.expect(std.mem.eql(i16, expected, actual)) catch return false;
    return true;
}

pub fn test2(allocator: Allocator) !bool {
    var solution = Solution.init(allocator);

    const nums: []const i16 = &.{ 7, 7 };
    const k = 1;
    const expected: []const i16 = &.{7};

    const actual = try solution.topKFrequent(nums, k);
    std.testing.expect(std.mem.eql(i16, expected, actual)) catch return false;
    return true;
}

pub fn test3(allocator: Allocator) !bool {
    var solution = Solution.init(allocator);

    const nums: []const i16 = &.{ 1, 1, 1, 2, 2, 3 };
    const k = 2;
    const expected: []const i16 = &.{ 1, 2 };

    const actual = try solution.topKFrequent(nums, k);
    std.testing.expect(std.mem.eql(i16, expected, actual)) catch return false;
    return true;
}
