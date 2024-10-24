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
        try writer.print("{{ num = {d}; frequency = {d} }}", .{ self.num, self.frequency });
    }

    // Use the value of the HashMap entry (which is the count of total
    // times number occurs) and return the std.math.Order of the left
    // and right values.
    fn compareTo(self: *Pair, other: *Pair) Order {
        std.debug.print("Comparing left ({s}) to right ({s})\n", .{ self, other });
        if (self.num == other.num) {
            // In order to find existing keys, we need to match on the pair's num field
            std.debug.print("left == right\n", .{});
            return .eq;
        } else if (self.frequency != other.frequency) {
            std.debug.print("return std.math.order({d}, {d})\n", .{ self.frequency, other.frequency });
            // We don't want to consider the same frequency as a full match
            return std.math.order(self.frequency, other.frequency);
        } else {
            std.debug.print("return std.math.order({d}, {d})\n", .{ self.num, other.num });
            // If the frequencies match, just return the larger num
            return std.math.order(self.num, other.num);
        }
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

        pub fn insertItem(self: *Self, item: *T) Allocator.Error!Treap.Entry {
            var node: Node = undefined;
            const nodePtr = try self.allocator.create(Node);
            errdefer self.allocator.destroy(nodePtr);
            nodePtr.* = node;
            node.key = item;

            var treapEntry = self.treap.getEntryFor(item);
            std.debug.print("insertItem - *item: {*}\n", .{item});
            std.debug.print("item: {s}; treapEntry.key: {s}; treapEntry.node: {?}; treapEntry.node*: {*}\n", .{ item, treapEntry.key, treapEntry.node, treapEntry.node });

            // Make sure we are adding a new entry
            assert(treapEntry.node == null);

            // Adds the node to the Treap
            treapEntry.set(nodePtr);

            std.debug.print("after set - treapEntry.node: {?}\n", .{treapEntry.node});
            std.debug.print("after set - treapEntry.node*: {*}\n", .{treapEntry.node});

            self.count += 1;

            return treapEntry;
        }

        // Update the item pointed to by the pointer and then
        // call this method to update the Treap with the new values
        pub fn updateItem(self: *Self, item: *T) void {
            var treapEntry = self.treap.getEntryFor(item);
            const node = treapEntry.node;

            std.debug.print("updateItem - *item: {*}\n", .{item});
            std.debug.print("item: {s}; treapEntry.key: {s}; treapEntry.node: {?}; treapEntry.node*: {*}\n", .{ item, treapEntry.key, treapEntry.node, treapEntry.node });

            // Make sure the item existed
            assert(node != null);
            treapEntry.set(node);
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
            if (!@hasDecl(T, "compareTo")) {
                @compileError("Expected a type T with a function called 'compareTo'");
            }

            std.debug.print("left: {s} ==? right: {s}\n", .{ left, right });
            //std.debug.print("left.compareTo(right): {s}\n", .{left.compareTo(right)});

            return left.compareTo(right);
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

        var numFrequency = AutoArrayHashMap(i16, *Pair).init(self.allocator);
        defer numFrequency.deinit();

        // Create a hashmap of the number frequencies
        for (nums) |i| {
            assert(-1000 <= i and i <= 1000);
            std.debug.print("=======================\ni: {d}\n", .{i});

            const getResult = try numFrequency.getOrPut(i);
            if (getResult.found_existing) {
                std.debug.print("found i: {d}; pair: {s}\n", .{ i, getResult.value_ptr });
                // Increment the count for this existing number
                getResult.value_ptr.*.frequency += 1;

                try numFrequency.put(i, getResult.value_ptr.*);
                self.heap.updateItem(getResult.value_ptr.*);
            } else {
                // Set count for newly found number to 1
                const newPair = Pair{ .num = i, .frequency = 1 };
                const pairPtr = try self.allocator.create(Pair);
                errdefer self.allocator.destroy(pairPtr);
                pairPtr.* = newPair;

                std.debug.print("new i: {d}; new pair: {s}; newpair*: {*}\n", .{ i, newPair, pairPtr });
                try numFrequency.put(i, pairPtr);
                _ = try self.heap.insertItem(pairPtr);
            }
        }

        // K must be less than the number of distinct elements in nums
        assert(k <= numFrequency.count());

        var results: [k]i16 = undefined;
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
