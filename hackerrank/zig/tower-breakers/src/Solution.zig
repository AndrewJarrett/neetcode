const std = @import("std");
const assert = std.debug.assert;

const Self = @This();

pub fn towerBreakers(n: u32, m: u32) u8 {
    assert(1 <= n);
    assert(n <= 1000000);
    assert(1 <= m);
    assert(m <= 1000000);

    var winner: u8 = 1;

    if (m == 1 or @mod(n, 2) == 0) {
        winner = 2;
    }

    return winner;
}

test "Test Case 1" {
    const winner = towerBreakers(1, 7);
    try std.testing.expect(winner == 1);
}

test "Test Case 2" {
    const winner = towerBreakers(3, 7);
    try std.testing.expect(winner == 1);
}

test "Test Case 3" {
    const winner = towerBreakers(2, 2);
    try std.testing.expect(winner == 2);
}

test "Test Case 4" {
    const winner = towerBreakers(1, 4);
    try std.testing.expect(winner == 1);
}
