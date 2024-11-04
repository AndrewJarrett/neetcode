const std = @import("std");
const assert = std.debug.assert;
const ArrayList = std.ArrayList;

const Self = @This();

pub fn minimumBribes(q: []usize) void {
    assert(1 <= q.len);
    assert(q.len <= 100000);

    var bribes: usize = 0;

    // Make a reference slice to compare and update to match the queue
    //const refArray: [100000]usize = undefined;
    const ref: @Vector(q.len, u32) = std.simd.iota(u32, q.len) + @as(@Vector(q.len, u32), @splat(@as(u32, 1)));
    //for (0..q.len) |i| {
    //    refArray[i] = i + 1;
    //}
    //var ref: []usize = refArray[0..q.len];

    for (q) |i| {
        const num = i + 1;
        if (num == ref[i]) {
            // No bribe detected
            continue;
        } else {
            // Check one ahead by swapping
            const temp = ref[i];
            ref[i] = ref[i + 1];
            ref[i + 1] = temp;

            if (num == ref[i]) {
                // The number was bribed only once
                bribes += 1;
                continue;
            } else {
                // Check two ahead if that didn't work
                temp = ref[i];
                ref[i] = ref[i + 2];
                ref[i + 2] = temp;

                if (num == ref[i]) {
                    // This number was bribed twice
                    bribes += 2;
                    continue;
                }
            }
        }

        // If we get to this point, the queue is too chaotic
        std.debug.print("Too chaotic\n", .{});
        break;
    }

    std.debug.print("{d}\n", .{bribes});
}

test "Test Case 1" {}

test "Test Case 2" {}

test "Test Case 3" {}

test "Test Case 4" {}
