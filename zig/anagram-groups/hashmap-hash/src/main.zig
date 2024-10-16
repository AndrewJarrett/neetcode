const std = @import("std");
const assert = std.debug.assert;
const ArrayHashMap = std.array_hash_map.ArrayHashMap;
const hashString = std.array_hash_map.hashString;
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

const SolutionContext = struct {
    // This hash function is used in the map and will call the hashAnagram
    // function that will generate a unique string that would match anagrams which
    // is then plugged into the default Wyhash string hashing algorithm to produce
    // the key code.
    pub fn hash(self: SolutionContext, key: str) u32 {
        return hashString(self.hashAnagram(key));
    }

    // This hash function will match on anagrams by generating a 26-character string.
    // Each character gets added to an array that maps to the corresponding index of the
    // character in the alphabet. Each occurrence gets an additional count added to the
    // index. Then the array is transformed back to an alphabetic string by adding the
    // offset of the character 'a' back to it. That is then transformed into a
    // []const u8 slice which is returned.
    fn hashAnagram(_: SolutionContext, key: str) str {
        assert(key.len >= 0 and key.len <= 100);

        var counts: @Vector(26, u8) = @splat(0);
        const offset: @Vector(26, u8) = @splat('a');

        for (key) |c| {
            assert(c >= 'a' and c <= 'z'); // Must be English lowercase
            counts[c - 'a'] += 1;
        }

        const chars = counts + offset; // Add back 'a' to every index of the vector
        const charArray: [26]u8 = chars; // Convert to an array
        const newKey: str = charArray[0..26]; // So we can get a final slice ([]const u8)

        return newKey;
    }

    // We must consider that string a only equals string b if the hashes match since
    // we want to consider anagrams as matches. We can match the string returned by
    // the hashAnagram function which may be slightly more optimal than using the
    // hash function itself.
    pub fn eql(self: SolutionContext, a: str, b: str, _: usize) bool {
        // eql function will compare length and check for length of 0 too
        return std.mem.eql(u8, self.hashAnagram(a), self.hashAnagram(b));
    }
};

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
        assert(strs.items.len >= 1 and strs.items.len <= 1000);

        var map = ArrayHashMap(str, ArrayListUnmanaged(str), SolutionContext, true).init(self.allocator);
        defer map.deinit();

        for (strs.items) |key| {
            // Use the custom context to calculate a hash code that will match an anagram or
            // produce a different hash code if the words are not anagrams.
            const getResult = try map.getOrPut(key);
            if (!getResult.found_existing) {
                // Create a new unamanged arraylist to hold anagram matches
                var list = try ArrayListUnmanaged(str).initCapacity(self.allocator, 4);
                try list.append(self.allocator, key);
                try map.put(key, list);
            } else {
                // Append the matched anagram to this group list
                try getResult.value_ptr.append(self.allocator, key);
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
