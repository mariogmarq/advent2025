const std = @import("std");
const dummy_input = @embedFile("day02_dummy.txt");
const input = @embedFile("day02.txt");

fn generate_next_invalid_number_part_1(number: u64) u64 {
    const num_zeroes = std.math.log10_int(number) + 1;
    const half_zeroes = @divExact(num_zeroes, 2);
    const new_half = @divTrunc(number, std.math.pow(u64, 10, half_zeroes)) + 1;
    const new_num_zeroes = std.math.log10_int(new_half) + 1;
    return (new_half * std.math.pow(u64, 10, new_num_zeroes)) + new_half;
}

fn generate_first_invalid_number_part_1(number: u64) u64 {
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

fn get_num_digits(number: u64) u64 {
    const num_digits: u64 = std.math.log10_int(number);
    return num_digits + 1;
}

fn duplicate_number_times(number: u64, times: u64) u64 {
    const num_digits = get_num_digits(number);
    const num_displacement = num_digits;

    const displacement = std.math.pow(u64, 10, num_displacement);
    var return_value = number;
    for (1..times) |_| {
        return_value *= displacement;
        return_value += number;
    }

    return return_value;
}

fn generate_next_invalid_number_part_2(number: u64) u64 {
    const num_digits = get_num_digits(number);
    if (num_digits < get_num_digits(number + 1)) {
        return generate_next_invalid_number_part_2(number + 1);
    }
    var return_value: u64 = std.math.maxInt(u64);
    for (1..num_digits) |divisor| {
        if (num_digits % divisor != 0) {
            continue;
        }

        // We want the first `divisor` digits of number
        const first_part = @divTrunc(number, std.math.pow(u64, 10, num_digits - divisor));
        const times = @divExact(num_digits, divisor);
        const repeated_part = duplicate_number_times(first_part, times);
        if (repeated_part > number) {
            return_value = @min(repeated_part, return_value);
        }

        const repeated_part_bigger = duplicate_number_times(first_part + 1, times);
        if (repeated_part_bigger > number) {
            return_value = @min(repeated_part_bigger, return_value);
        }
    }

    return return_value;
}

fn part1(ids: []const u8) !u64 {
    var ranges = std.mem.tokenizeScalar(u8, ids, ',');
    var total: u64 = 0;
    while (ranges.next()) |range| {
        var range_parts = std.mem.splitScalar(u8, range, '-');
        const first_part = try std.fmt.parseInt(u64, range_parts.next().?, 10);
        const second_part = try std.fmt.parseInt(u64, range_parts.next().?, 10);

        var first_invalid = generate_first_invalid_number_part_1(first_part);
        if (first_invalid < first_part) {
            std.debug.print("{d}-{d} with {d}\n", .{ first_part, second_part, first_invalid });
            return error.FirstInvalidLessThanFirst;
        }

        while (first_invalid <= second_part) : ({
            first_invalid = generate_next_invalid_number_part_1(first_invalid);
        }) {
            total += first_invalid;
        }
    }

    return total;
}

fn part2(ids: []const u8) !u64 {
    var ranges = std.mem.tokenizeScalar(u8, ids, ',');
    var total: u64 = 0;
    while (ranges.next()) |range| {
        var range_parts = std.mem.splitScalar(u8, range, '-');
        const first_part = try std.fmt.parseInt(u64, range_parts.next().?, 10);
        const second_part = try std.fmt.parseInt(u64, range_parts.next().?, 10);

        var first_invalid = generate_next_invalid_number_part_2(first_part - 1);
        if (first_invalid < first_part) {
            std.debug.print("{d}-{d} with {d}\n", .{ first_part, second_part, first_invalid });
            return error.FirstInvalidLessThanFirst;
        }

        while (first_invalid <= second_part) : ({
            first_invalid = generate_next_invalid_number_part_2(first_invalid);
        }) {
            total += first_invalid;
        }
    }

    return total;
}
pub fn main() !void {
    const part1_sol = try part1(input);
    std.debug.print("Part 1: {d}\n", .{part1_sol});
    const part2_sol = try part2(input);
    std.debug.print("Part 2: {d}\n", .{part2_sol});
}

test "part1" {
    try std.testing.expectEqual(1010, generate_first_invalid_number_part_1(999));
    try std.testing.expectEqual(566566, generate_first_invalid_number_part_1(565653));
    try std.testing.expectEqual(123123, generate_first_invalid_number_part_1(123122));
    try std.testing.expectEqual(123123, generate_first_invalid_number_part_1(123123));
    try std.testing.expectEqual(124124, generate_next_invalid_number_part_1(123123));
    try std.testing.expectEqual(100100, generate_next_invalid_number_part_1(9999));
    try std.testing.expectEqual(part1(dummy_input), 1227775554);
}

test "part2" {
    try std.testing.expectEqual(3, get_num_digits(999));
    try std.testing.expectEqual(4, get_num_digits(1000));
    try std.testing.expectEqual(1010, duplicate_number_times(10, 2));
    try std.testing.expectEqual(999, duplicate_number_times(9, 3));
    try std.testing.expectEqual(999, generate_next_invalid_number_part_2(888));
    try std.testing.expectEqual(1010, generate_next_invalid_number_part_2(999));
    try std.testing.expectEqual(22, generate_next_invalid_number_part_2(12));
    try std.testing.expectEqual(11, generate_next_invalid_number_part_2(10));
    try std.testing.expectEqual(111, generate_next_invalid_number_part_2(99));
    try std.testing.expectEqual(part2(dummy_input), 4174379265);
}
