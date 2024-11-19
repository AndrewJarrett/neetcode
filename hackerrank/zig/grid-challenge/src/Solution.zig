const std = @import("std");
const assert = std.debug.assert;
const ArrayList = std.ArrayList;

const Self = @This();

pub fn gridChallenge(grid: *ArrayList([]const u8)) []const u8 {
    assert(1 <= grid.items.len);
    assert(grid.items.len <= 100);

    var canRearrange = true;

    // Temporary arena allocator used within this function for sorting
    // This prevents memory leaks since we can clear everything at the
    // end of the function
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    for (0..grid.items.len - 1) |i| {
        if (i == 0) {
            // Duplicate and sort the current row using the arena - only for the first iteration
            const sorted: []u8 = arena.allocator().dupe(u8, grid.items[i]) catch unreachable;
            std.mem.sort(u8, sorted, {}, compare);
            grid.replaceRange(i, 1, &.{sorted}) catch unreachable;
        }

        // Duplicate and sort the next row using the arena
        const sorted: []u8 = arena.allocator().dupe(u8, grid.items[i + 1]) catch unreachable;
        std.mem.sort(u8, sorted, {}, compare);
        grid.replaceRange(i + 1, 1, &.{sorted}) catch unreachable;

        for (0..grid.items[i].len) |j| {
            if (grid.items[i][j] > grid.items[i + 1][j]) {
                canRearrange = false;
                break;
            }
        }
    }

    return if (canRearrange) "YES" else "NO";
}

// Function for sorting - true if left is smaller than right
fn compare(_: void, lhs: u8, rhs: u8) bool {
    return if (lhs < rhs) true else false;
}

test "Test Case 1" {
    var grid = ArrayList([]const u8).init(std.testing.allocator);
    defer grid.deinit();

    try grid.appendSlice(&.{
        "eabcd",
        "fghij",
        "olkmn",
        "trpqs",
        "xywuv",
    });
    try std.testing.expectEqualStrings("YES", gridChallenge(&grid));
}

test "Test Case 2" {
    var grid = ArrayList([]const u8).init(std.testing.allocator);
    defer grid.deinit();

    try grid.appendSlice(&.{
        "abc",
        "lmp",
        "qrt",
    });
    try std.testing.expectEqualStrings("YES", gridChallenge(&grid));

    var grid2 = ArrayList([]const u8).init(std.testing.allocator);
    defer grid2.deinit();

    try grid2.appendSlice(&.{
        "mpxz",
        "abcd",
        "wlmf",
    });
    try std.testing.expectEqualStrings("NO", gridChallenge(&grid2));

    var grid3 = ArrayList([]const u8).init(std.testing.allocator);
    defer grid3.deinit();

    try grid3.appendSlice(&.{
        "abc",
        "hjk",
        "mpq",
        "rtv",
    });
    try std.testing.expectEqualStrings("YES", gridChallenge(&grid3));
}

test "Test Case 3" {
    var grid = ArrayList([]const u8).init(std.testing.allocator);
    defer grid.deinit();

    try grid.appendSlice(&.{
        "ba",
        "cd",
    });
    try std.testing.expectEqualStrings("YES", gridChallenge(&grid));
}
