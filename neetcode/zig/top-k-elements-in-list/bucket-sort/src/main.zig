const std = @import("std");
const assert = std.debug.assert;
const AutoArrayHashMap = std.array_hash_map.AutoArrayHashMap;
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const BoundedArray = std.BoundedArray;

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    arena.deinit();

    std.debug.print("Test1... {s}\n", .{if (test1(arena.allocator()) catch false) "passed" else "failed"});
    std.debug.print("Test2... {s}\n", .{if (test2(arena.allocator()) catch false) "passed" else "failed"});
    std.debug.print("Test3... {s}\n", .{if (test3(arena.allocator()) catch false) "passed" else "failed"});
}

const Solution = struct {
    allocator: Allocator,

    pub fn init(allocator: Allocator) Solution {
        return Solution{
            .allocator = allocator,
        };
    }

    pub fn topKFrequent(self: *Solution, nums: []const i16, k: u16) ![]i16 {
        assert(1 <= nums.len and nums.len <= 10000);
        assert(1 <= k and k <= nums.len);

        var results = ArrayList(i16).init(self.allocator);
        defer results.deinit();

        var numFrequency = AutoArrayHashMap(i16, u16).init(self.allocator);
        defer numFrequency.deinit();

        var buckets = ArrayList(ArrayList(i16)).init(self.allocator);
        defer {
            for (buckets.items) |bucket| {
                bucket.deinit();
            }
            buckets.deinit();
        }

        // Create empty ArrayList(i16) for each index of the buckets arraylist
        for (0..nums.len) |_| {
            const bucket = ArrayList(i16).init(self.allocator);
            try buckets.append(bucket);
        }

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

        // Update bucket array where the index is the frequency and value is a slice of the numbers
        // with that frequency
        var it = numFrequency.iterator();
        while (it.next()) |entry| {
            // Subtract frequency from length to reverse the indices (make the most frequent
            // number "0" and least frequent nums.len - 1 (we won't mark numbers that occur 0 times)
            var bucket: *ArrayList(i16) = &buckets.items[nums.len - entry.value_ptr.*];
            try bucket.append(entry.key_ptr.*);
        }

        // Descend the buckets from the top until we find k elements
        findK: for (buckets.items) |b| {
            for (b.items) |num| {
                try results.append(num);

                if (results.items.len == k) {
                    break :findK;
                }
            }
        }

        var buffer: [10000]i16 = undefined;
        const topK: []i16 = buffer[0..k];
        @memcpy(topK, results.items);

        return topK;
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
    try std.testing.expectEqualSlices(i16, expected, actual);
    return true;
}

pub fn test2(allocator: Allocator) !bool {
    var solution = Solution.init(allocator);

    const nums: []const i16 = &.{ 7, 7 };
    const k = 1;
    const expected: []const i16 = &.{7};

    const actual = try solution.topKFrequent(nums, k);
    try std.testing.expect(std.mem.eql(i16, expected, actual));
    return true;
}

pub fn test3(allocator: Allocator) !bool {
    var solution = Solution.init(allocator);

    const nums: []const i16 = &.{ 1, 1, 1, 2, 2, 3 };
    const k = 2;
    const expected: []const i16 = &.{ 1, 2 };

    const actual = try solution.topKFrequent(nums, k);
    try std.testing.expect(std.mem.eql(i16, expected, actual));
    return true;
}
