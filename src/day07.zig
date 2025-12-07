const std = @import("std");
const dummy_input = @embedFile("data/day07_dummy.txt");
const input = @embedFile("data/day07.txt");

fn part1(alloc: std.mem.Allocator, data: []const u8) !u64 {
    var times_split: u64 = 0;
    var beam_positions = std.AutoHashMap(usize, void).init(alloc);
    defer beam_positions.deinit();

    var lines = std.mem.tokenizeScalar(u8, data, '\n');
    const first_line = lines.next().?;
    try beam_positions.put(std.mem.indexOf(u8, first_line, "S").?, {});
    while (lines.next()) |line| {
        for (line, 0..) |value, i| {
            if (value == '.') {
                continue;
            }

            // We found a ^ !!
            if (beam_positions.get(i) == null) {
                // No lasser to collide
                continue;
            }
            times_split += 1;

            const left_pos = i - 1;
            const right_pos = i + 1;

            if (beam_positions.get(left_pos) == null) {
                try beam_positions.put(left_pos, {});
            }
            if (beam_positions.get(right_pos) == null) {
                try beam_positions.put(right_pos, {});
            }

            _ = beam_positions.remove(i);
        }
    }

    return times_split;
}

fn part2(alloc: std.mem.Allocator, data: []const u8) !u64 {
    var beam_positions = std.AutoHashMap(usize, u64).init(alloc);
    defer beam_positions.deinit();

    var lines = std.mem.tokenizeScalar(u8, data, '\n');
    const first_line = lines.next().?;
    try beam_positions.put(std.mem.indexOf(u8, first_line, "S").?, 1);
    while (lines.next()) |line| {
        for (line, 0..) |value, i| {
            if (value == '.') {
                continue;
            }

            // We found a ^ !!
            const current_value = beam_positions.get(i);
            if (current_value == null or current_value.? == 0) {
                // No lasser to collide
                continue;
            }

            try beam_positions.put(i, 0);

            const left_pos = i - 1;
            const right_pos = i + 1;

            const left_beam = beam_positions.get(left_pos);
            const right_beam = beam_positions.get(right_pos);

            const left_amount = if (left_beam == null) current_value.? else (current_value.? + left_beam.?);
            const right_amount = if (right_beam == null) current_value.? else (current_value.? + right_beam.?);
            try beam_positions.put(left_pos, left_amount);
            try beam_positions.put(right_pos, right_amount);
        }
    }

    var total_paths: u64 = 0;
    var value_iterator = beam_positions.valueIterator();
    while (value_iterator.next()) |value| {
        total_paths += value.*;
    }

    return total_paths;
}

pub fn main() !void {
    const alloc = std.heap.smp_allocator;
    const sol1 = try part1(alloc, input);
    std.debug.print("Part 1 {}\n", .{sol1});
    const sol2 = try part2(alloc, input);
    std.debug.print("Part 2 {}\n", .{sol2});
}

test "part 1" {
    const alloc = std.testing.allocator;
    try std.testing.expectEqual(21, part1(alloc, dummy_input));
}

test "part 2" {
    const alloc = std.testing.allocator;
    try std.testing.expectEqual(40, part2(alloc, dummy_input));
}
