const std = @import("std");
const assert = std.debug.assert;

const Self = @This();

const lower = std.StaticStringMap(void).initComptime(.{
    .{"a"}, .{"b"}, .{"c"}, .{"d"}, .{"e"}, .{"f"}, .{"g"}, .{"h"}, .{"i"}, .{"j"}, .{"k"}, .{"l"}, .{"m"}, .{"n"}, .{"o"}, .{"p"}, .{"q"}, .{"r"}, .{"s"}, .{"t"}, .{"u"}, .{"v"}, .{"w"}, .{"x"}, .{"y"}, .{"z"},
});

const upper = std.StaticStringMap(void).initComptime(.{
    .{"A"}, .{"B"}, .{"C"}, .{"D"}, .{"E"}, .{"F"}, .{"G"}, .{"H"}, .{"I"}, .{"J"}, .{"K"}, .{"L"}, .{"M"}, .{"N"}, .{"O"}, .{"P"}, .{"Q"}, .{"R"}, .{"S"}, .{"T"}, .{"U"}, .{"V"}, .{"W"}, .{"X"}, .{"Y"}, .{"Z"},
});

pub fn caesarCipher(str: []u8, k: u8) []u8 {
    assert(1 <= str.len);
    assert(str.len <= 100);
    assert(0 <= k);
    assert(k <= 100);

    // Ensure no missed letters
    assert(lower.keys().len == 26);
    assert(upper.keys().len == 26);

    const r: u8 = @mod(k, 26); // Only need 26 characters max

    for (str, 0..) |c, i| {
        if (lower.has(&.{c})) {
            str[i] = 'a' + @mod(@as(u8, c) + r - 'a', 26);
        } else if (upper.has(&.{c})) {
            str[i] = 'A' + @mod(@as(u8, c) + r - 'A', 26);
        }
    }

    return str;
}

test "Test Case 1" {
    const input = "middle-Outz";
    const str = try std.testing.allocator.dupe(u8, input);
    defer std.testing.allocator.free(str);

    const actual = caesarCipher(str, 2);
    try std.testing.expectEqualStrings("okffng-Qwvb", actual);
}

test "Test Case 2" {
    const input = "There's-a-starman-waiting-in-the-sky";
    const str = try std.testing.allocator.dupe(u8, input);
    defer std.testing.allocator.free(str);

    const actual = caesarCipher(str, 3);
    try std.testing.expectEqualStrings("Wkhuh'v-d-vwdupdq-zdlwlqj-lq-wkh-vnb", actual);
}

test "Test Case 3" {
    const input = "Always-Look-on-the-Bright-Side-of-Life";
    const str = try std.testing.allocator.dupe(u8, input);
    defer std.testing.allocator.free(str);

    const actual = caesarCipher(str, 5);
    try std.testing.expectEqualStrings("Fqbfdx-Qttp-ts-ymj-Gwnlmy-Xnij-tk-Qnkj", actual);
}
