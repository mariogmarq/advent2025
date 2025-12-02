const std = @import("std");
const dummy_input = @embedFile("day02_dummy.txt");
const input = @embedFile("day02.txt");

fn generate_next_invalid_number(number: u64) u64 {
    const num_zeroes = std.math.log10_int(number) + 1;
    const half_zeroes = @divExact(num_zeroes, 2);
    const new_half = @divTrunc(number, std.math.pow(u64, 10, half_zeroes)) + 1;
    const new_num_zeroes = std.math.log10_int(new_half) + 1;
    return (new_half * std.math.pow(u64, 10, new_num_zeroes)) + new_half;
}

fn generate_first_invalid_number(number: u64) u64 {
    var num_zeroes: u64 = std.math.log10_int(number) + 1;
    var next_number_with_even_amount: u64 = undefined;
    if (num_zeroes % 2 == 0) {
        next_number_with_even_amount = number;
    } else {
        next_number_with_even_amount = std.math.pow(u64, 10, num_zeroes);
        num_zeroes += 1;
    }

    const half_number = @divExact(num_zeroes, 2);
    const half_base = std.math.pow(u64, 10, half_number);
    const first_half = @divTrunc(next_number_with_even_amount, half_base);
    const second_half = @mod(next_number_with_even_amount, half_base);

    if (first_half == second_half) {
        return next_number_with_even_amount;
    }

    if (second_half < first_half) {
        return first_half * half_base + first_half;
    }

    return (first_half + 1) * half_base + (first_half + 1);
}

fn part1(ids: []const u8) !u64 {
    var ranges = std.mem.tokenizeScalar(u8, ids, ',');
    var total: u64 = 0;
    while (ranges.next()) |range| {
        var range_parts = std.mem.splitScalar(u8, range, '-');
        const first_part = try std.fmt.parseInt(u64, range_parts.next().?, 10);
        const second_part = try std.fmt.parseInt(u64, range_parts.next().?, 10);

        var first_invalid = generate_first_invalid_number(first_part);
        if (first_invalid < first_part) {
            std.debug.print("{d}-{d} with {d}\n", .{ first_part, second_part, first_invalid });
            return error.FirstInvalidLessThanFirst;
        }

        while (first_invalid <= second_part) : ({
            first_invalid = generate_next_invalid_number(first_invalid);
        }) {
            total += first_invalid;
        }
    }

    return total;
}
pub fn main() !void {
    const part1_sol = try part1(input);
    std.debug.print("Part 1: {d}\n", .{part1_sol});
}

test "part1" {
    try std.testing.expectEqual(1010, generate_first_invalid_number(999));
    try std.testing.expectEqual(566566, generate_first_invalid_number(565653));
    try std.testing.expectEqual(123123, generate_first_invalid_number(123122));
    try std.testing.expectEqual(123123, generate_first_invalid_number(123123));
    try std.testing.expectEqual(124124, generate_next_invalid_number(123123));
    try std.testing.expectEqual(100100, generate_next_invalid_number(9999));
    try std.testing.expectEqual(part1(dummy_input), 1227775554);
}
