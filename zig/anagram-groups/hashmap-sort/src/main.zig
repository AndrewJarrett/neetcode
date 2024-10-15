const std = @import("std");
const StringArrayHashMap = std.array_hash_map.StringArrayHashMap;
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const ArrayListUnmanaged = std.ArrayListUnmanaged;
const str = []const u8;

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    arena.deinit();

    std.debug.print("Test1... {s}\n", .{if (try test1(arena.allocator())) "passed" else "failed"});
    std.debug.print("Test2... {s}\n", .{if (try test2(arena.allocator())) "passed" else "failed"});
    std.debug.print("Test3... {s}\n", .{if (try test3(arena.allocator())) "passed" else "failed"});
}

const Solution = struct {
    allocator: Allocator,
    results: ArrayList(ArrayList(str)),

    pub fn init(allocator: Allocator) Solution {
        return Solution{
            .allocator = allocator,
            .results = ArrayList(ArrayList(str)).init(allocator),
        };
    }

    pub fn deinit(self: *Solution) void {
        for (self.results.items) |list| {
            // Deinit inner ArrayList
            list.deinit();
        }
        // Deinit outer ArrayList
        self.results.deinit();
    }

    pub fn groupAnagrams(self: *Solution, strs: ArrayList(str)) Allocator.Error!ArrayList(ArrayList(str)) {
        var map = StringArrayHashMap(ArrayListUnmanaged(str)).init(self.allocator);
        defer map.deinit();

        for (strs.items) |orig| {
            // Copy the orig value to a new slice for sorting
            var buffer: [100]u8 = undefined;
            const sorted: []u8 = buffer[0..orig.len];
            std.mem.copyForwards(u8, sorted, orig);

            // Sort in asc order (only if > 1 character)
            // This value will be the map key to find anagram
            // matches/groups
            if (orig.len > 1) {
                std.mem.sort(u8, sorted, {}, std.sort.asc(u8));
            }

            const getResult = try map.getOrPut(sorted);
            if (!getResult.found_existing) {
                // Create a new unamanged arraylist to hold anagram matches
                var list = try ArrayListUnmanaged(str).initCapacity(self.allocator, 4);
                try list.append(self.allocator, orig);
                try map.put(sorted, list);
            } else {
                // Append the matched anagram to this group list
                try getResult.value_ptr.append(self.allocator, orig);
            }
        }

        // Gather the values of the map into the struct's results arraylist
        var it = map.iterator();
        while (it.next()) |entry| {
            // Transfer ownership of memory to another arraylist
            // (by using toOwnedSlice -> fromOwnedSlice) that will
            // be contained in the struct's results arraylist. This will
            // be freed when the struct is ultimately deinit()'d.
            const items = ArrayList(str).fromOwnedSlice(self.allocator, try entry.value_ptr.toOwnedSlice(self.allocator));
            try self.results.append(items);
        }

        return self.results;
    }
};

test "['act','pots','tops','cat','stop','hat'] => [['hat'],['act', 'cat'],['stop', 'pots', 'tops']]" {
    _ = try test1(std.testing.allocator);
}

test "['x'] => [['x']]" {
    _ = try test2(std.testing.allocator);
}

test "[''] => [['']]" {
    _ = try test3(std.testing.allocator);
}

pub fn test1(allocator: Allocator) !bool {
    var strs = ArrayList(str).initCapacity(allocator, 6) catch unreachable;
    strs.appendSliceAssumeCapacity(&.{ "act", "pots", "tops", "cat", "stop", "hat" });
    defer strs.deinit();

    var results = try ArrayList(ArrayList(str)).initCapacity(allocator, 1);
    defer results.deinit();

    var list1 = try ArrayList(str).initCapacity(allocator, 2);
    defer list1.deinit();
    list1.appendSliceAssumeCapacity(&.{ "act", "cat" });
    var list2 = try ArrayList(str).initCapacity(allocator, 3);
    defer list2.deinit();
    list2.appendSliceAssumeCapacity(&.{ "pots", "tops", "stop" });
    var list3 = try ArrayList(str).initCapacity(allocator, 1);
    defer list3.deinit();
    list3.appendSliceAssumeCapacity(&.{"hat"});
    try results.append(list1);
    try results.append(list2);
    try results.append(list3);

    var solution = Solution.init(allocator);
    defer solution.deinit();

    const groups = try solution.groupAnagrams(strs);
    for (groups.items, results.items) |group, result| {
        for (group.items, result.items) |actual, expected| {
            std.testing.expectEqualStrings(actual, expected) catch return false;
        }
    }
    return true;
}

pub fn test2(allocator: Allocator) !bool {
    var strs = ArrayList(str).initCapacity(allocator, 1) catch unreachable;
    strs.appendSliceAssumeCapacity(&.{"x"});
    defer strs.deinit();

    var results = try ArrayList(ArrayList(str)).initCapacity(allocator, 1);
    defer results.deinit();

    var list = try ArrayList(str).initCapacity(allocator, 1);
    defer list.deinit();
    list.appendSliceAssumeCapacity(&.{"x"});
    try results.append(list);

    var solution = Solution.init(allocator);
    defer solution.deinit();

    const groups = try solution.groupAnagrams(strs);
    for (groups.items, results.items) |group, result| {
        for (group.items, result.items) |actual, expected| {
            std.testing.expectEqualStrings(actual, expected) catch return false;
        }
    }
    return true;
}

pub fn test3(allocator: Allocator) !bool {
    var strs = try ArrayList(str).initCapacity(allocator, 1);
    strs.appendSliceAssumeCapacity(&.{""});
    defer strs.deinit();

    var results = try ArrayList(ArrayList(str)).initCapacity(allocator, 1);
    defer results.deinit();

    var list = try ArrayList(str).initCapacity(allocator, 1);
    defer list.deinit();
    list.appendSliceAssumeCapacity(&.{""});
    try results.append(list);

    var solution = Solution.init(allocator);
    defer solution.deinit();

    const groups = try solution.groupAnagrams(strs);
    for (groups.items, results.items) |group, result| {
        for (group.items, result.items) |actual, expected| {
            std.testing.expectEqualStrings(actual, expected) catch return false;
        }
    }
    return true;
}
