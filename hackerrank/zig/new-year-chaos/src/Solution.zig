const std = @import("std");
const assert = std.debug.assert;
const ArrayList = std.ArrayList;

const Self = @This();

pub fn minimumBribes(q: []const usize) []const u8 {
    assert(1 <= q.len);
    assert(q.len <= 100000);

    var bribes: usize = 0;

    // Make a reference slice to compare and update to match the queue
    //var refArray: [100000]usize = undefined;
    //var j: usize = 0;
    //const optimumSize: usize = std.simd.suggestVectorLength(usize) orelse 8;
    if (q.len == 1) {
        return "0";
    } else if (q.len == 2) {
        return if (q[0] > q[1]) "1" else "0";
    }

    std.debug.print("SIMD q: {d}\n", .{q});

    //const bribedOnceMask1: @Vector(3, usize) = [_]usize{ 1, 0, 2 };
    //const bribedOnceMask2: @Vector(3, usize) = [_]usize{ 2, 0, 1 };
    //const bribedTwiceMask1: @Vector(3, usize) = [_]usize{ 1, 2, 0 };
    //const bribedTwiceMask2: @Vector(3, usize) = [_]usize{ 2, 1, 0 };
    //var i: usize = 0;
    const simdSize: usize = 4;
    var groups = @divFloor(q.len, simdSize);
    groups += if (@mod(q.len, simdSize) == 0) 0 else 1;
    //const remainder = @mod(q.len, simdSize);
    for (0..groups) |i| {
        var qVec: @Vector(simdSize, usize) = undefined;

        // For the last loop, ensure that we make the last chunk the same size
        // as the simdSize.
        if (i + 1 == groups and @mod(q.len, simdSize) != 0) {
            std.debug.print("Last iteration - expanding last vector size...", .{});
            var buffer: [simdSize]usize = undefined;
            //@memset(&buffer, 0);
            std.mem.copyForwards(usize, &buffer, q[i..][0..simdSize]);
            qVec = buffer;
            std.debug.print("Last iteration: qVec: {d}\n", .{qVec});
        } else {
            qVec = q[(i * simdSize)..][0..simdSize].*;
        }
        //const num = q[i];
        //const numVec: @Vector(3, usize) = @splat(num);
        const offset: @Vector(simdSize, usize) = @splat((i * simdSize) + 1);
        //const offset: @Vector(simdSize, isize) = @splat(@as(isize, @intCast(i)) + 1);
        const ref: @Vector(simdSize, usize) = std.simd.iota(usize, simdSize) + offset;
        //const ref: @Vector(simdSize, isize) = std.simd.iota(isize, simdSize) + offset;
        //const qVec: @Vector(simdSize, isize) = @intCast(quVec);

        //const bribedOnce1: @Vector(3, usize) = @shuffle(usize, ref, undefined, bribedOnceMask1);
        //const bribedOnce2: @Vector(3, usize) = @shuffle(usize, ref, undefined, bribedOnceMask2);
        //const bribedTwice1: @Vector(3, usize) = @shuffle(usize, ref, undefined, bribedTwiceMask1);
        //const bribedTwice2: @Vector(3, usize) = @shuffle(usize, ref, undefined, bribedTwiceMask2);

        // 1. Get a boolean vector that is true where the number is less than the reference value
        //      - This will prevent later on having negative numbers (the reference place in line is
        //      greater than the value at that spot would give a negative number)
        // 2. Select elements from the reference if the value in line is less than the reference value
        //      - This makes the elements at this place in the queue equal which would result in a value
        //      of 0 when they are subtracted.
        // 3. Subtract the reference values from the normalized queue vector. This results in a vector
        //      that will have values of either the number of bribes the number had to give to get to that
        //      spot or the number zero if the reference value is the same as the queue value or it was greater
        //      than the queue value due to another number being swapped.
        // 4. Before summing up the total bribes, we need to check to see if any one number has a higher bribe
        //      than "2" which is the maximum number of bribes possible. We do that by comparing the difference
        //      vector with a vector of "2" and find values greater than two. Then we reduce using an or operation
        //      to determine if the queue was too chaotic.
        // 5. If the queue is not too chaotic, then we need to sum together the difference vector to get the total bribes.
        const isLesser: @Vector(simdSize, bool) = qVec < ref;
        //const zeroes: @Vector(simdSize, usize) = @splat(0);
        const qVecNormalized: @Vector(simdSize, usize) = @select(usize, isLesser, ref, qVec);
        std.debug.print("offset: {d}; ref: {d}; qVec: {d}; isLesser: {any}; qVecNormalized: {d}\n", .{ offset, ref, qVec, isLesser, qVecNormalized });
        const diff: @Vector(simdSize, usize) = qVecNormalized - ref;
        const twos: @Vector(simdSize, usize) = @splat(2);
        const tooChaotic: bool = @reduce(.Or, diff > twos);
        if (tooChaotic) {
            return "Too chaotic";
        }
        //const diff: @Vector(simdSize, isize) = qVec - ref;
        //const negOnes: @Vector(simdSize, isize) = @splat(-1);
        //const matches: @Vector(simdSize, bool) = negOnes == diff;
        //const zeroes: @Vector(simdSize, isize) = @as(@Vector(simdSize, isize), @splat(0));
        //const diffNoNegatives = @select(isize, matches, zeroes, diff);
        //bribes += @reduce(.Add, @as(@Vector(simdSize, usize), @intCast(diffNoNegatives)));
        bribes += @reduce(.Add, diff);

        //i += simdSize;

        std.debug.print("diff: {d}; isLesser: {any}; qVecNormalized: {d}; bribes: {d}\n", .{ diff, isLesser, qVecNormalized, bribes });
        //std.debug.print("ref: {d}; num: {d}; bribedOnceMask1: {d}; bribedOnce1: {d}; bribedOnceMask2: {d}; bribedOnce2: {d}, bribedTwiceMask1: {d}; bribedTwice1: {d}; bribedTwiceMask2: {d}; bribedTwice2: {d}; numVec: {d}; qVec: {d}\n", .{ ref, num, bribedOnceMask1, bribedOnce1, bribedOnceMask2, bribedOnce2, bribedTwiceMask1, bribedTwice1, bribedTwiceMask2, bribedTwice2, numVec, qVec });

        //if (num == ref[0]) {
        //    std.debug.print("At i={d}, match\n", .{i});
        //    i += 1;
        //} else if (@reduce(.And, bribedOnce1 == ref) or @reduce(.And, bribedOnce2 == ref)) {
        //    std.debug.print("At i={d}, bribed once\n", .{i});
        //    i += 2;
        //    bribes += 1;
        //} else if (@reduce(.And, bribedTwice1 == ref) or @reduce(.And, bribedTwice2 == ref)) {
        //    std.debug.print("At i={d}, bribed twice\n", .{i});
        //    i += 3;
        //    bribes += 2;
        //} else {
        //    return "Too chaotic";
        //}

        // Update q based on what we found.
    }
    std.debug.print("SIMD total bribes: {d}\n", .{bribes});
    //var ref: []usize = refArray[0..q.len];

    //for (q, 0..q.len) |num, i| {
    //    if (num == ref[i]) {
    //        // No bribe detected
    //        continue;
    //    } else {
    //        // Check one ahead by swapping
    //        var temp = ref[i];
    //        ref[i] = ref[i + 1];
    //        ref[i + 1] = temp;

    //        if (num == ref[i]) {
    //            // The number was bribed only once
    //            bribes += 1;
    //            continue;
    //        } else {
    //            // Check two ahead if that didn't work
    //            temp = ref[i];
    //            ref[i] = ref[i + 2];
    //            ref[i + 2] = temp;

    //            if (num == ref[i]) {
    //                // This number was bribed twice
    //                bribes += 2;
    //                continue;
    //            }
    //        }
    //    }

    //    // If we get to this point, the queue is too chaotic
    //    return "Too chaotic";
    //}

    var buffer: [100000]u8 = undefined;
    const bribesStr = std.fmt.bufPrint(&buffer, "{d}", .{bribes}) catch unreachable;
    return bribesStr;
}

test "Test Case 1" {
    const expected = "3";
    //const q = &.{ 2, 1, 5, 3, 4 };
    try std.testing.expectEqualStrings(expected, minimumBribes(&.{ 2, 1, 5, 3, 4 }));
}

test "Test Case 2" {
    const expected = "Too chaotic";
    const q = &.{ 2, 5, 1, 3, 4 };
    try std.testing.expectEqualStrings(expected, minimumBribes(q));
}

test "Test Case 3" {
    const expected = "Too chaotic";
    const q = &.{ 5, 1, 2, 3, 7, 8, 6, 4 };
    try std.testing.expectEqualStrings(expected, minimumBribes(q));
}

test "Test Case 4" {
    const expected = "7";
    const q = &.{ 1, 2, 5, 3, 7, 8, 6, 4 };
    try std.testing.expectEqualStrings(expected, minimumBribes(q));
}

test "Test Case 5" {
    const expected = "4";
    const q = &.{ 1, 2, 5, 3, 4, 7, 8, 6 };
    try std.testing.expectEqualStrings(expected, minimumBribes(q));
}
