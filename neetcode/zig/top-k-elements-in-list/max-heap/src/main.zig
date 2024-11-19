const std = @import("std");
const assert = std.debug.assert;
const AutoArrayHashMap = std.array_hash_map.AutoArrayHashMap;
const PriorityQueue = std.PriorityQueue;
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const Order = std.math.Order;

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    arena.deinit();

    std.debug.print("Test1... {s}\n", .{if (test1(arena.allocator()) catch false) "passed" else "failed"});
    std.debug.print("Test2... {s}\n", .{if (test2(arena.allocator()) catch false) "passed" else "failed"});
    std.debug.print("Test3... {s}\n", .{if (test3(arena.allocator()) catch false) "passed" else "failed"});
}

const Pair = struct {
    num: i16,
    frequency: u16,

    // Compare based on the frequency value and return Order.gt
    // if a < b so that we have a max heap
    fn compareTo(_: void, a: Pair, b: Pair) Order {
        return if (a.frequency == b.frequency)
            Order.eq
        else if (a.frequency < b.frequency)
            Order.gt
        else
            Order.lt;
    }
};

const Solution = struct {
    allocator: Allocator,
    results: ArrayList(i16),

    pub fn init(allocator: Allocator) Solution {
        return Solution{
            .allocator = allocator,
            .results = ArrayList(i16).init(allocator),
        };
    }

    pub fn deinit(self: *Solution) void {
        self.results.deinit();
    }

    pub fn topKFrequent(self: *Solution, nums: []const i16, comptime k: u16) ![]i16 {
        assert(1 <= nums.len and nums.len <= 10000);
        assert(1 <= k and k <= nums.len);

        var maxHeap = std.PriorityQueue(Pair, void, Pair.compareTo).init(self.allocator, {});
        defer maxHeap.deinit();

        var numFrequency = AutoArrayHashMap(i16, u16).init(self.allocator);
        defer numFrequency.deinit();

        // Create a hashmap of the number frequencies
        for (nums) |i| {
            assert(-1000 <= i and i <= 1000);

            // Increment the count for this existing number or insert a 0
            // if the entry doesn't exist
            const gop = try numFrequency.getOrPutValue(i, 0);
            gop.value_ptr.* += 1;
        }

        // K must be less than the number of distinct elements in nums
        assert(k <= numFrequency.count());

        // Add all entries into a max heap
        var it = numFrequency.iterator();
        while (it.next()) |entry| {
            try maxHeap.add(.{ .num = entry.key_ptr.*, .frequency = entry.value_ptr.* });
        }

        // Pop off the highest priority until we find k values
        var kCounter: u16 = 0;
        while (maxHeap.removeOrNull()) |pair| {
            try self.results.append(pair.num);
            kCounter += 1;
            if (kCounter == k) break;
        }

        return self.results.items;
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
    defer solution.deinit();

    const nums: []const i16 = &.{ 1, 2, 2, 3, 3, 3 };
    const k = 2;
    const expected: []const i16 = &.{ 3, 2 };

    const actual = try solution.topKFrequent(nums, k);
    try std.testing.expectEqualSlices(i16, expected, actual);
    return true;
}

pub fn test2(allocator: Allocator) !bool {
    var solution = Solution.init(allocator);
    defer solution.deinit();

    const nums: []const i16 = &.{ 7, 7 };
    const k = 1;
    const expected: []const i16 = &.{7};

    const actual = try solution.topKFrequent(nums, k);
    try std.testing.expectEqualSlices(i16, expected, actual);
    return true;
}

pub fn test3(allocator: Allocator) !bool {
    var solution = Solution.init(allocator);
    defer solution.deinit();

    const nums: []const i16 = &.{ 1, 1, 1, 2, 2, 3 };
    const k = 2;
    const expected: []const i16 = &.{ 1, 2 };

    const actual = try solution.topKFrequent(nums, k);
    try std.testing.expectEqualSlices(i16, expected, actual);
    return true;
}
