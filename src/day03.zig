const std = @import("std");
const dummy_input = @embedFile("day03_dummy.txt");
const input = @embedFile("day03.txt");

fn part1(joltages: []const u8) !u64 {
    var lines = std.mem.tokenizeScalar(u8, joltages, '\n');
    var total: u64 = 0;
    while (lines.next()) |line| {
        total += try find_best_greedy(line, 2);
    }

    return total;
}

fn part2(joltages: []const u8) !u64 {
    var lines = std.mem.tokenizeScalar(u8, joltages, '\n');
    var total: u64 = 0;
    while (lines.next()) |line| {
        const joltage = try find_best_greedy(line, 12);
        total += joltage;
    }

    return total;
}

fn find_best_greedy(line: []const u8, comptime s: usize) !u64 {
    var result_buf = [_]u8{0} ** s;
    var current_slice = line;

    for (0..s) |i| {
        const items_remaining_to_find = s - i;

        const search_len = current_slice.len - (items_remaining_to_find - 1);

        var max_digit: u8 = 0;
        var max_idx: usize = 0;

        for (current_slice[0..search_len], 0..) |digit, idx| {
            if (digit > max_digit) {
                max_digit = digit;
                max_idx = idx;
            }
        }

        result_buf[i] = max_digit;

        current_slice = current_slice[(max_idx + 1)..];
    }

    return try std.fmt.parseInt(u64, &result_buf, 10);
}

pub fn main() !void {
    const sol1 = try part1(input);
    std.debug.print("Part 1: {}\n", .{sol1});
    const sol2 = try part2(input);
    std.debug.print("Part 2: {}\n", .{sol2});
}

test "best combo" {
    try std.testing.expectEqual(89, find_best_greedy("811111111111119", 2));
    try std.testing.expectEqual(78, find_best_greedy("234234234234278", 2));
    try std.testing.expectEqual(357, part1(dummy_input));
}

test "part 2 best" {
    try std.testing.expectEqual(987654321111, find_best_greedy("987654321111111", 12));
    try std.testing.expectEqual(434234234278, find_best_greedy("234234234234278", 12));
    try std.testing.expectEqual(3121910778619, part2(dummy_input));
}
