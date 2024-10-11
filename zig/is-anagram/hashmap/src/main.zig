const std = @import("std");
const AutoHashMap = std.hash_map.AutoHashMap;
const Allocator = std.mem.Allocator;

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    arena.deinit();

    std.debug.print("Test1... {s}\n", .{if (try test1(arena.allocator())) "passed" else "failed"});
    std.debug.print("Test2... {s}\n", .{if (try test2(arena.allocator())) "passed" else "failed"});
}

const Solution = struct {
    allocator: Allocator,

    pub fn init(allocator: Allocator) Solution {
        return Solution{
            .allocator = allocator,
        };
    }

    pub fn isAnagram(self: Solution, s: []const u8, t: []const u8) bool {
        var isAnagramVar: bool = true;
        var map = AutoHashMap(u8, i32).init(self.allocator);
        defer map.deinit();

        if (s.len == t.len) {
            for (s, t) |s_i, t_i| {
                map.put(s_i, if (map.contains(s_i)) map.get(s_i).? + 1 else 1) catch unreachable;
                map.put(t_i, if (map.contains(t_i)) map.get(t_i).? - 1 else -1) catch unreachable;
            }

            var valIter = map.valueIterator();
            while (valIter.next()) |value| {
                if (value.* != 0) isAnagramVar = false;
            }
        } else {
            isAnagramVar = false;
        }

        return isAnagramVar;
    }
};

test "has a duplicate returns true" {
    _ = try test1(std.testing.allocator);
}

test "has no duplicates returns false" {
    _ = try test2(std.testing.allocator);
}

pub fn test1(allocator: Allocator) !bool {
    const s = "racecar";
    const t = "carrace";
    const solution = Solution.init(allocator);
    std.testing.expect(solution.isAnagram(s, t)) catch return false;
    return true;
}

pub fn test2(allocator: Allocator) !bool {
    const s = "jar";
    const t = "jam";
    const solution = Solution.init(allocator);
    std.testing.expectEqual(solution.isAnagram(s, t), false) catch return false;
    return true;
}
