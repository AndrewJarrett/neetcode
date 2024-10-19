const std = @import("std");
const assert = std.debug.assert;
const Order = std.math.Order;
const AutoArrayHashMap = std.array_hash_map.AutoArrayHashMap;
const Entry = AutoArrayHashMap(i16, u16).Entry;
const Allocator = std.mem.Allocator;

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    arena.deinit();

    std.debug.print("Test1... {s}\n", .{if (try test1(arena.allocator())) "passed" else "failed"});
    std.debug.print("Test2... {s}\n", .{if (try test2(arena.allocator())) "passed" else "failed"});
    std.debug.print("Test3... {s}\n", .{if (try test3(arena.allocator())) "passed" else "failed"});
}

// Used in a Treap to keep track of the frequency and number itself
const Pair = struct {
    num: i16,
    frequency: u16,

    pub fn format(self: *const Pair, _: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
        try writer.print("{{ num = {d}; frequency = {d} }}\n", .{ self.num, self.frequency });
    }

    // Use the value of the HashMap entry (which is the count of total
    // times number occurs) and return the std.math.Order of the left
    // and right values.
    fn compareValue(self: Pair) usize {
        return self.frequency;
    }
};

// A Heap structure/wrapper interface that uses a Treap
// on the backend for managing nodes
pub fn Heap(comptime T: anytype) type {
    return struct {
        const Self = @This();

        const Treap = std.Treap(*T, Self.compare);
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
                self.allocator.destroy(node.key);
                self.allocator.destroy(node);
            }
        }

        pub fn insertItem(self: *Self, item: T) Allocator.Error!Treap.Entry {
            const itemPtr = try self.allocator.create(T);
            errdefer self.allocator.destroy(itemPtr);
            itemPtr.* = item;

            var node: Node = undefined;
            const nodePtr = try self.allocator.create(Node);
            errdefer self.allocator.destroy(nodePtr);
            nodePtr.* = node;
            node.key = itemPtr;

            var treapEntry = self.treap.getEntryFor(itemPtr);

            // Make sure we are adding a new entry
            assert(treapEntry.node == null);

            // Adds the node to the Treap
            treapEntry.set(nodePtr);

            self.count += 1;

            return treapEntry;
        }

        pub fn getFirstK(self: *Self, comptime k: comptime_int) []T {
            assert(0 <= k and k <= self.count);

            // Iterate over the Treap and get the first k elements
            var results: [k]T = undefined;
            var i: u16 = 0;
            while (self.treap.getMax()) |node| {
                if (i >= k) break;
                assert(i >= 0 and i <= k);

                results[i] = node.key.*;

                // Remove this max node from the Treap and free memory
                var treapEntry = self.treap.getEntryForExisting(node);
                defer {
                    self.allocator.destroy(node.key);
                    self.allocator.destroy(node);
                }
                treapEntry.set(null);

                i += 1;
            }

            // Return the first k elements as a slice
            return results[0..k];
        }

        // Use the value of the HashMap entry (which is the count of total
        // times number occurs) and return the std.math.Order of the left
        // and right values.
        fn compare(left: *T, right: *T) Order {
            if (!@hasDecl(T, "compareValue")) {
                @compileError("Expected a type T with a function called 'compareValue'");
            }

            return std.math.order(left.compareValue(), right.compareValue());
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

        // Add Treap nodes for each map entry
        var it = numFrequency.iterator();
        while (it.next()) |mapEntry| {
            _ = try self.heap.insertItem(Pair{ .num = mapEntry.key_ptr.*, .frequency = mapEntry.value_ptr.* });
        }

        var results: [1000]i16 = undefined;
        const pairs = self.heap.getFirstK(k);
        for (pairs, 0..k) |pair, i| {
            results[i] = pair.num;
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
    std.testing.expect(std.mem.eql(i16, expected, actual)) catch return false;
    return true;
}

pub fn test2(allocator: Allocator) !bool {
    var solution = Solution.init(allocator);
    defer solution.deinit();

    const nums: []const i16 = &.{ 7, 7 };
    const k = 1;
    const expected: []const i16 = &.{7};

    const actual = try solution.topKFrequent(nums, k);
    std.testing.expect(std.mem.eql(i16, expected, actual)) catch return false;
    return true;
}

pub fn test3(allocator: Allocator) !bool {
    var solution = Solution.init(allocator);
    defer solution.deinit();

    const nums: []const i16 = &.{ 1, 1, 1, 2, 2, 3 };
    const k = 2;
    const expected: []const i16 = &.{ 1, 2 };

    const actual = try solution.topKFrequent(nums, k);
    std.testing.expect(std.mem.eql(i16, expected, actual)) catch return false;
    return true;
}
