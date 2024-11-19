const std = @import("std");
const assert = std.debug.assert;
const Order = std.math.Order;
const AutoArrayHashMap = std.array_hash_map.AutoArrayHashMap;
const Entry = AutoArrayHashMap(i16, u16).Entry;
const Allocator = std.mem.Allocator;

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    arena.deinit();

    std.debug.print("Test1... {s}\n", .{if (test1(arena.allocator()) catch false) "passed" else "failed"});
    std.debug.print("Test2... {s}\n", .{if (test2(arena.allocator()) catch false) "passed" else "failed"});
    std.debug.print("Test3... {s}\n", .{if (test3(arena.allocator()) catch false) "passed" else "failed"});
}

// Used in a Treap to keep track of the frequency and number itself
const Pair = struct {
    num: i16,
    freq: u16,
};

// A Heap structure/wrapper interface that uses a Treap
// on the backend for managing nodes
pub fn Heap(comptime T: anytype) type {
    return struct {
        const Self = @This();

        const Treap = std.Treap(T, Self.compare);
        const Node = Treap.Node;

        allocator: Allocator,
        treap: Treap,
        count: usize,

        pub fn init(allocator: Allocator) Self {
            return Self{ .allocator = allocator, .treap = .{}, .count = 0 };
        }

        pub fn deinit(self: *Self) void {
            // Free all the remaining nodes
            var treapIter = self.treap.inorderIterator();
            while (treapIter.next()) |node| {
                self.allocator.destroy(node);
            }
        }

        pub fn insert(self: *Self, item: T) Allocator.Error!Treap.Entry {
            var node: Node = undefined;
            const nodePtr = try self.allocator.create(Node);
            errdefer self.allocator.destroy(nodePtr);
            nodePtr.* = node;

            node.key = item;
            var treapEntry = self.treap.getEntryFor(item);

            // Make sure we are adding a new entry
            assert(treapEntry.node == null);

            // Adds the node to the Treap
            treapEntry.set(nodePtr);

            self.count += 1;
            return treapEntry;
        }

        // Use the value of the HashMap entry (which is the count of total
        // times number occurs) and return the std.math.Order of the left
        // and right values.
        //fn compare(left: *T, right: *T) Order {
        fn compare(left: T, right: T) Order {
            return std.math.order(left.freq, right.freq);
        }
    };
}

const Solution = struct {
    allocator: Allocator,
    heap: Heap(Pair),

    pub fn init(allocator: Allocator) Solution {
        return Solution{
            .allocator = allocator,
            .heap = Heap(Pair).init(allocator),
        };
    }

    pub fn deinit(self: *Solution) void {
        self.heap.deinit();
    }

    pub fn topKFrequent(self: *Solution, nums: []const i16, comptime k: u16) Allocator.Error![]const i16 {
        assert(1 <= nums.len and nums.len <= 10000);
        assert(1 <= k and k <= nums.len);

        var numFrequency = AutoArrayHashMap(i16, u16).init(self.allocator);
        defer numFrequency.deinit();

        // Create a hashmap of the number frequencies
        for (nums) |i| {
            assert(-1000 <= i and i <= 1000);

            // Add one to existing number or set with a default of 0
            const gop = try numFrequency.getOrPutValue(i, 0);
            gop.value_ptr.* += 1;
        }

        // K must be less than the number of distinct elements in nums
        assert(k <= numFrequency.count());

        // Put the pairs into the heap
        var it = numFrequency.iterator();
        while (it.next()) |entry| {
            _ = try self.heap.insert(.{ .num = entry.key_ptr.*, .freq = entry.value_ptr.* });
        }

        // Walk the heap in order and return the results
        var results: [k]i16 = undefined;
        var kCounter: u16 = 0;
        while (self.heap.treap.getMax()) |node| {
            assert(kCounter >= 0 and kCounter <= k);

            results[kCounter] = node.key.num;
            kCounter += 1;

            // Remove this node from the Treap and free memory
            var treapEntry = self.heap.treap.getEntryForExisting(node);
            defer self.allocator.destroy(node);
            treapEntry.set(null);

            if (kCounter >= k) break;
        }

        return results[0..k];
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
